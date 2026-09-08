param([int[]]$Ids)
foreach ($id in $Ids) {
  $p = Get-Process -Id $id -ErrorAction SilentlyContinue
  if ($null -eq $p) { Write-Output "PID $id : (not found)"; continue }
  Write-Output ("PID {0}" -f $p.Id)
  Write-Output ("  Name       : " + $p.ProcessName)
  Write-Output ("  Path       : " + $p.Path)
  Write-Output ("  StartTime  : " + $p.StartTime)
  Write-Output ("  TotalCPU   : " + $p.TotalProcessorTime)
  Write-Output ("  Threads    : " + $p.Threads.Count)
  Write-Output ("  WS (MB)    : " + [math]::Round($p.WorkingSet64/1MB))
}
