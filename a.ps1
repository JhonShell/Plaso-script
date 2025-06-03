<#
 Split a large Security.evtx into three valid .evtx chunks.
 Usage (run as Administrator):
   powershell -NoProfile -ExecutionPolicy Bypass -File .\split-security.ps1 `
     "C:\Path\Security.evtx"  "C:\Path\Chunks"
#>

param(
  [Parameter(Mandatory,Position=0)]
  [string]$SourcePath,                    # required

  [Parameter(Position=1)]
  [string]$OutDir = (Join-Path (Split-Path $SourcePath) 'Chunks')  # optional
)

if (-not (Test-Path $SourcePath)) { throw "Source file not found: $SourcePath" }

# --- 1. cheapest possible queries: one record each ------------------------
$oldest = [int64] (Get-WinEvent -Path $SourcePath -Oldest -MaxEvents 1).RecordId
$newest = [int64] (Get-WinEvent -Path $SourcePath          -MaxEvents 1).RecordId
$total  = $newest - $oldest + 1
$span   = [math]::Ceiling($total / 3)

Write-Host "Splitting IDs $oldest-$newest into 3 × $span-record slices"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# --- 2. stream-export three contiguous ID ranges -------------------------
for ($i = 0; $i -lt 3; $i++) {
    $from  = $oldest + ($i * $span)
    $to    = [math]::Min($from + $span - 1, $newest)
    $dest  = Join-Path $OutDir ("Security_part$($i+1).evtx")
    $query = "*[System[(EventRecordID >= $from) and (EventRecordID <= $to)]]"

    wevtutil epl "$SourcePath" "$dest" /lf:true /q:"$query" /ow:true
    Write-Host "  -> $dest   (IDs $from-$to)"
}

Write-Host "Done."
