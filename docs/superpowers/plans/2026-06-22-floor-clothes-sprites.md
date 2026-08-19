# Floor Clothes Sprite Set Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce six transparent 48×48 discarded-clothing sprites and one horizontal strip in the protagonist's cyan-blue and white theme.

**Architecture:** Generate one separated 3×2 pixel-art source sheet on a chroma-key background, remove the background with the installed imagegen helper, then deterministically crop and normalize each cell with Pillow. A final validation command checks count, dimensions, RGBA mode, transparent corners, occupied bounds, and strip size.

**Tech Stack:** Built-in imagegen, imagegen chroma-key removal helper, Python 3, Pillow

---

### Task 1: Generate the clothing source sheet

**Files:**
- Create: `data/tileset/generated/floor_clothes/floor_clothes_source.png`

- [ ] **Step 1: Generate one 3×2 source sheet**

Use built-in imagegen with the following production prompt:

```text
Use case: stylized-concept
Asset type: six top-down 2D RPG discarded-clothing sprites matching the supplied Japanese school and room-interior pixel-art tilesets
Primary request: create exactly six distinct feminine clothing items casually discarded on a bedroom floor
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background, with no floor plane
Subject: top row: a wrinkled white sailor-style blouse with cyan-blue collar and ribbon; a rumpled cyan-blue pleated skirt; a loosely dropped white knit cardigan with cyan-blue trim. Bottom row: a crumpled cyan-blue and white one-piece dress; a bundled pair of white ankle socks with cyan-blue accents; a modest pair of white women's underwear with a small cyan-blue bow and trim
Style/medium: crisp hand-drawn pixel art matching the reference tilesets, restrained color ramps, compact readable silhouettes, thin dark gray-blue pixel outlines, no smooth vector rendering
Composition/framing: clean 3 columns by 2 rows sprite sheet; one item centered in each equal square cell; all items isolated with generous separation; slightly elevated top-down RPG perspective; clothing looks wrinkled, folded over itself, or casually dropped
Lighting/mood: subtle upper-left highlight with pale blue-gray fold shadows; no external cast shadow
Color palette: white, warm off-white, cyan-blue, muted navy, pale blue-gray, medium gray-blue, charcoal blue-gray outline; do not use green in any clothing item
Constraints: exactly six items in the specified order; every item remains legible at 48×48 pixels; hard pixel edges; consistent scale and outline weight; no people, body parts, hangers, baskets, text, logos, watermark, or unrelated objects; background is one uniform #00ff00 with no gradients, texture, shadows, reflections, or lighting variation
```

- [ ] **Step 2: Copy the generated source into the workspace**

Copy the newest generated PNG to:

```text
data/tileset/generated/floor_clothes/floor_clothes_source.png
```

- [ ] **Step 3: Visually inspect the sheet**

Expected: six separated clothing items in the requested order, with consistent pixel-art scale and no merged silhouettes.

### Task 2: Remove the chroma-key background

**Files:**
- Create: `data/tileset/generated/floor_clothes/floor_clothes_transparent.png`

- [ ] **Step 1: Run the installed chroma-key helper**

Run:

```powershell
python 'C:\Users\user\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py' --input 'data\tileset\generated\floor_clothes\floor_clothes_source.png' --out 'data\tileset\generated\floor_clothes\floor_clothes_transparent.png' --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill
```

Expected: exit code 0 and a reported output path.

- [ ] **Step 2: Inspect transparency**

Expected: transparent background and no visible green fringe around garment edges. If a thin fringe remains, rerun once with `--edge-contract 1`.

### Task 3: Produce six normalized sprites and a strip

**Files:**
- Create: `tmp/process_floor_clothes.py`
- Create: `data/tileset/generated/floor_clothes/clothing_01_sailor_blouse.png`
- Create: `data/tileset/generated/floor_clothes/clothing_02_pleated_skirt.png`
- Create: `data/tileset/generated/floor_clothes/clothing_03_cardigan.png`
- Create: `data/tileset/generated/floor_clothes/clothing_04_dress.png`
- Create: `data/tileset/generated/floor_clothes/clothing_05_socks.png`
- Create: `data/tileset/generated/floor_clothes/clothing_06_underwear.png`
- Create: `data/tileset/generated/floor_clothes/floor_clothes_48x48_strip.png`

- [ ] **Step 1: Write the processing script**

Create a Pillow script that:

1. Divides the transparent source into three columns and two rows.
2. Finds pixels with alpha at least 32 in each cell.
3. Crops each occupied bounding box.
4. Resizes each item with nearest-neighbor sampling to fit within 42×42 pixels.
5. Converts alpha values at least 128 to opaque and lower values to transparent.
6. Centers each item on a transparent 48×48 RGBA canvas.
7. Saves the six semantic filenames listed above.
8. Composites the six canvases into a 288×48 horizontal strip.

- [ ] **Step 2: Run the processing script**

Run:

```powershell
python 'tmp\process_floor_clothes.py'
```

Expected: exit code 0 and seven final PNG files.

- [ ] **Step 3: Inspect the horizontal strip**

Expected: six clearly recognizable items, consistent scale, cyan-blue and white visual theme, transparent spacing, and no item touching a canvas edge.

### Task 4: Validate and clean up

**Files:**
- Delete: `tmp/process_floor_clothes.py`
- Delete: `data/tileset/generated/floor_clothes/floor_clothes_source.png`
- Delete: `data/tileset/generated/floor_clothes/floor_clothes_transparent.png`

- [ ] **Step 1: Validate final files with Pillow**

Run a Python validation that asserts:

```python
assert len(sprite_files) == 6
assert all(image.size == (48, 48) for image in sprites)
assert all(image.mode == "RGBA" for image in sprites)
assert all(image.getpixel((0, 0))[3] == 0 for image in sprites)
assert all(image.getchannel("A").getbbox() is not None for image in sprites)
assert strip.size == (288, 48)
assert strip.mode == "RGBA"
```

Expected: six per-file validation lines and one strip validation line, with exit code 0.

- [ ] **Step 2: Remove intermediate files**

Delete only the processing script and the two generated intermediate sheets listed above. Preserve all seven final PNG files.

- [ ] **Step 3: Check repository status**

Run:

```powershell
git status --short -- 'data/tileset/generated/floor_clothes'
```

Expected: only the final `floor_clothes` assets appear as untracked or modified project files.
