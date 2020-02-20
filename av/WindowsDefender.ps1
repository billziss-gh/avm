# av/WindowsDefender.ps1
#
# Copyright 2020 Bill Zissimopoulos

function AvScan-WindowsDefender {
    param (
        $ScanPath
    )

    $ScanOut = & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -Scan -ScanType 3 -File $ScanPath -DisableRemediation
    if ($LASTEXITCODE -ne 0) {
        Write-ScanOutput "SCAN: MpCmdRun.exe -Scan -ScanType 3 -File `"$(Split-Path $ScanPath -Leaf)`" -DisableRemediation`n"
        Write-ScanOutput $ScanOut
    }
}
