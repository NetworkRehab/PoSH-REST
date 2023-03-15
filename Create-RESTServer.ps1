# Adapted from https://hkeylocalmachine.com/?p=518

# Create a listener on port 8999
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8999/') 
$listener.Start()
'Listening for requests...'
 
# Setup Loop to listen for requests and process them
while ($true) {
    $context = $listener.GetContext() 
 
    # Capture the details about the request
    $request = $context.Request
 
    # Setup a place to deliver a response
    $response = $context.Response
   
    # Break from loop if GET request sent to /end
    if ($request.Url -match '/end$') { 
        break 
    } else {
 
        # Split request URL to get command and options
        $requestvars = ([String]$request.Url).split("/")
 
        # If a request is sent to http:// :8000/tnc
        Switch ($requestvars[3])
        {
            {$_ -match 'tnc'} 
                {
                    # Get the class name and server name from the URL and run get-WMIObject
                    $result = test-connection -IPv4 -targetname $requestvars[4] -TcpPort $requestvars[5]
 
                    # Convert the returned data to JSON and set the HTTP content type to JSON
                    $message = $result | ConvertTo-Json
                    $response.ContentType = 'application/json'
                }
            {$_ -match 'host'}
                {
                    $result = hostname

                    # Convert the returned data to JSON and set the HTTP content type to JSON
                    $message = $result | ConvertTo-Json
                    $response.ContentType = 'application/json'
                }
            default
                {
                    # If no matching subdirectory/route is found generate a 404 message
                    $message = "This is not the page you're looking for."
                    $response.ContentType = 'text/html'
                }
        }
 
       # Convert the data to UTF8 bytes
       [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
       
       # Set length of response
       $response.ContentLength64 = $buffer.length
       
       # Write response out and close
       $output = $response.OutputStream
       $output.Write($buffer, 0, $buffer.length)
       $output.Close()
   }    
}
 
#Terminate the listener
$listener.Stop()