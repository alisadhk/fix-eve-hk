::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFDN/cCCHL2CuCaUgudevvsORgRoXY+g2bo7+i+CrcbAJzXLjZtgk1XU6
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFDN/cCCHL2CuCaUg7uHjr++Rpw01f6w6YIq7
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
title Fix eve HK
color 0B

echo.
echo '##::::'##:'##:::'##::::'########:'####:'##::::'##:
echo  ##:::: ##: ##::'##::::: ##.....::. ##::. ##::'##::
echo  ##:::: ##: ##:'##:::::: ##:::::::: ##:::. ##'##:::
echo  #########: #####::::::: ######:::: ##::::. ###::::
echo  ##.... ##: ##. ##:::::: ##...::::: ##:::: ## ##:::
echo  ##:::: ##: ##:. ##::::: ##:::::::: ##::: ##:. ##::
echo  ##:::: ##: ##::. ##:::: ##:::::::'####: ##:::. ##:
echo ..:::::..::..::::..:::::..::::::::....::..:::::..::
echo.

echo ==================================================
echo   VMware Nested Virtualization Fix - Full Guide
echo ==================================================
echo.

:: --- Admin check ---
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo [!] Please run this script as Administrator.
  pause
  exit /b 1
)

:: --- Compact log header with timestamp ---
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set _TODAY=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ("%time%") do set _NOW=%%a-%%b
echo [i] Started at: %_TODAY% %_NOW%
echo.

echo ==================================================
echo  STEP 1) PRE-CHECK
echo ==================================================
echo Checking current Hyper-V state (systeminfo)...
systeminfo | findstr /i "Hyper-V Requirements"
echo --------------------------------------------------
echo If you see: "A hypervisor has been detected" ^- VMware can't use VT-x yet.
echo --------------------------------------------------
echo.

echo [*] Optional deeper check (Device Guard / VBS):
powershell -NoProfile -Command ^
 "Try {Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard ^| Format-List *} Catch {Write-Host 'Unable to query DeviceGuard (requires Admin).'}"
echo --------------------------------------------------
echo.

echo ==================================================
echo  STEP 2) DISABLE WINDOWS HYPERVISOR (bcdedit)
echo ==================================================
echo This removes Hyper-V from boot.
bcdedit /set hypervisorlaunchtype off
bcdedit /set vsmlaunchtype off
echo --------------------------------------------------
echo.

echo ==================================================
echo  STEP 3) DISABLE WINDOWS OPTIONAL FEATURES (dism)
echo ==================================================
echo We disable Hyper-V platform, WSL2, etc. Ignore errors if feature is absent.
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart
dism /online /disable-feature /featurename:HypervisorPlatform /norestart
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart
dism /online /disable-feature /featurename:Containers-DisposableClientVM /norestart
dism /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
:: The next two may not exist on all editions; errors OK
dism /online /disable-feature /featurename:Windows-Defender-ApplicationGuard /norestart
dism /online /disable-feature /featurename:WindowsSandbox /norestart
echo --------------------------------------------------
echo.

echo ==================================================
echo  STEP 4) STOP HYPER-V SERVICES
echo ==================================================
echo These services conflict with VMware nested VT-x (errors 1060/1062 are OK if not present).
sc stop vmcompute
sc config vmcompute start= disabled
sc stop vmms
sc config vmms start= disabled
sc stop HvHost
sc config HvHost start= disabled
echo --------------------------------------------------
echo.

echo ==================================================
echo  STEP 5) DISABLE VBS / DEVICE GUARD / CREDENTIAL GUARD
echo ==================================================
echo These registry changes ensure VBS/Guard are off.
echo If you see "Access is denied", disable Tamper Protection and Memory Integrity first.
echo --------------------------------------------------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v HypervisorEnforcedCodeIntegrity /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f

:: LSA / Cred Guard
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 0 /f

:: HVCI UI backing (may fail if Tamper Protection is ON)
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Device Guard" /v HypervisorEnforcedCodeIntegrity /t REG_DWORD /d 0 /f
echo --------------------------------------------------
echo.

echo ==================================================
echo  IMPORTANT MANUAL STEP A) TURN OFF TAMPER PROTECTION
echo ==================================================
echo 1. Open Windows Security
echo 2. Go to: Virus ^& threat protection
echo 3. Click "Manage settings"
echo 4. Set Tamper Protection = OFF
echo    Tip: You can open Windows Security now from here.
choice /m "Open Windows Security app now?"
if errorlevel 1 start windowsdefender:
echo --------------------------------------------------
echo.

echo ==================================================
echo  IMPORTANT MANUAL STEP B) TURN OFF MEMORY INTEGRITY
echo ==================================================
echo 1. Open Windows Security
echo 2. Go to: Device security
echo 3. Under "Core isolation", click Details
echo 4. Turn OFF:
echo    - Memory integrity
echo    - (if present) Kernel-mode Hardware-enforced Stack Protection
echo    Tip: This switch may require a reboot to turn OFF.
choice /m "Open Windows Security app again for Core isolation?"
if errorlevel 1 start windowsdefender:
echo --------------------------------------------------
echo If you cannot disable from UI, the registry edits above try to enforce it,
echo but manual switches are safer and can bypass Tamper Protection issues.
echo --------------------------------------------------
echo.

echo ==================================================
echo  STEP 6) POST-CHECK
echo ==================================================
echo Checking Hyper-V state again (may still show until cold shutdown)...
systeminfo | findstr /i "Hyper-V Requirements"
echo --------------------------------------------------
echo Device Guard / VBS status (for reference):
powershell -NoProfile -Command ^
 "Try {Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard ^| Format-List *} Catch {Write-Host 'Unable to query DeviceGuard.'}"
echo --------------------------------------------------
echo.

echo ==================================================
echo  STEP 7) FULL SHUTDOWN (REQUIRED)
echo ==================================================
echo A full shutdown is REQUIRED. Restart is not enough.
echo Command: shutdown /s /t 0
echo.
choice /m "Shutdown this computer now?"
if errorlevel 1 shutdown /s /t 0

echo.
echo [i] You chose not to shutdown automatically. Please run:
echo     shutdown /s /t 0
echo then power on and re-check:
echo     systeminfo ^| findstr /i "Hyper-V Requirements"
echo.
pause
