-- ════════════════════════════════════════════════════════════════════════════
-- SCHOOL DOCUMENTS MANAGEMENT SYSTEM - DATABASE SETUP (FIXED V2)
-- ════════════════════════════════════════════════════════════════════════════
-- This SQL script creates/fixes the necessary tables for documents with proper column handling

-- ────────────────────────────────────────────────────────────────────────────
-- 1. DROP EXISTING TABLE (if needed to reset)
-- ────────────────────────────────────────────────────────────────────────────
-- Uncomment the line below only if you want to completely reset the documents table
-- DROP TABLE IF EXISTS public.school_documents CASCADE;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. CREATE DOCUMENTS TABLE (if not exists)
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.school_documents (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  file_name TEXT DEFAULT 'document',
  file_url TEXT NOT NULL,
  file_size BIGINT DEFAULT 0,
  file_type TEXT DEFAULT 'application/octet-stream',
  icon_type TEXT DEFAULT 'document',
  uploaded_by TEXT DEFAULT 'Admin',
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  view_count INT DEFAULT 0,
  download_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT category_valid CHECK (category IN ('Syllabus', 'Admission', 'Calendar', 'Guidelines', 'Notes', 'Announcements', 'Reports'))
);

-- ────────────────────────────────────────────────────────────────────────────
-- 3. ADD MISSING COLUMNS (if table already exists)
-- ────────────────────────────────────────────────────────────────────────────

-- Add file_name if not exists (with DEFAULT to avoid NOT NULL constraint issues)
ALTER TABLE public.school_documents
  ADD COLUMN IF NOT EXISTS file_name TEXT DEFAULT 'document';

-- Add other columns if missing
ALTER TABLE public.school_documents
  ADD COLUMN IF NOT EXISTS file_size BIGINT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS file_type TEXT DEFAULT 'application/octet-stream',
  ADD COLUMN IF NOT EXISTS icon_type TEXT DEFAULT 'document',
  ADD COLUMN IF NOT EXISTS view_count INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS download_count INT DEFAULT 0;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. CREATE INDEXES
-- ────────────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_documents_category ON public.school_documents(category);
CREATE INDEX IF NOT EXISTS idx_documents_is_active ON public.school_documents(is_active);
CREATE INDEX IF NOT EXISTS idx_documents_display_order ON public.school_documents(display_order DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON public.school_documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_by ON public.school_documents(uploaded_by);

-- ────────────────────────────────────────────────────────────────────────────
-- 5. CREATE TRIGGER FOR UPDATED_AT
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_documents_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_documents_timestamp ON public.school_documents;

CREATE TRIGGER trigger_update_documents_timestamp
BEFORE UPDATE ON public.school_documents
FOR EACH ROW
EXECUTE FUNCTION update_documents_timestamp();

-- ────────────────────────────────────────────────────────────────────────────
-- 6. CREATE/UPDATE VIEW FOR PUBLIC DOCUMENTS
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW public.public_documents AS
SELECT 
  id,
  title,
  description,
  category,
  file_name,
  file_url,
  file_size,
  file_type,
  icon_type,
  display_order,
  view_count,
  download_count,
  created_at
FROM public.school_documents
WHERE is_active = TRUE
ORDER BY display_order DESC, created_at DESC;

-- ────────────────────────────────────────────────────────────────────────────
-- 7. ENABLE ROW LEVEL SECURITY
-- ────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.school_documents ENABLE ROW LEVEL SECURITY;

-- ────────────────────────────────────────────────────────────────────────────
-- 8. CREATE RLS POLICIES
-- ────────────────────────────────────────────────────────────────────────────

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow public to read active documents" ON public.school_documents;
DROP POLICY IF EXISTS "Allow authenticated admins to insert documents" ON public.school_documents;
DROP POLICY IF EXISTS "Allow authenticated admins to update documents" ON public.school_documents;
DROP POLICY IF EXISTS "Allow authenticated admins to delete documents" ON public.school_documents;

-- Allow anyone to read active documents (public access for viewing/downloading)
CREATE POLICY "Allow public to read active documents"
ON public.school_documents
FOR SELECT
USING (is_active = TRUE);

-- Allow authenticated admins to insert documents
CREATE POLICY "Allow authenticated admins to insert documents"
ON public.school_documents
FOR INSERT
WITH CHECK (auth.uid()::text IS NOT NULL);

-- Allow authenticated admins to update documents
CREATE POLICY "Allow authenticated admins to update documents"
ON public.school_documents
FOR UPDATE
USING (auth.uid()::text IS NOT NULL)
WITH CHECK (auth.uid()::text IS NOT NULL);

-- Allow authenticated admins to delete documents
CREATE POLICY "Allow authenticated admins to delete documents"
ON public.school_documents
FOR DELETE
USING (auth.uid()::text IS NOT NULL);

-- ────────────────────────────────────────────────────────────────────────────
-- 9. SAMPLE DATA (Optional - for testing)
-- ────────────────────────────────────────────────────────────────────────────

-- Uncomment to add sample documents for testing:

/*
INSERT INTO public.school_documents 
(title, description, category, file_name, file_url, file_type, icon_type, display_order, is_active, uploaded_by)
VALUES 
('Class 9-12 Engineering Syllabus', 'Complete syllabus for engineering stream classes 9 to 12', 'Syllabus', 'engineering_syllabus.pdf', 'https://example.com/engineering_syllabus.pdf', 'application/pdf', 'syllabus', 1, TRUE, 'Admin'),
('Admission Form 2083', 'Official admission application form', 'Admission', 'admission_form_2083.pdf', 'https://example.com/admission_form.pdf', 'application/pdf', 'admission', 2, TRUE, 'Admin'),
('Academic Calendar 2083', 'School academic calendar with holidays', 'Calendar', 'academic_calendar_2083.pdf', 'https://example.com/calendar.pdf', 'application/pdf', 'calendar', 3, TRUE, 'Admin');
*/

-- ────────────────────────────────────────────────────────────────────────────
-- 10. GRANT PERMISSIONS
-- ────────────────────────────────────────────────────────────────────────────

GRANT SELECT ON public.school_documents TO anon;
GRANT SELECT ON public.school_documents TO authenticated;
GRANT ALL ON public.school_documents TO authenticated;
GRANT SELECT ON public.public_documents TO anon;
GRANT SELECT ON public.public_documents TO authenticated;

-- ════════════════════════════════════════════════════════════════════════════
-- End of Documents Setup Script
-- ════════════════════════════════════════════════════════════════════════════
