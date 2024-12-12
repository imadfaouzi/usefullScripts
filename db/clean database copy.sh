#!/bin/bash

# Set database connection details
DB_HOST="192.168.11.3"
DB_PORT="5432"
DB_NAME="bankpreprod"
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"

# Export the password to avoid the prompt
export PGPASSWORD=$DB_PASSWORD

# List of tables to clean
TABLES=("messages" "conversation_historic")

# Loop through all tables and delete the data
for TABLE in "${TABLES[@]}"; do
  echo "Cleaning data from table: $TABLE"
  psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -c "TRUNCATE TABLE $TABLE RESTART IDENTITY CASCADE;"
done

echo "Database cleaned!"
