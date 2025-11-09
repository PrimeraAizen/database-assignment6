# JWT Authentication Implementation

This document describes the JWT authentication system implemented in the MyUniConnect project.

## Overview

The authentication system provides:
- User registration and login
- JWT token-based authentication
- Token refresh mechanism
- Protected routes with middleware
- Password hashing with bcrypt

## Configuration

Add JWT settings to your `config/config.yaml`:

```yaml
jwt:
  secret: "your-secret-key-change-this-in-production"
  access_token_duration: "15m"      # Access token expires in 15 minutes
  refresh_token_duration: "168h"    # Refresh token expires in 7 days
```

**Important**: Change the `secret` in production to a strong, randomly generated key.

## API Endpoints

### 1. Register a New User

**POST** `/api/v1/auth/register`

Request body:
```json
{
  "email": "user@example.com",
  "password": "strongpassword123"
}
```

Response (201 Created):
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "status": "active",
    "created_at": "2025-11-03T...",
    "updated_at": "2025-11-03T..."
  }
}
```

### 2. Login

**POST** `/api/v1/auth/login`

Request body:
```json
{
  "email": "user@example.com",
  "password": "strongpassword123"
}
```

Response (200 OK):
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "status": "active",
    "last_login_at": "2025-11-03T...",
    "created_at": "2025-11-03T...",
    "updated_at": "2025-11-03T..."
  }
}
```

### 3. Refresh Token

**POST** `/api/v1/auth/refresh`

Request body:
```json
{
  "refresh_token": "eyJhbGc..."
}
```

Response (200 OK):
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "status": "active",
    "created_at": "2025-11-03T...",
    "updated_at": "2025-11-03T..."
  }
}
```

### 4. Protected Endpoints

**GET** `/api/v1/protected/profile`

Headers:
```
Authorization: Bearer eyJhbGc...
```

Response (200 OK):
```json
{
  "user_id": "uuid",
  "email": "user@example.com"
}
```

**GET** `/api/v1/protected/example`

Headers:
```
Authorization: Bearer eyJhbGc...
```

Response (200 OK):
```json
{
  "message": "This is a protected endpoint",
  "user_id": "uuid",
  "email": "user@example.com"
}
```

## Using Authentication in Code

### Protecting Routes with Middleware

```go
package v1

import (
    "github.com/gin-gonic/gin"
    "github.com/PrimeraAizen/myuniconnect/internal/delivery/middleware"
)

func (h *Handler) InitYourRoutes(api *gin.RouterGroup, authMiddleware gin.HandlerFunc) {
    // Create a route group that requires authentication
    protected := api.Group("/your-resource")
    protected.Use(authMiddleware)
    {
        protected.GET("/", h.YourHandler)
        protected.POST("/", h.CreateHandler)
        protected.PUT("/:id", h.UpdateHandler)
        protected.DELETE("/:id", h.DeleteHandler)
    }
}
```

### Accessing User Information in Handlers

```go
package v1

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/PrimeraAizen/myuniconnect/internal/delivery/middleware"
)

func (h *Handler) YourHandler(c *gin.Context) {
    // Get the authenticated user's ID
    userID, err := middleware.GetUserID(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

    // Get the authenticated user's email
    email, err := middleware.GetUserEmail(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

    // Use userID and email in your logic
    c.JSON(http.StatusOK, gin.H{
        "user_id": userID,
        "email":   email,
    })
}
```

## Testing with cURL

### Register a new user:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Login:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Access protected endpoint:
```bash
curl -X GET http://localhost:8080/api/v1/protected/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Refresh token:
```bash
curl -X POST http://localhost:8080/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"YOUR_REFRESH_TOKEN"}'
```

## Error Handling

### Common Error Responses

**400 Bad Request** - Invalid request body or validation error:
```json
{
  "error": "invalid request body"
}
```

**401 Unauthorized** - Missing or invalid token:
```json
{
  "error": "invalid or expired token"
}
```

**403 Forbidden** - User account is inactive:
```json
{
  "error": "user account is inactive"
}
```

**409 Conflict** - User already exists:
```json
{
  "error": "user with this email already exists"
}
```

**500 Internal Server Error**:
```json
{
  "error": "failed to register user"
}
```

## Security Best Practices

1. **Strong Secret Key**: Use a long, random secret key for JWT signing in production
2. **HTTPS**: Always use HTTPS in production to prevent token interception
3. **Token Expiration**: Keep access token duration short (15 minutes recommended)
4. **Password Requirements**: Enforce strong passwords (minimum 8 characters)
5. **Rate Limiting**: Implement rate limiting on authentication endpoints
6. **Secure Storage**: Never store tokens in localStorage in web applications; use httpOnly cookies
7. **Token Revocation**: Consider implementing a token blacklist for logout functionality

## Architecture

### Components

1. **Domain Models** (`internal/domain/user.go`):
   - User struct
   - RegisterRequest, LoginRequest DTOs
   - AuthResponse, TokenClaims

2. **Repository** (`internal/repository/userRepository.go`):
   - User CRUD operations
   - Database interactions

3. **Service** (`internal/service/authService.go`):
   - Business logic for authentication
   - JWT token generation and validation
   - Password hashing and verification

4. **Middleware** (`internal/delivery/middleware/auth.go`):
   - JWT token extraction and validation
   - Request context population

5. **API Handlers** (`internal/delivery/rest/v1/auth_api.go`):
   - HTTP endpoint handlers
   - Request/response mapping

## Database Schema

The authentication system uses the existing `users` table:

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'pending')),
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## Future Enhancements

Consider implementing:
- Email verification
- Password reset functionality
- Two-factor authentication (2FA)
- OAuth2 integration
- Token blacklist for logout
- Role-based access control (RBAC)
- Account lockout after failed login attempts
- Session management
