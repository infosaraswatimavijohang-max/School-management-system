-- ====================================================================
-- CLASS SETUP & DYNAMIC MANAGEMENT SQL SCHEMA
-- Shree Saraswati Secondary School
-- ====================================================================

-- Run this on your Supabase Database (DB1)
-- URL: https://ohczlooperjqpyllmabo.supabase.co

-- ════════════════════════════════════════════════════════════════════
-- PART 1: CREATE CLASSES TABLE
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.classes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  grade_level TEXT NOT NULL,           -- e.g., "Grade 10", "Grade 9"
  section_name TEXT,                   -- e.g., "Section A", "Section B" (Optional)
  class_teacher TEXT,                  -- Name of the class teacher (Optional)
  class_teacher_code TEXT,             -- Reference to teachers_registry code (Optional)
  total_strength INTEGER DEFAULT 0,    -- Number of students in class
  status TEXT NOT NULL DEFAULT 'Active', -- 'Active' or 'Inactive'
  notes TEXT,                          -- Optional notes
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Ensure each class combination is unique (when section_name is provided)
  UNIQUE(grade_level, section_name)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_classes_status ON public.classes(status);
CREATE INDEX IF NOT EXISTS idx_classes_grade_level ON public.classes(grade_level);
CREATE INDEX IF NOT EXISTS idx_classes_section ON public.classes(section_name);

-- ════════════════════════════════════════════════════════════════════
-- PART 2: AUTO-UPDATE TIMESTAMP TRIGGER
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_classes_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_classes_timestamp ON public.classes;
CREATE TRIGGER trigger_update_classes_timestamp
  BEFORE UPDATE ON public.classes
  FOR EACH ROW
  EXECUTE FUNCTION update_classes_timestamp();

-- ════════════════════════════════════════════════════════════════════
-- PART 3: UPDATE RELATED TABLES (IF NEEDED)
-- ════════════════════════════════════════════════════════════════════

-- Update students_registry to ensure class names match format
-- This is optional - if you want to enforce consistency
-- ALTER TABLE public.students_registry 
-- ADD CONSTRAINT fk_student_class
-- FOREIGN KEY (class) REFERENCES public.classes(grade_level) ON DELETE RESTRICT;

-- ════════════════════════════════════════════════════════════════════
-- PART 4: ROW LEVEL SECURITY (RLS) POLICIES
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- Policy: Allow reading of classes
DROP POLICY IF EXISTS "Allow reading classes" ON public.classes;
CREATE POLICY "Allow reading classes"
  ON public.classes FOR SELECT
  TO authenticated
  USING (TRUE);

-- Policy: Allow admins to insert classes
DROP POLICY IF EXISTS "Allow admins to insert classes" ON public.classes;
CREATE POLICY "Allow admins to insert classes"
  ON public.classes FOR INSERT
  TO authenticated
  WITH CHECK (TRUE);

-- Policy: Allow admins to update classes
DROP POLICY IF EXISTS "Allow admins to update classes" ON public.classes;
CREATE POLICY "Allow admins to update classes"
  ON public.classes FOR UPDATE
  TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

-- Policy: Allow admins to delete classes
DROP POLICY IF EXISTS "Allow admins to delete classes" ON public.classes;
CREATE POLICY "Allow admins to delete classes"
  ON public.classes FOR DELETE
  TO authenticated
  USING (TRUE);

-- ════════════════════════════════════════════════════════════════════
-- PART 5: SAMPLE DATA (OPTIONAL - Add after schema is created)
-- ════════════════════════════════════════════════════════════════════

-- Insert sample classes
INSERT INTO public.classes (grade_level, section_name, class_teacher, status, total_strength)
VALUES
  ('Grade 10', 'Section A', 'Mr. Sharma', 'Active', 45),
  ('Grade 10', 'Section B', 'Mrs. Paudel', 'Active', 42),
  ('Grade 9', 'Section A', 'Mr. Karki', 'Active', 48),
  ('Grade 9', 'Section B', 'Mrs. Adhikari', 'Active', 43),
  ('Grade 8', 'Section A', 'Mr. Thapa', 'Active', 50),
  ('Grade 8', 'Section B', 'Mrs. Dahal', 'Active', 46)
ON CONFLICT (grade_level, section_name) DO NOTHING;

-- ════════════════════════════════════════════════════════════════════
-- PART 6: QUERY EXAMPLES
-- ════════════════════════════════════════════════════════════════════

-- Get all active classes
-- SELECT * FROM public.classes WHERE status = 'Active' ORDER BY grade_level, section_name;

-- Get classes for a specific grade
-- SELECT * FROM public.classes WHERE grade_level = 'Grade 10' AND status = 'Active';

-- Get class statistics
-- SELECT 
--   grade_level,
--   COUNT(*) as total_sections,
--   SUM(total_strength) as total_students
-- FROM public.classes
-- WHERE status = 'Active'
-- GROUP BY grade_level
-- ORDER BY grade_level DESC;

-- Get classes with teacher assignments
-- SELECT 
--   grade_level,
--   section_name,
--   class_teacher,
--   total_strength,
--   status
-- FROM public.classes
-- WHERE status = 'Active'
-- ORDER BY grade_level, section_name;

-- ════════════════════════════════════════════════════════════════════
-- PART 7: VIEWS (OPTIONAL)
-- ════════════════════════════════════════════════════════════════════

-- Create view for dashboard statistics
CREATE OR REPLACE VIEW public.class_statistics AS
SELECT
  grade_level,
  COUNT(*) as total_sections,
  SUM(COALESCE(total_strength, 0)) as total_strength,
  COUNT(CASE WHEN class_teacher IS NOT NULL THEN 1 END) as sections_with_teacher
FROM public.classes
WHERE status = 'Active'
GROUP BY grade_level
ORDER BY grade_level DESC;

-- ════════════════════════════════════════════════════════════════════
-- PART 8: INTEGRATION WITH STUDENTS TABLE
-- ════════════════════════════════════════════════════════════════════

-- Update students_registry table to link with classes
-- This ensures data integrity

-- Option 1: Add foreign key constraint (requires migration)
-- ALTER TABLE public.students_registry
-- ADD CONSTRAINT fk_student_class
-- FOREIGN KEY (class) REFERENCES public.classes(grade_level, section_name);

-- Option 2: Create a trigger to validate student class
CREATE OR REPLACE FUNCTION validate_student_class()
RETURNS TRIGGER AS $$
DECLARE
  class_exists BOOLEAN;
BEGIN
  -- Check if the class exists (optional - only if you want to enforce)
  -- SELECT EXISTS(
  --   SELECT 1 FROM public.classes 
  --   WHERE (grade_level || ' - ' || section_name) = NEW.class 
  --   AND status = 'Active'
  -- ) INTO class_exists;
  -- 
  -- IF NOT class_exists THEN
  --   RAISE EXCEPTION 'Invalid class: %', NEW.class;
  -- END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_student_class ON public.students_registry;
-- CREATE TRIGGER trigger_validate_student_class
--   BEFORE INSERT OR UPDATE ON public.students_registry
--   FOR EACH ROW
--   EXECUTE FUNCTION validate_student_class();

-- ════════════════════════════════════════════════════════════════════
-- PART 9: MAINTENANCE QUERIES
-- ════════════════════════════════════════════════════════════════════

-- Update class strength based on students registry
-- (Run periodically to keep count accurate)
-- UPDATE public.classes c
-- SET total_strength = (
--   SELECT COUNT(*)
--   FROM public.students_registry s
--   WHERE s.class = (c.grade_level || ' - ' || c.section_name)
--   AND s.status = 'Active'
-- )
-- WHERE status = 'Active';

-- Deactivate classes with no students (if desired)
-- UPDATE public.classes
-- SET status = 'Inactive'
-- WHERE total_strength = 0
-- AND status = 'Active'
-- AND updated_at < now() - INTERVAL '1 month';

-- ════════════════════════════════════════════════════════════════════
-- DONE! Classes table is ready to use in the system.
-- Classes will now appear automatically in:
-- ✅ Admin Portal - Class Setup section
-- ✅ Student addition forms
-- ✅ Online Admissions form
-- ✅ Teacher allocation forms
-- ════════════════════════════════════════════════════════════════════
