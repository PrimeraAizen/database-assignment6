# E-Commerce API with Recommendation System

A modern e-commerce REST API built with Go, MongoDB, JWT authentication, and collaborative filtering recommendation system.

## 🚀 Features

- **User Authentication**: JWT-based auth with access and refresh tokens
- **Product Catalog**: Full CRUD with categories, search, filtering, and pagination
- **MongoDB with Integer IDs**: NoSQL database with auto-incrementing integer IDs for better performance
- **User Interactions**: Track product views, likes, and purchases
- **Recommendation System**: Collaborative filtering with weighted user interactions (purchases 50%, likes 35%, views 15%)
- **User Profiles**: Separate profile management with personal information
- **Swagger Documentation**: Complete OpenAPI/Swagger UI at `/swagger/index.html`
- **CORS Support**: Pre-configured for frontend integration
- **Graceful Shutdown**: Proper cleanup of resources on SIGTERM/SIGINT
- **RESTful API**: Clean architecture with Gin framework
- **Docker Support**: Easy deployment with Docker Compose

## 📋 Prerequisites

- Go 1.23 or higher
- Docker and Docker Compose (recommended)
- MongoDB 7.0+ (if not using Docker)

## 🛠️ Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd db-assignment6
```

### 2. Configure Environment

Copy and edit the configuration:
```bash
cp config/config.example.yaml config/config.yaml
# Edit config/config.yaml with your settings
```

### 3. Start MongoDB

```bash
make docker-up
```

### 4. Run the Application

```bash
make run
```

API available at: `http://localhost:8080`  
Swagger UI available at: `http://localhost:8080/swagger/index.html`

### Or Do Everything at Once

```bash
make docker-up  # Start MongoDB
make run        # Start the application
```

## 🔑 Default Credentials

Register a new user or use test credentials from `docs/DEFAULT_CREDENTIALS.md`

Default test user:
- Email: `diyas.nurullaev@gmail.com`
- Password: `password123`

## 📚 API Documentation

### Swagger UI (Recommended)

Visit `http://localhost:8080/swagger/index.html` for interactive API documentation.

**Authentication in Swagger:**
1. Click the "Authorize" button (green lock icon)
2. Enter: `Bearer <your_access_token>` (include "Bearer " prefix)
3. Click "Authorize" then "Close"

Or simply enter your JWT token - the middleware accepts both formats.

### Authentication Endpoints

```bash
# Register
POST /api/v1/auth/register
{
  "email": "user@example.com",
  "password": "password123"
}

# Login
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}

# Refresh Token
POST /api/v1/auth/refresh
{
  "refresh_token": "your-refresh-token"
}
```

### Product Endpoints (All require authentication)

```bash
# List products with filters and pagination
GET /api/v1/products?page=1&limit=20
GET /api/v1/products?search=laptop&category_id=4
GET /api/v1/products?min_price=100&max_price=1000&sort_by=price&sort_order=asc
Authorization: Bearer <token>

# Get product details
GET /api/v1/products/:id
Authorization: Bearer <token>

# Get product statistics
GET /api/v1/products/:id/statistics
Authorization: Bearer <token>

# Create product (Admin only)
POST /api/v1/products
Authorization: Bearer <token>
{
  "name": "iPhone 15 Pro",
  "description": "Latest Apple flagship",
  "category_id": 1,
  "price": 999.99,
  "stock": 100,
  "image_url": "https://example.com/image.jpg"
}

# Update product (Admin only - supports partial updates)
PUT /api/v1/products/:id
Authorization: Bearer <token>
{
  "price": 899.99,
  "stock": 150
}

# Delete product (Admin only)
DELETE /api/v1/products/:id
Authorization: Bearer <token>
```

### User Interaction Endpoints

```bash
# Record product view
POST /api/v1/products/:id/view
Authorization: Bearer <token>

# Like a product
POST /api/v1/products/:id/like
Authorization: Bearer <token>

# Unlike a product
DELETE /api/v1/products/:id/like
Authorization: Bearer <token>

# Check if product is liked
GET /api/v1/products/:id/liked
Authorization: Bearer <token>

# Purchase a product
POST /api/v1/products/:id/purchase
Authorization: Bearer <token>
{
  "quantity": 2
}

# Check if product is purchased
GET /api/v1/products/:id/purchased
Authorization: Bearer <token>
```

### Category Endpoints (All require authentication)

```bash
# List all categories
GET /api/v1/categories
Authorization: Bearer <token>

# Get category
GET /api/v1/categories/:id
Authorization: Bearer <token>

# Create category (Admin only)
POST /api/v1/categories
Authorization: Bearer <token>

# Update category (Admin only - supports partial updates)
PUT /api/v1/categories/:id
Authorization: Bearer <token>

# Delete category (Admin only)
DELETE /api/v1/categories/:id
Authorization: Bearer <token>
```

### Profile Endpoints

```bash
# Get my profile
GET /api/v1/profiles/me
Authorization: Bearer <token>

# Update profile (supports partial updates)
PUT /api/v1/profiles/me
Authorization: Bearer <token>
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890"
}

# Change password
PUT /api/v1/profiles/me/password
Authorization: Bearer <token>
{
  "old_password": "oldpass123",
  "new_password": "newpass123"
}

# Delete account
DELETE /api/v1/profiles/me/account
Authorization: Bearer <token>
```

### Recommendation Endpoints

```bash
# Get personalized product recommendations
GET /api/v1/profiles/me/recommendations?limit=10
Authorization: Bearer <token>

# Get my interaction history
GET /api/v1/profiles/me/interactions
Authorization: Bearer <token>

# Get my viewed products
GET /api/v1/profiles/me/views
Authorization: Bearer <token>

# Get my liked products
GET /api/v1/profiles/me/likes
Authorization: Bearer <token>

# Get my purchase history
GET /api/v1/profiles/me/purchases
Authorization: Bearer <token>

# Find similar users
GET /api/v1/profiles/me/similar
Authorization: Bearer <token>
```

## ⚙️ Configuration

Edit `config/config.yaml`:

```yaml
http:
  host: "0.0.0.0"
  port: "8080"

mongodb:
  host: localhost
  port: "27017"
  database: ecommerce
  username: ""
  password: ""
  max_pool_size: 100
  min_pool_size: 10
  max_conn_idle_time: 60

jwt:
  secret: "your-secret-key-change-in-production"
  access_token_duration: "15m"
  refresh_token_duration: "168h"

logger:
  level: info
  format: json
  service: template
  version: "1.0.0"
  environment: development
```

### CORS Configuration

CORS is pre-configured for common development origins:
- `http://localhost:3000` (React)
- `http://localhost:5173` (Vite)
- `http://localhost:8080` (Swagger UI)

To add more origins, edit `internal/delivery/handler.go`:
```go
AllowOrigins: []string{
    "http://localhost:3000",
    "https://yourdomain.com",
},
```

## 🏗️ Project Structure

```
.
├── cmd/
│   └── web/
│       └── main.go              # Application entry point
├── config/
│   ├── config.go                # Configuration loader
│   ├── config.yaml              # Configuration file
│   └── config.example.yaml      # Example configuration
├── internal/
│   ├── app/
│   │   └── app.go               # App initialization
│   ├── domain/
│   │   ├── user.go              # User domain model
│   │   ├── product.go           # Product domain models
│   │   ├── interaction.go       # User interaction models
│   │   ├── recommendation.go    # Recommendation models
│   │   └── errors.go            # Domain errors
│   ├── repository/
│   │   ├── repository.go        # Repository factory
│   │   ├── userRepository.go    # User data access
│   │   ├── productRepository.go # Product data access
│   │   ├── profileRepository.go # Profile data access
│   │   └── interactionRepository.go # Interaction tracking
│   ├── service/
│   │   ├── service.go           # Service factory
│   │   ├── authService.go       # Auth business logic
│   │   ├── userService.go       # User management
│   │   ├── productService.go    # Product business logic
│   │   ├── interactionService.go # Interaction tracking
│   │   └── recommendationService.go # Collaborative filtering
│   ├── delivery/
│   │   ├── handler.go           # HTTP handler setup with CORS
│   │   ├── dto/
│   │   │   ├── auth.go          # Auth DTOs
│   │   │   └── product.go       # Product DTOs
│   │   ├── middleware/
│   │   │   └── auth.go          # JWT middleware
│   │   └── rest/v1/
│   │       ├── handlers.go      # Route registration
│   │       ├── auth_api.go      # Auth endpoints
│   │       ├── product_api.go   # Product & interaction endpoints
│   │       ├── categories_api.go # Category endpoints
│   │       └── profile_api.go   # Profile & recommendation endpoints
│   └── server/
│       └── server.go            # HTTP server
├── pkg/
│   ├── adapter/
│   │   └── mongodb/
│   │       └── mongodb.go       # MongoDB client
│   └── logger/
│       └── logger.go            # Structured logger
├── scripts/
│   └── seed/
│       └── main.go              # Database seeder
├── docs/
│   ├── docs.go                  # Generated Swagger docs
│   ├── swagger.json             # OpenAPI specification (JSON)
│   ├── swagger.yaml             # OpenAPI specification (YAML)
│   ├── MONGODB_MIGRATION.md     # MongoDB migration guide
│   ├── MIGRATION_SUMMARY.md     # Migration summary
│   ├── JWT_AUTH.md              # Auth documentation
│   ├── JWT_AUTH_IMPLEMENTATION.md # Auth implementation details
│   ├── API_PRODUCT_ENDPOINTS.md # Product API docs
│   └── DEFAULT_CREDENTIALS.md   # Test credentials
├── docker-compose.yml           # Docker Compose config
├── Dockerfile                   # Docker build file
├── Makefile                     # Build automation
├── go.mod                       # Go dependencies
└── go.sum                       # Go checksums
```

## 🧪 Testing

### Using Swagger UI (Recommended)

1. Open `http://localhost:8080/swagger/index.html`
2. Click "Authorize" button
3. Login to get token:
   - Use POST `/api/v1/auth/login` 
   - Copy the `access_token` from response
4. Enter: `Bearer <your_token>` in the authorization dialog
5. Test any endpoint interactively

### Using cURL

```bash
# 1. Register a user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# 2. Login and get token
TOKEN=$(curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | jq -r '.access_token')

# 3. List products
curl http://localhost:8080/api/v1/products \
  -H "Authorization: Bearer $TOKEN"

# 4. Get recommendations
curl http://localhost:8080/api/v1/profiles/me/recommendations \
  -H "Authorization: Bearer $TOKEN"

# 5. Purchase a product
curl -X POST http://localhost:8080/api/v1/products/2/purchase \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"quantity": 1}'
```

### Authentication Script

```bash
./scripts/test_auth_api.sh
```

## 🐳 Docker Deployment

### Build and Run with Docker Compose

```bash
# Start everything
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop everything
docker-compose down
```

### MongoDB Collections

The application uses these MongoDB collections:

- `users` - User accounts with auto-incrementing integer IDs
- `profiles` - Extended user profiles (first_name, last_name, phone, address, etc.)
- `categories` - Product categories with integer IDs
- `products` - Product catalog with integer IDs
- `interactions` - User interactions (views, likes, purchases) for recommendations
- `counters` - Auto-increment counters for integer ID generation

## 📖 Documentation

- [Swagger UI](http://localhost:8080/swagger/index.html) - Interactive API documentation
- [MongoDB Migration Guide](docs/MONGODB_MIGRATION.md) - Detailed migration notes
- [Migration Summary](docs/MIGRATION_SUMMARY.md) - Quick migration overview
- [JWT Authentication](docs/JWT_AUTH.md) - Auth implementation details
- [JWT Implementation](docs/JWT_AUTH_IMPLEMENTATION.md) - Technical auth details
- [Product API](docs/API_PRODUCT_ENDPOINTS.md) - Complete product endpoint docs
- [Default Credentials](docs/DEFAULT_CREDENTIALS.md) - Test user accounts

## 🔧 Makefile Commands

```bash
make run          # Run the application
make build        # Build binary
make clean        # Remove build artifacts
make docker-up    # Start MongoDB
make docker-down  # Stop Docker containers
```

## 🚨 Troubleshooting

### MongoDB Connection Failed

```bash
# Check if MongoDB is running
docker ps | grep mongodb

# Start MongoDB
make docker-up

# Check MongoDB logs
docker logs ecommerce_mongodb
```

### Application Won't Start

```bash
# Check configuration
cat config/config.yaml

# Verify MongoDB is accessible
docker exec -it ecommerce_mongodb mongosh

# Check if port 8080 is in use
lsof -ti:8080

# Kill process on port 8080
lsof -ti:8080 | xargs kill -9
```

### Graceful Shutdown

The application supports graceful shutdown with proper resource cleanup:

```bash
# Send SIGTERM signal (recommended)
pkill -TERM ecommerce

# Or use Ctrl+C if running in foreground
# The application will:
# 1. Stop accepting new HTTP requests
# 2. Wait for in-flight requests to complete (max 10 seconds)
# 3. Close MongoDB connections
# 4. Exit cleanly
```

**Shutdown timeout:** 10 seconds for HTTP server + database cleanup

### CORS Issues

If you're getting CORS errors from your frontend:

1. Check that your origin is in the allowed list (`internal/delivery/handler.go`)
2. Verify you're including the `Authorization` header correctly
3. Check browser console for specific CORS error messages

### Swagger Authentication Not Working

Make sure to include "Bearer " prefix:
- ✅ Correct: `Bearer eyJhbGciOiJIUzI1NiIs...`
- ❌ Wrong: `eyJhbGciOiJIUzI1NiIs...`

The middleware also accepts tokens without "Bearer " prefix for convenience.

## 🎯 Recommendation System

The recommendation system is **fully implemented** using collaborative filtering:

### Features

1. **Weighted User Interactions**:
   - Purchases: 50% weight (strongest signal)
   - Likes: 35% weight (strong interest)
   - Views: 15% weight (mild interest)

2. **User-Based Collaborative Filtering**:
   - Finds users with similar interaction patterns
   - Calculates similarity using weighted Jaccard index
   - Recommends products that similar users interacted with

3. **Endpoints**:
   - `GET /api/v1/profiles/me/recommendations` - Get personalized recommendations
   - `GET /api/v1/profiles/me/similar` - Find similar users
   - `GET /api/v1/profiles/me/interactions` - View interaction history

### How It Works

```bash
# 1. User interacts with products
POST /api/v1/products/1/view
POST /api/v1/products/2/like  
POST /api/v1/products/3/purchase

# 2. System tracks interactions in MongoDB
# Collection: interactions
# { user_id, product_id, interaction_type, quantity, created_at }

# 3. Get recommendations based on similar users
GET /api/v1/profiles/me/recommendations?limit=10
```

### Algorithm

```
For each user U:
  1. Find all other users who interacted with similar products
  2. Calculate similarity score using weighted interactions
  3. Rank similar users by similarity score
  4. Recommend products that similar users liked/purchased
  5. Exclude products current user already interacted with
  6. Return top N recommendations
```

### Example Response

```json
{
  "user_id": 8,
  "recommendations": [
    {
      "product_id": 5,
      "product_name": "Sony WH-1000XM5",
      "score": 0.85,
      "reason": "Based on users with similar interests"
    }
  ],
  "similar_users": [
    {
      "user_id": 12,
      "similarity_score": 0.75
    }
  ]
}
```

## 📝 License

This project is for educational purposes (Database Assignment #6).

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 🙏 Acknowledgments

- Built with [Gin Web Framework](https://github.com/gin-gonic/gin)
- MongoDB Go Driver
- JWT implementation with [golang-jwt](https://github.com/golang-jwt/jwt)
- Swagger documentation with [swaggo](https://github.com/swaggo/swag)
- CORS middleware with [gin-contrib/cors](https://github.com/gin-contrib/cors)
- Clean Architecture principles
- Collaborative filtering algorithm for recommendations

---

**Last Updated:** November 9, 2025
