# Define the port number as a variable
$port = 8999

# Create a listener on the specified port
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$port/")
$listener.Start()
'Listening for requests...'

# Setup Loop to listen for requests and process them
try {
    while ($true) {
        $context = $listener.GetContext()

        # Capture the details about the request
        $request = $context.Request

        # Setup a place to deliver a response
        $response = $context.Response

        # Handle GET requests
        if ($request.HttpMethod -eq 'GET') {
            # Split request URL to get command and options
            $requestVars = ($request.Url.LocalPath -split '/')[1..$($request.Url.Segments.Length - 1)]

            switch ($requestVars[0]) {
                "tnc" {
                    if ($requestVars.Count -ge 3) {
                        $targetName = $requestVars[1]
                        $tcpPort = $requestVars[2]
                        $result = Test-Connection -IPv4 -ComputerName $targetName -TcpPort $tcpPort
                        $message = $result | ConvertTo-Json
                        $response.ContentType = 'application/json'
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
                default {
                    $message = "This is not the page you're looking for."
                    $response.ContentType = 'text/html'
                    $response.StatusCode = 404  # Not Found
                }
            }

            # Convert the data to UTF8 bytes
            [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)

            # Set length of response
            $response.ContentLength64 = $buffer.Length

            # Write response out and close
            $output = $response.OutputStream
            $output.Write($buffer, 0, $buffer.Length)
            $output.Close()
        } else {
            $message = "Unsupported HTTP method: $($request.HttpMethod)"
            $response.ContentType = 'text/plain'
            $response.StatusCode = 405  # Method Not Allowed

            # Convert the data to UTF8 bytes
            [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
            $response.ContentLength64 = $buffer.Length

            $output = $response.OutputStream
            $output.Write($buffer, 0, $buffer.Length)
            $output.Close()
        }
    }
}
finally {
    # Terminate the listener when done
    $listener.Stop()
}
