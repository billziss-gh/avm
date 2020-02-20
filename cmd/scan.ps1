# avm-scan.ps1 - AntiVirus Monitor
#
# Copyright 2020 Bill Zissimopoulos

function WriteScanOut {
    $Scanner = (Get-PSCallStack)[1].Command
    if ($Scanner.StartsWith('ScanWith')) {
        $Scanner = $Scanner.Remove(0, 'ScanWith'.Length)
    }
    Write-Output $args >> ($ReportPath + '-' + $Scanner + '.txt')
    Write-Output $args
}

function ScanWithWindowsDefender {
    param (
        $ScanPath
    )

    $ScanOut = & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -Scan -ScanType 3 -File $ScanPath -DisableRemediation
    if ($LASTEXITCODE -ne 0) {
        WriteScanOut "SCAN: MpCmdRun.exe -Scan -ScanType 3 -File `"$(Split-Path $ScanPath -Leaf)`" -DisableRemediation`n"
        WriteScanOut $ScanOut
    }
}

function Scan {
    param (
        $ScanPath
    )

    ScanWithWindowsDefender $ScanPath
}

$ReportPath = Get-Date -Format FileDateTimeUniversal
$Threats = 0

foreach ($ScanPath in $args) {
    if ($ScanPath.StartsWith('http:',  'InvariantCultureIgnoreCase') -or
        $ScanPath.StartsWith('https:', 'InvariantCultureIgnoreCase')) {
        $TempName = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -Uri $ScanPath -OutFile $TempName
        $ScanPath = $TempName
    }

    if (-not (Test-Path $ScanPath)) {
        [Console]::Error.WriteLine("file '$ScanPath' not found")
    } else {
        $ScanPath = (Resolve-Path $ScanPath).Path
        $ScanOut = Scan $ScanPath
        if ($ScanOut) {
            Write-Output $ScanOut
            $Threats++
        }
    }

    if ($TempName) {
        Remove-Item $TempName
    }
}

if ($Threats -eq 0) {
    exit 0
} else {
    exit 1
}
