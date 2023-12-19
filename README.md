# Exalens Community Edition

Welcome to the Exalens Community Edition. This repository provides a Docker-based setup for the Exalens platform, allowing you to easily start and stop Exalens services on both Windows and Linux systems.

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
To start the services on Linux, use the provided script by executing the following command:
```bash
./linux/retina-cortex.sh --start
```
This script simplifies the process of starting the services by encapsulating the necessary Docker commands.

### On Windows
To start the services on Windows, use the provided script by executing the following command:

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

## Monitoring the Network Interface

This feature is applicable only for Linux host machines. To monitor the network interface using the Exalens platform on a Linux host, follow these steps:

#### Navigate to System Administration:
1. After logging into the Exalens service, click on the menu located in the top right corner (default admin).
2. Select `System Administration` from the dropdown menu.

#### Access Data Collector:
- In the System Administration panel, navigate to the `Data Collector` section.

#### Edit CortexProbe:
- Locate the `CortexProbe` data collector, which should be running on the cortex machine.
- Click to edit the CortexProbe. Here, you should find the status marked as `Connected`.
  - If the status is not `Connected`, ensure that the data collector service is running properly.

#### Specify the Interface to Monitor:
- In the edit mode, you will have the option to specify or change the interface name that you want to monitor.
- Enter the name of the network interface you wish to monitor.

#### Save Changes:
- After entering the desired interface name, submit your changes to start monitoring the specified network interface.


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
