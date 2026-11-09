# Manual test checklist

Run these checks in the Forerunner 255 simulator unless a physical watch is
explicitly required.

## Basic session

1. Launch the app. It shows `READY`, `20`, and six zone indicators.
2. Press START. Zone 1 begins at 20 seconds.
3. At each 20-second boundary, the zone increments and the countdown returns to
   20.
4. At 2:00, the screen shows `DONE` and zero seconds.
5. Press START from `DONE`. A new session begins from Zone 1.

## Pause and reset

1. Start a session and pause it after several seconds.
2. Wait at least ten seconds. The displayed time must not change.
3. Press START. The countdown resumes without consuming the paused interval.
4. Press BACK during a session. The app returns to `READY`.
5. Press BACK again. The app exits.

## Physical Forerunner 255

1. Confirm one short vibration is easy to feel at every zone change.
2. Confirm the final short-plus-long vibration is distinguishable.
3. Confirm START and BACK remain convenient with wet hands.
4. Complete a session against a separate stopwatch; the final vibration should
   occur at two minutes, within the 200 ms callback interval.

