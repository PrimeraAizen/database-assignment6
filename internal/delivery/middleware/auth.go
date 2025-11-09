package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/PrimeraAizen/e-comm/internal/domain"
	"github.com/PrimeraAizen/e-comm/internal/service"
)

const (
	authorizationHeader = "Authorization"
	userCtxKey          = "userId"
	emailCtxKey         = "userEmail"
)

// AuthMiddleware creates a middleware that validates JWT tokens
func AuthMiddleware(authService service.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractToken(c)
		if token == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "missing authorization token",
			})
			return
		}

		claims, err := authService.ValidateToken(token)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "invalid or expired token",
			})
			return
		}

		// Set user info in context
		c.Set(userCtxKey, claims.UserID)
		c.Set(emailCtxKey, claims.Email)

		c.Next()
	}
}

// extractToken extracts JWT token from Authorization header
func extractToken(c *gin.Context) string {
	bearerToken := c.GetHeader(authorizationHeader)
	if bearerToken == "" {
		return ""
	}

	// Expected format: "Bearer <token>"
	parts := strings.Split(bearerToken, " ")
	if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
		return ""
	}

	return parts[1]
}

// GetUserID retrieves the user ID from the context
func GetUserID(c *gin.Context) (string, error) {
	userID, exists := c.Get(userCtxKey)
	if !exists {
		return "", domain.ErrUnauthorized
	}

	id, ok := userID.(string)
	if !ok {
		return "", domain.ErrUnauthorized
	}

	return id, nil
}

// GetUserEmail retrieves the user email from the context
func GetUserEmail(c *gin.Context) (string, error) {
	email, exists := c.Get(emailCtxKey)
	if !exists {
		return "", domain.ErrUnauthorized
	}

	e, ok := email.(string)
	if !ok {
		return "", domain.ErrUnauthorized
	}

	return e, nil
}
