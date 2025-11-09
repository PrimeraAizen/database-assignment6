# Product API Endpoints Documentation

This document describes all product-related API endpoints including products and categories management.

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication
Most endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

---

## Products Endpoints

### 1. List Products (with Pagination, Filtering & Search)

Get a paginated list of products with optional search, filters and sorting. All parameters can be combined.

**Endpoint:** `GET /products`

**Authentication:** Not required

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-indexed) |
| `limit` | integer | 20 | Items per page (max: 100) |
| `search` | string | - | Search query (searches in product name and description) |
| `category_id` | UUID | - | Filter by category ID |
| `min_price` | decimal | - | Minimum price filter |
| `max_price` | decimal | - | Maximum price filter |
| `sort_by` | string | created_at | Sort field: `price`, `name`, `created_at` |
| `sort_order` | string | desc | Sort order: `asc` or `desc` |

**Example Requests:**

Basic listing:
```bash
curl -X GET "http://localhost:8080/api/v1/products?page=1&limit=10"
```

Search for products:
```bash
curl -X GET "http://localhost:8080/api/v1/products?search=macbook&page=1&limit=10"
```

Filter by category and price:
```bash
curl -X GET "http://localhost:8080/api/v1/products?page=1&limit=10&category_id=20000000-0000-0000-0000-000000000004&min_price=1000&max_price=3000&sort_by=price&sort_order=asc"
```

Combine search with filters:
```bash
curl -X GET "http://localhost:8080/api/v1/products?search=laptop&category_id=20000000-0000-0000-0000-000000000002&max_price=2000"
```

**Success Response (200 OK):**
```json
{
  "products": [
    {
      "id": "30000000-0000-0000-0000-000000000011",
      "name": "Lenovo ThinkPad X1",
      "description": "Business laptop with robust build",
      "category_id": "20000000-0000-0000-0000-000000000004",
      "category_name": "Laptops",
      "price": 1599.99,
      "stock": 70,
      "image_url": "https://via.placeholder.com/300x300?text=ThinkPad+X1",
      "is_active": true,
      "created_at": "2025-11-07T12:00:00Z",
      "updated_at": "2025-11-07T12:00:00Z"
    },
    {
      "id": "30000000-0000-0000-0000-000000000010",
      "name": "Dell XPS 15",
      "description": "Intel i7, 16GB RAM, 512GB SSD",
      "category_id": "20000000-0000-0000-0000-000000000004",
      "category_name": "Laptops",
      "price": 1799.99,
      "stock": 60,
      "image_url": "https://via.placeholder.com/300x300?text=Dell+XPS+15",
      "is_active": true,
      "created_at": "2025-11-07T12:00:00Z",
      "updated_at": "2025-11-07T12:00:00Z"
    }
  ],
  "total": 4,
  "page": 1,
  "limit": 10
}
```

---

### 2. Get Product by ID

Retrieve detailed information about a specific product.

**Endpoint:** `GET /products/:id`

**Authentication:** Not required

**Path Parameters:**
- `id` (UUID) - Product ID

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/v1/products/30000000-0000-0000-0000-000000000009"
```

**Success Response (200 OK):**
```json
{
  "id": "30000000-0000-0000-0000-000000000009",
  "name": "MacBook Pro 16\"",
  "description": "Apple M3 Pro chip, 18GB RAM, 512GB SSD",
  "category_id": "20000000-0000-0000-0000-000000000004",
  "category_name": "Laptops",
  "price": 2499.99,
  "stock": 40,
  "image_url": "https://via.placeholder.com/300x300?text=MacBook+Pro",
  "is_active": true,
  "created_at": "2025-11-07T12:00:00Z",
  "updated_at": "2025-11-07T12:00:00Z"
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "Product not found"
}
```

---

### 3. Create Product (Admin Only)

Create a new product in the catalog.

**Endpoint:** `POST /products`

**Authentication:** Required (Admin role)

**Request Headers:**
```
Authorization: Bearer <admin-jwt-token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "iPhone 16 Pro Max",
  "description": "Latest flagship iPhone with A18 chip",
  "category_id": "20000000-0000-0000-0000-000000000001",
  "price": 1199.99,
  "stock": 100,
  "image_url": "https://example.com/iphone16.jpg"
}
```

**Field Validations:**
- `name` (required, max 255 chars)
- `description` (optional)
- `category_id` (required, must exist)
- `price` (required, must be >= 0)
- `stock` (required, must be >= 0)
- `image_url` (optional, max 500 chars)

**Example Request:**
```bash
curl -X POST "http://localhost:8080/api/v1/products" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 16 Pro Max",
    "description": "Latest flagship iPhone with A18 chip",
    "category_id": "20000000-0000-0000-0000-000000000001",
    "price": 1199.99,
    "stock": 100,
    "image_url": "https://example.com/iphone16.jpg"
  }'
```

**Success Response (201 Created):**
```json
{
  "id": "40000000-0000-0000-0000-000000000001",
  "name": "iPhone 16 Pro Max",
  "description": "Latest flagship iPhone with A18 chip",
  "category_id": "20000000-0000-0000-0000-000000000001",
  "price": 1199.99,
  "stock": 100,
  "image_url": "https://example.com/iphone16.jpg",
  "is_active": true,
  "created_at": "2025-11-07T23:59:00Z",
  "updated_at": "2025-11-07T23:59:00Z"
}
```

**Error Responses:**

**400 Bad Request:**
```json
{
  "error": "Invalid request: price must be greater than or equal to 0"
}
```

**401 Unauthorized:**
```json
{
  "error": "Unauthorized"
}
```

**403 Forbidden:**
```json
{
  "error": "Admin access required"
}
```

---

### 4. Update Product (Admin Only)

Update an existing product.

**Endpoint:** `PUT /products/:id`

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (UUID) - Product ID

**Request Body:**
```json
{
  "name": "iPhone 16 Pro Max (Updated)",
  "description": "Updated description",
  "category_id": "20000000-0000-0000-0000-000000000001",
  "price": 1099.99,
  "stock": 150,
  "image_url": "https://example.com/iphone16-updated.jpg"
}
```

**Example Request:**
```bash
curl -X PUT "http://localhost:8080/api/v1/products/40000000-0000-0000-0000-000000000001" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 16 Pro Max (Updated)",
    "price": 1099.99,
    "stock": 150
  }'
```

**Success Response (200 OK):**
```json
{
  "id": "40000000-0000-0000-0000-000000000001",
  "name": "iPhone 16 Pro Max (Updated)",
  "description": "Latest flagship iPhone with A18 chip",
  "category_id": "20000000-0000-0000-0000-000000000001",
  "price": 1099.99,
  "stock": 150,
  "image_url": "https://example.com/iphone16.jpg",
  "is_active": true,
  "created_at": "2025-11-07T23:59:00Z",
  "updated_at": "2025-11-08T00:05:00Z"
}
```

---

### 5. Delete Product (Admin Only)

Delete a product from the catalog.

**Endpoint:** `DELETE /products/:id`

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (UUID) - Product ID

**Example Request:**
```bash
curl -X DELETE "http://localhost:8080/api/v1/products/40000000-0000-0000-0000-000000000001" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Success Response (204 No Content)**

**Error Response (404 Not Found):**
```json
{
  "error": "Product not found"
}
```

---

### 6. Get Product Statistics

Retrieve statistics for a specific product (views, likes, purchases, reviews).

**Endpoint:** `GET /products/:id/statistics`

**Authentication:** Not required

**Path Parameters:**
- `id` (UUID) - Product ID

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/v1/products/30000000-0000-0000-0000-000000000009/statistics"
```

**Success Response (200 OK):**
```json
{
  "product_id": "30000000-0000-0000-0000-000000000009",
  "product_name": "MacBook Pro 16\"",
  "view_count": 42,
  "like_count": 15,
  "purchase_count": 8,
  "average_rating": 4.8,
  "review_count": 12
}
```

---

## Categories Endpoints

### 1. List All Categories

Get all product categories (hierarchical structure).

**Endpoint:** `GET /categories`

**Authentication:** Not required

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/v1/categories"
```

**Success Response (200 OK):**
```json
{
  "categories": [
    {
      "id": "10000000-0000-0000-0000-000000000001",
      "name": "Electronics",
      "description": "Electronic devices and accessories",
      "parent_id": null,
      "created_at": "2025-11-07T12:00:00Z",
      "updated_at": "2025-11-07T12:00:00Z"
    },
    {
      "id": "20000000-0000-0000-0000-000000000001",
      "name": "Smartphones",
      "description": "Mobile phones and accessories",
      "parent_id": "10000000-0000-0000-0000-000000000001",
      "created_at": "2025-11-07T12:00:00Z",
      "updated_at": "2025-11-07T12:00:00Z"
    }
  ]
}
```

---

### 2. Get Category by ID

Retrieve a specific category with its details.

**Endpoint:** `GET /categories/:id`

**Authentication:** Not required

**Path Parameters:**
- `id` (UUID) - Category ID

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/v1/categories/10000000-0000-0000-0000-000000000002"
```

**Success Response (200 OK):**
```json
{
  "id": "10000000-0000-0000-0000-000000000002",
  "name": "Computers",
  "description": "Computers and computer accessories",
  "parent_id": null,
  "created_at": "2025-11-07T12:00:00Z",
  "updated_at": "2025-11-07T12:00:00Z"
}
```

---

### 3. Create Category (Admin Only)

Create a new product category.

**Endpoint:** `POST /categories`

**Authentication:** Required (Admin role)

**Request Body:**
```json
{
  "name": "Wearables",
  "description": "Smartwatches and fitness trackers",
  "parent_id": "10000000-0000-0000-0000-000000000001"
}
```

**Field Validations:**
- `name` (required, max 100 chars, must be unique)
- `description` (optional)
- `parent_id` (optional, must exist if provided)

**Example Request:**
```bash
curl -X POST "http://localhost:8080/api/v1/categories" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wearables",
    "description": "Smartwatches and fitness trackers",
    "parent_id": "10000000-0000-0000-0000-000000000001"
  }'
```

**Success Response (201 Created):**
```json
{
  "id": "50000000-0000-0000-0000-000000000001",
  "name": "Wearables",
  "description": "Smartwatches and fitness trackers",
  "parent_id": "10000000-0000-0000-0000-000000000001",
  "created_at": "2025-11-08T00:10:00Z",
  "updated_at": "2025-11-08T00:10:00Z"
}
```

---

### 4. Update Category (Admin Only)

Update an existing category.

**Endpoint:** `PUT /categories/:id`

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (UUID) - Category ID

**Request Body:**
```json
{
  "name": "Smart Wearables",
  "description": "Updated description for wearables"
}
```

**Example Request:**
```bash
curl -X PUT "http://localhost:8080/api/v1/categories/50000000-0000-0000-0000-000000000001" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Smart Wearables",
    "description": "Updated description for wearables"
  }'
```

**Success Response (200 OK):**
```json
{
  "id": "50000000-0000-0000-0000-000000000001",
  "name": "Smart Wearables",
  "description": "Updated description for wearables",
  "parent_id": "10000000-0000-0000-0000-000000000001",
  "created_at": "2025-11-08T00:10:00Z",
  "updated_at": "2025-11-08T00:15:00Z"
}
```

---

### 5. Delete Category (Admin Only)

Delete a category. Note: Cannot delete categories that have products or subcategories.

**Endpoint:** `DELETE /categories/:id`

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (UUID) - Category ID

**Example Request:**
```bash
curl -X DELETE "http://localhost:8080/api/v1/categories/50000000-0000-0000-0000-000000000001" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Success Response (204 No Content)**

**Error Response (400 Bad Request):**
```json
{
  "error": "Cannot delete category with existing products or subcategories"
}
```

---

## Common Error Responses

### 400 Bad Request
Invalid request data or validation errors.
```json
{
  "error": "Invalid request: price must be greater than or equal to 0"
}
```

### 401 Unauthorized
Missing or invalid authentication token.
```json
{
  "error": "Unauthorized"
}
```

### 403 Forbidden
Insufficient permissions for the requested operation.
```json
{
  "error": "Admin access required"
}
```

### 404 Not Found
Resource not found.
```json
{
  "error": "Product not found"
}
```

### 500 Internal Server Error
Server-side error.
```json
{
  "error": "Internal server error"
}
```

---

## Usage Examples

### Scenario 1: Browse Laptops Under $2000

```bash
# Get Laptops category ID first
curl -X GET "http://localhost:8080/api/v1/categories" | jq '.categories[] | select(.name=="Laptops")'

# List laptops under $2000
curl -X GET "http://localhost:8080/api/v1/products?category_id=20000000-0000-0000-0000-000000000004&max_price=2000&sort_by=price&sort_order=asc"
```

### Scenario 2: Search for Programming Books

```bash
curl -X GET "http://localhost:8080/api/v1/products?q=programming"
```

### Scenario 3: Admin Creates New Product

```bash
# 1. Login as admin
TOKEN=$(curl -X POST "http://localhost:8080/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ecomm.com","password":"password123"}' \
  | jq -r '.access_token')

# 2. Create product
curl -X POST "http://localhost:8080/api/v1/products" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Product",
    "description": "Amazing product",
    "category_id": "20000000-0000-0000-0000-000000000001",
    "price": 599.99,
    "stock": 50
  }'
```

### Scenario 4: Get Product Statistics

```bash
# Get statistics for MacBook Pro
curl -X GET "http://localhost:8080/api/v1/products/30000000-0000-0000-0000-000000000009/statistics"
```

---

## Notes

1. **Pagination**: All list endpoints support pagination with `page` and `limit` parameters
2. **Search**: Use the `q` parameter to search products by name or description (full-text search)
3. **Filtering**: Product list supports filtering by category, price range
4. **Sorting**: Product list supports sorting by name, price, or created_at
5. **Combined Queries**: You can combine search with filters (e.g., search "laptop" in "Computers" category under $2000)
6. **Full-Text Search**: Uses PostgreSQL pg_trgm extension for efficient searching
7. **Admin Endpoints**: Create, Update, Delete operations require admin authentication
8. **Performance**: Product statistics are cached in a materialized view for fast access

---

## Related Documentation

- [Authentication Endpoints](./API_AUTH_ENDPOINTS.md)
- [User Interaction Endpoints](./API_INTERACTION_ENDPOINTS.md)
- [Recommendation Endpoints](./API_RECOMMENDATION_ENDPOINTS.md)
- [Default Credentials](./DEFAULT_CREDENTIALS.md)

---

**Last Updated:** November 7, 2025
