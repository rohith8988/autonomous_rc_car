# Version 1 wiring table

Do not use wire colour alone as proof of function. Confirm the markings and
polarity of the actual ESC, servo, battery and ESP32 board.

| From | To | Net / function | Recommended wire | Connection note |
|---|---|---|---|---|
| B1 positive | F1 input | `VBAT_3S` | 14 AWG red silicone | Keep the fuse holder close to the battery connector. |
| F1 output | SW1 input | Fused battery positive | 14 AWG red silicone | F1 is 30 A. |
| SW1 output | ESC1 battery positive | `VBAT_SWITCHED` | 14 AWG red silicone | SW1 must be rated at least 40 A at 16 V DC. |
| B1 negative | ESC1 battery negative | `GND_PWR` | 14 AWG black silicone | Do not switch the negative lead. |
| ESC1 phase A | M1 phase U | `MOTOR_U` | ESC/motor phase wire | Phase order establishes the physical forward direction. |
| ESC1 phase B | M1 phase V | `MOTOR_V` | ESC/motor phase wire | Swap any two phases if direction is reversed. |
| ESC1 phase C | M1 phase W | `MOTOR_W` | ESC/motor phase wire | Insulate all bullet connectors completely. |
| ESC1 UBEC +5 V | TB1 +5 V bus | `+5V_LOGIC` | 20–22 AWG | This is the only 5 V regulator in Version 1. |
| ESC1 UBEC ground | TB1 ground bus | `GND` | 20–22 AWG | Common reference for both PWM signals. |
| ESC1 signal | U1 GPIO25 | `ESC_PWM` | Servo signal wire | Standard RC PWM; nominal 1500 us neutral. |
| TB1 +5 V bus | U1 VIN/5V | `+5V_LOGIC` | 22 AWG | Never connect this to U1's 3V3 pin. |
| TB1 ground bus | U1 GND | `GND` | 22 AWG | Use a short connection. |
| TB1 +5 V bus | SV1 red / V+ | `+5V_LOGIC` | Servo power lead | Verify the actual servo pin order. |
| TB1 ground bus | SV1 brown/black / GND | `GND` | Servo ground lead | Ground must remain common with U1 and ESC1. |
| U1 GPIO26 | SV1 orange/yellow / signal | `STEERING_PWM` | Servo signal lead | 50 Hz RC servo PWM. |
| TB1 +5 V bus | C1 positive | `+5V_LOGIC` | Short leads | C1 is 1000 uF, 10 V, low ESR. |
| TB1 ground bus | C1 negative stripe | `GND` | Short leads | Reversed capacitor polarity can cause failure. |
| PS4 controller | U1 radio | `BT_CLASSIC` | Wireless | There is no transmitter/receiver module or physical wire. |

## Harness rules

- Keep battery and motor wires away from the ESP32 antenna and PWM signal
  wires.
- Use heat-shrink over every soldered high-current joint.
- Provide strain relief so vibration cannot load the ESP32 headers or servo
  plugs.
- Keep battery leads short. Do not extend them without adding appropriate
  input capacitance at the ESC.
- Disconnect B1 before changing motor phases or connecting USB.
