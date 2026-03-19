# CUD Test Cases Final (Create / Update / Delete)

Date: 2026-03-19
Scope: POST /api/transactions, PUT /api/transactions/:id, DELETE /api/transactions/:id

## 1) Test Accounts for Ownership

Use 2 accounts for ownership checks:

- Owner account
  - email: owner.cud@example.com
  - password: Test@12345
- Non-owner account
  - email: other.cud@example.com
  - password: Test@12345

Notes:
- Register both accounts first using POST /api/auth/register.
- Create transaction using owner account token.
- Use non-owner token to call update/delete on owner transaction and expect 404.
- These accounts are also saved in backend/postman/env.json as ownerEmail, ownerPassword, otherEmail, otherPassword.

## 2) Expected Response Contract

### 2.1 Success

POST /api/transactions (201)
- success: true
- statusCode: 201
- message: Transaction created successfully
- data: created transaction object

PUT /api/transactions/:id (200)
- success: true
- statusCode: 200
- message: Transaction updated successfully
- data: updated transaction object

DELETE /api/transactions/:id (200)
- success: true
- statusCode: 200
- message: Transaction deleted successfully
- data: deleted transaction object

### 2.2 Bad Request

Validation errors for body or params return 400:
- success: false
- statusCode: 400
- message: Validation failed
- errors: array of validation details

### 2.3 Unauthorized

Missing token:
- status: 401
- success: false
- statusCode: 401
- errorCode: TOKEN_MISSING
- message: Access token required

Malformed token:
- status: 401
- success: false
- statusCode: 401
- errorCode: TOKEN_INVALID
- message: Invalid token

Expired token:
- status: 401
- success: false
- statusCode: 401
- errorCode: TOKEN_EXPIRED
- message: Token expired

### 2.4 Not Found

Not found or not owner for update/delete:
- status: 404
- success: false
- statusCode: 404
- message: Transaction not found

## 3) Final Test Case Set

### 3.1 Create - POST /api/transactions

Success:
- C-01 Create with valid body -> 201
- C-02 Create with amount = 0 -> 201

Validation fail (body):
- C-03 Missing title -> 400
- C-04 amount < 0 -> 400
- C-05 invalid category -> 400
- C-06 invalid date format -> 400

Unauthorized:
- C-07 no token -> 401 TOKEN_MISSING
- C-08 malformed token -> 401 TOKEN_INVALID
- C-09 expired token -> 401 TOKEN_EXPIRED

Not found:
- Not applicable for create endpoint

### 3.2 Update - PUT /api/transactions/:id

Success:
- U-01 Full update valid body -> 200
- U-02 Partial update single field -> 200
- U-03 Update amount to 0 -> 200

Validation fail (body):
- U-04 Empty body -> 400
- U-05 amount < 0 -> 400
- U-06 invalid category -> 400
- U-07 invalid date -> 400

Validation fail (param):
- U-08 id malformed (non-ObjectId) -> 400

Unauthorized:
- U-09 no token -> 401 TOKEN_MISSING
- U-10 malformed token -> 401 TOKEN_INVALID
- U-11 expired token -> 401 TOKEN_EXPIRED

Not found:
- U-12 valid id but transaction not found -> 404
- U-13 valid id but non-owner account -> 404

### 3.3 Delete - DELETE /api/transactions/:id

Success:
- D-01 Delete own transaction -> 200

Validation fail (param):
- D-02 invalid id format -> 400
- D-03 id too short -> 400

Unauthorized:
- D-04 no token -> 401 TOKEN_MISSING
- D-05 malformed token -> 401 TOKEN_INVALID

Not found:
- D-06 valid id but transaction not found -> 404
- D-07 valid id but non-owner account -> 404
- D-08 second delete same id (idempotency behavior) -> 404

## 4) Coverage Mapping to Automated Tests

Automated integration tests:
- backend/tests/integration/transaction.post.test.js
- backend/tests/integration/transaction.put.test.js
- backend/tests/integration/transaction.delete.test.js

These files now assert expected response fields for:
- success
- bad request
- unauthorized
- not found
