from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "assets" / "brand"
RES_DIR = ROOT / "android" / "app" / "src" / "main" / "res"

BG = (7, 12, 18)
BG_2 = (10, 20, 28)
GREEN = (0, 255, 159)
CYAN = (34, 211, 238)
WHITE = (229, 245, 241)
MUTED = (75, 100, 110)


def font(path: str, size: int):
    try:
        return ImageFont.truetype(path, size)
    except OSError:
        return ImageFont.load_default()


FONT_BLACK = r"C:\Windows\Fonts\seguibl.ttf"
FONT_MONO_BOLD = r"C:\Windows\Fonts\consolab.ttf"


def rounded_rectangle_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def make_icon(size: int = 1024) -> Image.Image:
    scale = 4
    canvas = size * scale
    img = Image.new("RGBA", (canvas, canvas), BG + (255,))
    draw = ImageDraw.Draw(img)

    # Subtle vertical gradient.
    for y in range(canvas):
        t = y / canvas
        r = int(BG[0] * (1 - t) + BG_2[0] * t)
        g = int(BG[1] * (1 - t) + BG_2[1] * t)
        b = int(BG[2] * (1 - t) + BG_2[2] * t)
        draw.line((0, y, canvas, y), fill=(r, g, b, 255))

    # Terminal grid, intentionally low contrast.
    step = 64 * scale
    for x in range(step, canvas, step):
        draw.line((x, 0, x, canvas), fill=(18, 36, 44, 50), width=1 * scale)
    for y in range(step, canvas, step):
        draw.line((0, y, canvas, y), fill=(18, 36, 44, 44), width=1 * scale)

    pad = 86 * scale
    radius = 184 * scale
    draw.rounded_rectangle(
        (pad, pad, canvas - pad, canvas - pad),
        radius=radius,
        fill=(8, 17, 23, 245),
        outline=(38, 245, 192, 95),
        width=10 * scale,
    )

    # Accent scanlines.
    draw.line(
        (168 * scale, 232 * scale, 856 * scale, 232 * scale),
        fill=GREEN + (210,),
        width=12 * scale,
    )
    draw.line(
        (168 * scale, 790 * scale, 620 * scale, 790 * scale),
        fill=CYAN + (180,),
        width=10 * scale,
    )

    # Prompt chevron.
    mono = font(FONT_MONO_BOLD, 188 * scale)
    draw.text((178 * scale, 338 * scale), ">", font=mono, fill=CYAN + (235,))

    # Monogram.
    mark_font = font(FONT_BLACK, 430 * scale)
    text = "ih"
    bbox = draw.textbbox((0, 0), text, font=mark_font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (canvas - tw) // 2 + 80 * scale
    ty = (canvas - th) // 2 - 14 * scale

    glow = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.text((tx, ty), text, font=mark_font, fill=GREEN + (180,))
    glow = glow.filter(ImageFilter.GaussianBlur(22 * scale))
    img.alpha_composite(glow)
    draw = ImageDraw.Draw(img)
    draw.text((tx, ty), text, font=mark_font, fill=WHITE + (255,))

    # Cursor block.
    draw.rounded_rectangle(
        (682 * scale, 660 * scale, 790 * scale, 724 * scale),
        radius=12 * scale,
        fill=GREEN + (255,),
    )

    # Small habit chain dots.
    for i, x in enumerate((246, 318, 390)):
        fill = GREEN if i < 2 else MUTED
        draw.ellipse(
            (
                x * scale,
                706 * scale,
                (x + 34) * scale,
                740 * scale,
            ),
            fill=fill + (245,),
        )
        if i < 2:
            draw.line(
                ((x + 36) * scale, 723 * scale, (x + 68) * scale, 723 * scale),
                fill=GREEN + (140,),
                width=6 * scale,
            )

    img = img.resize((size, size), Image.Resampling.LANCZOS)
    mask = rounded_rectangle_mask(size, 184)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def save_resized(source: Image.Image, path: Path, size: int):
    path.parent.mkdir(parents=True, exist_ok=True)
    source.resize((size, size), Image.Resampling.LANCZOS).save(path)


def main():
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    icon = make_icon(1024)
    icon.save(ASSET_DIR / "init_habits_logo_1024.png")
    icon.resize((512, 512), Image.Resampling.LANCZOS).save(
        ASSET_DIR / "init_habits_logo_512.png"
    )

    launcher_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    foreground_sizes = {
        "mipmap-mdpi": 108,
        "mipmap-hdpi": 162,
        "mipmap-xhdpi": 216,
        "mipmap-xxhdpi": 324,
        "mipmap-xxxhdpi": 432,
    }

    for density, px in launcher_sizes.items():
        save_resized(icon, RES_DIR / density / "ic_launcher.png", px)
        save_resized(icon, RES_DIR / density / "ic_launcher_round.png", px)

    # Adaptive icon foreground: transparent safe-zone centered mark.
    foreground = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    resized = icon.resize((760, 760), Image.Resampling.LANCZOS)
    foreground.alpha_composite(resized, (132, 132))
    foreground.save(ASSET_DIR / "init_habits_adaptive_foreground_1024.png")
    for density, px in foreground_sizes.items():
        save_resized(foreground, RES_DIR / density / "ic_launcher_foreground.png", px)


if __name__ == "__main__":
    main()
