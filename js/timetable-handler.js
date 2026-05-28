// ====================================================================
// TIMETABLE MANAGEMENT HANDLER - Dynamic Timetable & Teacher Assignments
// ====================================================================

class TimetableHandler {
  constructor() {
    this.supabaseDb = window.supabaseDb;
    this.classesCache = null;
    this.teachersCache = null;
    this.subjectsCache = null;
    this.cacheDuration = 5 * 60 * 1000; // 5 minutes
    this.lastCacheUpdate = 0;
  }

  /**
   * Get all teachers grouped by category (with unique names)
   */
  async getTeachersByCategory() {
    try {
      if (!this.supabaseDb) {
        console.error("Supabase database not initialized");
        return {};
      }

      // Check cache
      if (this.teachersCache && (Date.now() - this.lastCacheUpdate < this.cacheDuration)) {
        return this.teachersCache;
      }

      const { data, error } = await this.supabaseDb
        .from("teachers_registry")
        .select("code, name, subject, status")
        .eq("status", "Active")
        .order("subject", { ascending: true })
        .order("name", { ascending: true });

      if (error) {
        console.error("Error loading teachers:", error);
        return {};
      }

      // Group teachers by subject (category)
      const groupedTeachers = {};
      data.forEach(teacher => {
        const category = teacher.subject || "Unassigned";
        if (!groupedTeachers[category]) {
          groupedTeachers[category] = [];
        }
        groupedTeachers[category].push({
          code: teacher.code,
          name: teacher.name,
          subject: teacher.subject,
          display: teacher.name
        });
      });

      // Update cache
      this.teachersCache = groupedTeachers;
      this.lastCacheUpdate = Date.now();

      return groupedTeachers;
    } catch (error) {
      console.error("Exception in getTeachersByCategory:", error);
      return {};
    }
  }

  /**
   * Get all classes grouped by grade level (category)
   */
  async getClassesByGradeLevel() {
    try {
      if (!this.supabaseDb) {
        console.error("Supabase database not initialized");
        return {};
      }

      const { data, error } = await this.supabaseDb
        .from("classes")
        .select("*")
        .eq("status", "Active")
        .order("grade_level", { ascending: true })
        .order("section_name", { ascending: true });

      if (error) {
        console.error("Error loading classes:", error);
        return {};
      }

      // Group classes by grade level
      const groupedClasses = {};
      data.forEach(cls => {
        const gradeLevel = cls.grade_level || "Unassigned";
        if (!groupedClasses[gradeLevel]) {
          groupedClasses[gradeLevel] = [];
        }
        groupedClasses[gradeLevel].push({
          id: cls.id,
          display: `${cls.section_name || 'Default'}`,
          grade_level: cls.grade_level,
          section_name: cls.section_name,
          class_teacher: cls.class_teacher || "Unassigned",
          raw: cls
        });
      });

      return groupedClasses;
    } catch (error) {
      console.error("Exception in getClassesByGradeLevel:", error);
      return {};
    }
  }

  /**
   * Get all active subjects grouped by category
   */
  async getSubjectsByCategory() {
    try {
      if (!this.supabaseDb) {
        console.error("Supabase database not initialized");
        return {};
      }

      const { data, error } = await this.supabaseDb
        .from("subjects")
        .select("*")
        .eq("status", "Active")
        .order("category", { ascending: true })
        .order("subject_name", { ascending: true });

      if (error) {
        console.error("Error loading subjects:", error);
        return {};
      }

      // Group subjects by category
      const groupedSubjects = {};
      data.forEach(subject => {
        const category = subject.category || "Uncategorized";
        if (!groupedSubjects[category]) {
          groupedSubjects[category] = [];
        }
        groupedSubjects[category].push({
          id: subject.id,
          display: subject.subject_name,
          subject_name: subject.subject_name,
          subject_code: subject.subject_code,
          category: subject.category,
          raw: subject
        });
      });

      return groupedSubjects;
    } catch (error) {
      console.error("Exception in getSubjectsByCategory:", error);
      return {};
    }
  }

  /**
   * Get all timetable entries for display
   */
  async getTimetableEntries(filters = {}) {
    try {
      if (!this.supabaseDb) {
        console.error("Supabase database not initialized");
        return [];
      }

      let query = this.supabaseDb
        .from("class_timetable")
        .select("*")
        .eq("status", "Active");

      if (filters.class_id) {
        query = query.eq("class_id", filters.class_id);
      }
      if (filters.teacher_code) {
        query = query.eq("teacher_code", filters.teacher_code);
      }
      if (filters.day) {
        query = query.eq("day_of_week", filters.day);
      }

      const { data, error } = await query.order("day_of_week", { ascending: true });

      if (error) {
        console.error("Error loading timetable entries:", error);
        return [];
      }

      return data;
    } catch (error) {
      console.error("Exception in getTimetableEntries:", error);
      return [];
    }
  }

  /**
   * Add new timetable entry
   */
  async addTimetableEntry(entryData) {
    try {
      if (!this.supabaseDb) {
        return { success: false, error: "Database not initialized" };
      }

      // Validate required fields
      if (!entryData.class_id || !entryData.subject_id || !entryData.teacher_code || 
          !entryData.day_of_week || !entryData.start_time || !entryData.end_time) {
        return { success: false, error: "All fields are required" };
      }

      const newEntry = {
        class_id: entryData.class_id,
        grade_level: entryData.grade_level,
        section_name: entryData.section_name,
        subject_id: entryData.subject_id,
        subject_name: entryData.subject_name,
        teacher_code: entryData.teacher_code,
        teacher_name: entryData.teacher_name,
        day_of_week: entryData.day_of_week,
        start_time: entryData.start_time,
        end_time: entryData.end_time,
        classroom_number: entryData.classroom_number || null,
        remarks: entryData.remarks || null,
        status: "Active"
      };

      const { data, error } = await this.supabaseDb
        .from("class_timetable")
        .insert([newEntry])
        .select();

      if (error) {
        console.error("Error adding timetable entry:", error);
        return { 
          success: false, 
          error: error.message.includes("unique") 
            ? "This time slot is already assigned for this class!"
            : error.message
        };
      }

      return {
        success: true,
        id: data[0].id,
        message: "Class timetable entry added successfully!"
      };
    } catch (error) {
      console.error("Exception in addTimetableEntry:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Update timetable entry
   */
  async updateTimetableEntry(entryId, entryData) {
    try {
      if (!this.supabaseDb) {
        return { success: false, error: "Database not initialized" };
      }

      const updateData = {};
      if (entryData.subject_id) updateData.subject_id = entryData.subject_id;
      if (entryData.subject_name) updateData.subject_name = entryData.subject_name;
      if (entryData.teacher_code) updateData.teacher_code = entryData.teacher_code;
      if (entryData.teacher_name) updateData.teacher_name = entryData.teacher_name;
      if (entryData.day_of_week) updateData.day_of_week = entryData.day_of_week;
      if (entryData.start_time) updateData.start_time = entryData.start_time;
      if (entryData.end_time) updateData.end_time = entryData.end_time;
      if (entryData.classroom_number !== undefined) updateData.classroom_number = entryData.classroom_number;
      if (entryData.remarks !== undefined) updateData.remarks = entryData.remarks;

      const { error } = await this.supabaseDb
        .from("class_timetable")
        .update(updateData)
        .eq("id", entryId);

      if (error) {
        console.error("Error updating timetable entry:", error);
        return { success: false, error: error.message };
      }

      return { success: true, message: "Timetable entry updated successfully!" };
    } catch (error) {
      console.error("Exception in updateTimetableEntry:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Delete timetable entry
   */
  async deleteTimetableEntry(entryId) {
    try {
      if (!this.supabaseDb) {
        return { success: false, error: "Database not initialized" };
      }

      const { error } = await this.supabaseDb
        .from("class_timetable")
        .delete()
        .eq("id", entryId);

      if (error) {
        console.error("Error deleting timetable entry:", error);
        return { success: false, error: error.message };
      }

      return { success: true, message: "Timetable entry deleted successfully!" };
    } catch (error) {
      console.error("Exception in deleteTimetableEntry:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Get teacher assigned subjects for teacher portal
   */
  async getTeacherAssignedSubjects(teacherCode) {
    try {
      if (!this.supabaseDb) {
        console.error("Supabase database not initialized");
        return [];
      }

      const { data, error } = await this.supabaseDb
        .from("class_timetable")
        .select("*")
        .eq("teacher_code", teacherCode)
        .eq("status", "Active")
        .order("day_of_week", { ascending: true })
        .order("start_time", { ascending: true });

      if (error) {
        console.error("Error loading teacher assignments:", error);
        return [];
      }

      return data;
    } catch (error) {
      console.error("Exception in getTeacherAssignedSubjects:", error);
      return [];
    }
  }

  /**
   * Clear cache
   */
  clearCache() {
    this.classesCache = null;
    this.teachersCache = null;
    this.subjectsCache = null;
    this.lastCacheUpdate = 0;
  }
}

// Initialize handler
const timetableHandler = new TimetableHandler();

// Expose globally
window.timetableHandler = timetableHandler;
window.TimetableHandler = TimetableHandler;
