-- ============================================================
-- QUICK QUEUE / SMART CANTEEN DATABASE SCHEMA
-- ============================================================
-- SQLite schema; the Flask backend uses Python's sqlite3 driver.

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shops (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_no VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    owner_name VARCHAR(100),
    contact_no VARCHAR(20) NOT NULL,
    location_type VARCHAR(50) DEFAULT 'Main Canteen',
    location VARCHAR(255) NOT NULL,
    is_open BOOLEAN DEFAULT 1,
    image_url TEXT,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS menu_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INTEGER NOT NULL,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER DEFAULT 50,
    is_available BOOLEAN DEFAULT 1,
    day_of_week VARCHAR(20) DEFAULT 'All',
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token VARCHAR(20) UNIQUE NOT NULL,
    shop_id INTEGER NOT NULL,
    user_id INTEGER,
    customer_name VARCHAR(100) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'preparing', 'ready', 'completed', 'rejected')),
    payment_status VARCHAR(20) DEFAULT 'paid' CHECK (payment_status IN ('paid', 'pending', 'failed')),
    payment_method VARCHAR(50) DEFAULT 'UPI',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    menu_item_id INTEGER,
    item_name VARCHAR(150) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_shops_is_open ON shops(is_open);
CREATE INDEX IF NOT EXISTS idx_menu_shop_cat ON menu_items(shop_id, category);
CREATE INDEX IF NOT EXISTS idx_orders_token ON orders(token);
CREATE INDEX IF NOT EXISTS idx_orders_shop_status ON orders(shop_id, status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
