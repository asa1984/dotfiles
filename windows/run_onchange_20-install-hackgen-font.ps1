# HackGen Console NF (Nerd Fonts 版) をユーザーフォントとしてインストールする。
# winget/scoop に存在しないため GitHub リリースから直接取得する。
# このファイルの内容が変わったとき (バージョン更新時) に chezmoi が再実行する。
$ErrorActionPreference = 'Stop'

$version = 'v2.10.0'
$zipName = "HackGen_NF_$version.zip"
$url = "https://github.com/yuru7/HackGen/releases/download/$version/$zipName"

$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$regKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
$marker = Join-Path $fontDir '.hackgen-version'

# 同じバージョンが導入済みならスキップ (スクリプトのリネーム等での再実行対策)
if ((Test-Path $marker) -and ((Get-Content $marker) -eq $version)) {
    Write-Host "HackGen NF $version already installed."
    exit 0
}

$tmp = Join-Path $env:TEMP "hackgen-install"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null

Write-Host "Downloading HackGen NF $version ..."
Invoke-WebRequest -Uri $url -OutFile (Join-Path $tmp $zipName) -UseBasicParsing
Expand-Archive -Path (Join-Path $tmp $zipName) -DestinationPath $tmp

if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Path $fontDir | Out-Null }
if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }

$fonts = Get-ChildItem $tmp -Recurse -Filter '*.ttf'
foreach ($font in $fonts) {
    $dest = Join-Path $fontDir $font.Name
    try {
        Copy-Item $font.FullName $dest -Force
    } catch {
        # 使用中 (メモリマップ済み) のフォントは上書きできない。既存ファイルがあれば許容する
        if (-not (Test-Path $dest)) { throw }
        Write-Host "Skipped (in use): $($font.Name)"
    }
    # HKCU の Fonts キーに登録するとユーザーフォントとして認識される
    $entryName = "$($font.BaseName) (TrueType)"
    New-ItemProperty -Path $regKey -Name $entryName -Value $dest -PropertyType String -Force | Out-Null
    Write-Host "Installed: $($font.Name)"
}

# 再起動なしで現在のセッションにフォントを認識させる
Add-Type -Name Gdi32 -Namespace Native -MemberDefinition '[DllImport("gdi32.dll")] public static extern int AddFontResource(string lpFileName);'
foreach ($font in $fonts) {
    [Native.Gdi32]::AddFontResource((Join-Path $fontDir $font.Name)) | Out-Null
}

Set-Content -Path $marker -Value $version
Remove-Item $tmp -Recurse -Force
Write-Host "HackGen NF $version installed ($($fonts.Count) fonts)."
