# Use These Files For Postman Import (Import-Safe)

If Postman cannot import previous files, use these two files only:

- postman/cud-auth-testing.import-safe.postman_collection.json
- postman/cud-auth-testing.import-safe.postman_environment.json

## Why this works better

These files are normalized for compatibility:
- Collection schema forced to v2.1
- Every script has explicit type: text/javascript
- Request URL stored in simple raw-string format
- Environment variable type normalized to default (no secret type)
- Export metadata included

## Import Steps (Desktop App)

1. Open Postman Desktop
2. Click Import -> Files
3. Select both import-safe files above
4. Confirm imported collection and environment appear
5. Select environment before running requests

## If still fails

- Update Postman Desktop to latest stable
- Restart Postman and retry Import -> Files
- Ensure file extension is exactly .json
- Do not use Raw text import for this collection
