param (
    [string]$address = "localhost",
    [int]$port = 8999
)

# Create a listener on the specified address and port
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://$address:$port/")  # Restrict to specified address for security
$listener.Start()
Write-Output "Listening for requests on http://$address:$port/"

# Setup Loop to listen for requests and process them
try {
    while ($true) {
        $context = $listener.GetContext()

        # Capture the details about the request
        $request = $context.Request

        # Setup a place to deliver a response
        $response = $context.Response

        try {
            # Handle GET requests
            if ($request.HttpMethod -eq 'GET') {
                # Split request URL to get command and options
                $requestVars = ($request.Url.LocalPath -split '/')[1..$($request.Url.Segments.Length - 1)]

                switch ($requestVars[0]) {
                    "tnc" {
                        if ($requestVars.Count -ge 3) {
                            $targetName = $requestVars[1]
                            $tcpPort = $requestVars[2]
                            try {
                                $result = Test-Connection -IPv4 -ComputerName $targetName -TcpPort $tcpPort
                                $message = $result | ConvertTo-Json
                                $response.ContentType = 'application/json'
                            } catch {
                                $message = "Error testing connection: $_"
                                $response.ContentType = 'text/plain'
                                $response.StatusCode = 500  # Internal Server Error
                            }
                        } else {
                            $message = "Invalid request. Usage: /tnc/targetname/port"
                            $response.ContentType = 'text/plain'
                            $response.StatusCode = 400  # Bad Request
                        }
                    }
                    "host" {
                        $result = hostname
                        $message = $result | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    "datetime" {
                        $result = Get-Date
                        $message = $result | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    "uptime" {
                        $uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                        $elapsed = (Get-Date) - $uptime
                        $result = @{ Uptime = $elapsed.ToString() }
                        $message = $result | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    "processes" {
                        $processes = Get-Process | Select-Object Name, Id, CPU
                        $message = $processes | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    "disk" {
                        $drives = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, Free, Used
                        $message = $drives | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    "ipconfig" {
                        $networkInfo = Get-NetIPAddress | Select-Object InterfaceAlias, IPAddress, AddressFamily
                        $message = $networkInfo | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    "whoami" {
                        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
                        $result = @{ User = $user }
                        $message = $result | ConvertTo-Json
                        $response.ContentType = 'application/json'
                    }
                    default {
                        $message = "This is not the page you're looking for."
                        $response.ContentType = 'text/html'
                        $response.StatusCode = 404  # Not Found
                    }
                }

                # Convert the data to UTF8 bytes
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            } else {
                $response.StatusCode = 405  # Method Not Allowed
                $response.StatusDescription = "Only GET method is allowed."
            }
        } catch {
            $response.StatusCode = 500  # Internal Server Error
            $response.StatusDescription = "Internal Server Error: $_"
        } finally {
            $response.OutputStream.Close()
        }
    }
} catch {
    Write-Error "Listener error: $_"
} finally {
    $listener.Stop()
}