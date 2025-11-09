package delivery

import (
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"github.com/PrimeraAizen/e-comm/config"
	v1 "github.com/PrimeraAizen/e-comm/internal/delivery/rest/v1"
	"github.com/PrimeraAizen/e-comm/internal/service"
	"github.com/PrimeraAizen/e-comm/pkg/logger"

	_ "github.com/PrimeraAizen/e-comm/docs" // Import generated docs
)

type Handler struct {
	services *service.Service
	logger   *logger.Logger
}

func NewHandler(services *service.Service, appLogger *logger.Logger) *Handler {
	return &Handler{
		services: services,
		logger:   appLogger,
	}
}

func (h *Handler) Init(cfg *config.Config) *gin.Engine {
	router := gin.New()

	// CORS configuration
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:3000", "http://localhost:5173", "http://localhost:8080"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Add custom middleware
	router.Use(
		logger.RequestIDMiddleware(),
		logger.LoggingMiddleware(h.logger),
		logger.RecoveryMiddleware(h.logger),
		logger.ContextMiddleware(h.logger),
	)

	// Health check endpoint
	router.GET("/ping", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "pong")
	})

	// Swagger documentation
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	h.initAPI(router)

	return router
}

func (h *Handler) initAPI(router *gin.Engine) {
	handlerV1 := v1.NewHandler(h.services, h.logger)
	api := router.Group("/api")
	{
		handlerV1.Init(api)
	}
}
