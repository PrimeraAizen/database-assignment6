APP_NAME=ecommerce
MONGO_URI=mongodb://localhost:27017

.PHONY: run build clean docker-up docker-down seed swagger

swagger:
	swag init -g cmd/web/main.go

# Run the application
run:
	go run cmd/web/main.go

# Build the application binary
build:
	go build -o bin/$(APP_NAME) cmd/web/main.go

# Clean build artifacts
clean:
	rm -rf bin

# Start MongoDB with Docker
docker-up:
	docker-compose up -d mongodb

# Stop all Docker containers
docker-down:
	docker-compose down

# Seed MongoDB with test data
seed:
	go run scripts/seed/main.go

# Start everything (MongoDB + seed data + app)
start: docker-up
	@echo "Waiting for MongoDB to be ready..."
	@sleep 3
	@make seed
	@make run

# Complete setup (for first time)
setup: docker-up
	@echo "Waiting for MongoDB to be ready..."
	@sleep 3
	@make seed
	@echo "Setup complete! Run 'make run' to start the application"
