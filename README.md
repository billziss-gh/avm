# avm - AntiVirus Monitor

The goal of the AntiVirus Monitor project is to combat AntiVirus false positives. AntiVirus Monitor runs daily and scans a number of binaries using AntiVirus products. If an AntiVirus product reports a malware detection, then the detection is logged and the AntiVirus vendor can be contacted about a potential false positive.

## How it works

The AntiVirus Monitor is a collection of Powershell scripts that are driven by GitHub Actions. The main workflow is `scan.yml` and is currently scheduled to run twice daily (using a cron schedule of `0 14,20 * * *`) and scan releases of [WinFsp](https://github.com/billziss-gh/winfsp).

## Code Structure

The main script is `avm.ps1` and uses the subcommand pattern. Subcommands can be found in the `cmd` directory and support for different AntiVirus products in the `av` directory.

To add support for a new AntiVirus product `Product` a file named `Product.ps1` must be to added to the `av` directory and a function named `AvScan-Product` must exist in the file. For example, here is the `AvScan` function for Windows Defender:

```powershell
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
```
