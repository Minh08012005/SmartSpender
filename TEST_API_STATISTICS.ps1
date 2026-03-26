# TEST API STATISTICS - SMARTSPENDER
# Run: powershell -ExecutionPolicy Bypass -File TEST_API_STATISTICS.ps1

$BASE_URL = "http://localhost:3000"
$TEST_EMAIL = "test@smartspender.com"
$TEST_PASSWORD = "Test@123456"

Write-Host ""
Write-Host "====== TEST STATISTICS API ======" -ForegroundColor Cyan
Write-Host ""

# PART 1: Check Backend
Write-Host "1. Checking Backend Status..." -ForegroundColor Green
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/health" -Method Get -ErrorAction Stop
    Write-Host "OK: Backend is responding" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Backend not running" -ForegroundColor Red
    Write-Host "Start backend with: npm run dev" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# PART 2: Login
Write-Host "2. Logging in as $TEST_EMAIL..." -ForegroundColor Green

$loginBody = @{
    email = $TEST_EMAIL
    password = $TEST_PASSWORD
} | ConvertTo-Json

$token = $null
try {
    $loginResp = Invoke-RestMethod -Uri "$BASE_URL/api/auth/login" -Method Post -ContentType "application/json" -Body $loginBody -ErrorAction Stop
    
    if ($loginResp.success -eq $true) {
        $token = $loginResp.data.accessToken
        Write-Host "OK: Login successful" -ForegroundColor Green
    }
}
catch {
    Write-Host "Login failed, trying to register..." -ForegroundColor Yellow
    
    $regBody = @{
        email = $TEST_EMAIL
        password = $TEST_PASSWORD
        username = "testuser"
        fullName = "Test User"
    } | ConvertTo-Json
    
    try {
        $regResp = Invoke-RestMethod -Uri "$BASE_URL/api/auth/register" -Method Post -ContentType "application/json" -Body $regBody -ErrorAction Stop
        Write-Host "OK: Account created" -ForegroundColor Green
        
        $loginResp = Invoke-RestMethod -Uri "$BASE_URL/api/auth/login" -Method Post -ContentType "application/json" -Body $loginBody -ErrorAction Stop
        $token = $loginResp.data.accessToken
        Write-Host "OK: Login successful after registration" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Failed to register/login" -ForegroundColor Red
        exit 1
    }
}

if ($token -eq $null) {
    Write-Host "ERROR: No token received" -ForegroundColor Red
    exit 1
}

Write-Host ""

# PART 3: Test Statistics API
Write-Host "3. Testing Statistics API..." -ForegroundColor Green

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$passed = 0
$failed = 0

# Test month 3/2026
$url3 = "$BASE_URL/api/statistics/summary?month=3&year=2026"
try {
    $resp3 = Invoke-RestMethod -Uri $url3 -Method Get -Headers $headers -ErrorAction Stop
    if ($resp3.success -eq $true) {
        Write-Host "   Month 3/2026: Income=$($resp3.data.totalIncome), Expense=$($resp3.data.totalExpense), Balance=$($resp3.data.balance)" -ForegroundColor Cyan
        $passed++
    }
}
catch {
    Write-Host "   Month 3/2026: FAILED" -ForegroundColor Red
    $failed++
}

# Test month 2/2026
$url2 = "$BASE_URL/api/statistics/summary?month=2&year=2026"
try {
    $resp2 = Invoke-RestMethod -Uri $url2 -Method Get -Headers $headers -ErrorAction Stop
    if ($resp2.success -eq $true) {
        Write-Host "   Month 2/2026: Income=$($resp2.data.totalIncome), Expense=$($resp2.data.totalExpense), Balance=$($resp2.data.balance)" -ForegroundColor Cyan
        $passed++
    }
}
catch {
    Write-Host "   Month 2/2026: FAILED" -ForegroundColor Red
    $failed++
}

# Test month 1/2026
$url1 = "$BASE_URL/api/statistics/summary?month=1&year=2026"
try {
    $resp1 = Invoke-RestMethod -Uri $url1 -Method Get -Headers $headers -ErrorAction Stop
    if ($resp1.success -eq $true) {
        Write-Host "   Month 1/2026: Income=$($resp1.data.totalIncome), Expense=$($resp1.data.totalExpense), Balance=$($resp1.data.balance)" -ForegroundColor Cyan
        $passed++
    }
}
catch {
    Write-Host "   Month 1/2026: FAILED" -ForegroundColor Red
    $failed++
}

Write-Host ""

# PART 4: Test Transactions API
Write-Host "4. Testing Transactions API..." -ForegroundColor Green

try {
    $txResp = Invoke-RestMethod -Uri "$BASE_URL/api/transactions?month=3&year=2026" -Method Get -Headers $headers -ErrorAction Stop
    if ($txResp.success -eq $true) {
        $txCount = @($txResp.data.transactions).Count
        Write-Host "   OK: Found $txCount transactions" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "   ERROR: Could not get transactions" -ForegroundColor Red
}

Write-Host ""

# SUMMARY
Write-Host "====== SUMMARY ======" -ForegroundColor Cyan
Write-Host "Backend Connection: OK" -ForegroundColor Green
Write-Host "Authentication: OK" -ForegroundColor Green
Write-Host "Statistics API Tests: $passed PASSED, $failed FAILED" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""
Write-Host "Next: Launch mobile and verify KPI cards match above values" -ForegroundColor Yellow
Write-Host ""
