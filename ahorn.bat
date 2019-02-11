@echo off   
setlocal EnableDelayedExpansion

set minimum_version="v\"1.1.0\""

where julia >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo Using Julia from PATH environmental variable.
    echo Make sure this version is meeting the requirements for Ahorn.
    where julia

    julia -e "exit(Int(VERSION < %minimum_version%))"
    if %ERRORLEVEL% neq 0 (
        echo The Path Julia version is too old to run Ahorn. Attempting to use auto detected version.

        goto :autodetect
    )

    goto :run
)

:autodetect

for /F " tokens=*" %%i IN ('dir /b /ad-h /o-d "%LocalAppData%"') do (
    set fn=%%i
    if "!fn:~0,6!" == "Julia-" (
        set JULIA_PATH="%LocalAppData%\%%i\bin"

        goto :found
    )
) 

echo Julia installation not found in default install directory "%LocalAppData%".
echo Please install to the default directory or add Julia manually to the PATH environmental variable.
pause

goto :end

:found

set PATH=%PATH%;%JULIA_PATH%
echo Using Julia from: %JULIA_PATH%

:run

julia -e "exit(Int(VERSION < %minimum_version%))"
if %ERRORLEVEL% neq 0 (
    echo The Julia version is too old to run Ahorn. Please make sure the right version is used. You need at least Julia 1.1.0.

    goto :end
)

set AHORN_PATH=%LocalAppData%\Ahorn
set "AHORN_PATH=%AHORN_PATH:\=/%"
set AHORN_ENV=\"%AHORN_PATH%/env/\"

echo If this is the first time running Ahorn, this might take a while.
echo The window might stay blank for a long time, this is normal as packages are precompiling in the background.

julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); using Ahorn; Ahorn.displayMainWindow()" 2> "%AHORN_PATH%\error.log"

:end

pause