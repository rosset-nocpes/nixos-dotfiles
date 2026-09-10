#!/usr/bin/env python3
"""Sample the bar edges in memory, avoiding its foreground and hover highlights."""
import io
import json
import subprocess
import sys

from PIL import Image

CELL_WIDTH = 64


def linear(channel):
    value = channel / 255
    return value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4


def sample(image):
    image = image.convert("RGB")
    # Controls occupy y=7..35. The outer two rows contain only the background.
    rows = [0, 1, image.height - 2, image.height - 1]
    values = []
    for start in range(0, image.width, CELL_WIDTH):
        pixels = [image.getpixel((x, y))
                  for x in range(start, min(start + CELL_WIDTH, image.width), 4)
                  for y in rows]
        values.append(sum(0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
                          for r, g, b in pixels) / len(pixels))
    return values


def main():
    x, y, width, height = sys.argv[1:]
    geometry = f"{int(x)},{int(y)} {int(width)}x{int(height)}"
    try:
        result = subprocess.run(
            ["grim", "-g", geometry, "-s", "1", "-t", "ppm", "-"],
            capture_output=True, check=True, timeout=3)
        values = sample(Image.open(io.BytesIO(result.stdout)))
    except (subprocess.SubprocessError, OSError, ValueError):
        # Retain the last successful palette if capture is temporarily unavailable.
        return 1
    print(json.dumps(values))
    return 0


if __name__ == "__main__":
    sys.exit(main())
