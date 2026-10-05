#!/usr/bin/env python3
"""Build the printable layer map for the grazor Corne keymap.

Writes layer-map-color.html and layer-map-bw.html next to this script; print
them from a browser or turn them into PDFs with headless Chrome (see README
line at the bottom of the generated page footer).

The layer data below is written by hand to match
keyboards/crkbd/keymaps/grazor/keymap.c; update both together.
"""

from html import escape
from pathlib import Path

U = 16.0  # one key unit, mm
GAP = 1.2  # space between keycaps, mm

# Physical positions of LAYOUT_split_3x6_3, in key units (from crkbd info.json)
STAGGER = [0.3, 0.3, 0.1, 0.0, 0.1, 0.2]
GEOMETRY = []
for row in range(3):
    GEOMETRY += [(col, row + STAGGER[col], 1) for col in range(6)]
    GEOMETRY += [(9 + col, row + STAGGER[5 - col], 1) for col in range(6)]
GEOMETRY += [(4, 3.7, 1), (5, 3.7, 1), (6, 3.2, 1.5), (8, 3.2, 1.5), (9, 3.7, 1), (10, 3.7, 1)]


def K(main="", kind="plain", hold=None, shift=None, cap=None, strip="mod"):
    return dict(main=main, kind=kind, hold=hold, shift=shift, cap=cap, strip=strip)


X = K(kind="none")  # does nothing on this layer


def T(main, **kw):  # falls through to the base layer
    return K(main, kind="through", **kw)


CMD, OPT, CTL, SFT = "⌘", "⌥", "⌃", "⇧"

BASE = [
    K("`", shift="~"), K("q"), K("y"), K("o"), K("u"), K("=", shift="+"),
    K("x"), K("l"), K("d"), K("p"), K("z"), K("[", shift="{"),

    K("b"), K("c", hold=CTL), K("i", hold=OPT), K("a", hold=CMD), K("e", hold=SFT), K("-", shift="_"),
    K("k"), K("h", hold=SFT), K("t", hold=CMD), K("n", hold=OPT), K("s", hold=CTL), K("w"),

    K("Tab"), K("'", shift='"'), K(",", shift="<"), K(".", shift=">"), K(";", shift=":"), K("/", shift="?"),
    K("j"), K("m"), K("g"), K("f"), K("v"), X,

    K("Enter"), K("", hold="Numbers", strip="num"), K("Space"),
    K("r", hold="Command", strip="cmd"), K("", hold="Symbols", strip="sym"), K("⌫", cap="⇧ Delete"),
]

RUSSIAN = [
    T("ё"), K("й", "ru"), K("ц", "ru"), K("у", "ru"), K("к", "ru"), K("е", "ru"),
    K("н", "ru"), K("г", "ru"), K("ш", "ru"), K("щ", "ru"), K("з", "ru"), T("х"),

    T("и"), K("ф", "ru", hold=CTL), K("ы", "ru", hold=OPT), K("в", "ru", hold=CMD), K("а", "ru", hold=SFT), K("п", "ru"),
    K("р", "ru"), K("о", "ru", hold=SFT), K("л", "ru", hold=CMD), K("д", "ru", hold=OPT), K("ж", "ru", hold=CTL), K("э", "ru"),

    T("Tab"), K("я", "ru"), K("ч", "ru"), K("с", "ru"), K("м", "ru"), K("и", "ru"),
    K("т", "ru"), K("ь", "ru"), K("б", "ru"), K("ю", "ru"), K(".", "ru", shift=","), X,

    T("Enter"), T("", hold="Numbers", strip="num"), T("Space"),
    K("ъ", "ru", hold="Command", strip="cmd"), T("", hold="Symbols", strip="sym"), T("⌫", cap="⇧ Delete"),
]

SYMBOLS = [
    K("!", "pri"), K("[", "pri"), K("(", "pri"), K(")", "pri"), K("]", "pri"), K("?", "pri"),
    K("%", "pri"), K("+", "pri"), K("&", "pri"), K("'", "pri"), K(";", "pri"), K("`", "pri"),

    K("#", "pri"), K("^", "pri"), K("=", "pri"), K("_", "pri"), K("$", "pri"), K("*", "pri"),
    K("\\", "pri"), K("{", "pri"), K("}", "pri"), K('"', "pri"), K(":", "pri"), K("@", "pri"),

    K("~", "pri"), K("<", "pri"), K("|", "pri"), K("-", "pri"), K(">", "pri"), K("/", "pri"),
    X, X, K(",", "pri"), K(".", "pri"), X, K("Lock", "sec", cap="layer"),

    T("Enter"), T("", hold="Numbers", strip="num", cap="Typography"), T("Space"),
    X, K("held", "held"), T("⌫", cap="⇧ Delete"),
]

NUMBERS = [
    X, K("1", "pri"), K("2", "pri"), K("3", "pri"), K("4", "pri"), K("5", "pri"),
    K("6", "pri"), K("7", "pri"), K("8", "pri"), K("9", "pri"), K("0", "pri"), K("⌫", "sec"),

    X, K(CTL, "mod"), K(OPT, "mod"), K(CMD, "mod"), K(SFT, "mod"), K("Space", "sec"),
    K("*", "sec"), K("4", "pri"), K("5", "pri"), K("6", "pri"), K("+", "sec"), K("=", "sec"),

    K("Tab", "sec"), X, K(",", "pri"), K(".", "pri"), X, X,
    K("/", "sec"), K("1", "pri"), K("2", "pri"), K("3", "pri"), K("-", "sec"), K("Lock", "sec", cap="layer"),

    T("Enter"), K("held", "held"), T("Space"),
    K("0", "pri"), T("", hold="Symbols", strip="sym", cap="Typography"), T("⌫", cap="⇧ Delete"),
]

TYPOGRAPHY = [
    X, X, X, X, X, X,
    X, K("±", "pri"), K("∆", "pri"), K("π", "pri"), X, X,

    K("§", "pri"), K("°", "pri"), K("≠", "pri"), K("·", "pri"), K("€", "pri"), K("•", "pri"),
    X, X, K("™", "pri"), X, X, K("©", "pri"),

    K("≈", "pri"), K("≤", "pri"), K("∞", "pri"), K("—", "pri"), K("≥", "pri"), K("÷", "pri"),
    X, K("µ", "pri"), X, K("…", "pri"), K("√", "pri"), K("Lock", "sec", cap="layer"),

    T("Enter"), K("held", "held"), K("Space", "pri", cap="no-break"),
    X, K("held", "held"), T("⌫", cap="⇧ Delete"),
]

MOUSE = [
    X, X, X, X, X, X,
    X, K("Click", "sec", cap="left"), K("↑", "pri"), K("Click", "sec", cap="right"), K("Scroll", "sec", cap="up"), X,

    X, X, K("Click", "sec", cap="middle"), K("Click", "sec", cap="right"), K("Click", "sec", cap="left"), X,
    X, K("←", "pri"), K("↓", "pri"), K("→", "pri"), K("Scroll", "sec", cap="down"), X,

    X, X, X, X, X, X,
    X, X, X, X, X, K("Lock", "sec", cap="layer"),

    T("Enter"), K("held", "held"), T("Space"),
    K("held", "held"), X, T("⌫", cap="⇧ Delete"),
]

COMMAND = [
    K("F18", "sec", cap="mic"), X, X, K("EN", "sec", cap="layout"), K("RU", "sec", cap="layout"), K("⇧ Tab", "sec"),
    X, X, K("↑", "pri"), X, K("Page", "pri", cap="up"), K("Delete", "sec"),

    X, K(CTL, "mod"), K(OPT, "mod"), K(CMD, "mod"), K(SFT, "mod"), K("Tab", "sec"),
    X, K("←", "pri"), K("↓", "pri"), K("→", "pri"), K("Page", "pri", cap="down"), X,

    X, X, X, X, X, X,
    X, K("Vol −", "sec"), K("Mute", "sec"), K("Vol +", "sec"), X, K("Lock", "sec", cap="layer"),

    T("Enter"), T("", hold="Numbers", strip="num", cap="Mouse"), T("Space"),
    K("held", "held"), X, T("⌫", cap="⇧ Delete"),
]

LAYERS = {
    "base": dict(
        title="Enthium",
        keys=BASE,
        text="The base layer, in English. Hold a home-row key for the modifier on its lower edge, "
        "or a thumb key for the layer named on it. The display shows ENTH.",
    ),
    "ru": dict(
        title="Русский",
        keys=RUSSIAN,
        text="On whenever the system layout is Russian. Shortcuts with Control, Option or Command use the "
        "Enthium keys, so they stay under the same fingers. ъ is on the R thumb. The display shows RUS.",
    ),
    "sym": dict(
        title="Symbols",
        keys=SYMBOLS,
        text="Hold the middle key of the right thumb. Brackets and arrows roll inward on the left "
        "hand; Space, Enter and Backspace keep working. The display shows SYM.",
    ),
    "num": dict(
        title="Numbers",
        keys=NUMBERS,
        text="Hold the middle key of the left thumb. Digits run along the top row and again as a "
        "number pad under the right hand; comma and full stop sit where they are on the base layer. "
        "The display shows NUM.",
    ),
    "cmd": dict(
        title="Command",
        keys=COMMAND,
        text="Hold the R key on the right thumb. Arrows and paging under the right hand, layout "
        "switching and modifiers under the left. The display shows CMD.",
    ),
    "typo": dict(
        title="Typography",
        keys=TYPOGRAPHY,
        text="Hold both middle thumb keys. Signs sit on their plain cousin (— on -, ≤ ≥ on < >) or "
        "their Enthium letter (π on p, µ on m). Mac only. The display shows TYPO.",
    ),
    "mou": dict(
        title="Mouse",
        keys=MOUSE,
        text="Hold R for Command, then the middle key of the left thumb. The right hand moves the "
        "pointer; the left home row clicks, so you can hold a button and drag. The display shows MOUS.",
    ),
}


def main_class(text):
    if len(text) <= 1:
        return "glyph"
    return "word" if len(text) <= 5 else "word long"


# Keys under the resting fingers: pinky to index on each hand's home row
HOME = {13, 14, 15, 16, 19, 20, 21, 22}


def render_key(key, x, y, h, home=False):
    style = f"left:{x * U:.2f}mm;top:{y * U:.2f}mm;height:{h * U - GAP:.2f}mm"
    parts = []
    if key["shift"]:
        parts.append(f'<span class="shift">{escape(key["shift"])}</span>')
    face = f'<span class="main {main_class(key["main"])}">{escape(key["main"])}</span>' if key["main"] else ""
    if key["cap"]:
        face += f'<span class="cap">{escape(key["cap"])}</span>'
    parts.append(f'<span class="face">{face}</span>')
    if key["hold"]:
        size = "glyph" if len(key["hold"]) == 1 else "word"
        parts.append(f'<span class="hold {key["strip"]} {size}">{escape(key["hold"])}</span>')
    classes = f'key {key["kind"]}{" home" if home else ""}'
    return f'<div class="{classes}" style="{style}">{"".join(parts)}</div>'


def render_layer(name):
    layer = LAYERS[name]
    keys = "".join(
        render_key(key, *pos, home=index in HOME)
        for index, (key, pos) in enumerate(zip(layer["keys"], GEOMETRY, strict=True))
    )
    return f"""
    <section class="layer {name}">
      <header>
        <h2>{escape(layer["title"])}</h2>
        <p>{escape(layer["text"])}</p>
      </header>
      <div class="board">{keys}</div>
    </section>"""


def chip(*labels):
    return "".join(f'<span class="chip">{escape(label)}</span>' for label in labels)


NOTES = f"""
    <section class="notes">
      <header><h2>Between the layers</h2></header>
      <div class="grid">
      <div>
        <h3>Pressed together</h3>
        <dl>
          <dt>{chip("h", "t")}</dt><dd>Escape</dd>
          <dt>{chip("h", "t", "n")}</dt><dd>Escape, then English</dd>
          <dt>{chip("u", "-")}</dt><dd>English layout</dd>
          <dt>{chip("l", "k")}</dt><dd>Russian layout</dd>
        </dl>
        <p>The same four positions work in Russian.</p>
      </div>
      <div>
        <h3>Shift tricks</h3>
        <dl>
          <dt>{chip("⇧", "⇧")}</dt><dd>Caps Word: capitals until the word ends, in either layout</dd>
          <dt>{chip("⇧", "⌫")}</dt><dd>Delete</dd>
        </dl>
      </div>
      <div>
        <h3>Layouts</h3>
        <p>The keyboard follows the system layout, however you switch it. Its own EN and RU keys
        send Caps Lock and Shift + Caps Lock.</p>
        <p>In Russian, holding Symbols switches the system to English for as long as you hold it,
        so every symbol comes out the same in both layouts.</p>
      </div>
      <div>
        <h3>Symbol rolls</h3>
        <p>Roll inward on the left hand, pinky towards index:</p>
        <p class="rolls">{chip("( )")}{chip("[ ]")}{chip("< >")}{chip("->")}{chip("=>")}{chip("<-")}{chip("!=")}{chip("<=")}{chip("|>")}{chip("~/")}{chip("!(")}</p>
        <p>Slide one finger along its column:</p>
        <p class="rolls">{chip("/*")}{chip("*/")}{chip("#!")}</p>
        <p>Braces and quotes are on the right hand, so
        {chip("${")} {chip("={")} {chip("(" + chr(34))} alternate hands.</p>
      </div>
      <div>
        <h3>Staying on a layer</h3>
        <p>While holding a layer key, tap Lock (bottom right) and let go: the layer stays on.
        Tap Lock again to leave. Works for every layer you hold.</p>
      </div>
      <div>
        <h3>Right display</h3>
        <p>EN or RU in large type, the name of the layer you hold, and along the bottom the
        modifiers you hold, lit in finger order from pinky to index.</p>
      </div>
      <div>
        <h3>Home row</h3>
        <p>Each home key is a letter when tapped and a modifier when held: Control, Option,
        Command, Shift from pinky to index, mirrored on the right hand. On Linux, Control and
        the Super key trade places, so Control sits under the middle finger there.</p>
        <p>A modifier only takes hold with a key from the other hand, or after a short pause, so
        fast typing never triggers one by accident.</p>
      </div>
      <div>
        <h3>Reading the keys</h3>
        <ul class="legend">
          <li><span class="key plain swatch"><span class="face"><span class="main glyph">a</span></span><span class="hold mod glyph">⌃</span></span>Tap for the letter, hold for the lower edge</li>
          <li><span class="key plain home swatch"><span class="face"><span class="main glyph">t</span></span></span>Home position, where the fingers rest</li>
          <li><span class="key pri swatch"><span class="face"><span class="main glyph">7</span></span></span>What the layer is for</li>
          <li><span class="key sec swatch"><span class="face"><span class="main glyph">+</span></span></span>Extras on the layer</li>
          <li><span class="key held swatch"><span class="face"><span class="main word">held</span></span></span>The key you are holding</li>
          <li><span class="key through swatch"><span class="face"><span class="main word">Tab</span></span></span>Same as the base layer</li>
          <li><span class="key none swatch"></span>Does nothing</li>
        </ul>
      </div>
      </div>
    </section>"""

PAGES = [
    render_layer("base") + render_layer("ru"),
    render_layer("sym") + render_layer("typo"),
    render_layer("num") + render_layer("cmd"),
    render_layer("mou"),
    NOTES,
]

CSS = f"""
@page {{ size: A4 landscape; margin: 0; }}
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
html {{ -webkit-print-color-adjust: exact; print-color-adjust: exact; }}
body {{
  font-family: "Golos Text", "Helvetica Neue", "Apple Symbols", sans-serif;
  color: var(--ink); background: #d9dbe0;
  font-variant-ligatures: none; font-feature-settings: "liga" 0, "calt" 0, "dlig" 0;
}}
.sheet {{
  width: 297mm; height: 210mm; padding: 9mm 10mm 7mm; margin: 8mm auto;
  background: #fff; position: relative; overflow: hidden;
  display: flex; flex-direction: column; break-after: page;
}}
@media print {{
  body {{ background: none; }}
  .sheet {{ margin: 0; }}
}}

.layer {{ --hue: var(--ink); margin-bottom: 4.5mm; }}
.layer.ru  {{ --hue: var(--ru); }}
.layer.sym {{ --hue: var(--sym); }}
.layer.num {{ --hue: var(--num); }}
.layer.cmd {{ --hue: var(--cmd); }}
.layer.typo {{ --hue: var(--typ); }}
.layer.mou {{ --hue: var(--mou); }}

.layer header {{
  display: flex; align-items: flex-end; gap: 7mm;
  width: {15 * U}mm; margin: 0 auto 2.6mm; height: 10.5mm;
}}
h2 {{
  font-family: "Unbounded", "Golos Text", sans-serif; font-weight: 600;
  font-size: 8.4mm; line-height: 1; letter-spacing: -0.02em;
  color: var(--title, var(--hue)); white-space: nowrap;
}}
.layer header p {{
  font-size: 2.95mm; line-height: 1.38; max-width: 150mm; padding-bottom: 0.4mm;
}}

.board {{ position: relative; width: {15 * U}mm; height: {4.7 * U}mm; margin: 0 auto; }}

.key {{
  position: absolute; width: {U - GAP}mm; border-radius: 2.1mm;
  border: 0.22mm solid var(--edge); background: #fff;
  display: flex; flex-direction: column; overflow: hidden;
}}
.key.home::before {{
  content: ""; position: absolute; top: 1.15mm; left: 50%; width: 4.6mm; margin-left: -2.3mm;
  height: 0.75mm; border-radius: 0.4mm; background: var(--bump);
}}
.face {{
  flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 0.8mm; min-height: 0;
}}
.main {{ font-weight: 600; line-height: 1; }}
.main.glyph {{ font-size: 5.6mm; }}
.main.word {{ font-size: 2.9mm; }}
.main.long {{ font-size: 2.5mm; }}
.cap {{ font-size: 2.05mm; line-height: 1; color: var(--quiet); }}
.shift {{
  position: absolute; top: 1mm; right: 1.5mm; font-size: 2.7mm; line-height: 1;
  font-weight: 500; color: var(--quiet);
}}
.hold {{
  height: 4.4mm; flex: none; display: flex; align-items: center; justify-content: center;
  font-weight: 600; line-height: 1;
}}
.hold.glyph {{ font-size: 3.9mm; font-weight: 700; font-family: -apple-system, "Helvetica Neue", "Apple Symbols", sans-serif; }}
.key.mod .main, .chip {{ font-family: "Golos Text", -apple-system, "Helvetica Neue", sans-serif; }}
.hold.word {{ font-size: 2.15mm; }}

.notes {{ width: {15 * U}mm; margin: 0 auto; }}
.notes header {{ height: 10.5mm; display: flex; align-items: flex-end; margin-bottom: 6mm; }}
.notes .grid {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 8mm 10mm; }}
h3 {{ font-family: "Unbounded", "Golos Text", sans-serif; font-weight: 600; font-size: 3.7mm; margin-bottom: 3mm; }}
.notes p {{ font-size: 3.1mm; line-height: 1.42; margin-bottom: 2.2mm; }}
dl {{ display: grid; grid-template-columns: auto 1fr; gap: 2.8mm 3.5mm; align-items: center; margin-bottom: 3.5mm; }}
dt {{ display: flex; gap: 0.9mm; }}
dd {{ font-size: 3.2mm; line-height: 1.3; }}
.chip {{
  min-width: 6.6mm; height: 6.6mm; padding: 0 1.5mm; border-radius: 1.4mm;
  border: 0.22mm solid var(--edge); display: inline-flex; align-items: center; justify-content: center;
  font-size: 3.5mm; font-weight: 600; line-height: 1; white-space: nowrap;
}}
.rolls {{ display: flex; flex-wrap: wrap; gap: 1.2mm; }}
.legend {{ list-style: none; }}
.legend li {{ display: flex; align-items: center; gap: 3mm; font-size: 3.1mm; line-height: 1.25; margin-bottom: 1.3mm; }}
.key.swatch {{ position: relative; flex: none; width: 9mm; height: 9mm; border-radius: 1.5mm; --hue: var(--num); }}
.key.swatch.home::before {{ top: 0.8mm; width: 3.4mm; margin-left: -1.7mm; height: 0.6mm; }}
.swatch .main.glyph {{ font-size: 4mm; }}
.swatch .main.word {{ font-size: 2.2mm; }}
.swatch .hold {{ height: 3.1mm; }}
.swatch .hold.glyph {{ font-size: 2.3mm; }}

footer {{
  margin-top: auto; display: flex; justify-content: space-between;
  font-size: 2.4mm; color: var(--quiet);
}}
"""

THEMES = {
    "color": """
:root {
  --ink: #15171c; --quiet: #6d7480; --edge: #9aa1ab; --bump: #15171c;
  --ru: #cf2f4a; --sym: #6a48d7; --num: #0a8a76; --cmd: #d47a00; --mou: #1d6fd6; --typ: #4d8a12;
}
.hold.mod { background: #e3e6eb; }
.hold.num { background: var(--num); color: #fff; }
.hold.cmd { background: var(--cmd); color: #fff; }
.hold.sym { background: var(--sym); color: #fff; }
.key.ru   { background: color-mix(in srgb, var(--hue) 9%, #fff); border-color: color-mix(in srgb, var(--hue) 55%, #fff); }
.key.pri  { background: color-mix(in srgb, var(--hue) 17%, #fff); border-color: var(--hue); }
.key.sec  { border: 0.4mm solid var(--hue); color: color-mix(in srgb, var(--hue) 78%, #000); }
.key.sec .cap { color: inherit; opacity: 0.8; }
.key.mod  { background: #e3e6eb; }
.key.held { background: var(--hue); border-color: var(--hue); color: #fff; }
.key.through { border-style: dashed; border-color: #b9bec6; color: #9299a3; }
.key.through .cap, .key.through .shift { color: inherit; }
.key.through .hold { opacity: 0.45; }
.key.none { border-color: #e4e6ea; }
""",
    "bw": """
:root { --ink: #000; --quiet: #000; --edge: #000; --title: #000; --bump: #000; }
.hold.mod { border-top: 0.22mm solid #000; }
.hold.num, .hold.cmd, .hold.sym { background: #000; color: #fff; }
.key.pri  { border-width: 0.6mm; }
.key.sec  { border: 1.05mm double #000; }
.key.mod  { border-radius: 50%; }
.key.held { background: #000; color: #fff; }
.key.through { border-style: dashed; }
.key.through .main, .key.through .cap, .key.through .shift { font-weight: 400; }
.key.through .hold { background: none; color: #000; border-top: 0.22mm dashed #000; font-weight: 400; }
.key.none { border: 0.2mm dotted #000; }
.cap, .shift { font-weight: 400; }
""",
}

FONTS = (
    '<link rel="preconnect" href="https://fonts.googleapis.com">'
    '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
    '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?'
    'family=Golos+Text:wght@400;500;600;700&family=Unbounded:wght@500;600&display=swap">'
)


def build(theme):
    sheets = "".join(
        f'<article class="sheet">{body}'
        f"<footer><span>Corne, grazor keymap, Enthium v14</span><span>{number} of {len(PAGES)}</span></footer>"
        f"</article>"
        for number, body in enumerate(PAGES, 1)
    )
    return (
        '<!doctype html><html lang="en"><head><meta charset="utf-8">'
        f"<title>Corne layer map ({theme})</title>{FONTS}"
        f"<style>{CSS}{THEMES[theme]}</style></head><body>{sheets}</body></html>"
    )


if __name__ == "__main__":
    here = Path(__file__).parent
    for theme in THEMES:
        target = here / f"layer-map-{theme}.html"
        target.write_text(build(theme), encoding="utf-8")
        print(target)
