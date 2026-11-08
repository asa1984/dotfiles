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
  nodejs-slim_24 = nodejsBin prev.nodejs-slim_24 {
    version = "24.22.2";
    hashes = {
      aarch64-darwin = "1f5ac075be50bed4780ea3be19a007fda95ea4d527d28d76d0b91de47d915115";
      aarch64-linux = "eb187837a2230d4047161ac0be008584e16b46f726e9c9490ee35dc6b17d9ba8";
      x86_64-linux = "48cc0e21e048790e54c0cf5749c2725005313d652651c40b7a21feb9697aaf75";
    };
  };
}
