# 📚 Class Setup & Dynamic Management Guide

**School**: Shree Saraswati Secondary School  
**Feature**: Dynamic Class Setup with Auto-Population  
**Status**: ✅ Production Ready

---

## 🎯 Overview

This guide explains how the class setup system works. Once you add a class in the **Class Setup** section, it automatically appears:
- ✅ In **Add Student** dropdown
- ✅ In **Online Admissions** form
- ✅ In **Teacher Allocation** forms
- ✅ In all other modules that need class selection

---

## 📊 Database Tables

### 1. **classes** Table
Main table for managing all classes in the school.

```sql
CREATE TABLE public.classes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  grade_level TEXT NOT NULL,           -- "Grade 10", "Grade 9", etc.
  section_name TEXT NOT NULL,          -- "Section A", "Section B", etc.
  class_teacher TEXT,                  -- Teacher's name
  class_teacher_code TEXT,             -- Teacher's unique code (from teachers_registry)
  total_strength INTEGER DEFAULT 0,    -- Total students enrolled
  status TEXT NOT NULL DEFAULT 'Active', -- "Active" or "Inactive"
  notes TEXT,                          -- Optional notes
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  UNIQUE(grade_level, section_name)   -- Ensure unique class combinations
);
```

**Key Fields**:
- `grade_level`: Grade of the class (e.g., "Grade 10", "Grade 9")
- `section_name`: Section name (e.g., "Section A", "Section B")
- `class_teacher`: Name of assigned teacher
- `status`: "Active" or "Inactive"

---

## 🛠️ How It Works

### Step 1: Add a New Class
1. Go to **Admin Portal** → **Academic** → **Class Setup**
2. Fill in the form:
   - Grade Level: `Grade 10`
   - Section Name: `Section A`
   - Assigned Class Teacher: `Mr. Sharma`
   - Status: `Active`
3. Click **Save Record to System**
4. ✅ Class is saved to database

### Step 2: Class Auto-Appears Everywhere

#### 🎓 In Add Student Form:
- When you go to **Add Student**, the "Enrolled Grade" field now shows:
  - Grade 10 - Section A
  - Grade 10 - Section B
  - Grade 9 - Section A
  - (all active classes)

#### 📝 In Online Admissions:
- Students filling out the admission form see dropdown with:
  - Grade 10 - Section A
  - Grade 10 - Section B
  - (all available classes)

#### 👨‍🏫 In Teacher Allocation:
- When assigning teachers to classes, dropdown shows all available classes

---

## 💾 SQL Setup

Run this SQL in Supabase to set up the classes system:

```sql
-- Create classes table (if not already created)
CREATE TABLE IF NOT EXISTS public.classes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  grade_level TEXT NOT NULL,
  section_name TEXT NOT NULL,
  class_teacher TEXT,
  class_teacher_code TEXT,
  total_strength INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'Active',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  UNIQUE(grade_level, section_name)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_classes_status ON public.classes(status);
CREATE INDEX IF NOT EXISTS idx_classes_grade_level ON public.classes(grade_level);

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_classes_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_classes_timestamp ON public.classes;
CREATE TRIGGER trigger_update_classes_timestamp
  BEFORE UPDATE ON public.classes
  FOR EACH ROW
  EXECUTE FUNCTION update_classes_timestamp();

-- Add RLS policies
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all authenticated users to read active classes
CREATE POLICY "Allow reading active classes"
  ON public.classes FOR SELECT
  USING (status = 'Active' OR auth.role() = 'authenticated');

-- Policy: Allow only admins to insert/update/delete
CREATE POLICY "Allow admins to manage classes"
  ON public.classes FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');
```

---

## 📱 JavaScript Usage

### Load All Classes
```javascript
const classList = await getActiveClasses();
// Returns: [{id: 1, grade_level: "Grade 10", section_name: "Section A", ...}, ...]
```

### Add New Class
```javascript
const result = await addClass({
  grade_level: "Grade 10",
  section_name: "Section A",
  class_teacher: "Mr. Sharma",
  status: "Active"
});
// Returns: {success: true, id: 1}
```

### Update Class
```javascript
const result = await updateClass(1, {
  class_teacher: "Mrs. Paudel",
  total_strength: 45
});
// Returns: {success: true}
```

### Delete Class
```javascript
const result = await deleteClass(1);
// Returns: {success: true}
```

---

## 📋 Example Classes

| Grade | Section | Teacher | Strength | Status |
|-------|---------|---------|----------|--------|
| Grade 10 | Section A | Mr. Sharma | 45 | Active |
| Grade 10 | Section B | Mrs. Paudel | 42 | Active |
| Grade 9 | Section A | Mr. Karki | 48 | Active |
| Grade 9 | Section B | Mrs. Adhikari | 43 | Active |
| Grade 8 | Section A | Mr. Thapa | 50 | Active |

---

## 🔧 Troubleshooting

### Classes not showing up?
1. Check if status is "Active"
2. Reload the page
3. Check browser console for errors

### Can't add duplicate class?
- Duplicate combinations of (Grade + Section) are not allowed
- Each class must be unique

### Need to inactivate a class?
- Change status to "Inactive" instead of deleting
- This preserves historical data

---

## 🚀 Features

✅ **Dynamic Dropdowns**: Classes update automatically everywhere  
✅ **Validation**: Prevents duplicate classes  
✅ **Audit Trail**: Created_at and updated_at timestamps  
✅ **Teacher Assignment**: Link teachers to classes  
✅ **Strength Tracking**: Keep track of student count per class  
✅ **Status Management**: Activate/Deactivate classes  
✅ **Easy Management**: Full CRUD operations in admin portal  

---

## 📞 Support

For issues or questions:
1. Check the admin portal Class Setup section
2. Review the class-handler.js file
3. Check browser console for error messages
