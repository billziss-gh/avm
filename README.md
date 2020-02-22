# avm - AntiVirus Monitor

The goal of the AntiVirus Monitor project is to combat AntiVirus false positives. AntiVirus Monitor is used to scan binaries using AntiVirus products. If an AntiVirus product reports a malware detection, then the detection is logged and the AntiVirus vendor can be contacted about a potential false positive.

The AntiVirus monitor can be used as a GitHub Action in a workflow or as a script from the Windows command line.

## GitHub Action

The AntiVirus Monitor is a GitHub action that can scan binaries on a schedule and post a GitHub notification when a false positive is found.

To add this capability to your repository add a file named `.github/workflows/avm.yml` with the following contents:

**`.github/workflows/avm.yml`**:
```yaml
name: avm

on:
  schedule:
  - cron: '0 2,8,14,20 * * *'

jobs:
  scan:
    runs-on: [windows-latest]
    steps:
    - uses: billziss-gh/avm@v1
      with:
        files: |
            FILE1
            FILE2
            ...
```

This workflow is scheduled to run every 6 hours (at 00:00, 06:00, 12:00, 18:00 PST) and scan files `FILE1` and `FILE2` for viruses. If an AntiVirus product finds that one of the files is infected (e.g. because of a false positive due to a recent update of the product's signature database), then a GitHub notification is posted.

**NOTE**: In order to have GitHub notifications posted, make sure that you have enabled GitHub Actions notifications under your account's [Settings > Notifications > GitHub Actions](https://github.com/settings/notifications).

## Command line

The AntiVirus monitor is a Powershell script named `avm.ps1`. Its usage is simple:

```
avm scan [-OutputPath PATH] FILE...
```

This will scan the specified `FILE`'s. The `FILE` may be a local file or a file accessible via http(s). If any malware is detected, the script will output the details. Additionally the `-OutputPath` option can be used to have any malware reports saved in the specified directory `PATH`.

```
> .\avm scan https://github.com/InQuest/malware-samples/raw/master/2018-05-Agent-Tesla-Open-Directory/agent-tesla/0abb52b3e0c08d5e3713747746b019692a05c5ab8783fd99b1300f11ea59b1c9
VERS: WindowsDefender 1.309.1457.0

SCAN: WindowsDefender 1.309.1457.0
FILE: 0abb52b3e0c08d5e3713747746b019692a05c5ab8783fd99b1300f11ea59b1c9

Scan starting...
Scan finished.
Scanning C:\Users\billziss\AppData\Local\Temp\tmpC056.tmp found 1 threats.

<===========================LIST OF DETECTED THREATS==========================>
----------------------------- Threat information ------------------------------
Threat                  : TrojanDownloader:Win32/Upatre
Resources               : 1 total
    file                : C:\Users\billziss\AppData\Local\Temp\tmpC056.tmp
-------------------------------------------------------------------------------
```

## Supporting additional AntiVirus products

The AntiVirus Monitor supports the following AntiVirus products:

- Windows Defender

This section discusses the project structure and how to add support for additional AntiVirus products.

Project structure:

- [`avm.ps1`](avm.ps1): Main script. Follows the subcommand pattern.
- [`cmd`](cmd): Subcommands can be found here.
- [`av`](av): AntiVirus product support can be found here.
- [`action`](action): GitHub Action support files can be found here.

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
