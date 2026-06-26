#!/usr/bin/env bash
# SVG → SYADOW 앱 아이콘 (1024x1024 PNG) 생성.
# 사용법:
#   bash tools/build_icon_from_svg.sh s          # source_s.svg 사용 (정사각형 S)
#   bash tools/build_icon_from_svg.sh wordmark   # source_wordmark.svg 사용 (가로형)

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-s}"

if [[ "$MODE" == "s" ]]; then
  SVG="assets/icon/source_s.svg"
  CONTENT_RATIO=0.60      # S는 카드의 60% 폭
  OUT_PNG="assets/icon/app_icon.png"
elif [[ "$MODE" == "wordmark" ]]; then
  SVG="assets/icon/source_wordmark.svg"
  CONTENT_RATIO=0.78      # 워드마크는 좀 더 크게
  OUT_PNG="assets/icon/app_icon.png"
else
  echo "Usage: $0 [s|wordmark]" >&2
  exit 1
fi

SIZE=1024
BORDER=30
RADIUS=224
INNER_RADIUS=$((RADIUS - BORDER))

MIDNIGHT="#0B132B"
NEON_CYAN="#22D3EE"
NEON_PURPLE="#A78BFA"
NEON_PINK="#F472B6"

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# 1) 짙은 둥근사각형 베이스
magick -size ${SIZE}x${SIZE} xc:none \
  -fill "$MIDNIGHT" \
  -draw "roundrectangle 0,0 $((SIZE-1)),$((SIZE-1)) $RADIUS,$RADIUS" \
  "$TMP/base.png"

# 2) 그라데이션 (cyan→pink 대각선) + 보라 중앙
magick -size ${SIZE}x${SIZE} gradient:"$NEON_CYAN-$NEON_PINK" \
  -rotate 45 -gravity center -extent ${SIZE}x${SIZE} \
  "$TMP/grad.png"
magick "$TMP/grad.png" \
  \( -size ${SIZE}x${SIZE} radial-gradient:"$NEON_PURPLE-none" -evaluate Multiply 0.5 \) \
  -compose Over -composite "$TMP/grad.png"

# 3) 링 마스크 (보더 영역만 흰색)
INNER_OFF=$BORDER
INNER_END=$((SIZE - BORDER - 1))
magick -size ${SIZE}x${SIZE} xc:black \
  -fill white -draw "roundrectangle 0,0 $((SIZE-1)),$((SIZE-1)) $RADIUS,$RADIUS" \
  -fill black -draw "roundrectangle $INNER_OFF,$INNER_OFF $INNER_END,$INNER_END $INNER_RADIUS,$INNER_RADIUS" \
  "$TMP/ring_mask.png"

# 4) 그라데이션을 링으로 자르기
magick "$TMP/grad.png" "$TMP/ring_mask.png" \
  -alpha off -compose CopyOpacity -composite \
  "$TMP/ring.png"

# 5) 베이스 + ring 합성 = 카드
magick "$TMP/base.png" "$TMP/ring.png" \
  -compose Over -composite "$TMP/card.png"

# 6) SVG를 콘텐츠 폭으로 렌더 (비율 유지, 종이 영역에 맞춤)
CONTENT_W=$(python3 -c "print(int($SIZE * $CONTENT_RATIO))")
rsvg-convert -w "$CONTENT_W" "$SVG" > "$TMP/logo.png"

# 7) 흰색으로 색 변경 (로즈골드 → 흰색): alpha 유지 + RGB 흰색
magick "$TMP/logo.png" \
  \( +clone -alpha extract \) \
  \( -clone 0 -fill "#EAF0FA" -colorize 100 \) \
  -delete 0 \
  +swap -compose CopyOpacity -composite \
  "$TMP/logo_white.png"

# 8) 카드 가운데에 로고 합성
magick "$TMP/card.png" "$TMP/logo_white.png" \
  -gravity center -compose Over -composite \
  "$OUT_PNG"

echo "Mode: $MODE | Generated: $OUT_PNG ($(stat -f%z "$OUT_PNG") bytes)"
