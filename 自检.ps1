# 截图技能 · 自检脚本
# 双击即可（或在 PowerShell 里运行）：会在临时目录里跑 4 个用例，打印 PASS / FAIL
# 不改系统设置、不乱删文件；只在自己创建的临时目录里写截图

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $root 'screenshot\scripts\screenshot.py'
$outDir = Join-Path $env:TEMP ('screenshot-selftest-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Write-Host ''
Write-Host '截图技能自检' -ForegroundColor Green
Write-Host "临时目录: $outDir"
Write-Host ('-' * 60)

function Get-Python {
  foreach ($c in @('python', 'py')) {
    $cmd = Get-Command $c -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
  }
  return $null
}

$python = Get-Python
if (-not $python) {
  Write-Host 'FAIL  没有找到 Python。请先安装 Python 3.x，并确认命令行能运行 python。' -ForegroundColor Red
  Read-Host '按回车退出'
  exit 1
}
if (-not (Test-Path $script)) {
  Write-Host "FAIL  找不到脚本: $script" -ForegroundColor Red
  Read-Host '按回车退出'
  exit 1
}

function Invoke-Case($name, [string[]]$argList) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $python
  # Windows PowerShell 5.1 没有 ArgumentList，用引号拼 Arguments
  $parts = @($script) + $argList
  $psi.Arguments = (($parts | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join ' ')
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
  $psi.StandardErrorEncoding = [Text.Encoding]::UTF8
  $p = [System.Diagnostics.Process]::Start($psi)
  $out = $p.StandardOutput.ReadToEnd()
  $err = $p.StandardError.ReadToEnd()
  $p.WaitForExit()
  [pscustomobject]@{ Name = $name; Code = $p.ExitCode; Out = $out.Trim(); Err = $err.Trim() }
}

$results = @()

# T1 默认整屏 PNG
$r = Invoke-Case 'T1 整屏 PNG' @('--out', (Join-Path $outDir 't1-full.png'))
$ok = ($r.Code -eq 0) -and (Test-Path (Join-Path $outDir 't1-full.png')) -and $r.Out.StartsWith('{')
$results += [pscustomobject]@{ Name = $r.Name; Pass = $ok; Detail = ($r.Out + ' ' + $r.Err).Trim() }

# T2 JPEG + 质量
$r = Invoke-Case 'T2 JPEG 质量 85' @('--out', (Join-Path $outDir 't2.jpg'), '--quality', '85')
$ok = ($r.Code -eq 0) -and (Test-Path (Join-Path $outDir 't2.jpg'))
$results += [pscustomobject]@{ Name = $r.Name; Pass = $ok; Detail = $r.Out }

# T3 区域
$r = Invoke-Case 'T3 区域 640x360' @('--x', '100', '--y', '100', '--width', '640', '--height', '360', '--out', (Join-Path $outDir 't3-region.png'))
$f = Join-Path $outDir 't3-region.png'
$ok = ($r.Code -eq 0) -and (Test-Path $f) -and ($r.Out -match '"width":\s*640')
$results += [pscustomobject]@{ Name = $r.Name; Pass = $ok; Detail = $r.Out }

# T4 参数写错应当报错（非 0 退出）
$r = Invoke-Case 'T4 错误参数被拒绝' @('--output', (Join-Path $outDir 't4.png'))
$ok = ($r.Code -ne 0)
$results += [pscustomobject]@{ Name = $r.Name; Pass = $ok; Detail = $r.Err.Split("`n")[0] }

$pass = ($results | Where-Object Pass).Count
foreach ($x in $results) {
  $color = if ($x.Pass) { 'Green' } else { 'Red' }
  $mark = if ($x.Pass) { 'PASS' } else { 'FAIL' }
  Write-Host ("{0}  {1}" -f $mark, $x.Name) -ForegroundColor $color
  if (-not $x.Pass -and $x.Detail) { Write-Host "      $($x.Detail)" -ForegroundColor DarkGray }
}

Write-Host ('-' * 60)
Write-Host "结果：$pass / $($results.Count) 通过" -ForegroundColor $(if ($pass -eq $results.Count) { 'Green' } else { 'Yellow' })
Write-Host "截图保存在: $outDir"

@(
  "截图技能自检 — $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
  "Python: $python",
  "结果: $pass / $($results.Count) 通过",
  ''
) + ($results | ForEach-Object { $mark2 = 'PASS'; if (-not $_.Pass) { $mark2 = 'FAIL' }; "{0}  {1}`n    {2}" -f $mark2, $_.Name, $_.Detail }) |
  Set-Content -LiteralPath (Join-Path $outDir 'result.txt') -Encoding UTF8

Start-Process explorer.exe $outDir
Read-Host '按回车关闭'