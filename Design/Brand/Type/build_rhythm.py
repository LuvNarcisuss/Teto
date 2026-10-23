"""Build the Teto Rhythm typeface.

Two original cuts share one brush: a round, forward-leaning ribbon.
Text is the quieter cut for reading. Display is heavier and more slanted for titles.
Neither cut is a system font. Run this file to rewrite the app font files.
"""

import math
import os
import shutil
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

EM = 1000
ASCENDER = 860
DESCENDER = -280


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def sample_line(a, b, n=10):
    return [((1 - t) * a[0] + t * b[0], (1 - t) * a[1] + t * b[1]) for t in (i / n for i in range(n + 1))]


def sample_quad(a, b, c, n=16):
    points = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        points.append((u * u * a[0] + 2 * u * t * b[0] + t * t * c[0], u * u * a[1] + 2 * u * t * b[1] + t * t * c[1]))
    return points


def dedupe(points):
    cleaned = [points[0]]
    for point in points[1:]:
        if dist(cleaned[-1], point) > 0.8:
            cleaned.append(point)
    return cleaned


def normal(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    length = math.hypot(dx, dy) or 1
    return (-dy / length, dx / length)


def stroke_outline(points, width, closed):
    points = dedupe(points)
    count = len(points)
    if count < 2:
        return []
    normals = []
    for index in range(count):
        if closed:
            before = points[index - 1]
            after = points[(index + 1) % count]
        elif index == 0:
            before, after = points[0], points[1]
        elif index == count - 1:
            before, after = points[-2], points[-1]
        else:
            before, after = points[index - 1], points[index + 1]
        normals.append(normal(before, after))
    half = width / 2
    left = [(point[0] + nx * half, point[1] + ny * half) for point, (nx, ny) in zip(points, normals)]
    right = [(point[0] - nx * half, point[1] - ny * half) for point, (nx, ny) in zip(points, normals)]
    if closed:
        # Centerline runs counter-clockwise, so the left side is the outer edge.
        return [list(reversed(left)), right]
    end = round_cap(points[-1], normals[-1], half, outward=True)
    start = round_cap(points[0], normals[0], half, outward=False)
    return [left + end + list(reversed(right)) + start]


def round_cap(point, normal_vector, radius, outward):
    # Walk from the left side of the stroke to the right, bulging along the tangent.
    tangent = (normal_vector[1], -normal_vector[0]) if outward else (-normal_vector[1], normal_vector[0])
    steps = 7
    points = []
    for step in range(1, steps):
        angle = math.pi * step / steps
        mix_n = math.cos(angle)
        mix_t = math.sin(angle)
        points.append((
            point[0] + (normal_vector[0] * mix_n + tangent[0] * mix_t) * radius,
            point[1] + (normal_vector[1] * mix_n + tangent[1] * mix_t) * radius,
        ))
    return points


def disk(cx, cy, radius, steps=24):
    return [
        (cx + radius * math.cos(-2 * math.pi * i / steps), cy + radius * math.sin(-2 * math.pi * i / steps))
        for i in range(steps)
    ]


def ellipse(cx, cy, rx, ry, start, end, steps=48):
    points = []
    for i in range(steps + 1):
        angle = start + (end - start) * i / steps
        points.append((cx + rx * math.cos(angle), cy + ry * math.sin(angle)))
    return points


class Path(list):
    def __init__(self, points=None, closed=False):
        super().__init__(points or [])
        self.closed = closed


class Ink:
    def __init__(self):
        self.paths = []
        self.dots = []
        self.current = None

    def move(self, x, y):
        self.current = Path([(x, y)])
        self.paths.append(self.current)
        return self

    def line(self, x, y):
        self.current.extend(sample_line(self.current[-1], (x, y))[1:])
        return self

    def quad(self, cx, cy, x, y):
        self.current.extend(sample_quad(self.current[-1], (cx, cy), (x, y))[1:])
        return self

    def oval(self, cx, cy, rx, ry):
        self.paths.append(Path(ellipse(cx, cy, rx, ry, 0, math.tau, 56)[:-1], closed=True))
        return self

    def arc(self, cx, cy, rx, ry, start_deg, end_deg):
        start, end = math.radians(start_deg), math.radians(end_deg)
        if end < start:
            end += math.tau
        points = Path(ellipse(cx, cy, rx, ry, start, end, 40))
        self.paths.append(points)
        self.current = points
        return self

    def dot(self, x, y, radius):
        self.dots.append((x, y, radius))
        return self

    def contours(self, width):
        shapes = []
        for path in self.paths:
            shapes.extend(stroke_outline(path, width, path.closed))
        for x, y, radius in self.dots:
            shapes.append(disk(x, y, radius))
        return shapes


def shear(contours, amount):
    return [[(x + y * amount, y) for x, y in contour] for contour in contours]


def fit(contours, pad):
    xs = [x for contour in contours for x, _ in contour]
    min_x, max_x = min(xs), max(xs)
    shift = pad - min_x
    moved = [[(x + shift, y) for x, y in contour] for contour in contours]
    advance = int(math.ceil(max_x + shift + pad))
    return moved, advance


def glyph_from(contours):
    pen = TTGlyphPen(None)
    for contour in contours:
        if len(contour) < 3:
            continue
        pen.moveTo(contour[0])
        for point in contour[1:]:
            pen.lineTo(point)
        pen.closePath()
    return pen.glyph()


# Visual guides. Round caps sit on these lines.
H = 500
C = 730
A = 820
D = -210


def letters(swash):
    """Return a map of glyph name to an Ink drawing, before slant and weight."""
    g = {}

    def put(name, ink):
        g[name] = ink

    a = Ink()
    a.oval(205, 255, 128, 178)
    a.move(318, 70).quad(348, 300, 338, H)
    put("a", a)

    b = Ink()
    b.move(128, 8).line(118, A)
    b.oval(268, 245, 122, 175)
    put("b", b)

    c = Ink()
    c.arc(190, 255, 158, 205, 70, 290)
    put("c", c)

    d = Ink()
    d.oval(188, 255, 128, 180)
    d.move(312, 60).quad(330, 420, 322, A)
    put("d", d)

    e = Ink()
    e.arc(186, 255, 152, 198, 55, 305)
    e.move(55, 250).quad(170, 300, 310, 262)
    put("e", e)

    f = Ink()
    f.move(196, 10).quad(150, 360, 168, 620).quad(190, 820, 300, 790)
    f.move(78, 430).quad(170, 470, 292, 448)
    put("f", f)

    ge = Ink()
    ge.oval(196, 300, 124, 165)
    ge.move(308, 250).quad(360, 40, 250, D + 20).quad(90, D - 10, 70, -40)
    if swash:
        ge.quad(40, 80, 150, 40)
    put("g", ge)

    h = Ink()
    h.move(112, 0).line(104, A)
    h.move(112, 390).quad(250, 640, 348, 8)
    put("h", h)

    i = Ink()
    i.move(150, 16).line(156, H - 10)
    i.dot(168, 650, 34)
    put("i", i)

    j = Ink()
    j.move(186, H - 10).quad(170, 80, 120, -40).quad(70, D, 20, -90)
    j.dot(196, 650, 34)
    put("j", j)

    k = Ink()
    k.move(112, 0).line(104, A)
    k.move(320, H).quad(200, 360, 130, 250)
    k.move(168, 300).quad(230, 180, 340, 0)
    put("k", k)

    l = Ink()
    l.move(150, 20).quad(142, 400, 146, A)
    put("l", l)

    m = Ink()
    m.move(96, 8).line(90, H)
    m.move(96, 390).quad(210, 640, 292, 8)
    m.move(292, 390).quad(410, 640, 492, 8)
    put("m", m)

    n = Ink()
    n.move(108, 8).line(100, H)
    n.move(108, 390).quad(250, 650, 352, 8)
    put("n", n)

    o = Ink()
    o.oval(214, 255, 156, 205)
    if swash:
        o.move(330, 90).quad(430, 20, 470, 70)
    put("o", o)

    p = Ink()
    p.move(126, D).line(118, H)
    p.oval(268, 245, 124, 172)
    put("p", p)

    q = Ink()
    q.oval(190, 255, 132, 182)
    q.move(312, 220).quad(348, 40, 360, D).quad(372, D - 30, 430, -120 if swash else -70)
    put("q", q)

    r = Ink()
    r.move(112, 8).line(106, H)
    r.move(112, 360).quad(230, 560, 318, 400)
    put("r", r)

    s = Ink()
    s.move(300, 450).quad(330, 560, 160, 530).quad(20, 500, 70, 370).quad(130, 230, 240, 210).quad(390, 180, 300, 50).quad(190, -30, 60, 55)
    put("s", s)

    t = Ink()
    t.move(176, 0).line(168, 700)
    t.move(40, 400).quad(160, 455, 310, 412)
    put("t", t)

    u = Ink()
    u.move(100, H).quad(80, 80, 210, 50).quad(340, 20, 328, H)
    put("u", u)

    v = Ink()
    v.move(70, H).quad(150, 180, 196, 16).quad(250, 180, 360, H)
    put("v", v)

    w = Ink()
    w.move(36, H).quad(90, 160, 130, 20).quad(180, 220, 230, 360).quad(280, 180, 330, 16).quad(390, 200, 450, H)
    put("w", w)

    x = Ink()
    x.move(64, H).quad(170, 260, 300, 10)
    x.move(70, 16).quad(180, 250, 312, H)
    put("x", x)

    y = Ink()
    y.move(72, H).quad(140, 240, 196, 150)
    y.move(348, H).quad(250, 220, 196, 150).quad(90, -20, 70, D)
    if swash:
        y.quad(40, D - 40, 130, -80)
    put("y", y)

    z = Ink()
    z.move(64, H - 16).quad(180, H + 20, 312, H)
    z.move(300, H - 10).quad(180, 260, 70, 24)
    z.move(62, 16).quad(180, 0, 324, 28)
    put("z", z)

    put("A", cap_a(swash))
    put("B", cap_b())
    put("C", cap_c())
    put("D", cap_d())
    put("E", cap_e())
    put("F", cap_f())
    put("G", cap_g())
    put("H", cap_h())
    put("I", cap_i())
    put("J", cap_j())
    put("K", cap_k())
    put("L", cap_l())
    put("M", cap_m())
    put("N", cap_n())
    put("O", cap_o(swash))
    put("P", cap_p())
    put("Q", cap_q(swash))
    put("R", cap_r())
    put("S", cap_s())
    put("T", cap_t(swash))
    put("U", cap_u())
    put("V", cap_v())
    put("W", cap_w())
    put("X", cap_x())
    put("Y", cap_y(swash))
    put("Z", cap_z())

    for name, ink in digits().items():
        put(name, ink)
    for name, ink in marks(swash).items():
        put(name, ink)
    return g


def cap_a(swash):
    ink = Ink()
    ink.move(70, 10).quad(180, 200, 230, C)
    ink.move(392, 10).quad(300, 280, 230, C)
    ink.move(130, 250).quad(230, 300, 340, 240)
    if swash:
        ink.move(210, C).quad(280, C + 80, 360, C + 30)
    return ink


def cap_b():
    ink = Ink()
    ink.move(120, 0).line(108, C)
    ink.oval(250, 520, 118, 150)
    ink.oval(246, 190, 128, 165)
    return ink


def cap_c():
    ink = Ink()
    ink.arc(200, 365, 190, 290, 68, 292)
    return ink


def cap_d():
    ink = Ink()
    ink.move(100, 0).line(92, C)
    ink.oval(292, 365, 188, 330)
    return ink


def cap_e():
    ink = Ink()
    ink.move(118, 0).line(108, C)
    ink.move(118, C - 20).line(360, C)
    ink.move(112, 360).line(330, 380)
    ink.move(118, 16).line(340, 30)
    return ink


def cap_f():
    ink = Ink()
    ink.move(124, 0).line(112, C)
    ink.move(118, C - 16).quad(230, C + 30, 370, C - 10)
    ink.move(100, 370).line(330, 392)
    return ink


def cap_g():
    ink = Ink()
    ink.arc(200, 390, 190, 285, 60, 300)
    ink.move(230, 370).line(400, 356)
    ink.move(360, 370).quad(390, 160, 250, 30)
    return ink


def cap_h():
    ink = Ink()
    ink.move(112, 0).line(102, C)
    ink.move(360, 0).line(348, C)
    ink.move(112, 360).line(352, 384)
    return ink


def cap_i():
    ink = Ink()
    ink.move(150, 0).line(156, C)
    ink.move(70, C - 10).line(250, C + 8)
    ink.move(80, 12).line(250, 24)
    return ink


def cap_j():
    ink = Ink()
    ink.move(210, C).quad(190, 200, 120, 20).quad(40, D + 40, 150, D + 80)
    ink.move(120, C - 8).line(300, C + 10)
    return ink


def cap_k():
    ink = Ink()
    ink.move(112, 0).line(102, C)
    ink.move(360, C).quad(200, 420, 140, 300)
    ink.move(180, 340).quad(260, 180, 390, 0)
    return ink


def cap_l():
    ink = Ink()
    ink.move(130, 0).line(122, C)
    ink.move(122, 16).line(300, 28)
    return ink


def cap_m():
    ink = Ink()
    ink.move(70, 0).line(60, C)
    ink.move(70, C - 30).quad(180, C + 40, 230, 10)
    ink.move(230, C - 40).quad(340, C + 40, 400, 10)
    return ink


def cap_n():
    ink = Ink()
    ink.move(96, 8).line(88, C)
    ink.move(104, C - 24).line(348, 16)
    ink.move(340, 8).line(352, C)
    return ink


def cap_o(swash):
    ink = Ink()
    ink.oval(230, 365, 180, 285)
    if swash:
        ink.move(360, 120).quad(470, 40, 520, 110)
    return ink


def cap_p():
    ink = Ink()
    ink.move(120, 0).line(108, C)
    ink.oval(280, 500, 145, 175)
    return ink


def cap_q(swash):
    ink = Ink()
    ink.oval(220, 380, 175, 270)
    ink.move(340, 180).line(430, -30 if not swash else -90)
    return ink


def cap_r():
    ink = Ink()
    ink.move(116, 0).line(106, C)
    ink.oval(270, 530, 130, 150)
    ink.move(250, 400).quad(330, 240, 400, 0)
    return ink


def cap_s():
    ink = Ink()
    ink.move(360, 620).quad(390, 790, 180, 740).quad(0, 680, 70, 500).quad(150, 320, 280, 280).quad(450, 220, 340, 60).quad(200, -40, 50, 60)
    return ink


def cap_t(swash):
    ink = Ink()
    ink.move(210, 0).quad(190, 360, 200, C - 40)
    if swash:
        ink.move(20, 640).quad(180, 760, 430, 820)
    else:
        ink.move(40, 690).quad(200, 760, 390, 710)
    return ink


def cap_u():
    ink = Ink()
    ink.move(100, C).quad(80, 80, 230, 40).quad(390, 0, 370, C)
    return ink


def cap_v():
    ink = Ink()
    ink.move(60, C).quad(170, 200, 230, 10).quad(300, 220, 430, C)
    return ink


def cap_w():
    ink = Ink()
    ink.move(30, C).quad(90, 160, 130, 16).quad(190, 240, 250, 420).quad(310, 180, 360, 12).quad(430, 200, 500, C)
    return ink


def cap_x():
    ink = Ink()
    ink.move(60, C).quad(200, 360, 390, 10)
    ink.move(70, 16).quad(210, 340, 400, C)
    return ink


def cap_y(swash):
    ink = Ink()
    ink.move(70, C).quad(160, 280, 230, 160)
    ink.move(420, C).quad(300, 240, 230, 160).quad(110, 20, 90, D + 10)
    if swash:
        ink.quad(60, D - 30, 160, -60)
    return ink


def cap_z():
    ink = Ink()
    ink.move(60, C - 10).quad(200, C + 30, 400, C)
    ink.move(380, C - 16).quad(210, 360, 70, 24)
    ink.move(60, 16).quad(210, -10, 410, 30)
    return ink


def digits():
    found = {}
    zero = Ink()
    zero.oval(180, 360, 130, 250)
    found["zero"] = zero
    one = Ink()
    one.move(150, 20).line(168, 700)
    one.move(90, 600).quad(130, 700, 168, 700)
    one.move(80, 20).line(250, 28)
    found["one"] = one
    two = Ink()
    two.move(70, 560).quad(80, 760, 220, 700).quad(380, 630, 250, 300).quad(140, 80, 60, 30)
    two.move(60, 24).line(340, 36)
    found["two"] = two
    three = Ink()
    three.move(70, 640).quad(80, 790, 220, 730).quad(390, 650, 240, 420)
    three.move(150, 400).quad(360, 380, 300, 180).quad(240, -20, 70, 50)
    found["three"] = three
    four = Ink()
    four.move(250, 20).line(268, 720)
    four.move(40, 250).line(330, 270)
    four.move(250, 720).quad(80, 500, 50, 260)
    found["four"] = four
    five = Ink()
    five.move(300, 700).line(80, 680).quad(70, 400, 120, 360)
    five.move(90, 380).quad(300, 430, 320, 180).quad(330, -20, 80, 40)
    found["five"] = five
    six = Ink()
    # One bowl and a short open cap. The cap stays above the bowl and does not
    # turn back down. A hook that returns to the far rim reads as an eight.
    six.oval(200, 175, 128, 145)
    six.move(190, 300).line(125, 530).quad(100, 700, 260, 720)
    found["six"] = six
    seven = Ink()
    seven.move(50, 690).quad(180, 760, 340, 710)
    seven.move(320, 700).quad(230, 360, 140, 16)
    found["seven"] = seven
    eight = Ink()
    eight.oval(180, 540, 120, 145)
    eight.oval(180, 190, 132, 165)
    found["eight"] = eight
    nine = Ink()
    nine.oval(190, 520, 128, 160)
    nine.move(300, 400).quad(330, 80, 180, 10).quad(40, -30, 90, 180)
    found["nine"] = nine
    return found


def marks(swash):
    ink = {}

    def add(name, drawing):
        ink[name] = drawing

    period = Ink()
    period.dot(70, 70, 32)
    add("period", period)
    comma = Ink()
    comma.dot(80, 70, 30)
    comma.move(80, 50).quad(70, -20, 30, -70)
    add("comma", comma)
    colon = Ink()
    colon.dot(70, 160, 28)
    colon.dot(78, 420, 28)
    add("colon", colon)
    semicolon = Ink()
    semicolon.dot(78, 420, 28)
    semicolon.dot(74, 140, 26)
    semicolon.move(74, 120).quad(60, 40, 24, -20)
    add("semicolon", semicolon)
    excl = Ink()
    excl.move(90, 220).line(110, 720)
    excl.dot(86, 70, 30)
    add("exclam", excl)
    question = Ink()
    question.move(60, 620).quad(70, 800, 210, 740).quad(360, 670, 250, 430).quad(180, 280, 180, 220)
    question.dot(170, 70, 30)
    add("question", question)
    hyphen = Ink()
    hyphen.move(30, 280).quad(140, 310, 250, 286)
    add("hyphen", hyphen)
    endash = Ink()
    endash.move(20, 280).quad(160, 320, 340, 286)
    add("endash", endash)
    emdash = Ink()
    emdash.move(16, 280).quad(220, 330, 460, 286)
    add("emdash", emdash)
    quote = Ink()
    quote.move(70, 620).quad(50, 500, 40, 420)
    add("quotesingle", quote)
    quotedbl = Ink()
    quotedbl.move(50, 640).quad(34, 520, 26, 440)
    quotedbl.move(130, 650).quad(114, 530, 106, 450)
    add("quotedbl", quotedbl)
    quoteleft = Ink()
    quoteleft.move(40, 520).quad(70, 680, 110, 640)
    add("quoteleft", quoteleft)
    quoteright = Ink()
    quoteright.move(110, 640).quad(70, 500, 40, 540)
    add("quoteright", quoteright)
    quotedblleft = Ink()
    quotedblleft.move(30, 520).quad(60, 690, 100, 640)
    quotedblleft.move(120, 530).quad(150, 700, 190, 650)
    add("quotedblleft", quotedblleft)
    quotedblright = Ink()
    quotedblright.move(100, 650).quad(60, 500, 30, 540)
    quotedblright.move(190, 660).quad(150, 510, 120, 550)
    add("quotedblright", quotedblright)
    parenleft = Ink()
    parenleft.arc(180, 360, 120, 340, 110, 250)
    add("parenleft", parenleft)
    parenright = Ink()
    parenright.arc(40, 360, 120, 340, -70, 70)
    add("parenright", parenright)
    slash = Ink()
    slash.move(40, -20).line(220, 760)
    add("slash", slash)
    ampersand = Ink()
    ampersand.oval(150, 500, 95, 120)
    ampersand.move(70, 40).quad(40, 180, 160, 280).quad(280, 380, 210, 560)
    ampersand.move(150, 300).quad(240, 160, 360, 40)
    add("ampersand", ampersand)
    at = Ink()
    at.oval(210, 300, 80, 90)
    at.arc(210, 320, 160, 200, 40, 340)
    add("at", at)
    numbersign = Ink()
    numbersign.move(90, 40).line(150, 620)
    numbersign.move(210, 30).line(270, 610)
    numbersign.move(30, 220).line(330, 250)
    numbersign.move(50, 420).line(360, 450)
    add("numbersign", numbersign)
    plus = Ink()
    plus.move(40, 300).line(280, 312)
    plus.move(156, 140).line(164, 480)
    add("plus", plus)
    percent = Ink()
    percent.oval(90, 560, 60, 70)
    percent.oval(250, 140, 64, 74)
    percent.move(280, 680).line(60, 40)
    add("percent", percent)
    asterisk = Ink()
    asterisk.move(120, 420).line(128, 700)
    asterisk.move(40, 500).line(210, 640)
    asterisk.move(210, 500).line(40, 640)
    add("asterisk", asterisk)
    ellipsis = Ink()
    ellipsis.dot(40, 70, 26)
    ellipsis.dot(130, 70, 26)
    ellipsis.dot(220, 70, 26)
    add("ellipsis", ellipsis)
    bullet = Ink()
    bullet.dot(70, 280, 36)
    add("bullet", bullet)
    periodcentered = Ink()
    periodcentered.dot(60, 280, 28)
    add("periodcentered", periodcentered)
    arrow = Ink()
    arrow.move(20, 300).line(300, 312)
    arrow.move(210, 180).line(330, 310)
    arrow.move(210, 440).line(330, 308)
    add("arrowright", arrow)
    dollar = Ink()
    dollar.move(300, 600).quad(320, 760, 150, 710).quad(0, 650, 70, 460).quad(150, 280, 270, 250).quad(420, 210, 300, 40).quad(180, -30, 40, 50)
    dollar.move(170, -10).line(186, 780)
    add("dollar", dollar)
    colon_unused = swash  # keeps the argument visible to callers
    del colon_unused
    return ink


NAMES = {
    "space": 32,
    "zero": 48, "one": 49, "two": 50, "three": 51, "four": 52,
    "five": 53, "six": 54, "seven": 55, "eight": 56, "nine": 57,
    "A": 65, "B": 66, "C": 67, "D": 68, "E": 69, "F": 70, "G": 71, "H": 72, "I": 73,
    "J": 74, "K": 75, "L": 76, "M": 77, "N": 78, "O": 79, "P": 80, "Q": 81, "R": 82,
    "S": 83, "T": 84, "U": 85, "V": 86, "W": 87, "X": 88, "Y": 89, "Z": 90,
    "a": 97, "b": 98, "c": 99, "d": 100, "e": 101, "f": 102, "g": 103, "h": 104, "i": 105,
    "j": 106, "k": 107, "l": 108, "m": 109, "n": 110, "o": 111, "p": 112, "q": 113, "r": 114,
    "s": 115, "t": 116, "u": 117, "v": 118, "w": 119, "x": 120, "y": 121, "z": 122,
    "period": 46, "comma": 44, "colon": 58, "semicolon": 59, "exclam": 33, "question": 63,
    "hyphen": 45, "quotesingle": 39, "quotedbl": 34,
    "parenleft": 40, "parenright": 41, "slash": 47, "ampersand": 38, "at": 64,
    "numbersign": 35, "plus": 43, "percent": 37, "asterisk": 42,
    "ellipsis": 0x2026, "bullet": 0x2022, "periodcentered": 0x00B7, "arrowright": 0x2192,
    "endash": 0x2013, "emdash": 0x2014,
    "quoteleft": 0x2018, "quoteright": 0x2019, "quotedblleft": 0x201C, "quotedblright": 0x201D,
    "dollar": 36,
}


def build(path, family_style, ps_name, weight, slant, stroke, swash, italic):
    drawings = letters(swash)
    glyphs = {}
    metrics = {}
    order = [".notdef", "space"]
    missing = Ink()
    missing.move(40, 0).line(40, 700).line(360, 700).line(360, 0).line(40, 0)
    contours = shear(missing.contours(stroke * 0.7), slant)
    contours, advance = fit(contours, 40)
    glyphs[".notdef"] = glyph_from(contours)
    metrics[".notdef"] = (advance, 0)
    metrics["space"] = (320 if not swash else 300, 0)
    glyphs["space"] = glyph_from([])
    for name in NAMES:
        if name == "space":
            continue
        order.append(name)
        contours = shear(drawings[name].contours(stroke), slant)
        contours, advance = fit(contours, 36 if not swash else 30)
        glyphs[name] = glyph_from(contours)
        metrics[name] = (advance, 0)
    order.extend(name for name in NAMES if name not in order)
    builder = FontBuilder(EM, isTTF=True)
    builder.setupGlyphOrder(order)
    builder.setupCharacterMap({code: name for name, code in NAMES.items()})
    builder.setupGlyf(glyphs)
    builder.setupHorizontalMetrics(metrics)
    builder.setupHorizontalHeader(ascent=ASCENDER, descent=DESCENDER, lineGap=80)
    builder.setupOS2(
        sTypoAscender=ASCENDER,
        sTypoDescender=DESCENDER,
        sTypoLineGap=80,
        usWinAscent=ASCENDER,
        usWinDescent=abs(DESCENDER),
        sxHeight=H,
        sCapHeight=C,
        usWeightClass=weight,
        fsSelection=(0x01 if italic else 0) | (0x20 if weight >= 700 else 0x40),
        usWidthClass=5,
    )
    builder.setupPost(italicAngle=-math.degrees(math.atan(slant)))
    builder.setupNameTable({
        "familyName": "Teto Rhythm",
        "styleName": family_style,
        "uniqueFontIdentifier": f"Teto Rhythm {family_style}",
        "fullName": f"Teto Rhythm {family_style}",
        "psName": ps_name,
        "version": "Version 1.000",
        "designer": "Teto",
        "description": "Original ribbon lettering for the Teto dance app.",
        "typographicFamily": "Teto Rhythm",
        "typographicSubfamily": family_style,
    })
    mac_style = (1 if weight >= 700 else 0) | (2 if italic else 0)
    builder.font["head"].macStyle = mac_style
    builder.save(path)


def main():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
    destinations = [
        os.path.join(root, "Teto", "Resources", "Fonts"),
        os.path.join(root, "Agreements"),
    ]
    for folder in destinations:
        os.makedirs(folder, exist_ok=True)
    primary = destinations[0]
    build(
        os.path.join(primary, "TetoRhythm-Text.ttf"),
        "Text", "TetoRhythm-Text", 500, 0.18, 78, False, False,
    )
    build(
        os.path.join(primary, "TetoRhythm-Display.ttf"),
        "Display", "TetoRhythm-Display", 700, 0.30, 108, True, True,
    )
    for folder in destinations[1:]:
        for name in ("TetoRhythm-Text.ttf", "TetoRhythm-Display.ttf"):
            shutil.copy2(os.path.join(primary, name), os.path.join(folder, name))
    print("wrote", ", ".join(destinations))


if __name__ == "__main__":
    main()
