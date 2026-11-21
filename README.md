<h1 align="center">Fix EVE HK</h1>

<p align="center"><b>One-click script that frees VT-x so VMware can run nested virtualization</b></p>

<p align="center">
  <img src="https://img.shields.io/badge/Batch-script-4D4D4D" alt="Batch">
  <img src="https://img.shields.io/badge/platform-Windows-0078D6?logo=windows&logoColor=white" alt="Platform">
  <img src="https://img.shields.io/badge/updated-2025--09--22-success" alt="Updated">
  <a href="https://github.com/alisadhk/fix-eve-hk/releases/latest"><img src="https://img.shields.io/badge/downloads-Releases-blue" alt="Releases"></a>
</p>

---

## Overview
Windows features such as Hyper-V, VBS and Device Guard take over the CPU virtualization extensions and stop VMware Workstation from running nested hypervisors (for example EVE-NG). This script disables them step by step and tells you what is left to do manually.

## Features
- Pre-check of the current Hyper-V state
- Disables the Windows hypervisor launch type (bcdedit)
- Disables Hyper-V optional features (DISM) and related services
- Turns off VBS / Device Guard / Credential Guard policies
- Guides you through the manual Tamper Protection and Memory Integrity steps
- Post-check and optional full shutdown
- Seven clearly labeled steps, each printed on screen before it runs
- Works on Windows 10/11 with VMware Workstation and EVE-NG labs

## How it works
- **Step 1** reads the current state with systeminfo.
- **Step 2** sets hypervisorlaunchtype and smlaunchtype to off with cdedit.
- **Step 3** disables the Hyper-V and Hypervisor Platform optional features with DISM.
- **Step 4** stops and disables the vmcompute, vmms and HvHost services.
- **Step 5** writes the registry policies that turn off VBS, Device Guard and Credential Guard.
- **Steps 6-7** re-check the state and ask for a full shutdown, which is required for the changes to apply.

## Requirements
- Windows 10/11 and an Administrator account.
- VMware Workstation (the target of the fix).

## Screenshots
<p align="center"><img src="screenshots/screenshot-1.png" alt="Fix EVE HK screenshot" width="720"></p>

## Download and install
### Option A - Ready-to-run download (recommended)
1. Open the **[Releases page](https://github.com/alisadhk/fix-eve-hk/releases/latest)**.
2. Download the file(s) listed under **Assets**:

| File | Size |
|---|---|
| `Fix-EVE-HK.exe` | 0.1 MB |

3. Run it. Run it as Administrator; Windows UAC will ask for confirmation.

### Option B - Run the script
Download the script from this repository and run it as described in **How to use**.

## How to use
1. Right-click **Fix-EVE-HK.exe** (or the .cmd script) and choose **Run as administrator**.
2. Follow the on-screen steps 1 to 7. Each step prints what it changes.
3. When asked, turn off **Tamper Protection** and **Memory Integrity** manually in Windows Security.
4. Do a full shutdown (not a restart) when the script asks, then power the PC on again.
5. Start your VMware VM and verify that nested virtualization works.

## Configuration and privacy
- The script contains no credentials or personal data.

## Troubleshooting
- Still shows a hypervisor: use **Shut down**, not Restart, then power on again.
- Memory Integrity still on: turn it off in Windows Security > Device security > Core isolation.
- To undo: run cdedit /set hypervisorlaunchtype auto and re-enable the Hyper-V feature in Windows Features.



## Notes
- **Security warning:** this lowers Windows virtualization-based security. Only run it on a lab/test machine and review the script first.
- To undo the changes, re-enable Hyper-V and Memory Integrity from Windows Features / Windows Security.

---

<p align="center">Maintained by <a href="https://github.com/alisadhk">@alisadhk</a> - last update 2025-09-22</p>