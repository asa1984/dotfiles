{
  stdenv,
  fetchFromGitHub,
  swift,
  ...
}:
# UNUserNotification で通知を出す、terminal-notifier 互換 (一部) の macOS アプリ。
# herdr の `[ui.toast] delivery = "system"` から terminal-notifier として呼ばれ、
# 通知をクリックすると、直前に状態が変わったエージェントのペインへ `herdr agent focus` する。
# terminal-notifier や alerter が使う NSUserNotification は、今の macOS ではバナーが出ない。
#
# ここで作るのは .app の中身まで。署名と LaunchServices への登録は書き込める場所に
# 置いてからでないとできないので、home-manager の activation で行う。
stdenv.mkDerivation rec {
  pname = "herdr-notify";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "ntheanh201";
    repo = "herdr-notify";
    tag = "v${version}";
    hash = "sha256-pWjNe3dWNEiMJM4lbiExmOv+h9VLfAsvsh4I5z+prHc=";
  };
  # Herdr 0.9 では agent focus だけだとクライアントの表示タブが切り替わらないので、
  # 返ってきた tab_id で tab focus も行う
  patches = [ ./herdr-0.9-tab-focus.patch ];

  nativeBuildInputs = [ swift ];

  buildPhase = ''
    runHook preBuild
    swiftc -O -o herdr-notify main.swift -framework UserNotifications -framework AppKit
    # アイコンは絵文字を AppKit で描いて /usr/bin/iconutil で icns にする。できなければアイコン無し
    swiftc -O -o makeicon makeicon.swift -framework AppKit
    if ! { ./makeicon "🐑" AppIcon.iconset && /usr/bin/iconutil -c icns AppIcon.iconset -o AppIcon.icns; }; then
      rm -f AppIcon.icns
    fi
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    app="$out/Applications/Herdr Notify.app"
    install -Dm755 herdr-notify "$app/Contents/MacOS/herdr-notify"
    if [ -f AppIcon.icns ]; then
      install -Dm644 AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
    fi
    cat > "$app/Contents/Info.plist" <<'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>Herdr</string>
      <key>CFBundleDisplayName</key><string>Herdr</string>
      <key>CFBundleExecutable</key><string>herdr-notify</string>
      <key>CFBundleIdentifier</key><string>dev.herdr.notify</string>
      <key>CFBundleIconFile</key><string>AppIcon</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${version}</string>
      <key>CFBundleVersion</key><string>${version}</string>
      <key>LSMinimumSystemVersion</key><string>11.0</string>
      <key>LSUIElement</key><true/>
      <key>NSPrincipalClass</key><string>NSApplication</string>
    </dict>
    </plist>
    PLIST
    runHook postInstall
  '';
}
