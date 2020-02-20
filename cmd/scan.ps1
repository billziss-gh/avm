# cmd/scan.ps1
#
# Copyright 2020 Bill Zissimopoulos

$AvRoot = Join-Path $PSScriptRoot ".."
$AvRoot = Join-Path $AvRoot "av"
$AvList = (Get-ChildItem $AvRoot -Filter "*.ps1").BaseName
$AvList |
    foreach { . (Join-Path $AvRoot "$_.ps1") }

function Write-ScanOutput {
    $Scanner = (Get-PSCallStack)[1].Command
    if ($Scanner.StartsWith('AvScan-')) {
        $Scanner = $Scanner.Remove(0, 'AvScan-'.Length)
    }
    Write-Output $args >> ($ReportPath + '-' + $Scanner + '.txt')
    Write-Output $args
}

function Scan {
    param (
        $ScanPath
    )

    $AvList |
        foreach { & "AvScan-$_" $ScanPath }
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

exit ($Threats -ne 0)
