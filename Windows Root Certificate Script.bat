@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges
NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo You must run this script as an administrator.
    pause
    exit /b 1
)

:menu
cls
echo Main Menu:
echo 1. Check the number of certificates in Trusted Root Certification Authorities
echo 2. Download/Update Certificates
echo 3. Exit Script

set /p choice=Enter your choice: 

if "%choice%"== "1" (
    :: Show the number of certificates in Trusted Root Certification Authorities
    powershell -command "$certCount = (Get-ChildItem Cert:\LocalMachine\Root).Count; Write-Host 'Number of certificates in Trusted Root Certification Authorities: ' $certCount"
    pause
    goto menu
)

if "%choice%"== "2" (
    :: Check if folder C:\PS\ already exists
    if not exist "C:\PS" (
        mkdir "C:\PS"
    )

    :: Get the initial count of certificates in Trusted Root Certification Authorities
    set /a initialCount=0
    for /f %%A in ('powershell -command "(Get-ChildItem Cert:\LocalMachine\Root).Count"') do set /a initialCount=%%A

    :: Run certutil.exe to generate SST file
    certutil.exe -generateSSTFromWU C:\PS\roots.sst

    :: Wait for 5 seconds
    timeout /t 5 /nobreak >nul

    :: Run PowerShell script to import certificates
    powershell -command "$sstStore = (Get-ChildItem -Path C:\ps\roots.sst); $sstStore | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root"

    :: Get the updated count of certificates in Trusted Root Certification Authorities
    set /a updatedCount=0
    for /f %%A in ('powershell -command "(Get-ChildItem Cert:\LocalMachine\Root).Count"') do set /a updatedCount=%%A

    :: Display the number of added certificates and the new total
    set /a addedCount=updatedCount - initialCount
    echo Number of certificates added: !addedCount!
    echo New total number of certificates: !updatedCount!
    pause
    goto menu
)

if "%choice%"== "3" (
    exit /b
)

echo Invalid choice. Please try again.
pause
goto menu

endlocal
