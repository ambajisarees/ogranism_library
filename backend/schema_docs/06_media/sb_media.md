# Table: sb_media (Media Metadata Registry)

## Table Overview
`sb_media` is a Supabase metadata table that records all uploaded files (images, designs, invoices, and documents) in the ERP. It provides searchable indexes for tags and tracks entity connections to stitch media directly to active business workflows.

---

## Column Grouping

### 1. File Identity & Storage Paths
*   `id`: **Primary Key**. Automatically generated UUID.
*   `file_path`: Storage path key inside Supabase Storage (e.g. `'production/cutting/12/front.jpg'`).
*   `file_name`: Original name of the uploaded file.
*   `display_name`: Editable human-friendly display title.
*   `file_size`: Size in bytes (`bigint`).
*   `mime_type`: Standard MIME type identifier (e.g., `'image/jpeg'`, `'application/pdf'`).
*   `width`: Image width in pixels.
*   `height`: Image height in pixels.

### 2. Categorization & Tagging
*   `bucket`: High-level group folder name (`'sales'`, `'production'`, `'billing'`, `'general'`).
*   `media_type`: Specific classification chip (e.g. `'cutting_card_front'`, `'set_pic'`, `'challan_scan'`).
*   `tags`: String array containing free-form searchable keywords (`text[]`).

### 3. Entity Linkage
*   `entity_type`: Category of the connected business entity (`'cutting_batch'`, `'stitching_dispatch'`, `'stitching_receive'`, `'quality'`).
*   `entity_id`: Business identifier key (e.g. `MULTI_VNO` or `VNO` voucher numbers).
*   `entity_label`: Cached display text for linked tags (e.g. `'Batch #15'`, `'Moss Rimzim'`).
*   `is_linked`: Fast boolean query check to filter out unsorted uploads.

### 4. Image Optimization
*   `thumb_path`: Path to auto-generated small thumbnail preview.
*   `compressed_path`: Path to WebP compressed version of the original image.

### 5. Audit & Retention
*   `uploaded_by`: UUID of the user who uploaded the file (references `auth.users`).
*   `uploader_name`: Cached username from profile tables.
*   `linked_by`: UUID of user who established the entity link.
*   `linked_at`: Timestamp when the link was created.
*   `created_at` / `updated_at`: Standard creation/modification audit timestamps.
*   `is_archived` / `archived_at`: Soft delete control tags.

---

## SQL Queries

```sql
-- Query unsorted uploads (Sorting workflow)
SELECT * FROM "IMMBE2627"."sb_media" 
WHERE "is_linked" = false AND "is_archived" = false
ORDER BY "created_at" DESC;

-- Get all media linked to a cutting batch
SELECT * FROM "IMMBE2627"."sb_media" 
WHERE "entity_type" = 'cutting_batch' AND "entity_id" = '15' AND "is_archived" = false;
```
