# Floor Clothes Sprite Set

## Goal

Create six discarded-clothing sprites for the protagonist's room. The set should
read as feminine everyday clothing while matching the existing school and room
interior tilesets.

## Deliverables

- Six independent transparent PNG files, each exactly 48×48 pixels.
- One horizontal sprite strip containing all six sprites.
- Items: sailor-style blouse, pleated skirt, knit cardigan, one-piece dress,
  bundled socks, and underwear.

## Visual Direction

- Slightly elevated top-down RPG perspective.
- Clothing is wrinkled, loosely folded, or casually dropped on the floor.
- Crisp pixel-art edges, compact silhouettes, restrained shading, and thin dark
  gray-blue outlines matching the existing tilesets.
- Each item occupies approximately 70–85% of its 48×48 cell while retaining
  transparent padding.
- No people, hangers, laundry baskets, text, logos, or unrelated props.

## Palette

The protagonist's theme colors are cyan-blue and white.

- White and warm off-white form the main fabric colors.
- Cyan-blue and muted navy identify collars, trim, ribbons, or primary fabric.
- Pale blue-gray and medium gray-blue describe wrinkles and overlapping cloth.
- Small muted gray-pink accents are allowed only when needed to distinguish an
  item; they must not compete with the cyan-blue and white theme.

## Asset Processing

Generate the items as a separated sprite sheet on a flat chroma-key background.
Remove the background locally, crop each item, resize with nearest-neighbor
sampling, harden alpha edges, center each item on a transparent 48×48 canvas,
and assemble the horizontal preview strip.

## Acceptance Criteria

- All six requested clothing types are immediately distinguishable at native
  48×48 size.
- Every final image is RGBA with transparent corners.
- No visible chroma-key fringe remains.
- Scale, outline weight, lighting direction, and palette are consistent across
  the set and compatible with the existing room tileset.
