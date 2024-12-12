#!/bin/bash

# Set database connection details
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="bankassafa_db"
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"

# Export the password to avoid the prompt
export PGPASSWORD=$DB_PASSWORD

# Connect to the database and get a list of all tables
TABLES=$(psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

# Loop through all tables and delete the data
for TABLE in $TABLES; do
  if [ "$TABLE" != "pg_stat_user_tables" ]; then  # Avoid system tables
    echo "Cleaning data from table: $TABLE"
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "TRUNCATE TABLE $TABLE RESTART IDENTITY CASCADE;"
  fi
done

echo "Database cleaned!"
