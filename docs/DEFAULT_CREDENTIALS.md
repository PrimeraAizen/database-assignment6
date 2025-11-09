# Default User Credentials

This document contains the default user credentials seeded in the database for development and testing purposes.

## ⚠️ Security Warning

**IMPORTANT:** These credentials are for **development and testing only**. In production:
- Use strong, unique passwords
- Never commit real credentials to version control
- Implement proper password policies
- Use environment variables for sensitive data

---

## 🔑 Default Users

All users have the same password: **`password123`**

### Administrator Account
- **Email:** `admin@ecomm.com`
- **Password:** `password123`
- **Roles:** `admin`, `user`
- **Name:** System Administrator
- **Description:** Full system access with administrative privileges

### Moderator Account
- **Email:** `moderator@ecomm.com`
- **Password:** `password123`
- **Roles:** `moderator`, `user`
- **Name:** Content Moderator
- **Description:** Content moderation access with limited admin privileges

### Regular Users

#### John Doe
- **Email:** `john.doe@example.com`
- **Password:** `password123`
- **Roles:** `user`, `student`
- **Name:** John Doe
- **Profile:** Computer Science enthusiast

#### Jane Smith
- **Email:** `jane.smith@example.com`
- **Password:** `password123`
- **Roles:** `user`, `student`
- **Name:** Jane Smith
- **Profile:** Book lover, Business Administration major

#### Alice Johnson
- **Email:** `alice.johnson@example.com`
- **Password:** `password123`
- **Roles:** `user`, `student`
- **Name:** Alice Johnson
- **Profile:** Design enthusiast, Graphic Design major

#### Bob Wilson
- **Email:** `bob.wilson@example.com`
- **Password:** `password123`
- **Roles:** `user`, `student`
- **Name:** Bob Wilson
- **Profile:** Gaming enthusiast, Electrical Engineering student

---

## 📋 User Roles

### Available Roles in System

1. **admin** - Full system access
   - Manage all products
   - Manage all users
   - View all orders
   - System configuration

2. **moderator** - Limited administrative access
   - Moderate content
   - View reports
   - Limited user management

3. **user** - Basic user access
   - Browse products
   - Create orders
   - Manage own profile
   - Add reviews

4. **student** - Student-specific features
   - Student discount eligibility
   - Academic resources access

5. **teacher** - Teacher-specific features
   - Course material access
   - Student progress viewing

---

## 🧪 Testing Scenarios

### Authentication Testing
```bash
# Login as admin
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ecomm.com","password":"password123"}'

# Login as regular user
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"password123"}'
```

### User Behavior Patterns (for Recommendation Testing)

**John Doe (Tech Enthusiast)**
- Viewed: MacBook Pro, iPhone, Sony Headphones, Logitech Mouse, Clean Code book
- Liked: MacBook Pro, Clean Code
- Purchased: MacBook Pro, Clean Code

**Jane Smith (Book Lover)**
- Viewed: The Great Gatsby, 1984, Sapiens, Google Pixel
- Liked: 1984, Sapiens
- Purchased: Multiple fiction and science books

**Alice Johnson (Designer)**
- Viewed: MacBook Pro, Samsung Monitor, Keychron Keyboard, Canon Camera
- Liked: MacBook Pro, Canon Camera
- Purchased: MacBook Pro, Samsung Monitor

**Bob Wilson (Gamer)**
- Viewed: PlayStation 5, Steam Deck, Gaming Laptop, Algorithms book
- Liked: PlayStation 5, Gaming Laptop
- Purchased: PlayStation 5, Gaming Laptop

---

## 🔐 Password Hash Information

All passwords are hashed using **bcrypt** with cost factor 10:
- Algorithm: bcrypt
- Cost: 10 (DefaultCost)
- Hash: `$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i`
- Plain text: `password123`

---

## 📝 Notes

1. **IMPORTANT:** These users are only created after running the seed migration. You must first:
   
   a. Set your database URL:
   ```bash
   export DB_URL="postgres://postgres:secret@localhost:5432/postgres?sslmode=disable"
   ```
   
   b. Run migrations to create tables and seed data:
   ```bash
   make migrate-up
   ```

2. To reset the database and reseed:
   ```bash
   make migrate-down
   make migrate-up
   ```

3. Verify users were created:
   ```bash
   psql -h localhost -U postgres -d postgres -c "SELECT email, status FROM users;"
   ```

4. The seed data includes:
   - 6 users (2 admins, 1 moderator, 3 regular users)
   - 28 products across multiple categories
   - User interaction history (views, likes, purchases)
   - Sample orders and reviews

5. User IDs are fixed UUIDs for consistent testing:
   - Admin: `a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`
   - John: `b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`
   - Jane: `c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`
   - Alice: `d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`
   - Bob: `e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`
   - Moderator: `f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`

---

## 🚀 Quick Start

### Prerequisites
1. PostgreSQL must be running on localhost:5432
2. Database credentials: username=`postgres`, password=`secret`

### Setup Steps

1. **Set database URL environment variable:**
   ```bash
   export DB_URL="postgres://postgres:secret@localhost:5432/postgres?sslmode=disable"
   ```

2. **Run migrations to create tables and seed data:**
   ```bash
   cd /Users/diasnurullaev/projects/db-assignment6
   make migrate-up
   ```
   
   You should see output like:
   ```
   OK   20250916160326_initial_migration.sql
   OK   20251107000000_ecommerce_tables.sql
   OK   20251107000001_seed_data.sql
   ```

3. **Start the application:**
   ```bash
   make run
   # or
   go run cmd/web/main.go
   ```

4. **Test login:**
   ```bash
   curl -X POST http://localhost:8080/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"admin@ecomm.com","password":"password123"}'
   ```

5. **Use the JWT token** from the response to access protected endpoints

### Troubleshooting

**If login fails:**

1. Check if migrations ran successfully:
   ```bash
   make migrate-status
   ```

2. Verify users exist in database:
   ```bash
   psql -h localhost -U postgres -d postgres -c "SELECT email, status FROM users;"
   ```

3. Check if seed data was applied:
   ```bash
   psql -h localhost -U postgres -d postgres -c "SELECT COUNT(*) FROM products;"
   # Should return 28 products
   ```

4. If migrations failed, reset and try again:
   ```bash
   make migrate-down
   make migrate-up
   ```

For API documentation, see `docs/API_DOCUMENTATION.md`
