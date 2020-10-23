@echo off
setlocal EnableDelayedExpansion

set minimum_version="v\"1.3.0\""
set julia_url_64bit=https://julialang-s3.julialang.org/bin/winnt/x64/1.5/julia-1.5.2-win64.exe
set julia_url_32bit=https://julialang-s3.julialang.org/bin/winnt/x86/1.5/julia-1.5.2-win32.exe
set julia_filename=julia-1.5.2-installed.exe
set install_url=https://raw.githubusercontent.com/CelestialCartographers/Ahorn/master/install_ahorn.jl
set install_filename=install_ahorn.jl

rem Set up launch arguments
rem Not the best solution, but it works for simple arguments

set darkMode=0
set developerMode=0
set onlyUpdate=0
set updateFirst=0
set displayHelp=0

for %%A in (%*) do (
    if "%%A" equ "--dark" (
        set darkMode=1
    )

    if "%%A" equ "--developer" (
        set developerMode=1
    )

    if "%%A" equ "--update" (
        set updateFirst=1
    )

    if "%%A" equ "--onlyUpdate" (
        set onlyUpdate=1
        set updateFirst=1
    )

    if "%%A" equ "--help" (
        set displayHelp=1
    )
)

:darkmode

if %darkMode% equ 1 (
    SET GTK_CSD=1
    SET GTK_THEME=Adwaita:dark
)

:displayHelp

if %displayHelp% equ 1 (
    echo Program launch flags

    echo --help
    echo   Displays this page.
    echo.

    echo --dark
    echo   Sets environmental variables to use the default Gtk.jl dark theme.
    echo   This is not a native Windows theme, some interface elements might look different.
    echo.

    echo --developer
    echo   Puts error messages in the terminal rather than in the error log.
    echo.

    echo --update
    echo   Attempts to update Ahorn before starting.
    echo.

    echo --onlyUpdate
    echo   Only attempts to update Ahorn. Does not start the program afterwards.
    echo.

    goto :end
)

:start

rem Check if Julia runs at all when set with PATH
rem For some reason Windows might ship without `where` program
julia -e "exit(0)" >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo Using Julia from PATH environment variable.
    echo Making sure this version is meeting the requirements for Ahorn.

    julia -e "exit(Int(VERSION < %minimum_version%))"
    if !ERRORLEVEL! neq 0 (
        echo The PATH Julia version is too old to run Ahorn. Attempting to use auto detected version.

        goto :autodetect
    )

    goto :install
)

:autodetect

rem Default for 1.5
rem Looks for both Julia- and Julia, just to be safe
for /F " tokens=*" %%i in ('dir /b /ad-h /o-d "%LocalAppData%\Programs"') do (
    set fn=%%i
    if "!fn:~0,6!" == "Julia-" (
        set JULIA_PATH="%LocalAppData%\Programs\%%i\bin"

        goto :foundJulia
    )

    if "!fn:~0,6!" == "Julia " (
        set JULIA_PATH="%LocalAppData%\Programs\%%i\bin"

        goto :foundJulia
    )
)

rem Default for 1.4
for /F " tokens=*" %%i in ('dir /b /ad-h /o-d "%LocalAppData%\Programs\Julia"') do (
    set fn=%%i
    if "!fn:~0,6!" == "Julia-" (
        set JULIA_PATH="%LocalAppData%\Programs\Julia\%%i\bin"

        goto :foundJulia
    )
)

rem Default for 1.3
for /F " tokens=*" %%i in ('dir /b /ad-h /o-d "%LocalAppData%"') do (
    set fn=%%i
    if "!fn:~0,6!" == "Julia-" (
        set JULIA_PATH="%LocalAppData%\%%i\bin"

        goto :foundJulia
    )
)

echo Julia installation not found in default install directory "%LocalAppData%\Programs\".
echo Please install to the default directory or add Julia manually to the PATH environment variable.

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
        echo Install it into the default directory unless you want to manually add julia to the PATH environment variable.
        echo Make sure to restart the script after adding julia to the PATH if you are using a custom location.

        echo Downloading installer

        if "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (
            powershell -Command "(New-Object Net.WebClient).DownloadFile('%julia_url_64bit%', '%julia_filename%')"

        ) else (
            powershell -Command "(New-Object Net.WebClient).DownloadFile('%julia_url_32bit%', '%julia_filename%')"
        )

        if !ERRORLEVEL! neq 0 (
            echo Unable to download Julia installer.
            echo Might be due to TLS issues or PowerShell version.
            echo Please manually download and install Julia from the Julia website.

            goto end
        )

        echo Running installer
        start /wait "" "%~dp0%julia_filename%"

        del "%~dp0%julia_filename%"

        goto :start
    )

    goto :end
)

:install

set AHORN_PATH=%LocalAppData%\Ahorn
set "AHORN_PATH=%AHORN_PATH:\=/%"
set AHORN_ENV=\"%AHORN_PATH%/env/\"

julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); exit(length(Pkg.installed()))" > NUL 2>&1
if %ERRORLEVEL% equ 0 (
    echo Installing Ahorn, this might take a while.
    echo Please make sure not to put the command line into select mode, that means do not click inside the window.

    if not exist "%cd%\%install_filename%" (
        powershell -Command "(New-Object Net.WebClient).DownloadFile('%install_url%', '%install_filename%')"

        if !ERRORLEVEL! neq 0 (
            echo Unable to download Ahorn install script.
            echo Might be due to TLS issues or PowerShell version.
            echo Please manually download install_ahorn.jl and put it in the same folder as ahorn.bat and then rerun.
            echo Optionally install Ahorn manually via cross platform instructions.

            goto :end
        )
    )

    julia "%~dp0%install_filename%"

    del "%~dp0%install_filename%"

    julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); exit(length(Pkg.installed()))" > NUL 2>&1
    if !ERRORLEVEL! equ 0 (
        goto :end
    )

    goto :install
)

:update

if %updateFirst% equ 1 (
    echo Attempting to update Ahorn.

    if !developerMode! equ 1 (
        julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); Pkg.update()"

    ) else (
        julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); Pkg.update()" 2> "%AHORN_PATH%/update.log"
    )

    if !onlyUpdate! equ 1 (
        goto :end
    )
)

:run

if %developerMode% equ 1 (
    echo Warnings and errors will be printed to this window rather than error log.

    julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); using Ahorn; Ahorn.displayMainWindow()"

) else (
    echo If this is the first time running Ahorn, this might take a while.
    echo The window might stay blank for a long time, this is normal as packages are precompiling in the background.
    echo Be patient, the program is still running until the terminal says "Press any key to continue" (or equivalent in your language^).
    echo The error log is located at "%AHORN_PATH%/error.log", should any problems occur.

    julia -e "using Pkg; Pkg.activate(%AHORN_ENV%); using Ahorn; Ahorn.displayMainWindow()" 2> "%AHORN_PATH%/error.log"
)

:end
endlocal

pause