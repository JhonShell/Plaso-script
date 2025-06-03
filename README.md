What this script does

split-security.ps1 takes an offline Security.evtx file that has grown too large (4 GB+ is common) and exports it into three smaller, valid .evtx chunks.
Each chunk:

    contains a contiguous range of EventRecordIDs,

    has fully correct EVTX headers and checksums (because it is created with Microsoft’s own wevtutil),

    is small enough for Plaso, Event Viewer, or any other parser to open without exhausting RAM.


You might get a error on plaso about the evxt too large by spliting this by plaso will process those chunk like indepent evtx.

Usage:
# Run from an elevated PowerShell prompt
powershell -NoProfile -ExecutionPolicy Bypass -File .\split-security.ps1 `
  "C:\Evidence\Security.evtx"  "C:\Evidence\Chunks"

<OutDir>\Security_part1.evtx   (first  ~⅓ of the log)
<OutDir>\Security_part2.evtx   (middle ~⅓)
<OutDir>\Security_part3.evtx   (last   ~⅓)
