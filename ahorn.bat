@echo off   
setlocal EnableDelayedExpansion

set minimum_version="v\"1.3.0\""
set julia_url_64bit=https://julialang-s3.julialang.org/bin/winnt/x64/1.4/julia-1.4.1-win64.exe
set julia_url_32bit=https://julialang-s3.julialang.org/bin/winnt/x86/1.4/julia-1.4.1-win32.exe
set julia_filename=julia-1.4.1-installed.exe
set install_url=https://raw.githubusercontent.com/CelestialCartographers/Ahorn/master/install_ahorn.jl
set install_filename=install_ahorn.jl

:start

where julia >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo Using Julia from PATH environmental variable.
    echo Make sure this version is meeting the requirements for Ahorn.
    where julia

    julia -e "exit(Int(VERSION < %minimum_version%))"
    if !ERRORLEVEL! neq 0 (
        echo The Path Julia version is too old to run Ahorn. Attempting to use auto detected version.

        goto :autodetect
    )

    goto :run
)

:autodetect

rem New default directory, used for Julia 1.4
for /F " tokens=*" %%i IN ('dir /b /ad-h /o-d "%LocalAppData%\Programs\Julia"') do (
    set fn=%%i
    if "!fn:~0,6!" == "Julia-" (
        set JULIA_PATH="%LocalAppData%\Programs\Julia\%%i\bin"

        goto :foundJulia
    )
)

rem Old default directory, Julia 1.3 is a valid target
for /F " tokens=*" %%i IN ('dir /b /ad-h /o-d "%LocalAppData%"') do (
    set fn=%%i
    if "!fn:~0,6!" == "Julia-" (
        set JULIA_PATH="%LocalAppData%\%%i\bin"

        goto :foundJulia
    )
)

echo Julia installation not found in default install directory "%LocalAppData%\Programs\Julia\".
echo Please install to the default directory or add Julia manually to the PATH environmental variable.

goto :installPrompt

:foundJulia

set PATH=%JULIA_PATH%;%PATH%
echo Using Julia from: %JULIA_PATH%

julia -e "exit(Int(VERSION < %minimum_version%))"
if %ERRORLEVEL% neq 0 (
    echo The Julia version is too old to run Ahorn. Please make sure the right version is used. You need at least Julia 1.3.0.

    :installPrompt
    set /p "confirmJuliaInstall=Do you want to install a compatible version of Julia? [y/N]: "
    IF /I "!confirmJuliaInstall!" equ "y" (
        echo Downloading compatible Julia version and starting the installer.
        echo Install it into the default directory unless you want to manually add julia to the PATH environmental variable.
        echo Make sure to restart the script after adding julia to the PATH if you are using a custom location.

        echo Downloading installer

        if "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (
            powershell -Command "(New-Object Net.WebClient).DownloadFile('%julia_url_64bit%', '%julia_filename%')"

        ) else (
            powershell -Command "(New-Object Net.WebClient).DownloadFile('%julia_url_32bit%', '%julia_filename%')"
        )

        echo Running installer
        start /wait "" "%~dp0%julia_filename%"

        del "%~dp0%julia_filename%"

        goto :start
    )

    goto :end
)

:run

set AHORN_PATH=%LocalAppData%\Ahorn
set "AHORN_PATH=%AHORN_PATH:\=/%"
set AHORN_ENV=\"%AHORN_PATH%/env/\"

julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); exit(length(Pkg.installed()))" > NUL 2>&1
if %ERRORLEVEL% equ 0 (
    echo Installing Ahorn, this might take a while.
    echo Please make sure not to put the command line into select mode, that means do not click inside the window.

    powershell -Command "(New-Object Net.WebClient).DownloadFile('%install_url%', '%install_filename%')"

    julia "%~dp0%install_filename%"

    del "%~dp0%install_filename%"

    julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); exit(length(Pkg.installed()))" > NUL 2>&1
    if !ERRORLEVEL! equ 0 (
        goto end
    )

    goto :run
)

echo If this is the first time running Ahorn, this might take a while.
echo The window might stay blank for a long time, this is normal as packages are precompiling in the background.
echo Be patient, the program is still running until the terminal says "Press any key to continue" (or equivalent in your language).
echo The error log is located at "%AHORN_PATH%/error.log", should any problems occur.

julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); using Ahorn; Ahorn.displayMainWindow()" 2> "%AHORN_PATH%/error.log"

:end
endlocal

pause