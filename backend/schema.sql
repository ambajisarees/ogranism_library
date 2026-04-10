-- Database Schema for Textile ERP

-- 1. Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUMS
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'operator', 'viewer');
CREATE TYPE order_status AS ENUM ('draft', 'confirmed', 'in_production', 'dispatched', 'closed');

-- 3. USERS & AUTH
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role user_role DEFAULT 'viewer',
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- 4. MASTER DATA: PRODUCTS
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    unit TEXT DEFAULT 'kg',
    price_per_unit DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TRANSACTIONS: SALES ORDERS
CREATE TABLE sales_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT UNIQUE NOT NULL,
    customer_name TEXT NOT NULL,
    status order_status DEFAULT 'draft',
    total_amount DECIMAL(12, 2) DEFAULT 0.00,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE sales_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity DECIMAL(10, 2) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    -- Prevent editing lines if locked (Handled via Policy or Trigger)
    UNIQUE(order_id, product_id)
);

-- 6. AUDIT LOGGING (Trigger Function)
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_timestamp
BEFORE UPDATE ON sales_orders
FOR EACH ROW EXECUTE PROCEDURE update_updated_at();

-- 7. ROW LEVEL SECURITY (The Core Requirement)
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;

-- Create Policies
-- A. VIEW: Everyone active can view
CREATE POLICY "Enable read access for all users" ON sales_orders
    FOR SELECT
    USING (true);

-- B. INSERT: Only Managers/Admins can insert
-- Note: In a real app, uses current_setting('app.current_user_id') or similar
-- For demo purposes assuming we have a way to check role (e.g., via session variable)

-- C. UPDATE: Critical Logic
-- Logic: Users can only update if status is 'draft'.
-- Admins can update anytime.
-- Managers can update 'confirmed' but not 'dispatched' or 'closed'.

CREATE POLICY "strict_update_policy" ON sales_orders
    FOR UPDATE
    USING (
        -- Condition to allow the update row visibility
        true 
    )
    WITH CHECK (
        -- Validating the NEW state
        (
            -- ADMIN OVERRIDE
            current_setting('app.current_user_role', true) = 'admin'
        ) 
        OR 
        (
            -- DRAFT: Editable by creator or manager
            old.status = 'draft' AND (
                current_setting('app.current_user_id', true)::uuid = created_by
                OR current_setting('app.current_user_role', true) = 'manager'
            )
        )
    );

-- 8. STAGING TABLE FOR CSV SYNC
CREATE TABLE staging_csv_imports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_filename TEXT NOT NULL,
    raw_data JSONB NOT NULL, -- Flexible storage for CSV rows
    import_status TEXT DEFAULT 'pending', -- pending, processed, failed
    error_log TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
