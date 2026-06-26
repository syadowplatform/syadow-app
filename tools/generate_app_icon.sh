#!/usr/bin/env bash
# SYADOW 앱 아이콘 생성 (1024x1024 PNG)
# B안: midnight 배경 + 네온 그라데이션 보더 + 중앙 "S" (흰색, Orbitron + stroke로 Black 느낌)
#
# 출력: assets/icon/app_icon.png
# 사용: bash tools/generate_app_icon.sh

set -euo pipefail
cd "$(dirname "$0")/.."

OUT_DIR="assets/icon"
OUT_PNG="$OUT_DIR/app_icon.png"
FONT_DIR="tools/fonts"
FONT_PATH="$FONT_DIR/Orbitron-Variable.ttf"

mkdir -p "$OUT_DIR" "$FONT_DIR"

# Orbitron variable font 다운로드 (한 번만)
if [[ ! -f "$FONT_PATH" ]]; then
  echo "Downloading Orbitron variable font..."
  curl -fsSL -o "$FONT_PATH" \
    "https://raw.githubusercontent.com/google/fonts/main/ofl/orbitron/Orbitron%5Bwght%5D.ttf"
fi

SIZE=1024
BORDER=30          # 그라데이션 보더 두께
RADIUS=224         # 둥근사각형 코너 반경 (iOS 마스크와 자연스럽게 어울림)
INNER_RADIUS=$((RADIUS - BORDER))

# 색상 (AppColors)
MIDNIGHT="#0B132B"
TEXT_COLOR="#EAF0FA"
NEON_CYAN="#22D3EE"
NEON_PURPLE="#A78BFA"
NEON_PINK="#F472B6"

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# 1) 짙은 둥근사각형 베이스 (midnight)
magick -size ${SIZE}x${SIZE} xc:none \
  -fill "$MIDNIGHT" \
  -draw "roundrectangle 0,0 $((SIZE-1)),$((SIZE-1)) $RADIUS,$RADIUS" \
  "$TMP/base.png"

# 2) 그라데이션 캔버스 (cyan → pink 대각선) + 보라 부드러운 중앙 보강
magick \
  -size ${SIZE}x${SIZE} \
  gradient:"$NEON_CYAN-$NEON_PINK" \
  -rotate 45 \
  -gravity center -extent ${SIZE}x${SIZE} \
  "$TMP/grad.png"

magick "$TMP/grad.png" \
  \( -size ${SIZE}x${SIZE} radial-gradient:"$NEON_PURPLE-none" \
     -evaluate Multiply 0.5 \) \
  -compose Over -composite \
  "$TMP/grad.png"

# 3) 링 마스크 (외곽 둥근사각형 흰색 - 내부 둥근사각형 검정 = 보더 영역만 흰색)
INNER_OFF=$BORDER
INNER_END=$((SIZE - BORDER - 1))
magick -size ${SIZE}x${SIZE} xc:black \
  -fill white \
  -draw "roundrectangle 0,0 $((SIZE-1)),$((SIZE-1)) $RADIUS,$RADIUS" \
  -fill black \
  -draw "roundrectangle $INNER_OFF,$INNER_OFF $INNER_END,$INNER_END $INNER_RADIUS,$INNER_RADIUS" \
  "$TMP/ring_mask.png"

# 4) 그라데이션을 링 마스크로 자르기 → 보더 ring
magick "$TMP/grad.png" "$TMP/ring_mask.png" \
  -alpha off \
  -compose CopyOpacity -composite \
  "$TMP/ring.png"

# 5) 베이스 + 보더 ring 합성
magick "$TMP/base.png" "$TMP/ring.png" \
  -compose Over -composite \
  "$TMP/card.png"

# 6) 중앙 "S" 글자 (Orbitron + stroke로 Black 두께 흉내)
magick "$TMP/card.png" \
  -font "$FONT_PATH" \
  -pointsize 660 \
  -fill "$TEXT_COLOR" \
  -stroke "$TEXT_COLOR" \
  -strokewidth 28 \
  -gravity center \
  -annotate +0+10 "S" \
  "$OUT_PNG"

echo "Generated: $OUT_PNG ($(stat -f%z "$OUT_PNG") bytes)"

