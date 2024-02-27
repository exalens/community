@echo off
setlocal

set EXALENS_NETWORK=exalens
set VOLUME_PATH=C:\Users\%USERNAME%\.exalens
set file_path=%USERPROFILE%\.exalens\retinaCortex\log\boot.log
set TAG=latest

:checkArgs
if "%~1"=="" goto usage
if /I "%~1"=="--start" goto startServices
if /I "%~1"=="--stop" goto stopServices
if /I "%~1"=="--clean-install" goto cleanInstall
if /I "%~1"=="--update" goto updateImages
if /I "%~1"=="--update-hostname" goto updateProbeHostname
goto usage

:setTag
set TAG="%~2"
if "%TAG%" == "" (
  set TAG=latest
  echo Using default tag: "latest"
) else (
  echo Using provided tag: "%TAG%"
)
goto :EOF

:startServices
call :setTag
echo Starting services...

REM Delete the boot.log file if it exists
if exist "%file_path%" del /f /q "%file_path%"

docker network ls | findstr /C:%EXALENS_NETWORK% >nul
if errorlevel 1 (
    echo 'exalens' network does not exist. Creating network...
    docker network create %EXALENS_NETWORK%
) else (
    echo 'exalens' network already exists.
)

call :pullIfNotExists exalens/community_broker:%TAG%
call :pullIfNotExists exalens/community_cache_db:%TAG%
call :pullIfNotExists exalens/community_threat_intel_db:%TAG%
call :pullIfNotExists exalens/community_keycloak_db:%TAG%
call :pullIfNotExists exalens/community_keycloak:%TAG%
call :pullIfNotExists exalens/community_restapi:%TAG%
call :pullIfNotExists exalens/community_webserver:%TAG%
call :pullIfNotExists exalens/community_cortex:%TAG%
call :pullIfNotExists exalens/community_cache_mongo_db:%TAG%
call :pullIfNotExists exalens/community_threat_intel_mongo_db:%TAG%
call :pullIfNotExists exalens/community_cortex_ctrl:%TAG%
call :pullIfNotExists exalens/community_probe:%TAG%
call :pullIfNotExists exalens/community_zeek:%TAG%

docker run -d --name cortexCtrl --network %EXALENS_NETWORK% --restart always -v %VOLUME_PATH%:/opt -v //var/run/docker.sock:/var/run/docker.sock exalens/community_cortex_ctrl:%TAG%
echo Services started.
call :monitorStartup
goto end

:monitorStartup
set "prev_percent=0"

:wait_for_file
if not exist "%file_path%" (
    echo Initializing...
    timeout /t 1 /nobreak >nul
    goto wait_for_file
)

:loop
for /f "usebackq delims=" %%a in ("%file_path%") do (
    call :extract_percentage "%%a"
)
if not "%percent%"=="" (
    echo Current progress: %percent%%%
)
if not "%percent%"=="100" (
    timeout /t 1 /nobreak >nul
    goto :loop
)
goto :EOF

:extract_percentage
set "line=%~1"
set "percent="
for %%a in (%line::= %) do (
    set "percent=%%a"
)

goto :EOF


:stopServices
echo Stopping services...
docker stop cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB probe probe_ctrl zeek
docker rm cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB probe probe_ctrl zeek
echo Services stopped.
goto end

:cleanInstall
call :setTag
echo Performing a clean install...
call :stopServices

echo Deleting .exalens folder...
rmdir /s /q %VOLUME_PATH%

call :pullImages
goto startServices

:updateImages
call :setTag
echo Updating all images...
call :stopServices
call :pullImages
goto startServices

:pullImages
docker pull exalens/community_broker:%TAG%
docker pull exalens/community_cache_db:%TAG%
docker pull exalens/community_threat_intel_db:%TAG%
docker pull exalens/community_keycloak_db:%TAG%
docker pull exalens/community_keycloak:%TAG%
docker pull exalens/community_restapi:%TAG%
docker pull exalens/community_webserver:%TAG%
docker pull exalens/community_cortex:%TAG%
docker pull exalens/community_cache_mongo_db:%TAG%
docker pull exalens/community_threat_intel_mongo_db:%TAG%
docker pull exalens/community_cortex_ctrl:%TAG%
docker pull exalens/community_probe:%TAG%
docker pull exalens/community_zeek:%TAG%
goto :EOF

:pullIfNotExists
docker image inspect %~1 >nul 2>&1
if errorlevel 1 (
    echo Image %~1 not found. Pulling...
    docker pull %~1
) else (
    echo Image %~1 already exists.
)
goto :EOF


:updateProbeHostname
docker exec probe_ctrl python3.10 updateHostname.py %~1
goto eof

:usage
echo Usage: retina-cortex.bat --start ^| --stop ^| --clean-install ^| --update ^| --update-hostname

:end
endlocal
