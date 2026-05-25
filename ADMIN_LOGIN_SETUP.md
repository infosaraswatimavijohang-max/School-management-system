# Admin Login Setup Guide

## Default Credentials

**Email:** `info@sss.com`  
**Password:** `sss@121`

The login form is now integrated into the admin portal. Users must log in before accessing any features.

---

## Setting Up Admin User in Supabase

To enable full database functionality and fix the "row-level security policy" error, follow these steps:

### Step 1: Create Admin User in Supabase

1. Go to your Supabase Dashboard: https://supabase.com
2. Navigate to **Authentication > Users**
3. Click **"Add User"** button
4. Fill in the following details:
   - **Email:** `info@sss.com`
   - **Password:** `sss@121`
   - Check: "Auto send confirmation email" (optional)
5. Click **"Save user"**

### Step 2: Configure RLS (Row-Level Security) Policies

The "row-level security policy" error occurs because the database tables need proper permissions configured.

#### For the `classes` table:

1. Go to **SQL Editor** in Supabase
2. Create a new query and run the following SQL:

```sql
-- Enable RLS on classes table
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert their own classes
CREATE POLICY "Authenticated users can insert classes"
ON classes
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid()::text IS NOT NULL
);

-- Allow all users to read all classes
CREATE POLICY "Anyone can read classes"
ON classes
FOR SELECT
USING (true);

-- Allow users to update classes they created
CREATE POLICY "Users can update their own classes"
ON classes
FOR UPDATE
USING (
  created_by = auth.email()
)
WITH CHECK (
  created_by = auth.email()
);

-- Allow users to delete classes they created
CREATE POLICY "Users can delete their own classes"
ON classes
FOR DELETE
USING (
  created_by = auth.email()
);
```

#### For other tables (if you have more):

Apply similar policies to other tables. The pattern is:
- **SELECT:** Allow all or authenticated users
- **INSERT:** Allow authenticated users only
- **UPDATE/DELETE:** Allow only the user who created the record

### Step 3: Verify Credentials

After creating the admin user, try logging in with:
- **Email:** `info@sss.com`
- **Password:** `sss@121`

The login modal will appear on page load. Enter these credentials and click "Sign In".

---

## Features

✅ **Login Required:** Users must authenticate before accessing admin features  
✅ **Session Persistence:** Login session is saved in localStorage  
✅ **Logout Option:** Click on the admin profile in the top-right corner to see logout option  
✅ **Fallback Storage:** Even if Supabase has RLS issues, data is automatically saved to localStorage  
✅ **User Email Display:** The logged-in user's email is shown in the admin menu  

---

## Troubleshooting

### "Invalid email or password" error
- Make sure you created the user `info@sss.com` in Supabase Authentication
- Verify the password is exactly `sss@121`

### "row-level security policy" error
- This means RLS policies need to be configured (see Step 2 above)
- Data will still be saved to localStorage as a fallback

### Still can't save to database after setting up RLS
- Make sure the `created_by` column exists in the `classes` table
- If it doesn't exist, run this in SQL Editor:
  ```sql
  ALTER TABLE classes ADD COLUMN created_by TEXT;
  ```

---

## Testing

1. Load the admin portal in your browser
2. You should see the login modal
3. Enter: `info@sss.com` / `sss@121`
4. After login, the portal should load fully
5. Try adding a new class in **Academic > Class Setup**
6. You should see success message and the class should appear in the table

---

## Security Notes

⚠️ **For Production:**
- Change the default password `sss@121` to a strong password
- Use environment variables for sensitive data
- Enable Multi-Factor Authentication (MFA) for admin users
- Consider using OAuth for better security
- Regularly audit who has admin access

⚠️ **Current Setup:**
- Credentials are hardcoded in demo (change for production)
- Session persists in localStorage (consider adding timeout)
- Make sure HTTPS is used in production

---

## Next Steps

1. ✅ Create admin user in Supabase (Steps 1-2 above)
2. ✅ Test login with provided credentials
3. ✅ Verify data saves to both database and localStorage
4. ✅ Configure additional user accounts as needed
5. ✅ Set up similar RLS policies for other tables
