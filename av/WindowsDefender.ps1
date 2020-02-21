# av/WindowsDefender.ps1
#
# Copyright 2020 Bill Zissimopoulos

function AvVersion-WindowsDefender {
    $ThreatDefinitionVersion = (Get-MpComputerStatus).AntispywareSignatureVersion
    "SCANNER: WindowsDefender $ThreatDefinitionVersion"
}

function AvScan-WindowsDefender {
    param (
        $ScanPath,
        $DisplayName
    )

    $AvRoot = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name InstallLocation
    $AvProg = Join-Path $AvRoot 'MpCmdRun.exe'
    if (-not (Test-Path $AvProg)) {
        $AvProg = 'C:\Program Files\Windows Defender\MpCmdRun.exe'
    }

    $ScanOut = & $AvProg -Scan -ScanType 3 -File $ScanPath -DisableRemediation
    if ($LASTEXITCODE -ne 0) {
        $ThreatDefinitionVersion = (Get-MpComputerStatus).AntispywareSignatureVersion
        Write-ScanOutput "SCANNER: WindowsDefender $ThreatDefinitionVersion"
        Write-ScanOutput "COMMAND: MpCmdRun.exe -Scan -ScanType 3 -File `"$DisplayName`" -DisableRemediation`n"
        Write-ScanOutput $ScanOut
    }
}
