-- ====================================================================
-- ADMISSION SYSTEM TABLES
-- Run these statements on DB1: https://ohczlooperjqpyllmabo.supabase.co
-- ====================================================================

-- 1. ADMISSION APPLICATIONS TABLE
-- Stores all admission inquiry submissions
CREATE TABLE IF NOT EXISTS public.admission_applications (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  
  -- Personal Information
  full_name TEXT NOT NULL,
  date_of_birth DATE,
  gender TEXT,
  nationality TEXT,
  religion TEXT,
  blood_group TEXT,
  
  -- Parent/Guardian Information
  father_name TEXT,
  father_email TEXT,
  father_phone TEXT,
  father_occupation TEXT,
  mother_name TEXT,
  mother_email TEXT,
  mother_phone TEXT,
  mother_occupation TEXT,
  
  -- Address Information
  permanent_address TEXT,
  permanent_city TEXT,
  permanent_state TEXT,
  permanent_zip TEXT,
  temporary_address TEXT,
  temporary_city TEXT,
  temporary_state TEXT,
  temporary_zip TEXT,
  
  -- Academic Information
  class_applying_for TEXT,
  previous_school_name TEXT,
  previous_class TEXT,
  previous_percentage TEXT,
  academic_profile TEXT, -- 'Science', 'Management', 'Humanities', etc.
  
  -- Status & Metadata
  application_status TEXT DEFAULT 'pending', -- pending, shortlisted, rejected, admitted
  submitted_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  admission_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  CONSTRAINT application_full_name_check CHECK (CHAR_LENGTH(TRIM(full_name)) > 0)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_admission_status ON public.admission_applications(application_status);
CREATE INDEX IF NOT EXISTS idx_admission_submitted_date ON public.admission_applications(submitted_date DESC);
CREATE INDEX IF NOT EXISTS idx_admission_class ON public.admission_applications(class_applying_for);

-- 2. ADMISSION DOCUMENTS TABLE
-- Stores document metadata and references to files in storage
CREATE TABLE IF NOT EXISTS public.admission_documents (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  
  -- Foreign Key Reference
  application_id BIGINT NOT NULL,
  
  -- Document Information
  document_type TEXT NOT NULL, -- birth_certificate, transfer_certificate, previous_marks, character_certificate, photo, etc.
  document_name TEXT NOT NULL,
  document_url TEXT NOT NULL, -- Path to file in Supabase Storage
  file_size INTEGER, -- Size in bytes
  file_type TEXT, -- pdf, jpg, png, doc, docx, etc.
  
  -- Document Metadata
  uploaded_by TEXT,
  upload_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  document_status TEXT DEFAULT 'active', -- active, archived, verified
  verification_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Foreign Key Constraint
  CONSTRAINT fk_admission_documents_application FOREIGN KEY (application_id) 
    REFERENCES public.admission_applications(id) ON DELETE CASCADE
);

-- Index for faster document queries
CREATE INDEX IF NOT EXISTS idx_admission_documents_app_id ON public.admission_documents(application_id);
CREATE INDEX IF NOT EXISTS idx_admission_documents_type ON public.admission_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_admission_documents_status ON public.admission_documents(document_status);

-- 3. ADMISSION REQUIREMENTS TABLE
-- Defines what documents are required for each class
CREATE TABLE IF NOT EXISTS public.admission_requirements (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  
  class_name TEXT NOT NULL UNIQUE,
  
  -- Document Requirements (comma-separated or JSON format)
  required_documents TEXT NOT NULL, -- birth_certificate,transfer_certificate,previous_marks,photo,character_certificate
  
  -- Class Details
  total_seats INTEGER,
  available_seats INTEGER,
  age_min INTEGER,
  age_max INTEGER,
  description TEXT,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. ADMISSION INTERVIEW SCHEDULE TABLE
-- For tracking interview rounds and results
CREATE TABLE IF NOT EXISTS public.admission_interviews (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  
  application_id BIGINT NOT NULL,
  
  -- Interview Details
  interview_date DATE,
  interview_time TIME,
  interview_round INTEGER DEFAULT 1, -- 1, 2, 3, etc.
  interview_status TEXT DEFAULT 'scheduled', -- scheduled, completed, cancelled, no_show
  
  -- Results & Notes
  interviewer_name TEXT,
  interview_notes TEXT,
  interview_rating INTEGER, -- 1-5 scale
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  CONSTRAINT fk_admission_interviews_application FOREIGN KEY (application_id) 
    REFERENCES public.admission_applications(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_admission_interviews_app_id ON public.admission_interviews(application_id);
CREATE INDEX IF NOT EXISTS idx_admission_interviews_date ON public.admission_interviews(interview_date);
CREATE INDEX IF NOT EXISTS idx_admission_interviews_status ON public.admission_interviews(interview_status);

-- ====================================================================
-- SAMPLE DATA FOR ADMISSION REQUIREMENTS
-- ====================================================================

INSERT INTO public.admission_requirements (class_name, required_documents, total_seats, available_seats, age_min, age_max, description) 
VALUES 
  ('Class 1', 'birth_certificate,transfer_certificate,photo,character_certificate', 40, 35, 5, 6, 'Foundation Year'),
  ('Class 6', 'birth_certificate,transfer_certificate,previous_marks,photo,character_certificate', 50, 42, 10, 12, 'Middle School Entry'),
  ('Class 9', 'birth_certificate,transfer_certificate,previous_marks,photo,character_certificate', 60, 50, 13, 15, 'Secondary School Entry'),
  ('Class 11 - Science', 'birth_certificate,transfer_certificate,previous_marks,photo,character_certificate', 45, 38, 15, 17, 'Senior Secondary - Science'),
  ('Class 11 - Commerce', 'birth_certificate,transfer_certificate,previous_marks,photo,character_certificate', 40, 35, 15, 17, 'Senior Secondary - Commerce'),
  ('Class 11 - Humanities', 'birth_certificate,transfer_certificate,previous_marks,photo,character_certificate', 35, 30, 15, 17, 'Senior Secondary - Humanities')
ON CONFLICT DO NOTHING;

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

-- Enable RLS on admission_applications
ALTER TABLE public.admission_applications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view all applications" ON public.admission_applications;
DROP POLICY IF EXISTS "Anyone can submit applications" ON public.admission_applications;
DROP POLICY IF EXISTS "Admins can update applications" ON public.admission_applications;
CREATE POLICY "Allow all public access" ON public.admission_applications FOR ALL USING (true) WITH CHECK (true);

-- Enable RLS on admission_documents
ALTER TABLE public.admission_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "View associated documents" ON public.admission_documents;
DROP POLICY IF EXISTS "Anyone can upload documents" ON public.admission_documents;
CREATE POLICY "Allow all public access" ON public.admission_documents FOR ALL USING (true) WITH CHECK (true);

-- Enable RLS on admission_requirements
ALTER TABLE public.admission_requirements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all public access" ON public.admission_requirements;
CREATE POLICY "Allow all public access" ON public.admission_requirements FOR ALL USING (true) WITH CHECK (true);

-- Enable RLS on admission_interviews
ALTER TABLE public.admission_interviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all public access" ON public.admission_interviews;
CREATE POLICY "Allow all public access" ON public.admission_interviews FOR ALL USING (true) WITH CHECK (true);

-- ====================================================================
-- HELPFUL VIEWS FOR ADMIN QUERIES
-- ====================================================================

-- View: Admission Summary (for admin dashboard)
CREATE OR REPLACE VIEW public.admission_summary AS
SELECT 
  COUNT(*) as total_applications,
  SUM(CASE WHEN application_status = 'pending' THEN 1 ELSE 0 END) as pending_count,
  SUM(CASE WHEN application_status = 'shortlisted' THEN 1 ELSE 0 END) as shortlisted_count,
  SUM(CASE WHEN application_status = 'admitted' THEN 1 ELSE 0 END) as admitted_count,
  SUM(CASE WHEN application_status = 'rejected' THEN 1 ELSE 0 END) as rejected_count
FROM public.admission_applications;

-- View: Applications with Document Count
CREATE OR REPLACE VIEW public.applications_with_documents AS
SELECT 
  a.id,
  a.full_name,
  a.date_of_birth,
  a.class_applying_for,
  a.application_status,
  a.submitted_date,
  COUNT(d.id) as document_count,
  STRING_AGG(d.document_type, ', ') as document_types
FROM public.admission_applications a
LEFT JOIN public.admission_documents d ON a.id = d.application_id
GROUP BY a.id, a.full_name, a.date_of_birth, a.class_applying_for, a.application_status, a.submitted_date;

-- ====================================================================
-- STORAGE BUCKET FOR ADMISSION DOCUMENTS (Manual Setup Required)
-- In Supabase Dashboard:
-- 1. Go to Storage
-- 2. Create bucket named 'admission-documents'
-- 3. Set Policy: Allow public read on all files
-- 4. Set Policy: Allow authenticated uploads
-- 5. Path pattern: application_id/document_type/filename
-- ====================================================================

-- ====================================================================
-- USEFUL FUNCTIONS FOR TRIGGERS (Optional)
-- ====================================================================

-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_admission_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for admission_applications
DROP TRIGGER IF EXISTS update_admission_applications_timestamp ON public.admission_applications;
CREATE TRIGGER update_admission_applications_timestamp
BEFORE UPDATE ON public.admission_applications
FOR EACH ROW
EXECUTE FUNCTION update_admission_timestamp();

-- Trigger for admission_documents
DROP TRIGGER IF EXISTS update_admission_documents_timestamp ON public.admission_documents;
CREATE TRIGGER update_admission_documents_timestamp
BEFORE UPDATE ON public.admission_documents
FOR EACH ROW
EXECUTE FUNCTION update_admission_timestamp();

-- Trigger for admission_interviews
DROP TRIGGER IF EXISTS update_admission_interviews_timestamp ON public.admission_interviews;
CREATE TRIGGER update_admission_interviews_timestamp
BEFORE UPDATE ON public.admission_interviews
FOR EACH ROW
EXECUTE FUNCTION update_admission_timestamp();
