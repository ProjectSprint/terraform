#!/bin/bash

# Exit on any error
set -e

# Set variables
EASY_RSA_DIR="/tmp/easy-rsa"
PKI_DIR="$EASY_RSA_DIR/EasyRSA-3.1.1"
COMMON_NAME="ProjectSprintVPN"
CLIENT_NAME="projectsprint-client"

# Check for curl
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl to continue."
    exit 1
fi

# Clean up any existing files
rm -rf $EASY_RSA_DIR

# Create and enter Easy-RSA directory
mkdir -p $EASY_RSA_DIR
cd $EASY_RSA_DIR || exit 1

# Download and extract Easy-RSA using curl
echo "Downloading Easy-RSA..."
curl -sL https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.1/EasyRSA-3.1.1.tgz -o EasyRSA-3.1.1.tgz
if [ $? -ne 0 ]; then
    echo "Failed to download Easy-RSA. Please check your internet connection."
    exit 1
fi

tar -xzf EasyRSA-3.1.1.tgz
cd EasyRSA-3.1.1 || exit 1

# Initialize PKI
echo "Initializing PKI..."
./easyrsa init-pki

# Create CA
echo "Creating CA..."
./easyrsa --batch build-ca nopass

# Generate server certificate
echo "Generating server certificate..."
./easyrsa --batch build-server-full server nopass

# Generate client certificate
echo "Generating client certificate..."
./easyrsa --batch build-client-full $CLIENT_NAME nopass

# Debug: Print current directory and PKI structure
echo "Current directory: $(pwd)"
echo "PKI directory structure:"
find pki -type f

# Convert certificates to PEM format (using updated paths)
echo "Converting certificates to PEM format..."
openssl x509 -in pki/issued/server.crt -out server.crt.pem
openssl rsa -in pki/private/server.key -out server.key.pem

openssl x509 -in pki/issued/projectsprint-client.crt -out client.crt.pem
openssl rsa -in pki/private/projectsprint-client.key -out client.key.pem

cp pki/ca.crt ca.crt.pem

# Print AWS CLI commands
echo -e "\nCertificates generated successfully!"
echo -e "\nRun these AWS CLI commands to import the certificates:"
echo "cd /tmp/easy-rsa/EasyRSA-3.1.1/"
echo "aws acm import-certificate --certificate file://server.crt.pem --private-key file://server.key.pem --certificate-chain file://ca.crt.pem"
echo "aws acm import-certificate --certificate file://ca.crt.pem --private-key file://pki/private/ca.key"
