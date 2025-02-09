#!/bin/bash

# Set database connection details
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME_1="bankassafa_db"
DB_NAME_2="bankassafa_vector"
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"

# Get the current date in the format dd-mm-aaaa
CURRENT_DATE=$(date +"%d-%m-%Y")

# Dump the first database
DUMP_FILE_1="${DB_NAME_1}-${CURRENT_DATE}.sql"
echo "Dumping database ${DB_NAME_1} to ${DUMP_FILE_1}..."
PGPASSWORD="${DB_PASSWORD}" pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -F c -b -v -f "${DUMP_FILE_1}" "${DB_NAME_1}"
if [ $? -eq 0 ]; then
    echo "Dump of ${DB_NAME_1} completed successfully."
else
    echo "Error occurred while dumping ${DB_NAME_1}."
    exit 1
fi

# Dump the second database
DUMP_FILE_2="${DB_NAME_2}-${CURRENT_DATE}.sql"
echo "Dumping database ${DB_NAME_2} to ${DUMP_FILE_2}..."
PGPASSWORD="${DB_PASSWORD}" pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -F c -b -v -f "${DUMP_FILE_2}" "${DB_NAME_2}"
if [ $? -eq 0 ]; then
    echo "Dump of ${DB_NAME_2} completed successfully."
else
    echo "Error occurred while dumping ${DB_NAME_2}."
    exit 1
fi

echo "All dumps completed successfully."
