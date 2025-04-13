#!/bin/bash
echo "📦 Running entrypoint.sh..."

# Load required environment variables
source /app/ci.env.sh


# Execute the command received as argument
exec poetry run "$@"
