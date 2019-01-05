@echo off
rem This batch script sets up the development environment
rem by enabling the Profiler API and starting Visual Studio.
rem Any process started by VS will inherit the environment variables,
rem enabling the profiler for apps run from VS, including while debugging.

rem Set default values
set profiler_platform=x64
set profiler_configuration=Debug
set start_visual_studio=true

:next_argument
if not "%1" == "" (
    if /i "%1" == "--help" goto show_usage
    if /i "%1" == "-h" goto show_usage
    if "%1" == "/?" goto show_usage

    if /i "%1" == "Debug" set profiler_configuration=Debug
    if /i "%1" == "Release" set profiler_configuration=Release

    if /i "%1" == "x64" set profiler_platform=x64
    if /i "%1" == "x86" set profiler_platform=x86

    if /i "%1" == "vs+" set start_visual_studio=true
    if /i "%1" == "vs-" set start_visual_studio=false

    rem A "goto" gets around premature variable expansion
    goto check_valid_argument
    :check_valid_argument
    if "%profiler_configuration%" == "" if "%profiler_platform%" == "" if "%start_visual_studio%" == "" (
        rem If neither option was set
        echo Invalid option: "%1".
        goto show_usage
    )

    shift
    goto next_argument
)

echo Enabling profiler for "%profiler_configuration%/%profiler_platform%".

rem Enable .NET Framework Profiling API
SET COR_ENABLE_PROFILING=1
SET COR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
SET COR_PROFILER_PATH=%~dp0\src\Datadog.Trace.ClrProfiler.Native\bin\%profiler_configuration%\%profiler_platform%\Datadog.Trace.ClrProfiler.Native.dll

rem Enable .NET Core Profiling API
SET CORECLR_ENABLE_PROFILING=1
SET CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
SET CORECLR_PROFILER_PATH=%~dp0\src\Datadog.Trace.ClrProfiler.Native\bin\%profiler_configuration%\%profiler_platform%\Datadog.Trace.ClrProfiler.Native.dll

rem Limit profiling to these processes only
SET DD_PROFILER_PROCESSES=w3wp.exe;iisexpress.exe;Samples.AspNetCoreMvc2.exe;dotnet.exe;Samples.ConsoleFramework.exe;Samples.ConsoleCore.exe;Samples.SqlServer.exe;Samples.RedisCore.exe;Samples.Elasticsearch.exe

rem Set location of integration definitions
SET DD_INTEGRATIONS=%~dp0\integrations.json;%~dp0\test-integrations.json

SET DOTNET_ADDITIONAL_DEPS=%PROGRAMFILES%\dotnet\x64\additionalDeps\Datadog.Trace.ClrProfiler.Managed

if "%start_visual_studio%" == "true" (
    echo Starting Visual Studio...
    IF EXIST "D:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" (
    START "Visual Studio" "D:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" "%~dp0\Datadog.Trace.sln"
    ) ELSE (
    START "Visual Studio" "D:\Program Files (x86)\Microsoft Visual Studio\Preview\Enterprise\Common7\IDE\devenv.exe" "%~dp0\Datadog.Trace.sln"
    )
)
goto end

:show_usage
echo Usage: %0 [Release^|Debug] [x64^|x86] [vs+^|vs-]
echo   All arguments are optional and can be provided in any order.
echo   If an argument is provided multiple times, the last value wins.
echo   The default configuration is "Release".
echo   The default platform is "x64".
echo   Visual Studio is started unless "vs-" is specified.

:end
rem Clear temporary values
set profiler_platform=
set profiler_configuration=
set start_visual_studio=