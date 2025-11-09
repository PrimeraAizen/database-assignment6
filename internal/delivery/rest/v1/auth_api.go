package v1

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/PrimeraAizen/e-comm/internal/delivery/dto"
	"github.com/PrimeraAizen/e-comm/internal/domain"
)

// InitAuthRoutes initializes auth routes
func (h *Handler) InitAuthRoutes(api *gin.RouterGroup) {
	auth := api.Group("/auth")
	{
		auth.POST("/register", h.Register)
		auth.POST("/login", h.Login)
		auth.POST("/refresh", h.RefreshToken)
	}
}

// Register handles user registration
// @Summary Register a new user
// @Description Create a new user account with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param user body dto.RegisterRequest true "Registration details"
// @Success 201 {object} dto.AuthResponse "User registered successfully with tokens"
// @Failure 400 {object} dto.ErrorResponse "Invalid request body or validation error"
// @Failure 409 {object} dto.ErrorResponse "User with this email already exists"
// @Failure 500 {object} dto.ErrorResponse "Internal server error"
// @Router /auth/register [post]
func (h *Handler) Register(c *gin.Context) {
	var req dto.RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "invalid request body",
		})
		return
	}

	if err := req.Validate(); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: err.Error(),
		})
		return
	}

	user, err := req.ToDomain()
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{})
		return
	}

	resp, err := h.services.AuthService.Register(c.Request.Context(), user)
	if err != nil {
		if err == domain.ErrAlreadyExists {
			c.JSON(http.StatusConflict, dto.ErrorResponse{
				Error: "user with this email already exists",
			})
			return
		}

		h.logger.WithComponent("auth").WithError(err).Error("Failed to register user")
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error: "failed to register user",
		})
		return
	}

	c.JSON(http.StatusCreated, resp)
}

// Login handles user login
// @Summary Login user
// @Description Authenticate user with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param credentials body dto.LoginRequest true "Login credentials"
// @Success 200 {object} dto.AuthResponse "Login successful with tokens"
// @Failure 400 {object} dto.ErrorResponse "Invalid request body or validation error"
// @Failure 401 {object} dto.ErrorResponse "Invalid email or password"
// @Failure 403 {object} dto.ErrorResponse "User account is inactive"
// @Failure 500 {object} dto.ErrorResponse "Internal server error"
// @Router /auth/login [post]
func (h *Handler) Login(c *gin.Context) {
	var req dto.LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "invalid request body",
		})
		return
	}

	if err := req.Validate(); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: err.Error(),
		})
		return
	}

	// Convert DTO to domain
	domainReq := &domain.LoginRequest{
		Email:    req.Email,
		Password: req.Password,
	}

	resp, err := h.services.AuthService.Login(c.Request.Context(), domainReq)
	if err != nil {
		if err == domain.ErrInvalidCredentials {
			c.JSON(http.StatusUnauthorized, dto.ErrorResponse{
				Error: "invalid email or password",
			})
			return
		}

		if err == domain.ErrUserInactive {
			c.JSON(http.StatusForbidden, dto.ErrorResponse{
				Error: "user account is inactive",
			})
			return
		}

		h.logger.WithComponent("auth").WithError(err).Error("Failed to login user")
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error: "failed to login",
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// RefreshToken handles token refresh
// @Summary Refresh access token
// @Description Get a new access token using a valid refresh token
// @Tags auth
// @Accept json
// @Produce json
// @Param token body dto.RefreshTokenRequest true "Refresh token"
// @Success 200 {object} dto.AuthResponse "Token refreshed successfully"
// @Failure 400 {object} dto.ErrorResponse "Invalid request body or missing refresh token"
// @Failure 401 {object} dto.ErrorResponse "Invalid or expired refresh token"
// @Failure 403 {object} dto.ErrorResponse "User account is inactive"
// @Failure 500 {object} dto.ErrorResponse "Internal server error"
// @Router /auth/refresh [post]
func (h *Handler) RefreshToken(c *gin.Context) {
	var req dto.RefreshTokenRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "invalid request body",
		})
		return
	}

	if req.RefreshToken == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "refresh token is required",
		})
		return
	}

	resp, err := h.services.AuthService.RefreshToken(c.Request.Context(), req.RefreshToken)
	if err != nil {
		if err == domain.ErrInvalidToken {
			c.JSON(http.StatusUnauthorized, dto.ErrorResponse{
				Error: "invalid or expired refresh token",
			})
			return
		}

		if err == domain.ErrUserInactive {
			c.JSON(http.StatusForbidden, dto.ErrorResponse{
				Error: "user account is inactive",
			})
			return
		}

		h.logger.WithComponent("auth").WithError(err).Error("Failed to refresh token")
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error: "failed to refresh token",
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}
