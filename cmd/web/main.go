package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/PrimeraAizen/e-comm/config"
	"github.com/PrimeraAizen/e-comm/internal/app"
	"github.com/PrimeraAizen/e-comm/pkg/logger"
)

// @title E-Commerce API
// @version 1.0
// @description E-Commerce API with MongoDB, JWT Authentication, Product Catalog, User Interactions, and Recommendation System
// @BasePath /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Enter your JWT token in the format: Bearer {token}

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	// Load configuration first
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	// Initialize custom logger
	appLogger, err := logger.New(&cfg.Logger)
	if err != nil {
		log.Fatalf("failed to initialize logger: %v", err)
	}
	defer appLogger.Close()

	// Set as global logger
	appLogger.SetGlobal()

	// Log application startup
	appLogger.WithFields(logger.Fields{
		"service":     cfg.Logger.Service,
		"version":     cfg.Logger.Version,
		"environment": cfg.Logger.Environment,
	}).Info("Application starting")

	if err := app.StartWebServer(ctx, cfg, appLogger); err != nil {
		appLogger.WithError(err).Fatal("Failed to start web server")
	}
}
