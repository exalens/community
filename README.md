
# Exalens Industrial AI Analyst Community Edition
## A Unified Industry 4.0 Monitoring Solution

The Exalens Industrial AI Analyst Community Edition represents a groundbreaking convergence of Exalens DataMonitor's comprehensive data collection and management framework with the sophisticated AI-driven analytics of Exalens Industrial AI Analyst. This integration yields a no-code, plug-and-play industrial AI solution that seamlessly complements existing monitoring infrastructures such as SCADA, Historian, and HMI, facilitating an enhanced and integrated monitoring experience.

### Key Features

- **Plug ‘n Play Industrial AI:** Simplifies deployment and integration with current monitoring systems, eradicating the necessity for coding, a dedicated data science team, or additional hardware.
  
- **Self-learning Anomaly Detection and Root Cause Analysis:** Utilizes advanced AI to autonomously identify anomalies and decipher the root causes of issues across both cyber and physical domains, ensuring prompt detection and remediation of potential challenges.
  
- **Multiple Protocols Support:** Ensures compatibility with a diverse array of protocols, including OPCUA, MQTT, SNMP, and MTConnect, with plans to extend support to Modbus TCP and S7, enabling exhaustive data collection from a multitude of sources.
  
- **Advanced Browsing, Filtering, and Searching:** Provides sophisticated tools for efficient navigation, filtering, and searching through collected data.
  
- **Visualization Tools:** Equipped with advanced features for visually representing data, facilitating easier understanding and analysis.
  
- **Data Forwarding via REST API:** Enhances interoperability and integration capabilities by allowing the forwarding of collected data to external products through a RESTful API.
  
- **Data Download Facility:** Facilitates easy access and utilization of the collected information, allowing users to download data using the REST API.

### Prerequisites

Before starting, ensure you have the following installed:
- Docker
- Git (to clone this repository)

### Cloning the Repository

Clone this repository to your local machine using the following command:

```bash
git clone https://github.com/exalens/community.git
cd community
```

### Starting the Services

#### On Linux
To start the services on Linux, use the provided script by executing the following command:

```bash
./linux/retina-cortex.sh --start
```
This script simplifies the process of starting the services by encapsulating the necessary Docker commands.

### Accessing the Service

After starting the service, open your web browser and navigate to:

```html
https://[IP_ADDRESS]:443
```

Replace `[IP_ADDRESS]` with the IP address of the machine where the Exalens service is running.

### Monitoring the Network Interface

This feature is applicable only for Linux host machines. To monitor the network interface using the Exalens platform on a Linux host, follow these steps:

#### Navigate to System Administration:

1. After logging into the Exalens service, click on the menu located in the top right corner (default admin).
2. Select `System Administration` from the dropdown menu.

#### Access Data Collector:

- In the System Administration panel, navigate to the `Data Collector` section.

#### Edit CortexProbe:

- Locate the `CortexProbe` data collector, which should be running on the cortex machine.
- Click to edit the CortexProbe. Here, you should find the status marked as `Connected`.

#### Specify the Interface to Monitor:

- In the edit mode, you will have the option to specify or change the interface name that you want to monitor.
- Enter the name of the network interface you wish to monitor.

#### Save Changes:

- After entering the desired interface name, submit your changes to start monitoring the specified network interface.

### Stopping the Services

#### On Linux

To stop the services on Linux, use the same script with the --stop argument

```bash
./linux/retina-cortex.sh --stop
```

### Additional Script Options

#### `--clean-install`

The `--clean-install` option performs a complete reinstallation of the Exalens services. This option is useful for ensuring a fresh start with the latest updates and configurations.

#### `--update`

The `--update` option updates all Docker images used by the Exalens platform to their latest versions. This ensures that your setup is running with the most current software versions.
