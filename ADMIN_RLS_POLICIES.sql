-- ========================================
-- ADMIN RLS POLICIES SETUP FOR SUPABASE
-- ========================================
-- This SQL creates admin role management and RLS policies
-- Admin email: info@sss.com

-- Step 1: Create admin_users table to manage admin access
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  is_admin BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Step 2: Add admin flag to auth.users via metadata (alternative approach)
-- Note: You can also store admin status in a separate table (recommended)

-- Step 3: Insert admin user
INSERT INTO admin_users (email, is_admin)
VALUES ('info@sss.com', true)
ON CONFLICT (email) DO UPDATE SET is_admin = true;

-- ========================================
-- ADD MISSING COLUMNS TO EXISTING TABLES
-- ========================================

-- Add created_by column to classes table if it doesn't exist
ALTER TABLE classes ADD COLUMN IF NOT EXISTS created_by TEXT DEFAULT NULL;

-- Add created_at and updated_at columns for tracking
ALTER TABLE classes ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT now();
ALTER TABLE classes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT now();

-- ========================================
-- ENABLE RLS ON TABLES
-- ========================================

-- Enable RLS on classes table
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Enable RLS on admin_users table
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- ========================================
-- HELPER FUNCTION: Check if user is admin
-- ========================================

CREATE OR REPLACE FUNCTION is_admin(email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_users 
    WHERE admin_users.email = $1 
    AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- RLS POLICIES FOR CLASSES TABLE
-- ========================================

-- Policy 1: Allow admins to insert classes
CREATE POLICY "Admins can insert classes"
ON classes
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- Policy 2: Allow admins to read all classes
CREATE POLICY "Admins can read all classes"
ON classes
FOR SELECT
USING (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- Policy 3: Allow admins to update all classes
CREATE POLICY "Admins can update all classes"
ON classes
FOR UPDATE
USING (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
)
WITH CHECK (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- Policy 4: Allow admins to delete classes
CREATE POLICY "Admins can delete classes"
ON classes
FOR DELETE
USING (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- ========================================
-- RLS POLICIES FOR ADMIN_USERS TABLE
-- ========================================

-- Policy 1: Allow only admins to read admin_users
CREATE POLICY "Only admins can read admin users"
ON admin_users
FOR SELECT
USING (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- Policy 2: Allow only admins to insert admin_users
CREATE POLICY "Only admins can insert admin users"
ON admin_users
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- Policy 3: Allow only admins to update admin_users
CREATE POLICY "Only admins can update admin users"
ON admin_users
FOR UPDATE
USING (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
)
WITH CHECK (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- Policy 4: Allow only admins to delete admin_users
CREATE POLICY "Only admins can delete admin users"
ON admin_users
FOR DELETE
USING (
  auth.role() = 'authenticated'
  AND is_admin(auth.email())
);

-- ========================================
-- VERIFY SETUP
-- ========================================

-- Check if admin user exists
SELECT * FROM admin_users WHERE email = 'info@sss.com';

-- Test the is_admin function
SELECT is_admin('info@sss.com') as is_admin;
SELECT is_admin('other@example.com') as is_admin;

-- ========================================
-- ADDITIONAL ADMIN USERS (if needed)
-- ========================================

-- Add more admins like this:
-- INSERT INTO admin_users (email, is_admin) VALUES ('admin2@school.com', true);
-- INSERT INTO admin_users (email, is_admin) VALUES ('admin3@school.com', true);

-- Remove admin access:
-- UPDATE admin_users SET is_admin = false WHERE email = 'admin2@school.com';
-- DELETE FROM admin_users WHERE email = 'admin2@school.com';
