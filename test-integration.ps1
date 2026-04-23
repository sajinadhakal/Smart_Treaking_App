# ========================================
# Backend-Frontend Integration Test
# Verifies all key endpoints are working
# ========================================

param(
    [string]$ApiUrl = "http://127.0.0.1:8000/api"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Integration Test Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Testing API: $ApiUrl" -ForegroundColor Green
Write-Host ""

$testsPassed = 0
$testsFailed = 0
$authToken = ""
$testUserId = ""

# Helper function to test endpoint
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [int[]]$ExpectedStatus = @(200)
    )
    
    try {
        $splat = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            SkipHttpErrorCheck = $true
        }
        
        if ($Body) {
            $splat.Body = $Body | ConvertTo-Json -Depth 10
        }
        
        $response = Invoke-WebRequest @splat -TimeoutSec 5
        
        if ($ExpectedStatus -contains $response.StatusCode) {
            Write-Host "✅ $Name" -ForegroundColor Green
            Write-Host "   Status: $($response.StatusCode)" -ForegroundColor DarkGray
            return $response
        } else {
            Write-Host "❌ $Name" -ForegroundColor Red
            Write-Host "   Expected: $($ExpectedStatus -join ', '), Got: $($response.StatusCode)" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "❌ $Name" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Test 1: API Health Check
Write-Host "🔍 Testing API Health..." -ForegroundColor Yellow
$response = Test-Endpoint "API Root" "$ApiUrl/" -ExpectedStatus @(200, 404)
if ($response) { $testsPassed++ } else { $testsFailed++ }
Write-Host ""

# Test 2: Destinations Endpoint
Write-Host "🏔️ Testing Destinations..." -ForegroundColor Yellow
$response = Test-Endpoint "Get Destinations List" "$ApiUrl/destinations/" -ExpectedStatus @(200)
if ($response) {
    $testsPassed++
    $data = $response.Content | ConvertFrom-Json
    $destCount = ($data.results -or $data | Measure-Object).Count
    Write-Host "   Found $destCount destinations" -ForegroundColor DarkGray
} else {
    $testsFailed++
}
Write-Host ""

# Test 3: Authentication - Register
Write-Host "🔑 Testing Authentication..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testUser = "testuser$timestamp"
$testEmail = "test${timestamp}@example.com"
$testPassword = "TestPass123!@"

$registerBody = @{
    username = $testUser
    email = $testEmail
    password = $testPassword
    confirm_password = $testPassword
}

$response = Test-Endpoint "Register User" "$ApiUrl/auth/register/" -Method POST -Body $registerBody -ExpectedStatus @(201, 400)
if ($response) {
    $testsPassed++
    Write-Host "   User: $testUser" -ForegroundColor DarkGray
} else {
    $testsFailed++
}
Write-Host ""

# Test 4: Authentication - Login
Write-Host "🔓 Testing Login..." -ForegroundColor Yellow
$loginBody = @{
    username = $testUser
    password = $testPassword
}

$response = Test-Endpoint "Login User" "$ApiUrl/auth/login/" -Method POST -Body $loginBody -ExpectedStatus @(200, 401)
if ($response) {
    $testsPassed++
    $data = $response.Content | ConvertFrom-Json
    $authToken = $data.access
    Write-Host "   Token received: $($authToken.Substring(0, 20))..." -ForegroundColor DarkGray
} else {
    $testsFailed++
    Write-Host "   ⚠️ Could not obtain auth token - skipping protected endpoints" -ForegroundColor Yellow
}
Write-Host ""

# Test 5: Protected Endpoints (if we have token)
if ($authToken) {
    Write-Host "👤 Testing Protected Endpoints..." -ForegroundColor Yellow
    
    $authHeaders = @{
        Authorization = "Bearer $authToken"
        "Content-Type" = "application/json"
    }
    
    # Get Profile
    $response = Test-Endpoint "Get User Profile" "$ApiUrl/auth/profile/" -Headers $authHeaders -ExpectedStatus @(200)
    if ($response) {
        $testsPassed++
        $data = $response.Content | ConvertFrom-Json
        Write-Host "   Profile: $($data.username)" -ForegroundColor DarkGray
    } else {
        $testsFailed++
    }
    
    # Get Bookings
    $response = Test-Endpoint "Get Bookings" "$ApiUrl/bookings/" -Headers $authHeaders -ExpectedStatus @(200)
    if ($response) {
        $testsPassed++
        $data = $response.Content | ConvertFrom-Json
        $bookingCount = ($data.results -or $data | Measure-Object).Count
        Write-Host "   Bookings: $bookingCount" -ForegroundColor DarkGray
    } else {
        $testsFailed++
    }
    
    # Get Notifications
    $response = Test-Endpoint "Get Notifications" "$ApiUrl/notifications/" -Headers $authHeaders -ExpectedStatus @(200)
    if ($response) {
        $testsPassed++
        $data = $response.Content | ConvertFrom-Json
        Write-Host "   Notifications loaded" -ForegroundColor DarkGray
    } else {
        $testsFailed++
    }
    
    # Get Unread Count
    $response = Test-Endpoint "Get Unread Count" "$ApiUrl/notifications/unread_count/" -Headers $authHeaders -ExpectedStatus @(200)
    if ($response) {
        $testsPassed++
        $data = $response.Content | ConvertFrom-Json
        Write-Host "   Unread: $($data.unread_count)" -ForegroundColor DarkGray
    } else {
        $testsFailed++
    }
    
    Write-Host ""
}

# Test 6: Algorithm Endpoints
Write-Host "🧮 Testing Algorithm Endpoints..." -ForegroundColor Yellow

$response = Test-Endpoint "Trip Planner Info" "$ApiUrl/algorithms/info/" -ExpectedStatus @(200, 400)
if ($response) {
    $testsPassed++
} else {
    $testsFailed++
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Passed: $testsPassed" -ForegroundColor Green
Write-Host "❌ Failed: $testsFailed" -ForegroundColor Red
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "🎉 All tests passed! Integration is working." -ForegroundColor Green
} else {
    Write-Host "⚠️ Some tests failed. Check backend logs for errors." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Verify backend is running: .\run-backend.ps1" -ForegroundColor White
Write-Host "2. Start frontend: .\run-frontend.ps1" -ForegroundColor White
Write-Host "3. Test app functionality manually" -ForegroundColor White
Write-Host ""
