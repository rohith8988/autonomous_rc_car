// Version 1 firmware: PS4 controller over Bluetooth Classic -> ESC + steering servo.
// GPIO map from Hardware/Electronics/version_1/Wiring_Table.md.
#include <Bluepad32.h>
#include <ESP32Servo.h>
#include <Preferences.h>
#include "mapping.h"

const int ESC_PIN   = 25;   // ESC_PWM
const int STEER_PIN = 26;   // STEERING_PWM

Servo esc, steer;
ControllerPtr gamepad = nullptr;
Preferences prefs;
int steerTrim = STEER_TRIM_US;        // live steering centre, survives power cycles

void onConnected(ControllerPtr ctl)    { if (!gamepad) gamepad = ctl; }
void onDisconnected(ControllerPtr ctl) { if (gamepad == ctl) gamepad = nullptr; }

// D-pad left/right walks the steering centre and stores it. Bluepad32 dpad bits: up 1, down 2, right 4, left 8.
void nudgeTrim(uint8_t dpad) {
  static uint32_t last = 0;
  if (millis() - last < STEER_TRIM_REPEAT_MS) return;  // repeat rate, also debounces the pad
  int delta = (dpad & 0x08) ? -STEER_TRIM_STEP : (dpad & 0x04) ? STEER_TRIM_STEP : 0;
  if (!delta) return;
  last = millis();
  steerTrim += delta;
  if (steerTrim >  STEER_TRIM_MAX) steerTrim =  STEER_TRIM_MAX;
  if (steerTrim < -STEER_TRIM_MAX) steerTrim = -STEER_TRIM_MAX;
  prefs.putInt("trim", steerTrim);                    // ponytail: writes NVS per nudge, fine at 150 ms; batch on release if wear ever matters
  Serial.printf("trim=%d\n", steerTrim);
}

void setup() {
  Serial.begin(115200);
  prefs.begin("rccar", false);
  steerTrim = prefs.getInt("trim", STEER_TRIM_US);
  for (int t = 0; t < 4; t++) ESP32PWM::allocateTimer(t);   // required before attach(), or channels fail silently
  esc.setPeriodHertz(50);
  steer.setPeriodHertz(50);
  int escCh   = esc.attach(ESC_PIN, 1000, 2000);
  int steerCh = steer.attach(STEER_PIN, 500, 2500);
  Serial.printf("attach: esc ch=%d steer ch=%d\n", escCh, steerCh);   // 0 means the pin did not attach
  esc.writeMicroseconds(NEUTRAL_US);
  steer.writeMicroseconds(NEUTRAL_US + steerTrim);  // saved trim is the real centre, not raw 1500
  delay(3000);                        // ESC arms only after a steady neutral
  BP32.setup(&onConnected, &onDisconnected);
  // BP32.forgetBluetoothKeys();      // uncomment for one flash if the controller refuses to pair
}

void loop() {
  BP32.update();
  int th = NEUTRAL_US, st = NEUTRAL_US + steerTrim;      // failsafe: no controller, holds calibrated centre
  int ry = 0, ax = 0;
  bool linked = gamepad && gamepad->isConnected();
  if (linked) {
    ry = gamepad->axisRY();           // raw pad values, so a stuck reading is visible
    ax = gamepad->axisX();
    th = throttleUs(ry);
    st = steerUs(ax, steerTrim);
    nudgeTrim(gamepad->dpad());
  }
  static float stSmooth = NEUTRAL_US + steerTrim;       // first-order filter, takes the step out of stick moves
  stSmooth += (st - stSmooth) * STEER_SMOOTH;

  esc.writeMicroseconds(th);
  steer.writeMicroseconds(int(stSmooth));

  static uint32_t last = 0;           // 4 Hz telemetry, the only view into what the ESC is being told
  if (millis() - last > 250) {
    last = millis();
    Serial.printf("pad=%d dpad=%d ry=%d ax=%d th=%d st=%d trim=%d\n", linked, linked ? gamepad->dpad() : 0, ry, ax, th, st, steerTrim);
  }
  delay(20);                          // 50 Hz
}
