@echo off
setlocal

set EXALENS_NETWORK=exalens
set VOLUME_PATH=C:\Users\%USERNAME%\.exalens

:checkArgs
if "%~1"=="" goto usage
if /I "%~1"=="--start" goto startServices
if /I "%~1"=="--stop" goto stopServices
if /I "%~1"=="--clean-install" goto cleanInstall
if /I "%~1"=="--update" goto updateImages
goto usage

:startServices
echo Starting services...

docker network ls | findstr /C:%EXALENS_NETWORK% >nul
if errorlevel 1 (
    echo 'exalens' network does not exist. Creating network...
    docker network create %EXALENS_NETWORK%
) else (
    echo 'exalens' network already exists.
)

call :pullIfNotExists exalens/community_broker:latest
call :pullIfNotExists exalens/community_cache_db:latest
call :pullIfNotExists exalens/community_threat_intel_db:latest
call :pullIfNotExists exalens/community_keycloak_db:latest
call :pullIfNotExists exalens/community_keycloak:latest
call :pullIfNotExists exalens/community_restapi:latest
call :pullIfNotExists exalens/community_webserver:latest
call :pullIfNotExists exalens/community_cortex:latest
call :pullIfNotExists exalens/community_cache_mongo_db:latest
call :pullIfNotExists exalens/community_threat_intel_mongo_db:latest
call :pullIfNotExists exalens/community_cortex_ctrl:latest
call :pullIfNotExists exalens/community_probe:latest
call :pullIfNotExists exalens/community_probe_ctrl:latest
call :pullIfNotExists exalens/community_zeek:latest

docker run -d --name cortexCtrl --network %EXALENS_NETWORK% --restart always -v %VOLUME_PATH%:/opt -v //var/run/docker.sock:/var/run/docker.sock exalens/community_cortex_ctrl:latest
echo Services started.
goto end

:stopServices
echo Stopping services...
docker stop cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB probe probe_ctrl zeek
docker rm cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB probe probe_ctrl zeek
echo Services stopped.
goto end

:cleanInstall
echo Performing a clean install...
call :stopServices

echo Deleting .exalens folder...
rmdir /s /q %VOLUME_PATH%

call :pullImages
goto startServices

:updateImages
echo Updating all images...
call :stopServices
call :pullImages
goto startServices

:pullImages
docker pull exalens/community_broker:latest
docker pull exalens/community_cache_db:latest
docker pull exalens/community_threat_intel_db:latest
docker pull exalens/community_keycloak_db:latest
docker pull exalens/community_keycloak:latest
docker pull exalens/community_restapi:latest
docker pull exalens/community_webserver:latest
docker pull exalens/community_cortex:latest
docker pull exalens/community_cache_mongo_db:latest
docker pull exalens/community_threat_intel_mongo_db:latest
docker pull exalens/community_cortex_ctrl:latest
docker pull exalens/community_probe:latest
docker pull exalens/community_probe_ctrl:latest
docker pull exalens/community_zeek:latest
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

:usage
echo Usage: retina-cortex.bat --start ^| --stop ^| --clean-install ^| --update

:end
endlocal
