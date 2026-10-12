// UNUserNotification で通知を出す、terminal-notifier 互換 (一部) の macOS アプリ。
//
// 引数付きで実行すると通知を出して終わる (CLI)。通知をクリックすると macOS がこのアプリを
// 引数無しで起動するので、そのときは通知に持たせた情報で Herdr のペインとターミナルを前に出す。
//
// terminal-notifier から受け付けるのは -message、-title、-subtitle、-sound、-group、
// -activate、-list、-remove だけで、それ以外のオプションは無視する。
import AppKit
import UserNotifications

let center = UNUserNotificationCenter.current()
let ownBundleID = Bundle.main.bundleIdentifier ?? "dev.herdr.notify"

// MARK: - 外部コマンド

@discardableResult
func run(_ path: String, _ args: [String]) -> (status: Int32, output: String) {
  let task = Process()
  task.executableURL = URL(fileURLWithPath: path)
  task.arguments = args
  let pipe = Pipe()
  task.standardOutput = pipe
  task.standardError = FileHandle.nullDevice
  do {
    try task.run()
  } catch {
    return (-1, "")
  }
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  task.waitUntilExit()
  return (task.terminationStatus, String(decoding: data, as: UTF8.self))
}

func jsonResult(_ output: String) -> [String: Any]? {
  guard let data = output.data(using: .utf8),
    let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
  else { return nil }
  return root["result"] as? [String: Any]
}

// クリックで起動されたときは PATH が最小限なので、通知を出すときに見つけたパス (hint) を優先する
func resolveHerdrBinary(hint: String?) -> String? {
  let fm = FileManager.default
  let home = fm.homeDirectoryForCurrentUser.path
  let env = ProcessInfo.processInfo.environment
  var candidates: [String] = []
  if let hint { candidates.append(hint) }
  candidates += (env["PATH"] ?? "").split(separator: ":").map { "\($0)/herdr" }
  if let user = env["USER"] { candidates.append("/etc/profiles/per-user/\(user)/bin/herdr") }
  candidates += [
    "\(home)/.nix-profile/bin/herdr",
    "/run/current-system/sw/bin/herdr",
    "/opt/homebrew/bin/herdr",
    "/usr/local/bin/herdr",
    "\(home)/.local/bin/herdr",
    "\(home)/.cargo/bin/herdr",
  ]
  return candidates.first { fm.isExecutableFile(atPath: $0) }
}

// state_change_seq は全エージェントで通しの番号なので、最大のものが直前に状態が変わったエージェントである
func latestAgentPane(herdr: String) -> String? {
  let (status, output) = run(herdr, ["agent", "list"])
  guard status == 0, let agents = jsonResult(output)?["agents"] as? [[String: Any]] else {
    return nil
  }
  let seq = { (agent: [String: Any]) in agent["state_change_seq"] as? Int ?? -1 }
  return agents.max { seq($0) < seq($1) }?["pane_id"] as? String
}

// MARK: - CLI

let usage =
  "usage: herdr-notify -message TEXT [-title TEXT] [-subtitle TEXT] [-sound NAME] [-group ID] [-activate BUNDLE_ID]\n"
  + "       herdr-notify -list ID|ALL\n"
  + "       herdr-notify -remove ID|ALL\n"

let valueOptions: Set<String> = [
  "message", "title", "subtitle", "sound", "group", "activate", "list", "remove",
  "sender", "execute", "open", "appIcon", "contentImage",
]

func parseOptions(_ args: [String]) -> [String: String] {
  var options: [String: String] = [:]
  var i = 0
  while i < args.count {
    let arg = args[i]
    i += 1
    guard arg.hasPrefix("-"), arg.count > 1 else { continue }
    let key = String(arg.dropFirst())
    if valueOptions.contains(key), i < args.count {
      options[key] = args[i]
      i += 1
    } else {
      options[key] = ""
    }
  }
  return options
}

func wait(_ semaphore: DispatchSemaphore) -> Bool {
  if semaphore.wait(timeout: .now() + 10) == .timedOut {
    fputs("timed out waiting for notification center\n", stderr)
    return false
  }
  return true
}

func authorize() -> Bool {
  let done = DispatchSemaphore(value: 0)
  var granted = false
  center.requestAuthorization(options: [.alert, .sound]) { ok, error in
    if let error { fputs("authorization error: \(error.localizedDescription)\n", stderr) }
    granted = ok
    done.signal()
  }
  guard wait(done) else { return false }
  if !granted { fputs("notification authorization denied\n", stderr) }
  return granted
}

func deliveredNotifications() -> [UNNotification] {
  let done = DispatchSemaphore(value: 0)
  var notifications: [UNNotification] = []
  center.getDeliveredNotifications {
    notifications = $0
    done.signal()
  }
  _ = wait(done)
  return notifications
}

func list(group: String) -> Int32 {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
  print("GroupID\tTitle\tSubtitle\tMessage\tDelivered At")
  for notification in deliveredNotifications()
  where group == "ALL" || notification.request.identifier == group {
    let content = notification.request.content
    let fields = [
      notification.request.identifier, content.title, content.subtitle, content.body,
      formatter.string(from: notification.date),
    ]
    print(fields.joined(separator: "\t"))
  }
  return 0
}

func remove(group: String) -> Int32 {
  if group == "ALL" {
    center.removeAllDeliveredNotifications()
  } else {
    center.removeDeliveredNotifications(withIdentifiers: [group])
  }
  return 0
}

func playSound(named name: String) {
  guard let sound = NSSound(named: NSSound.Name(name)) else { return }
  sound.play()
  // CLI はすぐに終わるので、鳴り終わるまで待つ
  usleep(useconds_t(min(sound.duration, 5) * 1_000_000))
}

func deliver(_ options: [String: String], message: String) -> Int32 {
  guard authorize() else { return 1 }

  let content = UNMutableNotificationContent()
  content.title = options["title"] ?? "Herdr"
  content.subtitle = options["subtitle"] ?? ""
  content.body = message
  let sound = options["sound"]
  if sound == "default" { content.sound = .default }

  var info: [String: String] = [:]
  if let herdr = resolveHerdrBinary(hint: nil) {
    info["herdr_bin"] = herdr
    info["pane_id"] = latestAgentPane(herdr: herdr)
  }
  // herdr は -activate にターミナルの bundle id を渡す。渡されないときは、herdr のサーバーを
  // 起動したターミナルの bundle id が環境変数に残っていればそれを使う
  let env = ProcessInfo.processInfo.environment
  if let app = options["activate"] ?? env["__CFBundleIdentifier"], app != ownBundleID {
    info["activate"] = app
  }
  content.userInfo = info

  // -group が同じ通知は置き換える
  let identifier = options["group"] ?? UUID().uuidString
  if let group = options["group"] { content.threadIdentifier = group }

  let done = DispatchSemaphore(value: 0)
  var failed = false
  let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
  center.add(request) { error in
    if let error {
      fputs("deliver failed: \(error.localizedDescription)\n", stderr)
      failed = true
    }
    done.signal()
  }
  guard wait(done), !failed else { return 1 }

  if let sound, sound != "default" { playSound(named: sound) }
  return 0
}

func runCLI(_ args: [String]) -> Int32 {
  let options = parseOptions(args)
  if options["help"] != nil {
    print(usage, terminator: "")
    return 0
  }
  if let group = options["list"] { return list(group: group) }
  if let group = options["remove"] { return remove(group: group) }
  guard let message = options["message"] else {
    fputs(usage, stderr)
    return 1
  }
  return deliver(options, message: message)
}

// MARK: - 通知のクリック

func activateApp(bundleID: String, completion: @escaping () -> Void) {
  guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
    completion()
    return
  }
  // 起動済みのアプリでも openApplication で前面に出せる
  NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) {
    _, _ in completion()
  }
}

func focus(_ info: [AnyHashable: Any], completion: @escaping () -> Void) {
  if let pane = info["pane_id"] as? String, !pane.isEmpty,
    let herdr = resolveHerdrBinary(hint: info["herdr_bin"] as? String)
  {
    // herdr はクライアントごとに表示するタブを持つので、エージェントの focus だけでは
    // 表示中のタブが切り替わらない。返ってきた tab_id でタブも focus する
    let (status, output) = run(herdr, ["agent", "focus", pane])
    if status == 0,
      let agent = jsonResult(output)?["agent"] as? [String: Any],
      let tab = agent["tab_id"] as? String, !tab.isEmpty
    {
      run(herdr, ["tab", "focus", tab])
    }
  }
  if let app = info["activate"] as? String, !app.isEmpty {
    activateApp(bundleID: app, completion: completion)
  } else {
    completion()
  }
}

final class ClickHandler: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
  func applicationWillFinishLaunching(_ notification: Notification) {
    // クリックの応答は起動を終える前に delegate を置いておかないと受け取れない
    center.delegate = self
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    // クリック以外 (Finder から開いた等) で起動したときは、何もせずに終わる
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) { NSApp.terminate(nil) }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let info = response.notification.request.content.userInfo
    DispatchQueue.global().async {
      focus(info) {
        completionHandler()
        DispatchQueue.main.async { NSApp.terminate(nil) }
      }
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .list, .sound])
  }
}

// MARK: - main

// LaunchServices から起動されたときに付く -psn_ は引数として扱わない
let args = CommandLine.arguments.dropFirst().filter { !$0.hasPrefix("-psn_") }
if args.isEmpty {
  let app = NSApplication.shared
  let handler = ClickHandler()
  app.delegate = handler
  app.setActivationPolicy(.accessory)
  app.run()
} else {
  exit(runCLI(Array(args)))
}
