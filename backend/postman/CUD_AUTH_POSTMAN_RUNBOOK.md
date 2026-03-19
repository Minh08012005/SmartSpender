# Postman Runbook for CUD + Auth Evidence

## Files to Import

- Collection: backend/postman/cud-auth-testing.collection.json
- Environment: backend/postman/cud-auth-testing.env.json

## Pre-conditions

- Backend is running at http://localhost:3000
- Database is connected and writable
- Environment selected in Postman: SmartSpender CUD Auth Testing

## One-time setup for expired token test

The app marks token as expired only if JWT is valid and exp is in the past.
Set the environment variable expiredToken before running folder 07.

PowerShell example (run in backend folder):

```powershell
$env:JWT_SECRET = "<same-secret-used-by-backend>"
node -e "const {SignJWT}=require('jose'); const {TextEncoder}=require('util'); (async()=>{ const now=Math.floor(Date.now()/1000); const secret=new TextEncoder().encode(process.env.JWT_SECRET); const t=await new SignJWT({userId:'000000000000000000000001'}).setProtectedHeader({alg:'HS256'}).setIssuedAt(now-7200).setExpirationTime(now-3600).sign(secret); console.log(t); })();"
```

Copy printed token to environment variable expiredToken.

## Execution Order (for clean evidence screenshots)

1. Run folder 00 - Setup Accounts & Tokens
2. Run folder 01 - Auth Endpoint Tests
3. Run folder 02 - POST /api/transactions
4. Run folder 03 - PUT /api/transactions/:id
5. Run folder 04 - DELETE /api/transactions/:id
6. Run folder 05 - CRUD without token
7. Run folder 06 - CRUD with invalid token
8. Run folder 07 - CRUD with expired token

## Mapping to Required Evidence

- POST /api/auth/register: 01/TC-A01
- POST /api/auth/login: 01/TC-A02
- POST valid / negative amount / missing required / invalid category / invalid date:
  - 02/TC-P01 to TC-P05
- PUT success / partial / amount=0 / empty payload / bad id / non-owner:
  - 03/TC-U01 to TC-U06
- DELETE success / bad id / non-existent / non-owner:
  - 04/TC-D01 to TC-D04
- CRUD without token:
  - 05/TC-NT-C, TC-NT-R, TC-NT-U, TC-NT-D
- CRUD invalid token:
  - 06/TC-IT-C, TC-IT-R, TC-IT-U, TC-IT-D
- CRUD expired token:
  - 07/TC-ET-C, TC-ET-R, TC-ET-U, TC-ET-D

## Screenshot suggestion

- Capture Collection Runner summary per folder (all tests pass)
- Capture one representative request detail per folder showing:
  - URL, method, request body/header
  - status code
  - Tests tab passed
