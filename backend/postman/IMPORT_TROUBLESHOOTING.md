# Postman Import Troubleshooting

If you cannot import the files, use this checklist in order.

## 1) Import from file path (recommended)

- Open Postman Desktop app
- Click Import -> Files
- Select both files:
  - backend/postman/cud-auth-testing.collection.json
  - backend/postman/cud-auth-testing.env.json

Do not copy/paste JSON into Raw text import for very large collections.

## 2) If import still fails

- Rename files to remove potential parser cache issues:
  - cud-auth-testing.collection.json -> cud-auth-testing.v2.collection.json
  - cud-auth-testing.env.json -> cud-auth-testing.v2.env.json
- Re-open Postman and retry Import -> Files.

## 3) Environment import specific

If collection imports but environment fails:
- Create a new environment manually in Postman with name:
  - SmartSpender CUD Auth Testing
- Add variables from file:
  - backend/postman/cud-auth-testing.env.json

## 4) Version compatibility fallback

If your Postman version is old:
- Update Postman Desktop to latest stable
- Retry import by file

## 5) Verify successful import

After import, you should see:
- Collection: SmartSpender - CUD + Auth Testing Evidence
- Environment: SmartSpender CUD Auth Testing

Then follow run order in:
- backend/postman/CUD_AUTH_POSTMAN_RUNBOOK.md
