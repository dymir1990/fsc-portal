# 📁 Archive Directory
## Consolidated Project Files

This directory contains files that have been consolidated into the main project documentation to reduce redundancy and improve organization.

---

## 📚 Documentation Archive

**Location:** `archive/documentation/`

### Consolidated Files
- `COMPLETION_SUMMARY.md` → Merged into `FSC_PORTAL_MASTER_DOCUMENTATION.md`
- `PHASE2_HANDOFF_SUMMARY.md` → Merged into master doc
- `MIGRATION_STATUS.md` → Merged into master doc
- `PHASE2_SEED_DOCUMENT.md` → Merged into master doc
- `PHASE2_IMPLEMENTATION_PLAN.md` → Merged into master doc
- `MACKENZI_PREPARATION_SUMMARY.md` → Merged into master doc
- `MACKENZI_QUICK_REFERENCE.md` → Merged into `QUICK_HANDOFF.md`
- `MACKENZI_VALIDATION_GUIDE.md` → Merged into master doc
- `FIXES_APPLIED.md` → Merged into master doc
- `UI_REVIEW.md` → Merged into master doc

### Why Archived
These files contained overlapping information that was creating confusion and maintenance overhead. All essential information has been consolidated into:

1. **`FSC_PORTAL_MASTER_DOCUMENTATION.md`** - Complete project reference
2. **`QUICK_HANDOFF.md`** - Essential commands and quick reference
3. **`CONTEXT_HANDOFF_TEMPLATE.md`** - AI assistant handoff format

---

## 🗄️ SQL Scripts Archive

**Location:** `archive/sql-scripts/`

### Archived Scripts
- `check-migration-status.sql` → Superseded by current schema
- `verify-migration.sql` → Superseded by current schema
- `verify-migration 2.sql` → Duplicate
- `create-views-fixed 2.sql` → Duplicate
- `phase2-migration-resume.sql` → Superseded
- `step7-fix.sql` → Superseded
- `phase2-migration-corrected.sql` → Superseded
- `phase2-migration.sql` → Superseded

### Current Essential Scripts
**Location:** `sql/essential/`
- `2024-09-28-update-sessions.sql` - Main migration script
- `create-missing-views.sql` - Essential views
- `create-views-fixed.sql` - Working view definitions
- `check-sessions-structure.sql` - Schema verification
- `role-enum-fix.sql` - Role management
- `seed-payers.sql` - Insurance companies
- `seed-test-data.sql` - Sample data

---

## 📋 Consolidation Benefits

### Before Consolidation
- 18+ documentation files with overlapping content
- 16 SQL scripts with duplicates and outdated versions
- Scattered information across multiple files
- Difficult to maintain consistency
- Hard to find current information

### After Consolidation
- 3 main documentation files with clear purposes
- 7 essential SQL scripts in organized structure
- Single source of truth for project information
- Easy to maintain and update
- Clear file organization

---

## 🔄 How to Use Archived Files

### If You Need Historical Information
1. Check the main documentation files first
2. If specific details are missing, refer to archived files
3. Update main documentation if you find important missing information

### If You Need Old SQL Scripts
1. Check `sql/essential/` for current working scripts
2. Refer to archived scripts only for historical reference
3. Do not run archived scripts without understanding their purpose

---

## 📝 Maintenance Notes

- **Archive Date:** October 19, 2025
- **Consolidation Reason:** Reduce redundancy and improve project organization
- **Main Documentation:** `FSC_PORTAL_MASTER_DOCUMENTATION.md`
- **Quick Reference:** `QUICK_HANDOFF.md`
- **AI Handoff:** `CONTEXT_HANDOFF_TEMPLATE.md`

---

## 🎯 Next Steps

1. Use the consolidated documentation for all future development
2. Update main files when making changes
3. Archive outdated files rather than deleting them
4. Maintain the single source of truth principle

---

**This archive preserves historical information while maintaining a clean, organized project structure.**
