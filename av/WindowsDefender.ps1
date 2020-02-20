# av/WindowsDefender.ps1
#
# Copyright 2020 Bill Zissimopoulos

function AvScan-WindowsDefender {
    param (
        $ScanPath
    )

    $AvRoot = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name InstallLocation
    $AvProg = Join-Path $AvRoot 'MpCmdRun.exe'
    if (-not (Test-Path $AvProg)) {
        $AvProg = 'C:\Program Files\Windows Defender\MpCmdRun.exe'
    }

    $ScanOut = & $AvProg -Scan -ScanType 3 -File $ScanPath -DisableRemediation
    if ($LASTEXITCODE -ne 0) {
        Write-ScanOutput "SCAN: MpCmdRun.exe -Scan -ScanType 3 -File `"$(Split-Path $ScanPath -Leaf)`" -DisableRemediation`n"
        Write-ScanOutput $ScanOut
    }
}
