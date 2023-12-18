@echo off
setlocal

set EXALENS_NETWORK=exalens
set VOLUME_PATH=C:\Users\%USERNAME%\.exalens
set IMAGE_NAME=exalens/community_cortex_ctrl:latest

:checkArgs
if "%1"=="" goto usage
if /I "%1"=="--start" goto startServices
if /I "%1"=="--stop" goto stopServices
goto usage

:startServices
echo Starting services...

docker network ls | findstr /C:%EXALENS_NETWORK% > nul
if errorlevel 1 (
    echo 'exalens' network does not exist. Creating network...
    docker network create %EXALENS_NETWORK%
) else (
    echo 'exalens' network already exists.
)

docker run -d --name cortexCtrl --network %EXALENS_NETWORK% -v %VOLUME_PATH%:/opt -v //var/run/docker.sock:/var/run/docker.sock %IMAGE_NAME%
echo Services started.
goto end

:stopServices
echo Stopping services...
docker stop cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB
echo Services stopped.
goto end

:usage
echo Usage: retina-cortex.bat --start ^| --stop

:end
endlocal
