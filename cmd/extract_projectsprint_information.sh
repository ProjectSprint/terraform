#!/bin/bash

# Check if a file path is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-json-file>"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' does not exist"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

# Process the JSON file with proper parsing
jq -r '
. as $root |
{
  teams: [
    .projectsprint_user_credentials.value | to_entries[] | 
    .key as $team |
    {
      name: $team,
      resources: {
        databases: $root.projectsprint_db_info.value[$team],
        ec2_instances: $root.projectsprint_ec2_instance_ips.value[$team],
        load_balancer_dns: $root.projectsprint_load_balancers.value[$team].dns,
        aws_credentials: {
          username: $root.projectsprint_user_credentials.value[$team].username,
          password: $root.projectsprint_user_credentials.value[$team].password,
          secret_key: $root.projectsprint_user_credentials.value[$team].secret_key,
          access_key: $root.projectsprint_user_credentials.value[$team].access_key
        }
      }
    }
  ]
}' "$1"
