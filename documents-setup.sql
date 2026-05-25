-- ════════════════════════════════════════════════════════════════════════════
-- SCHOOL DOCUMENTS MANAGEMENT SYSTEM - DATABASE SETUP
-- ════════════════════════════════════════════════════════════════════════════
-- This SQL script creates the necessary tables and functions for managing
-- school documents including file uploads, categorization, and public access.

-- ────────────────────────────────────────────────────────────────────────────
-- 1. CREATE DOCUMENTS TABLE
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.school_documents (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_size BIGINT, -- File size in bytes
  file_type TEXT, -- MIME type: application/pdf, image/png, etc.
  icon_type TEXT DEFAULT 'document', -- document, syllabus, calendar, admission, pdf, image
  uploaded_by TEXT DEFAULT 'Admin', -- Who uploaded: Admin or Teacher
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  view_count INT DEFAULT 0,
  download_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT category_valid CHECK (category IN ('Syllabus', 'Admission', 'Calendar', 'Guidelines', 'Notes', 'Announcements', 'Reports'))
);

-- ────────────────────────────────────────────────────────────────────────────
-- 2. CREATE INDEXES
-- ────────────────────────────────────────────────────────────────────────────

CREATE INDEX idx_documents_category ON public.school_documents(category);
CREATE INDEX idx_documents_is_active ON public.school_documents(is_active);
CREATE INDEX idx_documents_display_order ON public.school_documents(display_order DESC, created_at DESC);
CREATE INDEX idx_documents_created_at ON public.school_documents(created_at DESC);
CREATE INDEX idx_documents_uploaded_by ON public.school_documents(uploaded_by);

-- ────────────────────────────────────────────────────────────────────────────
-- 3. CREATE TRIGGER FOR UPDATED_AT
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
-- 4. CREATE VIEW FOR PUBLIC DOCUMENTS
-- ────────────────────────────────────────────────────────────────────────────
-- This view shows only active documents ordered by display priority

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
-- 5. CREATE ROW LEVEL SECURITY POLICIES
-- ────────────────────────────────────────────────────────────────────────────

-- Enable RLS on the table
ALTER TABLE public.school_documents ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read all active documents
CREATE POLICY "Allow authenticated users to read active documents"
ON public.school_documents
FOR SELECT
USING (is_active = TRUE OR auth.uid()::text IS NOT NULL);

-- Policy: Allow authenticated users (admins) to insert documents
CREATE POLICY "Allow authenticated users to insert documents"
ON public.school_documents
FOR INSERT
WITH CHECK (auth.uid()::text IS NOT NULL);

-- Policy: Allow authenticated users (admins) to update their own documents
CREATE POLICY "Allow authenticated users to update documents"
ON public.school_documents
FOR UPDATE
USING (auth.uid()::text IS NOT NULL);

-- Policy: Allow authenticated users (admins) to delete documents
CREATE POLICY "Allow authenticated users to delete documents"
ON public.school_documents
FOR DELETE
USING (auth.uid()::text IS NOT NULL);

-- ────────────────────────────────────────────────────────────────────────────
-- 6. CREATE STORAGE BUCKET (For File Uploads)
-- ────────────────────────────────────────────────────────────────────────────
-- Note: This needs to be done through Supabase Dashboard -> Storage
-- Bucket name: school-documents
-- Make it public so files can be downloaded without authentication

-- Manual Setup Required:
-- 1. Go to Supabase Dashboard
-- 2. Click "Storage" in sidebar
-- 3. Create new bucket named "school-documents"
-- 4. Make bucket PUBLIC
-- 5. Go to Policies tab and add:
--    - Allow public read access for SELECT
--    - Allow authenticated INSERT/UPDATE/DELETE

-- ────────────────────────────────────────────────────────────────────────────
-- 7. SAMPLE DATA (OPTIONAL - Remove after testing)
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO public.school_documents (
  title, 
  description, 
  category, 
  file_name, 
  file_url, 
  file_type, 
  icon_type, 
  uploaded_by, 
  display_order, 
  is_active
) VALUES 
(
  'Admission Application Form 2083',
  'Official admission application form required during registration.',
  'Admission',
  'admission_form_2083.pdf',
  'https://example-bucket.supabase.co/school-documents/admission_form_2083.pdf',
  'application/pdf',
  'admission',
  'Admin',
  10,
  TRUE
),
(
  'Computer Engineering Syllabus Classes 9-12',
  'Complete curriculum index for Computer Engineering stream.',
  'Syllabus',
  'engineering_syllabus.pdf',
  'https://example-bucket.supabase.co/school-documents/engineering_syllabus.pdf',
  'application/pdf',
  'syllabus',
  'Admin',
  9,
  TRUE
),
(
  'Academic Calendar 2083',
  'Yearly planner with vacations, festivals, and examination dates.',
  'Calendar',
  'academic_calendar_2083.pdf',
  'https://example-bucket.supabase.co/school-documents/academic_calendar_2083.pdf',
  'application/pdf',
  'calendar',
  'Admin',
  8,
  TRUE
),
(
  'Admission Fees Charter',
  'Complete fee details, scholarship guidelines, and quotas.',
  'Guidelines',
  'admission_fees_2083.pdf',
  'https://example-bucket.supabase.co/school-documents/admission_fees_2083.pdf',
  'application/pdf',
  'document',
  'Admin',
  7,
  TRUE
);

-- ════════════════════════════════════════════════════════════════════════════
-- END OF SETUP SCRIPT
-- ════════════════════════════════════════════════════════════════════════════
