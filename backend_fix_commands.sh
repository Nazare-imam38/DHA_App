#!/bin/bash
# Backend Fix Commands for Property Update API Issue
# Run these commands on the backend server

echo "=== Searching for invalid validation rules ==="
cd /var/www/html/dha-marketplace-backend

echo "\n1. Finding 'sometimes_if' usage:"
grep -rn "sometimes_if" app/

echo "\n2. Finding UpdatePropertyRequest or similar:"
find app/Http/Requests -name "*Property*Request.php"

echo "\n3. Checking all validation files:"
find app/Http/Requests -type f -name "*.php"

echo "\n=== After fixing the validation rules, restart the application ==="
echo "php artisan config:clear"
echo "php artisan cache:clear"
echo "php artisan route:clear"

echo "\n=== Test the endpoint ==="
echo "Check logs: tail -f storage/logs/laravel.log"
