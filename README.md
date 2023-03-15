# PoSH-REST

This is the start of a REST API in Powershell

Example usage for “Server-A” and “ClientPC”
So on Server-A you run the script.

Let’s say you want to see if Server-A can get to google.com

Run the script on Server-A (Script will loop and act like a service)
In a browser tab on ClientPC go to http://Server-A:8999/tnc/google.com/443

you will either get back true or false depending on if the connection failed or not.

you can put anything in place of google.com. Can be FQDN or IP.

You can also change the port at the end to anything as well.

Finally, just go to http://Server-A:8999/end and the script will close itself.

http://Server-A:8999/host will also return the hostname of the machine it is being run on.
