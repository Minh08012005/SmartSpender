#!/usr/bin/env bash
# Simple script to check backend health and CORS via curl
BASE_URL=${1:-https://smartspender-x1fl.onrender.com}

echo "Checking backend health at: ${BASE_URL}/health"
curl -s -w "\nHTTP_STATUS:%{http_code}\n" -o /tmp/health_response.json "${BASE_URL}/health"
echo "Response body:" && cat /tmp/health_response.json || true

echo
echo "Checking root GET request and CORS headers"
curl -s -D - -o /tmp/root_headers.txt "${BASE_URL}/" || true
echo "--- Response headers (first 50 lines) ---"
head -n 50 /tmp/root_headers.txt || true

echo
echo "If you see 'Access-Control-Allow-Origin' header set to your frontend domain, CORS is OK."
