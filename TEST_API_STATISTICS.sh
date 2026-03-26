#!/bin/bash
# ============================================================================
# 🧪 TEST API STATISTICS - SMARTSPENDER (BASH VERSION)
# Chạy từ Git Bash: bash TEST_API_STATISTICS.sh
# ============================================================================

BASE_URL="http://localhost:3000"
TEST_EMAIL="test@smartspender.com"
TEST_PASSWORD="Test@123456"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🧪 SMARTSPENDER - TEST API STATISTICS (BASH)             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# PART 1: CHECK BACKEND STATUS
# ============================================================================

echo "📋 PART 1: KIỂM TRA BACKEND STATUS"
echo "─────────────────────────────────────────────────────────────"

if curl -s -f "$BASE_URL/health" > /dev/null 2>&1; then
    echo "✅ Backend responding at $BASE_URL"
else
    echo "❌ Backend NOT responding at $BASE_URL"
    echo "💡 Start backend: cd backend && npm run dev"
    exit 1
fi

echo ""

# ============================================================================
# PART 2: LOGIN & GET TOKEN
# ============================================================================

echo "📋 PART 2: ĐĂNG NHẬP & LẤY TOKEN"
echo "─────────────────────────────────────────────────────────────"

echo "🔐 Đăng nhập: $TEST_EMAIL"

LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
USER_ID=$(echo "$LOGIN_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "⚠️  Login failed - Thử đăng ký tài khoản mới"
    
    REG_RESPONSE=$(curl -s -X POST "$BASE_URL/register" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"username\":\"testuser\",\"fullName\":\"Test User\"}")
    
    # Retry login
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")
    
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
    USER_ID=$(echo "$LOGIN_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
    echo "✅ Đăng ký & login thành công!"
fi

if [ -z "$TOKEN" ]; then
    echo "❌ Không lấy được token"
    exit 1
fi

echo "✅ Login thành công!"
echo "   User ID: $USER_ID"
echo "   Token: ${TOKEN:0:50}..."

echo ""

# ============================================================================
# PART 3: TEST STATISTICS API
# ============================================================================

echo "📋 PART 3: TEST STATISTICS API"
echo "─────────────────────────────────────────────────────────────"

PASS_COUNT=0
FAIL_COUNT=0

# Test Case 1
echo ""
echo "🔍 Test: Lấy thống kê tháng 3/2026"

RESPONSE=$(curl -s -X GET "$BASE_URL/api/statistics/summary?month=3&year=2026" \
  -H "Authorization: Bearer $TOKEN")

TOTAL_INCOME=$(echo "$RESPONSE" | grep -o '"totalIncome":[0-9.]*' | cut -d':' -f2)
TOTAL_EXPENSE=$(echo "$RESPONSE" | grep -o '"totalExpense":[0-9.]*' | cut -d':' -f2)
BALANCE=$(echo "$RESPONSE" | grep -o '"balance":[0-9.]*' | cut -d':' -f2)

if [ ! -z "$TOTAL_INCOME" ]; then
    echo "   ✅ Status: 200 OK"
    echo "   📊 Total Income:  ₫$TOTAL_INCOME"
    echo "   📊 Total Expense: ₫$TOTAL_EXPENSE"
    echo "   📊 Balance:       ₫$BALANCE"
    ((PASS_COUNT++))
else
    echo "   ❌ Failed to get data"
    ((FAIL_COUNT++))
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  📊 TEST SUMMARY                                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "✅ Backend Connection:     SUCCESS"
echo "✅ Authentication:         SUCCESS"
echo "📊 Statistics API Tests:   $PASS_COUNT PASSED, $FAIL_COUNT FAILED"
echo ""

echo "🎯 Next Steps:"
echo "   1. Kiểm tra backend values khớp MongoDB"
echo "   2. Launch mobile app: cd mobile && flutter run"
echo "   3. Login: $TEST_EMAIL / $TEST_PASSWORD"
echo "   4. Navigate to Statistics screen"
echo "   5. Verify KPI cards match values trên:"
echo "      • Income: ₫$TOTAL_INCOME"
echo "      • Expense: ₫$TOTAL_EXPENSE"
echo "      • Balance: ₫$BALANCE"
echo ""

echo "✅ Backend API Test Complete!"
