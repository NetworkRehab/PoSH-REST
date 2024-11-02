# Use the official PowerShell image as the base image
FROM mcr.microsoft.com/powershell:latest

# Set the working directory
WORKDIR /app

# Copy the PowerShell script into the container
COPY Create-RESTServer.ps1 .

# Expose the port that the REST server will listen on
EXPOSE 80

# Set environment variables for address and port
ENV ADDRESS=0.0.0.0
ENV PORT=80

# Run the PowerShell script with the specified address and port
CMD ["pwsh", "-File", "Create-RESTServer.ps1", "-address", "$env:ADDRESS", "-port", "$env:PORT"]
