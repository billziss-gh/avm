# avm - AntiVirus Monitor

The goal of the AntiVirus Monitor project is to combat AntiVirus false positives. AntiVirus Monitor runs daily and scans a number of binaries using AntiVirus products. If an AntiVirus product reports a malware detection, then the detection is logged and the AntiVirus vendor can be contacted about a potential false positive.

## How it works

The AntiVirus Monitor is a collection of Powershell scripts that are driven by GitHub Actions. The main workflow is `scan.yml` and is currently scheduled to run twice daily (using a cron schedule of `0 14,20 * * *`) and scan releases of [WinFsp](https://github.com/billziss-gh/winfsp).

## Code Structure

The main script is `avm.ps1` and uses the subcommand pattern. Subcommands can be found in the `cmd` directory and support for different AntiVirus products in the `av` directory.

To add support for a new AntiVirus product `PRODUCT` a file named `PRODUCT.ps1` must be to added to the `av` directory and the functions named `AvVersion-PRODUCT` and `AvScan-PRODUCT` must exist in the file. For example, here are the functions for Windows Defender:

**`AvVersion-PRODUCT`**:
```powershell
function AvVersion-WindowsDefender {
    $ThreatDefinitionVersion = (Get-MpComputerStatus).AntispywareSignatureVersion
    "VERS: WindowsDefender $ThreatDefinitionVersion"
}
```

**`AvScan-PRODUCT`**:
```powershell
function AvScan-WindowsDefender ($ScanPath, $DisplayName) {
    $AvRoot = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name InstallLocation
    $AvProg = Join-Path $AvRoot 'MpCmdRun.exe'
    if (-not (Test-Path $AvProg)) {
        $AvProg = 'C:\Program Files\Windows Defender\MpCmdRun.exe'
    }

    $ScanOut = & $AvProg -Scan -ScanType 3 -File $ScanPath -DisableRemediation
    if ($LASTEXITCODE -ne 0) {
        $ThreatDefinitionVersion = (Get-MpComputerStatus).AntispywareSignatureVersion
        Write-ScanOutput "SCAN: WindowsDefender $ThreatDefinitionVersion"
        Write-ScanOutput "FILE: $DisplayName`n"
        Write-ScanOutput $ScanOut
    }
}
```
