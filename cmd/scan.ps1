# cmd/scan.ps1
#
# Copyright 2020 Bill Zissimopoulos

param (
    [string]$OutputPath,
    [Parameter(Position=0, ValueFromRemainingArguments)][string[]]$args
)

function Write-ScanOutput {
    if ($OutputPath) {
        $Scanner = (Get-PSCallStack)[1].Command
        if ($Scanner.StartsWith('AvScan-')) {
            $Scanner = $Scanner.Remove(0, 'AvScan-'.Length)
        }
        Write-Output $args >> ($OutputPath + '-' + $Scanner + '.txt')
    }
    Write-Output $args
}

function AvVersion {
    $AvList |
        foreach { & "AvVersion-$_" }
}

function AvScan {
    param (
        $ScanPath,
        $DisplayName
    )

    $AvList |
        foreach { & "AvScan-$_" $ScanPath $DisplayName }
}

$AvRoot = Join-Path $PSScriptRoot ".."
$AvRoot = Join-Path $AvRoot "av"
$AvList = (Get-ChildItem $AvRoot -Filter "*.ps1").BaseName
$AvList |
    foreach { . (Join-Path $AvRoot "$_.ps1") }

if ($OutputPath) {
    $OutputPath = Join-Path $OutputPath (Get-Date -Format FileDateTimeUniversal)
}

$Threats = 0
foreach ($ScanPath in $args) {
    $DisplayName = Split-Path $ScanPath -Leaf
    $TempName = $null

    if ($ScanPath.StartsWith('http:',  'InvariantCultureIgnoreCase') -or
        $ScanPath.StartsWith('https:', 'InvariantCultureIgnoreCase')) {
        $TempName = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -Uri $ScanPath -OutFile $TempName
        $ScanPath = $TempName
    }

    if (-not (Test-Path $ScanPath)) {
        [Console]::Error.WriteLine("file '$ScanPath' not found")
    } else {
        if (-not $AvVersion) {
            $AvVersion = AvVersion
            Write-Output "$AvVersion`n"
        }
        $ScanPath = (Resolve-Path $ScanPath).Path
        $ScanOut = AvScan $ScanPath $DisplayName
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
