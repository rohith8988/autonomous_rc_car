# Version 1 electronics

Version 1 controls the car from a PS4 controller over Bluetooth Classic. An
original ESP32 generates separate RC-style PWM signals for steering and
throttle. Firmware and ROS integration are intentionally not included yet.

## Files

- [`RC_Car_Electrical_Diagram.svg`](RC_Car_Electrical_Diagram.svg) — editable
  vector master.
- [`RC_Car_Electrical_Diagram.pdf`](RC_Car_Electrical_Diagram.pdf) —
  print-ready A3 landscape export.
- [`RC_Car_Electrical_Diagram.png`](RC_Car_Electrical_Diagram.png) —
  high-resolution viewing export.
- [`Wiring_Table.md`](Wiring_Table.md) — point-to-point connection schedule.
- [`BOM.csv`](BOM.csv) — Version 1 bill of materials.

## Electrical architecture

- B1 is the Pro Range 3S 2200 mAh 30C LiPo: 11.1 V nominal and 12.6 V fully
  charged.
- F1 is a 30 A inline automotive fuse installed as close to B1 positive as
  practical.
- SW1 is a normally-open SPST master switch rated for at least 40 A at 16 V DC.
  A small AC or panel toggle is not suitable.
- ESC1 is the Robu SKU 1345166 bidirectional 50 A, 2–6S sensorless brushless
  ESC with an integrated 5 V/5 A UBEC.
- ESC1 drives the three motor phases and supplies the complete 5 V logic rail.
  No separate UBEC is used in this revision.
- U1 is an original ESP32-family development board supporting Bluetooth
  Classic. Its 5 V/VIN pin is powered from the ESC UBEC.
- SV1 is the TowardPro MG90S steering servo.
- C1 is a 1000 uF, 10 V low-ESR electrolytic capacitor fitted near the 5 V
  distribution point to reduce radio/servo brownouts.

The ESP32 uses GPIO25 for `ESC_PWM` and GPIO26 for `STEERING_PWM`. Both are
3.3 V logic signals. All signal and power grounds are common.

## Important limits

- Never connect the 3S battery rail to the ESP32, servo, or 5 V distribution
  point.
- The selected ESC is a generic module. Treat its current marking as a maximum
  product rating, retain the 30 A fuse, provide airflow, and stop if the ESC,
  motor, or wiring becomes hot.
- Wire colours on generic ESCs can vary. Identify battery, motor phase, signal,
  5 V and ground connections from the product labels before soldering.
- If the ESP32 or ESC does not reliably recognize a 3.3 V PWM high level, stop
  testing and add a logic buffer in a future revision. Do not improvise a
  direct 5 V connection to an ESP32 GPIO.
- Unplug the battery before connecting USB to the ESP32. Do not rely only on
  SW1 while changing wiring.

## Assembly sequence

1. Keep the motor disconnected and remove the battery from the car.
2. Install F1 and SW1 in the positive battery lead using 14 AWG silicone wire,
   insulated solder joints, and strain relief.
3. Connect ESC1 battery positive after SW1 and battery negative directly to B1
   negative. Verify polarity with a multimeter.
4. Connect the ESC UBEC 5 V and ground to TB1, then connect U1, SV1 and C1 to
   the same 5 V distribution point.
5. Connect GPIO25 to the ESC signal and GPIO26 to the servo signal.
6. Connect the motor phases only after the low-voltage system passes the tests
   below.

## Commissioning

1. Raise all four wheels and make sure the drivetrain turns freely by hand.
2. With B1 disconnected, verify that there is no continuity between
   `VBAT_SWITCHED` and ground, and confirm F1/SW1 continuity behaves correctly.
3. Leave the motor disconnected. Connect B1, close SW1, and verify the UBEC
   output is approximately 5 V before installing U1 or SV1.
4. Power U1 and SV1. Confirm that steering movement does not reset the ESP32.
5. Firmware must output neutral throttle (nominally 1500 us) before ESC1 is
   armed. Loss of the PS4 connection must immediately command neutral.
6. Connect the motor, power on with the wheels raised, and use only a very low
   throttle command. If forward is mechanically reversed, disconnect B1 and
   swap any two motor phase wires.
7. Recheck connector, ESC, motor and wire temperature after a short unloaded
   run, then repeat under progressively higher load.

The motor and printed drivetrain are capable of causing injury. Do not work
near the gears or wheels while B1 is connected.
