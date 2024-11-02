# PoSH-REST

A simple REST API implemented in PowerShell.

## Description

This PowerShell script creates a RESTful API that allows remote clients to perform various system queries and actions on the server where the script is running.

## Getting Started

### Prerequisites

- Docker

### Running the Script

#### Using Docker

1. Build the Docker image:

    ```sh
    docker build -t posh-rest .
    ```

2. Run the Docker container:

    ```sh
    docker run -d -p 80:80 posh-rest
    ```

The script will start listening for requests on port 80.

#### Without Docker

On `Server-A`, run the `Create-RESTServer.ps1` script:

```powershell
.\Create-RESTServer.ps1
```

The script will start listening for requests on port 8999.

## Usage

From ClientPC, you can access the API endpoints using a web browser or tools like Invoke-WebRequest or curl.

### Test Network Connectivity

Check if Server-A can connect to a specified target and port:

**Example:**

```bash
curl 'http://Server-A:8999/test-connection?target=google.com&port=80'
```

**Sample Response:**

```json
{
  "status": "Success",
  "message": "Connected to google.com on port 80."
}
```

### Get Hostname

Retrieve the hostname of Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/hostname'
```

**Sample Response:**

```json
{
  "hostname": "Server-A"
}
```

### Get Current Date and Time

Get the current date and time on Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/datetime'
```

**Sample Response:**

```json
{
  "datetime": "2023-10-05T14:30:00Z"
}
```

### Get Server Uptime

Get the uptime of Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/uptime'
```

**Sample Response:**

```json
{
  "uptime": "3 days, 4 hours, 12 minutes"
}
```

### List Running Processes

Retrieve a list of running processes on Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/processes'
```

**Sample Response:**

```json
{
  "processes": [
    "apache2",
    "mysqld",
    "python",
    "ssh"
  ]
}
```

### Get Disk Information

Get information about disk usage on Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/disk-info'
```

**Sample Response:**

```json
{
  "disk_usage": {
    "total": "500GB",
    "used": "300GB",
    "free": "200GB",
    "percent_used": "60%"
  }
}
```

### Get Network Configuration

Retrieve network configuration details of Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/network-config'
```

**Sample Response:**

```json
{
  "ip_addresses": ["192.168.1.10"],
  "mac_addresses": ["00:1A:2B:3C:4D:5E"],
  "gateway": "192.168.1.1",
  "dns_servers": ["8.8.8.8", "8.8.4.4"]
}
```

### Get Current User

Get the current user running the script on Server-A:

**Example:**

```bash
curl 'http://Server-A:8999/current-user'
```

**Sample Response:**

```json
{
  "user": "admin"
}
```

### Stop the Server

To stop the REST API server:

**Example:**

```bash
curl -X POST 'http://Server-A:8999/stop-server'
```

## Notes

- Replace `Server-A` with the hostname or IP address of the server running the script.
- Ensure that port `8999` is open and accessible.
- The API returns JSON-formatted responses for easy integration with applications.

## Security Considerations

By default, the listener is restricted to `localhost` for security.

To allow remote connections, modify the listener prefix in the script:

```powershell
# Original listener prefix
listener_prefix = "http://localhost:8999/"

# Modify to allow connections from any IP address (use with caution)
listener_prefix = "http://0.0.0.0:8999/"
```

Use appropriate security measures when exposing the server to external networks, such as:

- Implementing authentication and authorization.
- Using a firewall to restrict access.
- Running the server behind a reverse proxy.

## License

This project is licensed under the MIT License.