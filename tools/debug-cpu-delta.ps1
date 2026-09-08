param([int[]]$TargetPid, [double]$Seconds = 5)
$ids = $TargetPid
if (-not $ids -or $ids.Count -eq 0) { $ids = (Get-Process | Where-Object { $_.ProcessName -like '*RK87*' }).Id }
$before = @{}
$threadBefore = @{}
foreach ($id in $ids) {
  $p = Get-Process -Id $id -ErrorAction SilentlyContinue
  if ($p) {
    $before[$id] = $p.TotalProcessorTime.TotalMilliseconds
    $threadBefore[$id] = @{}
    foreach ($t in $p.Threads) { $threadBefore[$id][$t.Id] = $t.TotalProcessorTime.TotalMilliseconds }
  }
}
Start-Sleep -Seconds $Seconds
foreach ($id in $before.Keys) {
  $p = Get-Process -Id $id -ErrorAction SilentlyContinue
  if (-not $p) { continue }
  $delta = $p.TotalProcessorTime.TotalMilliseconds - $before[$id]
  $pct = [math]::Round($delta / ($Seconds * 1000) * 100, 1)
  Write-Output ("PID {0} ({1}): +{2:N0}ms CPU in {3}s = {4}% of one core, threads={5}" -f $id, $p.ProcessName, $delta, $Seconds, $pct, $p.Threads.Count)
  $rows = @()
  foreach ($t in $p.Threads) {
    $tb = 0
    if ($threadBefore[$id].ContainsKey($t.Id)) { $tb = $threadBefore[$id][$t.Id] }
    $td = $t.TotalProcessorTime.TotalMilliseconds - $tb
    if ($td -gt 50) { $rows += [pscustomobject]@{ Tid = $t.Id; DeltaMs = [math]::Round($td); State = $t.ThreadState; Wait = $t.WaitReason } }
  }
  $rows | Sort-Object DeltaMs -Descending | Select-Object -First 6 | ForEach-Object {
    Write-Output ("    thread {0}: +{1}ms  state={2} wait={3}" -f $_.Tid, $_.DeltaMs, $_.State, $_.Wait)
  }
}
