#!/bin/bash

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
while ! pg_isready -h postgresql -p 5432 -U hive; do
  echo "PostgreSQL is not ready yet, waiting..."
  sleep 2
done

echo "PostgreSQL is ready!"

# Initialize schema if it doesn't exist
echo "Checking if schema exists..."
SCHEMA_EXISTS=$(PGPASSWORD=hive psql -h postgresql -U hive -d metastore -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TBLS';" 2>/dev/null | xargs)

if [ "$SCHEMA_EXISTS" = "0" ] || [ -z "$SCHEMA_EXISTS" ]; then
    echo "Initializing Hive Metastore schema..."
    cd /opt/hive-metastore/bin
    ./schematool -dbType postgres -initSchema
    echo "Schema initialization completed!"
else
    echo "Schema already exists, skipping initialization."
fi

# Start the Hive Metastore
echo "Starting Hive Metastore..."
exec /opt/hive-metastore/bin/hive --service metastore
