# nixpkgs にまだ入っていない上流のリリースを当てる。
#
# nixpkgs 側が同じかそれ以降のバージョンに追いつくと assert で評価が止まるので、
# そのときは該当するエントリを消す。
final: prev:
let
  inherit (prev) lib;

  # nixpkgs の pkg が version より古いことを確かめてから f pkg を返す。
  bump =
    pkg: version: f:
    assert lib.assertMsg (lib.versionOlder pkg.version version) ''
      nixpkgs now ships ${pkg.name} (>= ${version}).
      Drop its override from overlays/bumps.nix.
    '';
    f pkg;

  # node はソースからのビルドに時間がかかりすぎるので、公式のビルド済みバイナリを
  # nixpkgs の nodejs-slim と同じ出力構成 (out, npm, corepack, dev) に並べ直す。
  # 依存ライブラリは nixpkgs の共有ライブラリではなくバイナリに同梱のものを使う。
  # libv8 出力は作らない (使っているパッケージがない)。
  nodejsBin =
    slim:
    { version, hashes }:
    bump slim version (
      p:
      let
        inherit (final) stdenvNoCC;
        inherit (stdenvNoCC.hostPlatform) system isDarwin isLinux;
        platform =
          {
            aarch64-darwin = "darwin-arm64";
            aarch64-linux = "linux-arm64";
            x86_64-linux = "linux-x64";
          }
          .${system} or (throw "nodejs ${version}: no prebuilt binary for ${system}");
        nodejsDir = final.path + "/pkgs/development/web/nodejs";
        hasCorepack = builtins.elem "corepack" p.outputs;
      in
      stdenvNoCC.mkDerivation {
        inherit (p) pname setupHook;
        inherit version;

        src = final.fetchurl {
          url = "https://nodejs.org/dist/v${version}/node-v${version}-${platform}.tar.xz";
          sha256 = hashes.${system};
        };

        outputs = [
          "out"
          "npm"
          "dev"
        ]
        ++ lib.optional hasCorepack "corepack";
        # nixpkgs と同じく $out にもヘッダを残す (node-gyp はそこを見る)。
        setOutputFlags = false;
        moveToDev = false;

        nativeBuildInputs = [
          final.installShellFiles
        ]
        ++ lib.optionals isDarwin [ final.patchutils ]
        ++ lib.optionals isLinux [ final.autoPatchelfHook ];
        buildInputs = lib.optionals isLinux [ final.stdenv.cc.cc.lib ];

        # darwin のバイナリは Node.js の Developer ID 署名付きなので strip しない。
        dontStrip = true;

        # buildNpmPackage が前提にしている nixpkgs の npm 向けパッチを、バイナリ同梱の
        # npm に当てる (パッチのパスは node のソースツリー基準)。
        postPatch = ''
          pushd lib/node_modules/npm
          patch -p3 < ${nodejsDir}/node-npm-build-npm-package-logic.patch
          ${lib.optionalString isDarwin ''
            filterdiff -p1 -i 'deps/npm/*' ${nodejsDir}/gyp-patches-set-fallback-value-for-CLT-darwin.patch \
              | patch -p3
          ''}
          popd
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $npm/bin $npm/lib/node_modules $dev
          cp bin/node $out/bin/
          cp -r include share $out/
          cp -r $out/include $dev/

          mv lib/node_modules/npm $npm/lib/node_modules/
          ln -s ../lib/node_modules/npm/bin/npm-cli.js $npm/bin/npm
          ln -s ../lib/node_modules/npm/bin/npx-cli.js $npm/bin/npx
          mkdir -p $npm/share/bash-completion/completions
          ln -s $npm/lib/node_modules/npm/lib/utils/completion.sh \
            $npm/share/bash-completion/completions/npm

          ${lib.optionalString hasCorepack ''
            mkdir -p $corepack/bin $corepack/lib/node_modules
            mv lib/node_modules/corepack $corepack/lib/node_modules/
            ln -s ../lib/node_modules/corepack/dist/corepack.js $corepack/bin/corepack
          ''}

          ${lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
            $out/bin/node --completion-bash > node.bash
            installShellCompletion node.bash
          ''}

          runHook postInstall
        '';

        postFixup = ''
          HOST_PATH=$out/bin patchShebangs --host $npm ${lib.optionalString hasCorepack "$corepack"}

          for dir in "$npm/lib/node_modules/npm/man/"*; do
            mkdir -p $npm/share/man/$(basename "$dir")
            for page in "$dir"/*; do
              ln -rs $page $npm/share/man/$(basename "$dir")
            done
          done
        '';

        passthru = removeAttrs p.passthru [
          "tests"
          "updateScript"
        ];

        meta = p.meta // {
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
          platforms = builtins.attrNames hashes;
        };
      }
    );
in
{
  # nodejs_2x と nodejs はこれらの symlink ラッパー。
  nodejs-slim_22 = nodejsBin prev.nodejs-slim_22 {
    version = "22.23.4";
    hashes = {
      aarch64-darwin = "037650d0839f457747396f052073fb48333d31bf5abd3c98b74da20d89ebb1ad";
      aarch64-linux = "6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b";
      x86_64-linux = "1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce";
    };
  };
  nodejs-slim_24 = nodejsBin prev.nodejs-slim_24 {
    version = "24.22.1";
    hashes = {
      aarch64-darwin = "654ba79de6155647e22321932b45f2a1ccb705976cc337c9b8e278beb085a628";
      aarch64-linux = "dbabf7a1cbf947e6059ffad2c27b80041db97dea1e553b62afdee7f13fca336e";
      x86_64-linux = "6c172a9ab6718f7b801fb5a7bd486af2ee5e32758086a04b84fcce2aa77095e6";
    };
  };

  bun = bump prev.bun "1.4.4" (
    p:
    let
      sources =
        lib.mapAttrs
          (
            _:
            { name, hash }:
            final.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v1.4.4/${name}";
              inherit hash;
            }
          )
          {
            aarch64-darwin = {
              name = "bun-darwin-aarch64.zip";
              hash = "sha256-wkDX8My5DCY6hJ/NsJt+5iYw2SE0jtaq/ahrnVd7xRA=";
            };
            aarch64-linux = {
              name = "bun-linux-aarch64.zip";
              hash = "sha256-uqa7NvUdblhWHgK76oJQOKnfRU9nPW13bou/hvjHhQ4=";
            };
            x86_64-linux = {
              name = "bun-linux-x64-baseline.zip";
              hash = "sha256-4ERutVmVdy65iUvrrppr42jZhai5Jx7hJEhvmUbu3XY=";
            };
          };
    in
    p.overrideAttrs (old: {
      version = "1.4.4";
      src = sources.${final.stdenvNoCC.hostPlatform.system};
      passthru = old.passthru // {
        inherit sources;
      };
    })
  );
}
