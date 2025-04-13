#!/bin/bash
set -e

source "/app/.env.$ENVIRONMENT"

echo "Current ENVIRONMENT: $ENVIRONMENT"

echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo "POSTGRES_DB: $POSTGRES_DB"

# Ensure the PostgreSQL database is running
wait_for_postgres() {
    until PGPASSWORD=$POSTGRES_PASSWORD psql -h db -U $POSTGRES_USER -d $POSTGRES_DB -c "\q"; do
        echo "PostgreSQL is not ready yet. Retrying in 2 seconds..."
        sleep 2
    done
}

# Wait for PostgreSQL to be up and running
wait_for_postgres

# Connect to the PostgreSQL server and create schema/initialize data
psql -h db -U postgres <<EOF
CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';
CREATE DATABASE ${POSTGRES_DB} || true;
GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};
EOF

echo "Database initialized successfully."
