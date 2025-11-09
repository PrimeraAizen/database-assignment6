-- +goose Up
-- +goose StatementBegin

-- =====================================================
-- Seed Data Migration
-- Creates default roles, users, admins, categories, and products
-- =====================================================

-- Insert system roles
INSERT INTO roles (id, name, description, is_system_role, created_at, updated_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin', 'System administrator with full access', true, NOW(), NOW()),
    ('00000000-0000-0000-0000-000000000002', 'user', 'Regular user with basic access', true, NOW(), NOW()),
    ('00000000-0000-0000-0000-000000000003', 'moderator', 'Content moderator with limited admin access', true, NOW(), NOW()),
    ('00000000-0000-0000-0000-000000000004', 'student', 'Student user role', true, NOW(), NOW()),
    ('00000000-0000-0000-0000-000000000005', 'teacher', 'Teacher user role', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert default users (passwords are hashed with bcrypt for 'password123')
-- Note: In production, use stronger passwords and proper password management
INSERT INTO users (id, email, password_hash, status, created_at, updated_at) VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin@ecomm.com', '$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i', 'active', NOW(), NOW()),
    ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'john.doe@example.com', '$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i', 'active', NOW(), NOW()),
    ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'jane.smith@example.com', '$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i', 'active', NOW(), NOW()),
    ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'alice.johnson@example.com', '$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i', 'active', NOW(), NOW()),
    ('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'bob.wilson@example.com', '$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i', 'active', NOW(), NOW()),
    ('f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'moderator@ecomm.com', '$2a$10$Y0Zy3Q9boY.QO8CYrHdXf.BszNRGaA51xIbERHOEJuX1cwAzttw1i', 'active', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Assign roles to users
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    -- Admin user has both admin and user roles
    (gen_random_uuid(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000001', NOW()),
    (gen_random_uuid(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000002', NOW()),
    -- Regular users with student role
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000002', NOW()),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000004', NOW()),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000002', NOW()),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000004', NOW()),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000002', NOW()),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000004', NOW()),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000002', NOW()),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000004', NOW()),
    -- Moderator user has moderator and user roles
    (gen_random_uuid(), 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000003', NOW()),
    (gen_random_uuid(), 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000002', NOW())
ON CONFLICT ON CONSTRAINT unique_user_role DO NOTHING;

-- Insert user profiles (matches actual schema: first_name, last_name are NOT NULL)
INSERT INTO profiles (id, user_id, first_name, last_name, date_of_birth, phone, address, city, country, created_at, updated_at) VALUES
    (gen_random_uuid(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'System', 'Administrator', '1990-01-01', '+1234567890', '123 Admin St', 'Tech City', 'USA', NOW(), NOW()),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'John', 'Doe', '2000-05-15', '+1234567891', '456 Student Ave', 'University Town', 'USA', NOW(), NOW()),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Jane', 'Smith', '2001-08-22', '+1234567892', '789 Campus Rd', 'College City', 'USA', NOW(), NOW()),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Alice', 'Johnson', '1999-12-10', '+1234567893', '321 Design Blvd', 'Art District', 'USA', NOW(), NOW()),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bob', 'Wilson', '2002-03-30', '+1234567894', '654 Engineer Way', 'Tech Park', 'USA', NOW(), NOW()),
    (gen_random_uuid(), 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Content', 'Moderator', '1992-07-20', '+1234567895', '987 Mod Lane', 'Control Center', 'USA', NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

-- Insert categories (hierarchical structure)
INSERT INTO categories (id, name, description, parent_id, created_at, updated_at) VALUES
    -- Top-level categories
    ('10000000-0000-0000-0000-000000000001', 'Electronics', 'Electronic devices and accessories', NULL, NOW(), NOW()),
    ('10000000-0000-0000-0000-000000000002', 'Computers', 'Computers and computer accessories', NULL, NOW(), NOW()),
    ('10000000-0000-0000-0000-000000000003', 'Books', 'Books and educational materials', NULL, NOW(), NOW()),
    ('10000000-0000-0000-0000-000000000004', 'Clothing', 'Apparel and fashion', NULL, NOW(), NOW()),
    ('10000000-0000-0000-0000-000000000005', 'Home & Garden', 'Home improvement and garden supplies', NULL, NOW(), NOW()),
    ('10000000-0000-0000-0000-000000000006', 'Sports', 'Sports equipment and outdoor gear', NULL, NOW(), NOW()),
    
    -- Electronics subcategories
    ('20000000-0000-0000-0000-000000000001', 'Smartphones', 'Mobile phones and accessories', '10000000-0000-0000-0000-000000000001', NOW(), NOW()),
    ('20000000-0000-0000-0000-000000000002', 'Audio', 'Headphones, speakers, and audio equipment', '10000000-0000-0000-0000-000000000001', NOW(), NOW()),
    ('20000000-0000-0000-0000-000000000003', 'Cameras', 'Digital cameras and photography equipment', '10000000-0000-0000-0000-000000000001', NOW(), NOW()),
    
    -- Computers subcategories
    ('20000000-0000-0000-0000-000000000004', 'Laptops', 'Portable computers', '10000000-0000-0000-0000-000000000002', NOW(), NOW()),
    ('20000000-0000-0000-0000-000000000005', 'Accessories', 'Computer accessories and peripherals', '10000000-0000-0000-0000-000000000002', NOW(), NOW()),
    ('20000000-0000-0000-0000-000000000006', 'Gaming', 'Gaming computers and equipment', '10000000-0000-0000-0000-000000000002', NOW(), NOW()),
    
    -- Books subcategories
    ('20000000-0000-0000-0000-000000000007', 'Programming', 'Programming and software development books', '10000000-0000-0000-0000-000000000003', NOW(), NOW()),
    ('20000000-0000-0000-0000-000000000008', 'Fiction', 'Novels and fiction books', '10000000-0000-0000-0000-000000000003', NOW(), NOW()),
    ('20000000-0000-0000-0000-000000000009', 'Science', 'Science and technology books', '10000000-0000-0000-0000-000000000003', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert products with various categories and price ranges
INSERT INTO products (id, name, description, category_id, price, stock, image_url, created_at, updated_at) VALUES
    -- Smartphones
    ('30000000-0000-0000-0000-000000000001', 'iPhone 15 Pro', 'Latest Apple smartphone with A17 Pro chip', '20000000-0000-0000-0000-000000000001', 999.99, 50, 'https://via.placeholder.com/300x300?text=iPhone+15+Pro', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000002', 'Samsung Galaxy S24', 'Flagship Android smartphone', '20000000-0000-0000-0000-000000000001', 899.99, 75, 'https://via.placeholder.com/300x300?text=Galaxy+S24', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000003', 'Google Pixel 8', 'Pure Android experience with AI features', '20000000-0000-0000-0000-000000000001', 699.99, 100, 'https://via.placeholder.com/300x300?text=Pixel+8', NOW(), NOW()),
    
    -- Audio
    ('30000000-0000-0000-0000-000000000004', 'Sony WH-1000XM5', 'Premium noise-cancelling headphones', '20000000-0000-0000-0000-000000000002', 399.99, 120, 'https://via.placeholder.com/300x300?text=Sony+WH-1000XM5', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000005', 'AirPods Pro 2', 'Apple wireless earbuds with ANC', '20000000-0000-0000-0000-000000000002', 249.99, 200, 'https://via.placeholder.com/300x300?text=AirPods+Pro', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000006', 'JBL Flip 6', 'Portable Bluetooth speaker', '20000000-0000-0000-0000-000000000002', 129.99, 150, 'https://via.placeholder.com/300x300?text=JBL+Flip+6', NOW(), NOW()),
    
    -- Cameras
    ('30000000-0000-0000-0000-000000000007', 'Canon EOS R6', 'Professional mirrorless camera', '20000000-0000-0000-0000-000000000003', 2499.99, 30, 'https://via.placeholder.com/300x300?text=Canon+EOS+R6', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000008', 'GoPro Hero 12', 'Action camera for adventures', '20000000-0000-0000-0000-000000000003', 399.99, 80, 'https://via.placeholder.com/300x300?text=GoPro+Hero+12', NOW(), NOW()),
    
    -- Laptops
    ('30000000-0000-0000-0000-000000000009', 'MacBook Pro 16"', 'Apple M3 Pro chip, 18GB RAM, 512GB SSD', '20000000-0000-0000-0000-000000000004', 2499.99, 40, 'https://via.placeholder.com/300x300?text=MacBook+Pro', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000010', 'Dell XPS 15', 'Intel i7, 16GB RAM, 512GB SSD', '20000000-0000-0000-0000-000000000004', 1799.99, 60, 'https://via.placeholder.com/300x300?text=Dell+XPS+15', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000011', 'Lenovo ThinkPad X1', 'Business laptop with robust build', '20000000-0000-0000-0000-000000000004', 1599.99, 70, 'https://via.placeholder.com/300x300?text=ThinkPad+X1', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000012', 'ASUS ROG Zephyrus', 'Gaming laptop with RTX 4070', '20000000-0000-0000-0000-000000000004', 2199.99, 45, 'https://via.placeholder.com/300x300?text=ROG+Zephyrus', NOW(), NOW()),
    
    -- Computer Accessories
    ('30000000-0000-0000-0000-000000000013', 'Logitech MX Master 3S', 'Wireless productivity mouse', '20000000-0000-0000-0000-000000000005', 99.99, 180, 'https://via.placeholder.com/300x300?text=MX+Master+3S', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000014', 'Keychron K8', 'Mechanical keyboard, hot-swappable', '20000000-0000-0000-0000-000000000005', 89.99, 140, 'https://via.placeholder.com/300x300?text=Keychron+K8', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000015', 'Samsung 27" 4K Monitor', 'UHD monitor with HDR', '20000000-0000-0000-0000-000000000005', 449.99, 90, 'https://via.placeholder.com/300x300?text=Samsung+Monitor', NOW(), NOW()),
    
    -- Gaming
    ('30000000-0000-0000-0000-000000000016', 'PlayStation 5', 'Sony next-gen gaming console', '20000000-0000-0000-0000-000000000006', 499.99, 35, 'https://via.placeholder.com/300x300?text=PS5', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000017', 'Xbox Series X', 'Microsoft gaming console', '20000000-0000-0000-0000-000000000006', 499.99, 40, 'https://via.placeholder.com/300x300?text=Xbox+Series+X', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000018', 'Steam Deck', 'Portable gaming PC', '20000000-0000-0000-0000-000000000006', 399.99, 55, 'https://via.placeholder.com/300x300?text=Steam+Deck', NOW(), NOW()),
    
    -- Programming Books
    ('30000000-0000-0000-0000-000000000019', 'Clean Code', 'A Handbook of Agile Software Craftsmanship by Robert Martin', '20000000-0000-0000-0000-000000000007', 42.99, 200, 'https://via.placeholder.com/300x300?text=Clean+Code', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000020', 'Design Patterns', 'Elements of Reusable Object-Oriented Software', '20000000-0000-0000-0000-000000000007', 54.99, 150, 'https://via.placeholder.com/300x300?text=Design+Patterns', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000021', 'The Pragmatic Programmer', 'Your Journey to Mastery', '20000000-0000-0000-0000-000000000007', 39.99, 180, 'https://via.placeholder.com/300x300?text=Pragmatic+Programmer', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000022', 'Introduction to Algorithms', 'Comprehensive algorithms textbook (CLRS)', '20000000-0000-0000-0000-000000000007', 89.99, 100, 'https://via.placeholder.com/300x300?text=CLRS', NOW(), NOW()),
    
    -- Fiction Books
    ('30000000-0000-0000-0000-000000000023', 'The Great Gatsby', 'Classic American novel by F. Scott Fitzgerald', '20000000-0000-0000-0000-000000000008', 14.99, 300, 'https://via.placeholder.com/300x300?text=Great+Gatsby', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000024', '1984', 'Dystopian novel by George Orwell', '20000000-0000-0000-0000-000000000008', 16.99, 250, 'https://via.placeholder.com/300x300?text=1984', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000025', 'To Kill a Mockingbird', 'Novel by Harper Lee', '20000000-0000-0000-0000-000000000008', 15.99, 280, 'https://via.placeholder.com/300x300?text=Mockingbird', NOW(), NOW()),
    
    -- Science Books
    ('30000000-0000-0000-0000-000000000026', 'A Brief History of Time', 'Cosmology book by Stephen Hawking', '20000000-0000-0000-0000-000000000009', 18.99, 220, 'https://via.placeholder.com/300x300?text=Brief+History', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000027', 'The Selfish Gene', 'Evolutionary biology by Richard Dawkins', '20000000-0000-0000-0000-000000000009', 17.99, 190, 'https://via.placeholder.com/300x300?text=Selfish+Gene', NOW(), NOW()),
    ('30000000-0000-0000-0000-000000000028', 'Sapiens', 'A Brief History of Humankind by Yuval Noah Harari', '20000000-0000-0000-0000-000000000009', 24.99, 310, 'https://via.placeholder.com/300x300?text=Sapiens', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert some sample user interactions for recommendation testing
INSERT INTO user_product_views (id, user_id, product_id, viewed_at) VALUES
    -- John Doe (tech enthusiast) views
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000009', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000001', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000004', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000013', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000019', NOW() - INTERVAL '1 day'),
    
    -- Jane Smith (book lover) views
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000023', NOW() - INTERVAL '6 days'),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000024', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000028', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000003', NOW() - INTERVAL '2 days'),
    
    -- Alice Johnson (design and tech) views
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000009', NOW() - INTERVAL '7 days'),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000015', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000014', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000007', NOW() - INTERVAL '1 day'),
    
    -- Bob Wilson (gaming enthusiast) views
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000016', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000018', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000012', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000022', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- Insert sample likes (favorites)
INSERT INTO user_product_likes (id, user_id, product_id, created_at) VALUES
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000009', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000019', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000024', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000028', NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000009', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000007', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000016', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000012', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- Insert sample orders (status can be: pending, processing, completed, cancelled, refunded)
INSERT INTO orders (id, user_id, total_amount, status, created_at, updated_at) VALUES
    ('40000000-0000-0000-0000-000000000001', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2542.98, 'completed', NOW() - INTERVAL '10 days', NOW() - INTERVAL '3 days'),
    ('40000000-0000-0000-0000-000000000002', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 72.96, 'completed', NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days'),
    ('40000000-0000-0000-0000-000000000003', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2949.98, 'processing', NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day'),
    ('40000000-0000-0000-0000-000000000004', 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2699.98, 'processing', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- Insert order items (must use price_at_purchase and subtotal columns)
INSERT INTO order_items (id, order_id, product_id, quantity, price_at_purchase, subtotal, created_at) VALUES
    -- John's order: MacBook Pro + Clean Code
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000009', 1, 2499.99, 2499.99, NOW() - INTERVAL '10 days'),
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000019', 1, 42.99, 42.99, NOW() - INTERVAL '10 days'),
    
    -- Jane's order: Books
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000024', 1, 16.99, 16.99, NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000025', 1, 15.99, 15.99, NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000023', 1, 14.99, 14.99, NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000028', 1, 24.99, 24.99, NOW() - INTERVAL '8 days'),
    
    -- Alice's order: MacBook Pro + Monitor
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000009', 1, 2499.99, 2499.99, NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000015', 1, 449.99, 449.99, NOW() - INTERVAL '5 days'),
    
    -- Bob's order: Gaming setup
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000016', 1, 499.99, 499.99, NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), '40000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000012', 1, 2199.99, 2199.99, NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- Insert sample product reviews
INSERT INTO product_reviews (id, product_id, user_id, rating, comment, created_at, updated_at) VALUES
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000009', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 5, 'Amazing laptop! The M3 Pro chip is incredibly fast. Perfect for development.', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000019', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 5, 'Every developer must read this book. Changed how I write code.', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000024', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 5, 'Timeless classic. Still relevant today.', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000028', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 4, 'Fascinating read about human history. Very thought-provoking.', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000016', 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 5, 'Best gaming console! Graphics are incredible.', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000004', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 5, 'Best noise cancellation on the market. Sound quality is superb.', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), '30000000-0000-0000-0000-000000000001', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 4, 'Great phone, but expensive. Camera is outstanding.', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- Insert some cart items for active users
INSERT INTO cart_items (id, user_id, product_id, quantity, created_at, updated_at) VALUES
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000013', 1, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000014', 1, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours'),
    (gen_random_uuid(), 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000026', 1, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours'),
    (gen_random_uuid(), 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '30000000-0000-0000-0000-000000000005', 2, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- Refresh the materialized view to include statistics
REFRESH MATERIALIZED VIEW product_statistics;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

-- Remove seed data in reverse order
DELETE FROM cart_items WHERE user_id IN (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

DELETE FROM product_reviews WHERE user_id IN (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

DELETE FROM order_items WHERE order_id IN (
    '40000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000002',
    '40000000-0000-0000-0000-000000000003',
    '40000000-0000-0000-0000-000000000004'
);

DELETE FROM orders WHERE id IN (
    '40000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000002',
    '40000000-0000-0000-0000-000000000003',
    '40000000-0000-0000-0000-000000000004'
);

DELETE FROM user_product_likes WHERE user_id IN (
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

DELETE FROM user_product_views WHERE user_id IN (
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

DELETE FROM products WHERE id LIKE '30000000-%';

DELETE FROM categories WHERE id LIKE '10000000-%' OR id LIKE '20000000-%';

DELETE FROM profiles WHERE user_id IN (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

-- Delete user_roles (must happen before deleting users or roles)
DELETE FROM user_roles WHERE user_id IN (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

DELETE FROM users WHERE id IN (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
);

DELETE FROM roles WHERE id IN (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000005'
);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW product_statistics;

-- +goose StatementEnd
