# Top-down Camera Tripod Tileset Design

## Goal

Create one standalone camera-on-tripod prop matching the perspective, palette, and pixel density of:

- `data/tileset/room_interior/pika_nos_in_tiles01_B.png`
- `data/tileset/room_interior/pika_nos_in_tiles01_C.png`

## Output

- File: `data/tileset/school/camera_tripod_48x96.png`
- Canvas: exactly 48×96 pixels
- Format: RGBA PNG
- Background: fully transparent
- Contents: one camera mounted on a three-legged tripod

## Visual Direction

- Use the approximately 45-degree top-down perspective seen in the room-interior furniture.
- Point the camera lens directly toward screen-left.
- Show the camera's top plane and right-side plane; avoid a side-view or eye-level silhouette.
- Arrange the three tripod legs as a readable footprint on the floor plane, spreading downward and diagonally rather than hanging vertically.
- Keep the complete object inside the canvas with a small transparent margin.

## Style and Palette

- Use crisp, manually readable pixel clusters and hard edges.
- Match the references' low-saturation blue-gray, warm gray, beige, and dark brown palette.
- Use compact dark outlines and limited stepped shading.
- Simplify mechanical details so the camera and tripod remain legible at native 48×96 resolution.
- Do not include text, logos, people, extra props, cast shadows, or floor tiles.

## Acceptance Checks

- The image is exactly 48×96 RGBA.
- All four corners are transparent.
- No chroma-key pixels remain.
- The camera reads as facing screen-left.
- The top and right planes are visible.
- The tripod legs form a top-down floor footprint.
- The sprite remains visually coherent at 1× scale.
