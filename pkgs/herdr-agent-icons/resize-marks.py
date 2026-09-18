"""状態の記号のうち、大きすぎる 2 つを idle の輪と同じ大きさに縮める。

herdr-radar は SVG から TTF を作るときに、字ごとの拡大率 (tools/codepoints.toml の
[fit]) を焼き込んでいる。そこで小さく調整されているのは、タイトルの横に並ぶ
idle の輪 (0.68) と blocked の疑問符 (0.88) だけで、

  E1C4 塗り丸 (idle_fresh)  … radar が使うのをやめたので、既定の 1.20 のまま
  E1C3 点線の丸 (unknown)   … 使ってはいるが、めったに出ないので調整されていない

の 2 つは cell いっぱいの大きさで残っている。herdr-glance は idle を 3 段階に分けて
塗り丸も使うので、この 2 つだけ輪に合わせて縮め、輪の中心に置き直す。

字形そのものは変えない (拡大縮小と平行移動だけ)。done のチェックと blocked の疑問符は
「起きたこと」を知らせる記号なので、大きいまま触らない。
"""

import sys

from fontTools.misc.transform import Transform
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

RING = 0xE1C2  # 大きさと位置の手本 (state_idle)
RESIZE = (0xE1C3, 0xE1C4)  # state_unknown, state_idle_fresh


def box(glyphset, name):
    pen = BoundsPen(glyphset)
    glyphset[name].draw(pen)
    x0, y0, x1, y1 = pen.bounds
    return (x1 - x0, y1 - y0, (x0 + x1) / 2, (y0 + y1) / 2)


def main(src, dst):
    font = TTFont(src)
    cmap = font.getBestCmap()
    glyphset = font.getGlyphSet()
    glyf = font["glyf"]

    ring_w, ring_h, ring_cx, ring_cy = box(glyphset, cmap[RING])
    target = max(ring_w, ring_h)

    for codepoint in RESIZE:
        name = cmap[codepoint]
        width, height, cx, cy = box(glyphset, name)
        scale = target / max(width, height)
        # 点は中心を輪に合わせてから縮める (後ろに書いたものが先に効く)
        transform = Transform().translate(ring_cx, ring_cy).scale(scale).translate(-cx, -cy)
        record = DecomposingRecordingPen(glyphset)
        glyphset[name].draw(record)
        pen = TTGlyphPen(glyphset)
        record.replay(TransformPen(pen, transform))
        glyf[name] = pen.glyph()
        glyf[name].recalcBounds(glyf)

    # 同じ版のまま字形だけ変えると、macOS が古い字形を使い続けることがある
    font["head"].fontRevision = round(font["head"].fontRevision + 0.001, 3)
    for record in font["name"].names:
        if record.nameID in (3, 5):  # 固有名と版の文字列 (family は変えない)
            record.string = record.toUnicode() + "; glance"

    font.save(dst)

    # 縮めたつもりで縮んでいない、を防ぐ
    check = TTFont(dst)
    checkset = check.getGlyphSet()
    for codepoint in RESIZE:
        width, height, cx, cy = box(checkset, check.getBestCmap()[codepoint])
        assert abs(max(width, height) - target) <= 1, (codepoint, width, height)
        assert abs(cx - ring_cx) <= 1 and abs(cy - ring_cy) <= 1, (codepoint, cx, cy)
        print(f"U+{codepoint:04X}: {width:.0f} x {height:.0f} (ring {target:.0f})")


if __name__ == "__main__":
    main(*sys.argv[1:3])
