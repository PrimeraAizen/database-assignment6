package app

import (
	"context"
	"fmt"
	"time"

	"github.com/PrimeraAizen/e-comm/config"
	"github.com/PrimeraAizen/e-comm/internal/delivery"
	"github.com/PrimeraAizen/e-comm/internal/repository"
	"github.com/PrimeraAizen/e-comm/internal/server"
	"github.com/PrimeraAizen/e-comm/internal/service"
	mongodb "github.com/PrimeraAizen/e-comm/pkg/adapter/mongodb"
	"github.com/PrimeraAizen/e-comm/pkg/logger"
)

func StartWebServer(ctx context.Context, cfg *config.Config, appLogger *logger.Logger) error {
	appLogger.WithComponent("app").Info("Initializing web server")

	// Initialize database connection
	appLogger.WithComponent("database").Info("Connecting to MongoDB")
	db, err := mongodb.New(ctx, &cfg.Mongo)
	if err != nil {
		appLogger.WithComponent("database").WithError(err).Error("Failed to initialize MongoDB connection")
		return fmt.Errorf("could not init mongodb connection: %w", err)
	}

	appLogger.WithComponent("database").Info("MongoDB connection established")

	// Initialize repositories
	appLogger.WithComponent("repository").Info("Initializing repositories")
	repos := repository.NewRepositories(db)

	// Initialize services
	appLogger.WithComponent("service").Info("Initializing services")
	services := service.NewServices(service.Deps{
		Repos:  repos,
		Config: cfg,
	})

	// Initialize handlers
	appLogger.WithComponent("handler").Info("Initializing handlers")
	handlers := delivery.NewHandler(services, appLogger)

	// Initialize server
	appLogger.WithComponent("server").Info("Initializing HTTP server")
	srv := server.NewServer(cfg, handlers.Init(cfg), appLogger)

	// Start server
	appLogger.WithComponent("server").WithFields(logger.Fields{
		"host": cfg.Http.Host,
		"port": cfg.Http.Port,
	}).Info("Starting HTTP server")

	srv.Run()
	appLogger.WithComponent("server").Info("HTTP server started successfully")

	// Wait for shutdown signal
	<-ctx.Done()
	appLogger.WithComponent("app").Info("Received shutdown signal")

	// Graceful shutdown with timeout
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Stop HTTP server
	appLogger.WithComponent("server").Info("Stopping HTTP server")
	if err := srv.Stop(); err != nil {
		appLogger.WithComponent("server").WithError(err).Error("Error stopping HTTP server")
	}

	// Close database connection
	appLogger.WithComponent("database").Info("Closing MongoDB connection")
	if err := db.Close(shutdownCtx); err != nil {
		appLogger.WithComponent("database").WithError(err).Error("Error closing MongoDB connection")
	}

	appLogger.WithComponent("app").Info("Graceful shutdown completed")
	return nil
}
