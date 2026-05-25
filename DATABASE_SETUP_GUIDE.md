# Database Setup Guide - Shree Saraswati Secondary School

## Problem
You're seeing errors like: **"Could not find the table 'public.student_credentials' in the schema cache"**

This happens because the SQL tables defined in `setup.sql` have not been created in Supabase yet.

## Solution: Run Setup SQL in Supabase

### Step 1: Open Supabase SQL Editor
1. Go to: https://app.supabase.com
2. Select your project: **Shree Saraswati Secondary School**
3. Click on the **"SQL Editor"** tab in the left sidebar
4. Click **"+ New Query"**

### Step 2: Copy and Run Setup SQL

**IMPORTANT: Run each section separately!**

1. **Copy the contents of `setup.sql`** from your project files
2. **Paste** into the Supabase SQL Editor
3. **Click "Run"** (⌘+Enter or Ctrl+Enter)

**Wait for the query to complete** - you'll see "✓ Success" message

### Step 3: Verify Tables Created

After running setup.sql, verify the tables exist:

1. Go to **"Table Editor"** in Supabase
2. You should see these tables listed:
   - ✓ `students_registry`
   - ✓ `student_credentials` **← This fixes the error**
   - ✓ `teachers_registry`
   - ✓ `teacher_credentials` **← This fixes the teacher error**
   - ✓ `classes`
   - ✓ `fee_payments`
   - ✓ `student_leaves`
   - ✓ `school_timetables`
   - ✓ `school_announcements`
   - ✓ `school_events`
   - ✓ `submitted_results`
   - (and more...)

### Step 4: Create Sample Classes (for Class Dropdown)

If the "Class" dropdown is empty, add some sample classes:

```sql
INSERT INTO public.classes (grade_level, section_name, status) VALUES
('Grade 10', 'Section A', 'Active'),
('Grade 10', 'Section B', 'Active'),
('Grade 9', 'Section A', 'Active'),
('Grade 9', 'Section B', 'Active'),
('Grade 8', 'Section A', 'Active'),
('Grade 8', 'Section B', 'Active'),
('Grade 7', 'Section A', 'Active'),
('Grade 7', 'Section B', 'Active');
```

### Step 5: Refresh Your Application

1. Go back to your admin portal: http://localhost:8000/admin-portal.html (or your deployment URL)
2. **Refresh the page** (F5 or Cmd+R)
3. The "Class" dropdown should now show classes
4. Student and teacher creation should work without errors

---

## Troubleshooting

### "Table already exists" errors
This is fine - it means the table was already created. The `if not exists` clause prevents errors.

### Still getting "schema cache" error?
Try this:
1. **Hard refresh** your browser (Ctrl+Shift+R or Cmd+Shift+R)
2. Close and reopen the admin portal
3. Wait 30 seconds and try again

### Class dropdown still empty?
1. Verify the `classes` table has data (use the Table Editor in Supabase)
2. Check that classes have `status = 'Active'`
3. The dropdown loads from the 'classes' table on page load

### Can't find Supabase SQL Editor?
1. Make sure you're logged into Supabase: https://app.supabase.com
2. Navigate to your project
3. Look for **SQL Editor** in the left sidebar menu

---

## Files Reference

- `setup.sql` - Contains all table definitions (run this in Supabase)
- `admin-portal.html` - Admin dashboard (forms and functions)
- `supabase-client.js` - Database connection and credential functions
- `admission-handler.js` - Admission application handler

## Quick Fix Checklist

- [ ] Opened Supabase SQL Editor
- [ ] Copied all SQL from setup.sql  
- [ ] Ran the SQL query
- [ ] Verified tables appear in Table Editor
- [ ] Inserted sample classes (optional but recommended)
- [ ] Refreshed the admin portal page
- [ ] Student/Teacher creation now works

---

**Need help?** Check the browser console (F12) for detailed error messages.
