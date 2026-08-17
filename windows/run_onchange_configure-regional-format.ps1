# 時刻表示形式を US スタイル (h:mm tt, AM/PM) にする。
# ロケール自体は ja-JP のまま、時刻フォーマットのみ上書きする。日付は変更しない。
$ErrorActionPreference = 'Stop'

$intl = 'HKCU:\Control Panel\International'

Set-ItemProperty -Path $intl -Name sShortTime -Value 'h:mm tt'
Set-ItemProperty -Path $intl -Name sTimeFormat -Value 'h:mm:ss tt'
Set-ItemProperty -Path $intl -Name s1159 -Value 'AM'
Set-ItemProperty -Path $intl -Name s2359 -Value 'PM'

# 実行中のアプリ (タスクバー時計含む) に設定変更を通知する
Add-Type -Namespace Native -Name User32 -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
$result = [UIntPtr]::Zero
[Native.User32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, 'Intl', 2, 5000, [ref]$result) | Out-Null

Write-Host 'Time format set to US style (h:mm tt).'
