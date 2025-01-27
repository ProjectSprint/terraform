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
  account_id: .root_account_id.value,
  ops_server: {
    private_ip: .projectsprint_ops.value.private_ip,
    public_ip: .projectsprint_ops.value.public_ip
  },
  teams: [
    .projectsprint_user_credentials.value | to_entries[] |
    .key as $team |
    {
      name: $team,
      resources: {
        databases: (
          if $root.projectsprint_db.value[$team] then
            $root.projectsprint_db.value[$team] | to_entries[] |
            {
              name: .key,
              endpoint: .value.endpoint,
              username: .value.username,
              password: .value.password
            }
          else
            null
          end
        ),
        ecr_repositories: (
          if $root.projectsprint_ecr.value[$team] then
            if $root.projectsprint_ecr.value[$team] != {} then
              [$root.projectsprint_ecr.value[$team] | to_entries[] | 
              {
                name: .key,
                endpoint: .value.endpoint
              }]
            else
              null
            end
          else
            null
          end
        ),
        ecs_load_balancers: (
          if $root.projectsprint_ecs_load_balancers.value[$team] then
            if $root.projectsprint_ecs_load_balancers.value[$team] != {} then
              [$root.projectsprint_ecs_load_balancers.value[$team] | to_entries[] |
              {
                name: .key,
                endpoint: .value.endpoint
              }]
            else
              null
            end
          else
            null
          end
        ),
        projectsprint_ec2: (
          if $root.projectsprint_ec2.value[$team] then
            if $root.projectsprint_ec2.value[$team] != {} then
              $root.projectsprint_ec2.value[$team]
            else
              null
            end
          else
            null
          end
        ),
        ec2_load_balancers: (
          if $root.projectsprint_ec2_load_balancers.value[$team] then
            if $root.projectsprint_ec2_load_balancers.value[$team] != {} then
              $root.projectsprint_ec2_load_balancers.value[$team]
            else
              null
            end
          else
            null
          end
        ),
        aws_credentials: {
          username: .value.username,
          password: .value.password,
          access_key: .value.access_key,
          secret_key: .value.secret_key
        }
      }
    }
  ]
}' "$1"
