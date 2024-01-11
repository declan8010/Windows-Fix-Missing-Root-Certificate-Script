@echo off
setlocal

:menu
cls
echo Main Menu:
echo 1. Check the number of certificates in Trusted Root Certification Authorities
echo 2. Run the main script
echo 3. Exit

set /p choice=Enter your choice: 

if "%choice%"== "1" (
    :: Show the number of certificates in Trusted Root Certification Authorities
    powershell -command "$certCount = (Get-ChildItem Cert:\LocalMachine\Root).Count; Write-Host 'Number of certificates in Trusted Root Certification Authorities: ' $certCount"
    pause
    goto menu
)

if "%choice%"== "2" (
    :: Create folder C:\PS\
    mkdir "C:\PS"

    :: Run certutil.exe to generate SST file
    certutil.exe -generateSSTFromWU C:\PS\roots.sst

    :: Wait for 5 seconds
    timeout /t 5 /nobreak >nul

    :: Run PowerShell script
    powershell -command "$sstStore = (Get-ChildItem -Path C:\ps\roots.sst); $sstStore | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root"

    :: Show real-time output of the PowerShell script
    powershell -command "$sstStore = (Get-ChildItem -Path C:\ps\roots.sst); $sstStore | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root"
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
