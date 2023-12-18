# Exalens Community Edition
Welcome to the Exalens Community Edition. This repository provides Docker-based setup for the Exalens platform, allowing you to easily start and stop Exalens services on both Windows and Linux systems.
## Prerequisites
Before starting, ensure you have the following installed:
- Docker
- Git (to clone this repository)
## Cloning the Repository
Clone this repository to your local machine using the following command:
```bash
git clone https://github.com/exalens/community.git
cd community
```
## Starting the Services
### On Linux
To start the services on Linux, execute the following commands:
```bash
./linux/retina-cortex.sh --start
```
### On Windows

```cmd
.\windows\retina-cortex.bat --start
```
## Accessing the Service
After starting the service, open your web browser and navigate to:
```html
https://[IP_ADDRESS]:443
```
Replace [IP_ADDRESS] with the IP address of the machine where the Exalens service is running.

Upon your first visit, your browser may warn you about the security risk due to the use of a self-signed certificate. This is a common alert when using self-signed certificates. Please proceed by accepting the risk or adding an exception in your browser to continue. This process varies depending on the browser you are using.

Once you proceed, the user login prompt for Exalens will appear. Enter the credentials provided in the email you received. Following this, the UI will prompt you for the license key. Enter the license key that was given in the email and accept the end-user license agreement.

## Stopping the Services
### On Linux

To stop the services on Linux, use the same script with the --stop argument
```bash
./linux/retina-cortex.sh --start
```
### On Windows
To stop the services on Linux, use the same script with the --stop argument
```cmd
./windows/retina-cortex.bat --stop
```
