#pragma once

// --- Tuning knobs. Real servos and ESCs never match the numbers on paper. ---
constexpr float THROTTLE_LIMIT    = 0.1f;  // fraction of full throttle. 1.0 is the full 980 KV on 3S.
constexpr int   THROTTLE_DEADBAND = 40;     // stick counts around centre treated as zero
constexpr int   STEER_TRIM_US     = 0;      // startup default only; the D-pad overrides and saves it
constexpr int   STEER_TRIM_MAX    = 300;    // clamp, so trim can never drive the linkage into its stops
constexpr int   STEER_TRIM_STEP   = 30;     // us per D-pad nudge
constexpr int   STEER_TRIM_REPEAT_MS = 60;  // ms between nudges while held
constexpr int   STEER_DEADBAND    = 24;     // stick counts around centre ignored, kills servo buzz at rest
constexpr float STEER_SMOOTH      = 0.25f;  // 0..1 per 20 ms tick. Lower is smoother and laggier.
constexpr float STEER_RANGE_L     = 0.8f;   // fraction of servo travel, ax < 0 side (tune down if this side turns sharper)
constexpr float STEER_RANGE_R     = 0.8f;   // fraction of servo travel, ax > 0 side
constexpr int   NEUTRAL_US        = 1500;
constexpr int   STEER_MIN_US      = 800;    // steering-only floor, inside the 500-2500 servo.attach() range
constexpr int   STEER_MAX_US      = 2200;   // steering-only ceiling

inline int clampUs(int us) { return us < 1000 ? 1000 : (us > 2000 ? 2000 : us); }
inline int clampSteerUs(int us) { return us < STEER_MIN_US ? STEER_MIN_US : (us > STEER_MAX_US ? STEER_MAX_US : us); }

// right stick Y, -512..511, up is negative -> ESC pulse width. Up drives forward, down reverses.
inline int throttleUs(int ry) {
  int v = -ry;
  if (v > -THROTTLE_DEADBAND && v < THROTTLE_DEADBAND) v = 0;
  return clampUs(NEUTRAL_US + int(v / 512.0f * 500 * THROTTLE_LIMIT));
}

// left stick X, -512..511, plus the live trim -> servo pulse width
inline int steerUs(int ax, int trimUs) {
  if (ax > -STEER_DEADBAND && ax < STEER_DEADBAND) ax = 0;
  float range = ax < 0 ? STEER_RANGE_L : STEER_RANGE_R;
  return clampSteerUs(NEUTRAL_US + trimUs + int(ax / 512.0f * 500 * range));
}
