# Pattern Examples & Use Cases

## Table of Contents
1. [Photography & Media](#photography--media)
2. [Document Management](#document-management)
3. [Project Organization](#project-organization)
4. [Backup & Archival](#backup--archival)
5. [Development & Code](#development--code)
6. [Creative Workflows](#creative-workflows)

---

## Photography & Media

### Vacation Photos
**Scenario:** You have 200+ photos from a vacation with generic camera names

```
Pattern: Vacation_Hawaii_{date:yyyy-MM-dd}_{counter:1,4}
Before:  DSC_0001.jpg, DSC_0002.jpg, DSC_0003.jpg
After:   Vacation_Hawaii_2025-08-15_0001.jpg
         Vacation_Hawaii_2025-08-15_0002.jpg
         Vacation_Hawaii_2025-08-16_0003.jpg
```

### Wedding Photography
**Scenario:** Professional photography organization by event sections

```
Pattern: {parent}_{created:yyyy-MM-dd}_{counter:1,4}_{name}
Before:  (in folder "Wedding_Smith") ceremony1.jpg, reception5.jpg
After:   Wedding_Smith_2025-06-20_0001_ceremony1.jpg
         Wedding_Smith_2025-06-20_0042_reception5.jpg
```

### Video Project Files
**Scenario:** Organize raw footage by date and sequence

```
Pattern: Project_{parent}_{date:yyyyMMdd}_{counter:1,3}
Before:  (in "Commercial_Nike") clip1.mp4, clip2.mp4
After:   Project_Commercial_Nike_20251115_001.mp4
         Project_Commercial_Nike_20251115_002.mp4
```

### Stock Photography
**Scenario:** Rename for stock photo submission with unique IDs

```
Pattern: {parent}_{random:8}_{counter:1,4}
Before:  (in "Nature") sunset.jpg, mountain.jpg
After:   Nature_aB3xY9mK_0001.jpg
         Nature_kL8pQ2vN_0002.jpg
```

---

## Document Management

### Invoice Numbering
**Scenario:** Create sequential invoice numbers with dates

```
Pattern: Invoice_{date:yyyy-MM-dd}_{counter:1001,4}
Before:  invoice.pdf, payment.pdf
After:   Invoice_2025-11-15_1001.pdf
         Invoice_2025-11-15_1002.pdf
```

### Meeting Minutes
**Scenario:** Organize meeting notes chronologically

```
Pattern: {parent}_Minutes_{created:yyyy-MM-dd}_{counter:1,3}
Before:  (in "Board_Meetings") notes.docx, agenda.docx
After:   Board_Meetings_Minutes_2025-11-01_001.docx
         Board_Meetings_Minutes_2025-11-15_002.docx
```

### Legal Documents
**Scenario:** Professional document organization with case numbers

```
Pattern: {parent}_Doc_{counter:1000,5}_{date:yyyyMMdd}
Before:  (in "Case_2025_123") filing.pdf, evidence.pdf
After:   Case_2025_123_Doc_01000_20251115.pdf
         Case_2025_123_Doc_01001_20251115.pdf
```

### Report Versioning
**Scenario:** Track document versions with timestamps

```
Pattern: {name}_v{counter:1,2}_{date:yyyyMMdd}
Before:  quarterly_report.docx
After:   quarterly_report_v01_20251115.docx
         quarterly_report_v02_20251116.docx
```

---

## Project Organization

### Software Project Files
**Scenario:** Organize project deliverables

```
Pattern: {parent}_Deliverable_{counter:1,2}_{name}
Before:  (in "ProjectAlpha") spec.pdf, design.pdf, code.zip
After:   ProjectAlpha_Deliverable_01_spec.pdf
         ProjectAlpha_Deliverable_02_design.pdf
         ProjectAlpha_Deliverable_03_code.zip
```

### Research Data Files
**Scenario:** Organize experimental data with dates

```
Pattern: Experiment_{counter:1,3}_{date:yyyy-MM-dd}_{name}
Before:  results.csv, analysis.xlsx
After:   Experiment_001_2025-11-15_results.csv
         Experiment_002_2025-11-15_analysis.xlsx
```

### Client Deliverables
**Scenario:** Professional naming for client files

```
Pattern: {parent}_Final_{date:yyyy-MM-dd}_{counter:1,2}
Before:  (in "Client_Acme") logo.ai, brochure.pdf
After:   Client_Acme_Final_2025-11-15_01.ai
         Client_Acme_Final_2025-11-15_02.pdf
```

---

## Backup & Archival

### Database Backups
**Scenario:** Timestamped database backups

```
Pattern: {name}_backup_{date:yyyy-MM-dd_HHmmss}
Before:  production_db.sql
After:   production_db_backup_2025-11-15_143022.sql
         production_db_backup_2025-11-15_150000.sql
```

### Configuration Backups
**Scenario:** Preserve configuration file history

```
Pattern: {name}_{date:yyyyMMdd}_{counter:1,2}
Before:  config.json, settings.xml
After:   config_20251115_01.json
         settings_20251115_01.xml
```

### Archive Organization
**Scenario:** Organize files into year/month structure

```
Pattern: Archive_{created:yyyy}/{created:MM}_{parent}_{counter:1,5}
Before:  (created 2025-08, in "Documents") file.pdf
After:   Archive_2025/08_Documents_00001.pdf
```

### Incremental Backups
**Scenario:** Daily backup sequences

```
Pattern: Backup_{date:yyyy-MM-dd}_Set{counter:1,3}_{name}
Before:  data.zip, files.tar
After:   Backup_2025-11-15_Set001_data.zip
         Backup_2025-11-15_Set002_files.tar
```

---

## Development & Code

### Code Releases
**Scenario:** Version control for releases

```
Pattern: Release_v{counter:1,2}.{counter:0,2}_{date:yyyyMMdd}
Before:  build.zip
After:   Release_v1.00_20251115.zip
         Release_v1.01_20251116.zip
```

### Log Files
**Scenario:** Organize application logs

```
Pattern: {parent}_log_{date:yyyy-MM-dd}_{counter:1,4}
Before:  (in "WebServer") access.log, error.log
After:   WebServer_log_2025-11-15_0001.log
         WebServer_log_2025-11-15_0002.log
```

### Test Data
**Scenario:** Organize test datasets

```
Pattern: Test_{parent}_{counter:100,4}_{name}
Before:  (in "UserAuth") input.json, expected.json
After:   Test_UserAuth_0100_input.json
         Test_UserAuth_0101_expected.json
```

### Documentation
**Scenario:** API documentation versions

```
Pattern: API_Docs_v{counter:1,1}.{counter:0,2}_{date:yyyy-MM-dd}
Before:  api.html
After:   API_Docs_v1.00_2025-11-15.html
         API_Docs_v1.01_2025-11-16.html
```

---

## Creative Workflows

### Music Production
**Scenario:** Organize audio project files

```
Pattern: {parent}_Track{counter:1,2}_{name}_{date:yyyyMMdd}
Before:  (in "Album_Summer") vocals.wav, drums.wav
After:   Album_Summer_Track01_vocals_20251115.wav
         Album_Summer_Track02_drums_20251115.wav
```

### Graphic Design Assets
**Scenario:** Organize design iterations

```
Pattern: {parent}_{name}_v{counter:1,2}_{date:MMdd}
Before:  (in "Logo_Redesign") concept.ai, final.ai
After:   Logo_Redesign_concept_v01_1115.ai
         Logo_Redesign_final_v02_1115.ai
```

### Video Editing
**Scenario:** Organize video project renders

```
Pattern: Render_{parent}_{date:yyyy-MM-dd}_{counter:1,3}
Before:  (in "Commercial_Draft") version1.mp4, version2.mp4
After:   Render_Commercial_Draft_2025-11-15_001.mp4
         Render_Commercial_Draft_2025-11-15_002.mp4
```

### 3D Modeling
**Scenario:** Track model iterations

```
Pattern: Model_{name}_r{counter:1,3}_{date:yyMMdd}
Before:  character.obj, environment.obj
After:   Model_character_r001_251115.obj
         Model_environment_r002_251115.obj
```

---

## Advanced Patterns

### Multi-Component Pattern
**Scenario:** Maximum information preservation

```
Pattern: {parent}_{date:yyyy-MM-dd}_{counter:1,4}_{name}_{size}
Before:  (in "Reports", 2.5MB) quarterly.pdf
After:   Reports_2025-11-15_0001_quarterly_2.5MB.pdf
```

### Conditional Formatting
**Scenario:** Different formats based on file metadata

```
Pattern: {created:yyyy}/{created:MM}/{parent}_{counter:1,5}_{name}
Before:  (created different months) file1.jpg, file2.jpg
After:   2025/08/Photos_00001_file1.jpg
         2025/09/Photos_00002_file2.jpg
```

### UUID-Based Unique Naming
**Scenario:** Guaranteed unique identifiers

```
Pattern: {parent}_{uuid}
Before:  (in "Uploads") file1.pdf, file2.pdf
After:   Uploads_a1b2c3d4-e5f6-7890-abcd-ef1234567890.pdf
         Uploads_f9e8d7c6-b5a4-3210-9876-543210fedcba.pdf
```

---

## Tips for Each Category

### Photography
- Use date formats that match your camera's timezone
- Include location or event in the pattern
- Use 4-digit padding for large photo sets
- Consider creation date vs modification date

### Documents
- Start counters at logical numbers (invoices at 1001)
- Include version numbers for iterative documents
- Use consistent date formats across organization
- Add department or project codes

### Projects
- Include project identifiers in every filename
- Use hierarchical numbering (1.1, 1.2, 2.1)
- Add status indicators (Draft, Final, Review)
- Maintain naming consistency across team

### Backups
- Always include timestamps with time
- Use creation date to preserve original timing
- Include backup type or scope in name
- Consider using ISO 8601 date format (yyyy-MM-dd)

### Development
- Include version numbers systematically
- Use semantic versioning when appropriate
- Add environment indicators (dev, staging, prod)
- Timestamp builds and releases

### Creative
- Track iteration numbers explicitly
- Include project phase information
- Use consistent abbreviations
- Consider file size for large media files

---

## Pattern Combinations Reference

### Common Token Combinations

```
{parent}_{counter:1,3}
{date:yyyy-MM-dd}_{counter:1,4}
{name}_{date:yyyyMMdd}
{parent}_{date:yyyy-MM}_{counter:1,3}
{created:yyyy-MM-dd}_{name}_{counter:1,2}
{parent}_{counter:1,4}_{name}
{date:yyyyMMdd}_{random:6}
{uuid}
```

### Safe Patterns (No Conflicts)
These patterns are highly unlikely to create duplicate names:

```
{uuid}
{random:12}_{counter:1,4}
{date:yyyy-MM-dd_HHmmss}_{counter:1,5}
{parent}_{uuid}
{date:yyyyMMddHHmmss}_{random:8}
```

---

## Testing Your Pattern

Before renaming important files:

1. **Create test folder** with sample files
2. **Run preview** to verify pattern output
3. **Check for duplicates** in preview
4. **Verify sort order** is correct
5. **Test edge cases** (special characters, long names)
6. **Confirm on test files** first
7. **Then apply to real files**

---

For more information, see USAGE.md or run the utility and select option 4 for examples.
