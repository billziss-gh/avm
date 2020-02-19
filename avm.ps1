# avm.ps1 - AntiVirus Monitor
#
# Copyright 2020 Bill Zissimopoulos

param (
    $Command
)

function Usage {
    [Console]::Error.WriteLine("usage: $ProgName command args...`n`ncommands:")
    (Get-ChildItem $ProgRoot -Filter "$ProgName-*.ps1").BaseName |
        foreach { [Console]::Error.WriteLine("  " + $_.Remove(0, $ProgName.Length + 1)) }
    exit 2
}

$ProgRoot = $PSScriptRoot
$ProgName = (Get-Item $PSCommandPath).BaseName

$CmdProg = Join-Path $ProgRoot "$ProgName-$Command.ps1"
if (-not (Test-Path $CmdProg)) {
    Usage
}

& $CmdProg @args
exit $LASTEXITCODE
