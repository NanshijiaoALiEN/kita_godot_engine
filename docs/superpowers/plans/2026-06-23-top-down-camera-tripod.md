# Top-down Camera Tripod Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing side-view camera sprite with a 48×96 top-down camera-on-tripod prop matching the room-interior tilesets.

**Architecture:** Generate one high-resolution pixel-art source using the two room-interior sheets as style references, remove a flat chroma-key background, then crop and nearest-neighbor resize it into the final fixed canvas. Validate the PNG mechanically and inspect it at native scale against the approved design.

**Tech Stack:** Built-in image generation, Pillow, `remove_chroma_key.py`, PNG RGBA

---

### Task 1: Generate the corrected top-down source

**Files:**
- Reference: `data/tileset/room_interior/pika_nos_in_tiles01_B.png`
- Reference: `data/tileset/room_interior/pika_nos_in_tiles01_C.png`
- Create temporary: `data/tileset/school/camera_tripod_topdown_source.png`

- [ ] **Step 1: Generate one source image**

Use the built-in image generator with both reference sheets visible. Require a 45-degree top-down floor-plane view, lens pointing screen-left, visible top and right camera planes, and three tripod legs spreading downward and diagonally.

- [ ] **Step 2: Inspect perspective**

Reject the image if the tripod legs hang vertically, the camera reads as eye-level, or the camera top plane is not visible.

### Task 2: Produce the project asset

**Files:**
- Replace: `data/tileset/school/camera_tripod_48x96.png`
- Create temporary: `data/tileset/school/camera_tripod_topdown_alpha.png`

- [ ] **Step 1: Remove the chroma key**

Run:

```powershell
& $bundledPython C:\Users\steven.tung\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py `
  --input data\tileset\school\camera_tripod_topdown_source.png `
  --out data\tileset\school\camera_tripod_topdown_alpha.png `
  --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill
```

Expected: an RGBA image with transparent corners and no green fringe.

- [ ] **Step 2: Crop and resize**

Crop to the non-transparent subject bounds, fit within a 44×92 area, resize with nearest-neighbor sampling, harden alpha to 0 or 255, and center on a transparent 48×96 canvas.

- [ ] **Step 3: Remove temporary project copies**

Delete only `camera_tripod_topdown_source.png` and `camera_tripod_topdown_alpha.png`; preserve the generator's original output.

### Task 3: Verify the asset

**Files:**
- Test: `data/tileset/school/camera_tripod_48x96.png`

- [ ] **Step 1: Run mechanical validation**

Use Pillow assertions for:

```text
size == (48, 96)
mode == RGBA
all four corners have alpha 0
subject bounds remain inside the canvas
alpha values are only 0 and 255
no opaque pixel is chroma-key green
```

- [ ] **Step 2: Perform visual validation**

Inspect at native scale and confirm the lens faces screen-left, the top and right camera planes are visible, the legs form a floor footprint, and the palette matches the low-saturation room-interior references.
