-- +goose Up
-- +goose StatementBegin

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- PRODUCTS AND CATEGORIES
-- ============================================

-- Categories table for product organization
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

COMMENT ON TABLE categories IS 'Product categories with support for hierarchical structure';

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_created_at ON products(created_at DESC);

-- Full-text search index for products
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);

COMMENT ON TABLE products IS 'Product catalog with pricing and inventory';
COMMENT ON COLUMN products.price IS 'Product price in decimal format';
COMMENT ON COLUMN products.stock IS 'Available inventory quantity';
COMMENT ON COLUMN products.is_active IS 'Whether product is visible in catalog';

-- ============================================
-- USER INTERACTIONS
-- ============================================

-- Product views tracking
CREATE TABLE user_product_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    session_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT
);

CREATE INDEX idx_user_product_views_user_id ON user_product_views(user_id);
CREATE INDEX idx_user_product_views_product_id ON user_product_views(product_id);
CREATE INDEX idx_user_product_views_viewed_at ON user_product_views(viewed_at DESC);
CREATE INDEX idx_user_product_views_user_product ON user_product_views(user_id, product_id);

COMMENT ON TABLE user_product_views IS 'Tracks when users view products for recommendation engine';

-- Product likes/favorites
CREATE TABLE user_product_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_product_like UNIQUE (user_id, product_id)
);

CREATE INDEX idx_user_product_likes_user_id ON user_product_likes(user_id);
CREATE INDEX idx_user_product_likes_product_id ON user_product_likes(product_id);
CREATE INDEX idx_user_product_likes_created_at ON user_product_likes(created_at DESC);

COMMENT ON TABLE user_product_likes IS 'User favorite products for personalized recommendations';

-- ============================================
-- ORDERS AND PURCHASES
-- ============================================

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled', 'refunded')),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address TEXT,
    billing_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

COMMENT ON TABLE orders IS 'Customer orders and purchase history';
COMMENT ON COLUMN orders.status IS 'Order processing status';
COMMENT ON COLUMN orders.payment_status IS 'Payment transaction status';

-- Order items (products in each order)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMERIC(10, 2) NOT NULL CHECK (price_at_purchase >= 0),
    subtotal NUMERIC(10, 2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

COMMENT ON TABLE order_items IS 'Individual products within each order';
COMMENT ON COLUMN order_items.price_at_purchase IS 'Product price at time of purchase (historical)';
COMMENT ON COLUMN order_items.subtotal IS 'quantity * price_at_purchase';

-- ============================================
-- PRODUCT REVIEWS (Optional but useful)
-- ============================================

CREATE TABLE product_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_product_review UNIQUE (user_id, product_id)
);

CREATE INDEX idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_product_reviews_user_id ON product_reviews(user_id);
CREATE INDEX idx_product_reviews_rating ON product_reviews(rating);
CREATE INDEX idx_product_reviews_created_at ON product_reviews(created_at DESC);

COMMENT ON TABLE product_reviews IS 'User reviews and ratings for products';
COMMENT ON COLUMN product_reviews.is_verified_purchase IS 'Whether user actually purchased the product';

-- ============================================
-- SHOPPING CART
-- ============================================

CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_cart_product UNIQUE (user_id, product_id)
);

CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);

COMMENT ON TABLE cart_items IS 'User shopping cart items';

-- ============================================
-- PRODUCT STATISTICS (Materialized view for performance)
-- ============================================

CREATE MATERIALIZED VIEW product_statistics AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    COUNT(DISTINCT upv.user_id) AS view_count,
    COUNT(DISTINCT upl.user_id) AS like_count,
    COUNT(DISTINCT oi.order_id) AS purchase_count,
    COALESCE(AVG(pr.rating), 0) AS average_rating,
    COUNT(pr.id) AS review_count
FROM products p
LEFT JOIN user_product_views upv ON p.id = upv.product_id
LEFT JOIN user_product_likes upl ON p.id = upl.product_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN product_reviews pr ON p.id = pr.product_id
GROUP BY p.id, p.name;

CREATE UNIQUE INDEX idx_product_statistics_product_id ON product_statistics(product_id);


-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP MATERIALIZED VIEW IF EXISTS product_statistics;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS product_reviews CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS user_product_likes CASCADE;
DROP TABLE IF EXISTS user_product_views CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- +goose StatementEnd
