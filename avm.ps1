# avm.ps1
# AntiVirus Monitor
#
# Copyright 2020 Bill Zissimopoulos

param (
    $Command
)

function Usage {
    [Console]::Error.WriteLine("usage: $ProgName command args...`n`ncommands:")
    (Get-ChildItem $CmdRoot -Filter "*.ps1").BaseName |
        foreach { [Console]::Error.WriteLine("  " + $_) }
    exit 2
}

$ProgRoot = $PSScriptRoot
$ProgName = (Get-Item $PSCommandPath).BaseName

$CmdRoot = Join-Path $ProgRoot "cmd"
$CmdProg = Join-Path $CmdRoot "$Command.ps1"
if (-not (Test-Path $CmdProg)) {
    Usage
}

& $CmdProg @args
exit $LASTEXITCODE
