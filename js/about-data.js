// ====================================================================
// ABOUT PAGE DATA MANAGEMENT - CRUD OPERATIONS
// ====================================================================

// ─ STATS CRUD ─
async function createAboutStat(icon_emoji, stat_number, stat_label, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_stats').insert([{
    icon_emoji, stat_number, stat_label, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating stat:', error); return null; }
  console.log('Stat created:', data);
  return data?.[0];
}

async function readAllAboutStats() {
  const { data, error } = await supabaseDb.from('about_stats')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading stats:', error); return []; }
  localStorage.setItem('about_stats', JSON.stringify(data));
  return data;
}

async function updateAboutStat(id, updates) {
  const { data, error } = await supabaseDb.from('about_stats')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating stat:', error); return null; }
  console.log('Stat updated:', data);
  await readAllAboutStats(); // Refresh cache
  return data?.[0];
}

async function deleteAboutStat(id) {
  const { error } = await supabaseDb.from('about_stats').delete().eq('id', id);
  if (error) { console.error('Error deleting stat:', error); return false; }
  console.log('Stat deleted');
  await readAllAboutStats(); // Refresh cache
  return true;
}

// ─ VISION & MISSION CRUD ─
async function createVisionMission(section_type, icon_emoji, section_title, section_description, key_points, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_vision_mission').insert([{
    section_type, icon_emoji, section_title, section_description, key_points, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating vision/mission:', error); return null; }
  return data?.[0];
}

async function readAllVisionMission() {
  const { data, error } = await supabaseDb.from('about_vision_mission')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading vision/mission:', error); return []; }
  localStorage.setItem('about_vision_mission', JSON.stringify(data));
  return data;
}

async function updateVisionMission(id, updates) {
  const { data, error } = await supabaseDb.from('about_vision_mission')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating vision/mission:', error); return null; }
  await readAllVisionMission(); // Refresh cache
  return data?.[0];
}

async function deleteVisionMission(id) {
  const { error } = await supabaseDb.from('about_vision_mission').delete().eq('id', id);
  if (error) { console.error('Error deleting vision/mission:', error); return false; }
  await readAllVisionMission(); // Refresh cache
  return true;
}

// ─ ERA CARDS CRUD ─
async function createEraCard(icon_emoji, era_badge, era_title, era_description, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_era_cards').insert([{
    icon_emoji, era_badge, era_title, era_description, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating era card:', error); return null; }
  return data?.[0];
}

async function readAllEraCards() {
  const { data, error } = await supabaseDb.from('about_era_cards')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading era cards:', error); return []; }
  localStorage.setItem('about_era_cards', JSON.stringify(data));
  return data;
}

async function updateEraCard(id, updates) {
  const { data, error } = await supabaseDb.from('about_era_cards')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating era card:', error); return null; }
  await readAllEraCards(); // Refresh cache
  return data?.[0];
}

async function deleteEraCard(id) {
  const { error } = await supabaseDb.from('about_era_cards').delete().eq('id', id);
  if (error) { console.error('Error deleting era card:', error); return false; }
  await readAllEraCards(); // Refresh cache
  return true;
}

// ─ TIMELINE CRUD ─
async function createTimelineItem(icon_emoji, timeline_date, timeline_title, timeline_description, timeline_position, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_timeline').insert([{
    icon_emoji, timeline_date, timeline_title, timeline_description, timeline_position, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating timeline:', error); return null; }
  return data?.[0];
}

async function readAllTimeline() {
  const { data, error } = await supabaseDb.from('about_timeline')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading timeline:', error); return []; }
  localStorage.setItem('about_timeline', JSON.stringify(data));
  return data;
}

async function updateTimelineItem(id, updates) {
  const { data, error } = await supabaseDb.from('about_timeline')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating timeline:', error); return null; }
  await readAllTimeline(); // Refresh cache
  return data?.[0];
}

async function deleteTimelineItem(id) {
  const { error } = await supabaseDb.from('about_timeline').delete().eq('id', id);
  if (error) { console.error('Error deleting timeline:', error); return false; }
  await readAllTimeline(); // Refresh cache
  return true;
}

// ─ ADMIN TEAM CRUD ─
async function createAdminMember(member_name, member_role, member_department, member_photo_url = '', member_email = '', hierarchy_level = 0, reports_to_id = null, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_admin_team').insert([{
    member_name, member_role, member_department, member_photo_url, member_email, hierarchy_level, reports_to_id, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating admin member:', error); return null; }
  return data?.[0];
}

async function readAllAdminTeam() {
  const { data, error } = await supabaseDb.from('about_admin_team')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading admin team:', error); return []; }
  localStorage.setItem('about_admin_team', JSON.stringify(data));
  return data;
}

async function updateAdminMember(id, updates) {
  const { data, error } = await supabaseDb.from('about_admin_team')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating admin member:', error); return null; }
  await readAllAdminTeam(); // Refresh cache
  return data?.[0];
}

async function deleteAdminMember(id) {
  const { error } = await supabaseDb.from('about_admin_team').delete().eq('id', id);
  if (error) { console.error('Error deleting admin member:', error); return false; }
  await readAllAdminTeam(); // Refresh cache
  return true;
}

// ─ PRINCIPALS TREE CRUD ─
async function createPrincipal(principal_name, principal_tenure_start, principal_tenure_end, principal_description, principal_photo_url = '', tree_position, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_principals_tree').insert([{
    principal_name, principal_tenure_start, principal_tenure_end, principal_description, principal_photo_url, tree_position, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating principal:', error); return null; }
  return data?.[0];
}

async function readAllPrincipals() {
  const { data, error } = await supabaseDb.from('about_principals_tree')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading principals:', error); return []; }
  localStorage.setItem('about_principals_tree', JSON.stringify(data));
  return data;
}

async function updatePrincipal(id, updates) {
  const { data, error } = await supabaseDb.from('about_principals_tree')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating principal:', error); return null; }
  await readAllPrincipals(); // Refresh cache
  return data?.[0];
}

async function deletePrincipal(id) {
  const { error } = await supabaseDb.from('about_principals_tree').delete().eq('id', id);
  if (error) { console.error('Error deleting principal:', error); return false; }
  await readAllPrincipals(); // Refresh cache
  return true;
}

// ─ TECHNICAL INCHARGE CRUD ─
async function createTechnicalIncharge(incharge_name, incharge_tenure_start, incharge_tenure_end, incharge_description, incharge_photo_url = '', tree_position, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_technical_incharge_tree').insert([{
    incharge_name, incharge_tenure_start, incharge_tenure_end, incharge_description, incharge_photo_url, tree_position, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating technical incharge:', error); return null; }
  return data?.[0];
}

async function readAllTechnicalIncharge() {
  const { data, error } = await supabaseDb.from('about_technical_incharge_tree')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading technical incharge:', error); return []; }
  localStorage.setItem('about_technical_incharge_tree', JSON.stringify(data));
  return data;
}

async function updateTechnicalIncharge(id, updates) {
  const { data, error } = await supabaseDb.from('about_technical_incharge_tree')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating technical incharge:', error); return null; }
  await readAllTechnicalIncharge(); // Refresh cache
  return data?.[0];
}

async function deleteTechnicalIncharge(id) {
  const { error } = await supabaseDb.from('about_technical_incharge_tree').delete().eq('id', id);
  if (error) { console.error('Error deleting technical incharge:', error); return false; }
  await readAllTechnicalIncharge(); // Refresh cache
  return true;
}

// ─ PRIMARY INCHARGE CRUD ─
async function createPrimaryIncharge(incharge_name, incharge_tenure_start, incharge_tenure_end, incharge_description, incharge_photo_url = '', tree_position, display_order = 0) {
  const { data, error } = await supabaseDb.from('about_primary_incharge_tree').insert([{
    incharge_name, incharge_tenure_start, incharge_tenure_end, incharge_description, incharge_photo_url, tree_position, display_order, is_active: true
  }]).select();
  if (error) { console.error('Error creating primary incharge:', error); return null; }
  return data?.[0];
}

async function readAllPrimaryIncharge() {
  const { data, error } = await supabaseDb.from('about_primary_incharge_tree')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true });
  if (error) { console.error('Error reading primary incharge:', error); return []; }
  localStorage.setItem('about_primary_incharge_tree', JSON.stringify(data));
  return data;
}

// ====================================================================
// EXPORT FUNCTIONS TO WINDOW OBJECT FOR GLOBAL ACCESS
// ====================================================================

// Admin Team Functions
window.readAllAdminTeam = readAllAdminTeam;
window.createAdminMember = createAdminMember;
window.updateAdminMember = updateAdminMember;
window.deleteAdminMember = deleteAdminMember;

// Stats Functions
window.createAboutStat = createAboutStat;
window.readAllAboutStats = readAllAboutStats;
window.updateAboutStat = updateAboutStat;
window.deleteAboutStat = deleteAboutStat;

// Vision/Mission Functions
window.createVisionMission = createVisionMission;
window.readAllVisionMission = readAllVisionMission;
window.updateVisionMission = updateVisionMission;
window.deleteVisionMission = deleteVisionMission;

// Era Card Functions
window.createEraCard = createEraCard;
window.readAllEraCards = readAllEraCards;
window.updateEraCard = updateEraCard;
window.deleteEraCard = deleteEraCard;

// Principals Tree Functions
window.createPrincipal = createPrincipal;
window.readAllPrincipals = readAllPrincipals;
window.updatePrincipal = updatePrincipal;
window.deletePrincipal = deletePrincipal;

// Technical Incharge Functions
window.createTechnicalIncharge = createTechnicalIncharge;
window.readAllTechnicalIncharge = readAllTechnicalIncharge;
window.updateTechnicalIncharge = updateTechnicalIncharge;
window.deleteTechnicalIncharge = deleteTechnicalIncharge;

// Primary Incharge Functions
window.createPrimaryIncharge = createPrimaryIncharge;
window.readAllPrimaryIncharge = readAllPrimaryIncharge;
window.updatePrimaryIncharge = updatePrimaryIncharge;
window.deletePrimaryIncharge = deletePrimaryIncharge;

console.log('✓ About-data.js functions exported to window object');

async function updatePrimaryIncharge(id, updates) {
  const { data, error } = await supabaseDb.from('about_primary_incharge_tree')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select();
  if (error) { console.error('Error updating primary incharge:', error); return null; }
  await readAllPrimaryIncharge(); // Refresh cache
  return data?.[0];
}

async function deletePrimaryIncharge(id) {
  const { error } = await supabaseDb.from('about_primary_incharge_tree').delete().eq('id', id);
  if (error) { console.error('Error deleting primary incharge:', error); return false; }
  await readAllPrimaryIncharge(); // Refresh cache
  return true;
}

// ─ BULK LOAD ALL ABOUT DATA ─
async function loadAllAboutData() {
  console.log('Loading all about page data from Supabase...');
  await Promise.all([
    readAllAboutStats(),
    readAllVisionMission(),
    readAllEraCards(),
    readAllTimeline(),
    readAllAdminTeam(),
    readAllPrincipals(),
    readAllTechnicalIncharge(),
    readAllPrimaryIncharge()
  ]);
  console.log('About page data loaded and cached in localStorage');
}
