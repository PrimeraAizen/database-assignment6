# E-Commerce API - MongoDB Migration

This project has been fully migrated from PostgreSQL to MongoDB.

## Prerequisites

- Go 1.24 or higher
- Docker and Docker Compose (for MongoDB)
- MongoDB 7.0 or higher (if not using Docker)

## Quick Start

### 1. Start MongoDB

Using Docker (recommended):
```bash
make docker-up
```

Or start MongoDB manually on `localhost:27017`

### 2. Seed the Database

```bash
make seed
```

This will create:
- 5 roles (admin, user, moderator, student, teacher)
- 6 test users
- 5 product categories
- 10 sample products

### 3. Run the Application

```bash
make run
```

The API will be available at `http://localhost:8080`

## Default Credentials

After seeding, you can login with these accounts:

- **Admin**: `admin@example.com` / `password123`
- **Moderator**: `moderator@example.com` / `password123`
- **Regular User**: `user1@example.com` / `password123`
- **Another User**: `user2@example.com` / `password123`
- **Student**: `student@example.com` / `password123`
- **Teacher**: `teacher@example.com` / `password123`

## Configuration

Edit `config/config.yaml` to configure MongoDB connection:

```yaml
mongodb:
  host: localhost
  port: "27017"
  database: ecommerce
  username: ""  # Optional
  password: ""  # Optional
  max_pool_size: 100
  min_pool_size: 10
  max_conn_idle_time: 60  # seconds
```

Or use environment variables:
```bash
export APP_MONGODB_HOST=localhost
export APP_MONGODB_PORT=27017
export APP_MONGODB_DATABASE=ecommerce
```

## Available Make Commands

- `make run` - Run the application
- `make build` - Build the binary
- `make docker-up` - Start MongoDB container
- `make docker-down` - Stop all containers
- `make seed` - Seed MongoDB with test data
- `make setup` - Complete first-time setup (MongoDB + seed data)
- `make start` - Start MongoDB, seed data, and run app
- `make clean` - Remove build artifacts

## MongoDB Collections

The application uses the following collections:

- `users` - User accounts
- `roles` - User roles (admin, user, moderator, etc.)
- `user_roles` - User-to-role mappings
- `categories` - Product categories
- `products` - Product catalog
- `orders` - Customer orders
- `order_items` - Order line items
- `user_product_views` - Product view tracking
- `user_product_likes` - Product likes
- `profiles` - Extended user profiles

## Key Changes from PostgreSQL

1. **No Migrations**: MongoDB uses indexes created automatically on startup
2. **UUID-based IDs**: Still using UUIDs as document `_id` fields
3. **BSON Tags**: Domain models use `bson` tags instead of `db` tags
4. **Aggregations**: Complex queries use MongoDB aggregation pipelines
5. **Full-Text Search**: Text search on product names and descriptions
6. **Flexible Schema**: Can add fields dynamically without migrations

## API Documentation

See:
- `docs/JWT_AUTH.md` - Authentication endpoints
- `docs/API_PRODUCT_ENDPOINTS.md` - Product and category endpoints
- `docs/DEFAULT_CREDENTIALS.md` - Test user credentials

## Development

### Resetting the Database

```bash
# Drop all collections and reseed
make docker-down
make docker-up
sleep 3
make seed
```

### Testing Endpoints

```bash
# Register a new user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"newuser@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password123"}'

# List products
curl http://localhost:8080/api/v1/products

# Search products
curl "http://localhost:8080/api/v1/products?search=macbook&limit=10"
```

## MongoDB Advantages

1. **Faster Development**: No migrations needed for schema changes
2. **Better Performance**: Optimized for document-based data
3. **Scalability**: Easy horizontal scaling with sharding
4. **Flexible Schema**: Add new fields without altering tables
5. **Native JSON**: Works naturally with Go structs and JSON APIs
6. **Aggregation Framework**: Powerful data processing pipelines
7. **Full-Text Search**: Built-in text search capabilities

## Troubleshooting

### MongoDB Connection Failed

Make sure MongoDB is running:
```bash
docker ps | grep mongodb
```

Start MongoDB if not running:
```bash
make docker-up
```

### Indexes Not Created

Indexes are created automatically when the application starts. Check logs for any errors.

### Seed Data Not Loading

Make sure MongoDB is running and accessible, then run:
```bash
go run scripts/seed/main.go
```

## Architecture

```
cmd/web/          - Application entry point
internal/
  app/            - Application initialization
  domain/         - Domain models with BSON tags
  repository/     - MongoDB data access layer
  service/        - Business logic
  delivery/       - HTTP handlers (Gin)
pkg/
  adapter/mongodb/ - MongoDB client wrapper
  logger/         - Structured logging
config/           - Configuration management
scripts/seed/     - Database seeding script
```
