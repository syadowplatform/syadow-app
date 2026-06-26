#!/usr/bin/env bash
# SYADOW 앱 아이콘 (S 단독, 로즈골드 그라데이션 보더) 생성.
# SVG 템플릿으로 동심 둥근사각형을 그려서 모서리 정확도 확보 + librsvg로 1024x1024 렌더.
#
# 출력: assets/icon/app_icon.png

set -euo pipefail
cd "$(dirname "$0")/.."

OUT_DIR="assets/icon"
OUT_PNG="$OUT_DIR/app_icon.png"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

mkdir -p "$OUT_DIR"

# 디자인 토큰 (AppColors와 동일)
MIDNIGHT="#0B132B"
GOLD_DARK="#8B6B4A"
GOLD_MAIN="#D4A373"
GOLD_LIGHT="#F4D29F"
LOGO_COLOR="$GOLD_MAIN"   # 골드 단색 (보더와 톤 일치, midnight 배경 위에서 잘 보임)

SIZE=1024
BORDER=32
RADIUS_OUT=320   # iOS squircle 느낌에 맞춘 둥근 모서리 (31%)
RADIUS_IN=$((RADIUS_OUT - BORDER))
INNER_OFF=$BORDER
INNER_SIZE=$((SIZE - BORDER * 2))

# S 로고 (source_s.svg viewBox 71.18 x 69.29)
LOGO_W_PCT=58           # 카드 가로의 58%
LOGO_W=$(python3 -c "print(round($SIZE * $LOGO_W_PCT / 100, 2))")
LOGO_SCALE=$(python3 -c "print(round($LOGO_W / 71.18, 4))")
LOGO_H=$(python3 -c "print(round(71.18 * $LOGO_SCALE * 69.29 / 71.18, 2))")
LOGO_X=$(python3 -c "print(round(($SIZE - $LOGO_W) / 2, 2))")
LOGO_Y=$(python3 -c "print(round(($SIZE - $LOGO_H) / 2, 2))")

cat > "$TMP/icon.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="$SIZE" height="$SIZE" viewBox="0 0 $SIZE $SIZE">
  <defs>
    <!-- 배경: 깊이감 그라데이션 (위 밝음 → 아래 어두움) -->
    <linearGradient id="bgGrad" x1="50%" y1="0%" x2="50%" y2="100%">
      <stop offset="0%"   stop-color="#1A2342"/>
      <stop offset="55%"  stop-color="$MIDNIGHT"/>
      <stop offset="100%" stop-color="#050813"/>
    </linearGradient>

    <!-- 로고: 메탈릭 골드 그라데이션 (어두운 골드 → 메인 → 밝은 골드 → 메인) -->
    <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%"   stop-color="$GOLD_DARK"/>
      <stop offset="35%"  stop-color="$GOLD_MAIN"/>
      <stop offset="65%"  stop-color="$GOLD_LIGHT"/>
      <stop offset="100%" stop-color="$GOLD_MAIN"/>
    </linearGradient>

    <!-- 상단 하이라이트 (얇은 광택) -->
    <linearGradient id="topShine" x1="50%" y1="0%" x2="50%" y2="100%">
      <stop offset="0%"   stop-color="#FFFFFF" stop-opacity="0.10"/>
      <stop offset="40%"  stop-color="#FFFFFF" stop-opacity="0"/>
    </linearGradient>
  </defs>

  <!-- 배경 풀블리드 (iOS/Android가 자동으로 마스크 적용) -->
  <rect x="0" y="0" width="$SIZE" height="$SIZE" fill="url(#bgGrad)"/>

  <!-- 상단 광택 (입체감) -->
  <rect x="0" y="0" width="$SIZE" height="$SIZE" fill="url(#topShine)"/>

  <!-- S 로고 (메탈릭 골드 그라데이션) -->
  <g transform="translate($LOGO_X, $LOGO_Y) scale($LOGO_SCALE)">
    <path fill="url(#logoGrad)" d="M48.8,40.78h0c-3.33-2.36-8.77-4.52-16.18-6.45-5.57-1.49-9.6-2.83-11.97-3.98-2.29-1.08-4.25-2.72-5.81-4.86-1.5-2.03-2.26-4.44-2.26-7.14,0-.98,.25-2.16,.73-3.52l1.36-3.8-2.55,3.12c-2.38,2.91-3.58,5.93-3.58,8.99,0,2.76,.9,5.28,2.66,7.47,1.62,2.15,3.88,3.87,6.74,5.13,2.39,1.04,6.44,2.37,12.04,3.95,6.88,1.92,11.53,3.65,13.83,5.15,2.26,1.46,3.36,3.45,3.36,6.09s-1.16,4.62-3.54,6.45c-2.41,1.84-5.59,2.78-9.47,2.78s-7.33-.83-10.48-2.46c-.19-.1-.38-.2-.57-.31l3.34-5.87L0,60.41l26.49,8.89-2.58-4.53c.1,.02,.2,.03,.3,.05,3.78,.61,6.85,.92,9.14,.92,6.74,0,11.9-1.6,15.33-4.76,3.41-3.14,5.13-6.7,5.13-10.6s-1.69-7.23-5.01-9.6Z"/>
    <path fill="url(#logoGrad)" d="M71.18,8.89L44.7,0l2.47,4.34c-.11-.01-.22-.03-.32-.04-2.8-.32-5.36-.48-7.62-.48-7.37,0-13.16,1.2-17.22,3.57-4.17,2.51-6.28,6.03-6.28,10.46,0,3.87,1.41,6.77,4.19,8.63,2.66,1.74,8.16,3.77,16.8,6.21,5.56,1.56,9.62,3.04,12.06,4.4,2.35,1.31,4.36,3.09,5.97,5.3,1.5,2.15,2.27,4.65,2.27,7.43,0,2.94-.68,5.24-2.03,6.83l-3.12,3.68,4.02-2.65c4.15-2.73,6.26-6.56,6.26-11.38,0-3.15-.96-6.05-2.86-8.63-1.87-2.47-4.24-4.39-7.05-5.72-2.57-1.19-7.1-2.74-13.47-4.61-6.76-2-11.33-3.73-13.6-5.17-2.04-1.24-3.03-2.86-3.03-4.98,0-1.95,1.28-3.61,3.91-5.08,2.68-1.51,6.18-2.28,10.39-2.28s7.88,.61,11.08,1.82c.18,.07,.36,.14,.53,.21l-3.36,5.91,26.48-8.89Z"/>
  </g>
</svg>
SVG

rsvg-convert -w $SIZE -h $SIZE "$TMP/icon.svg" -o "$OUT_PNG"
echo "Generated: $OUT_PNG ($(stat -f%z "$OUT_PNG") bytes)"
