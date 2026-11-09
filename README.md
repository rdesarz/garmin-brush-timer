# Garmin Brush Timer

A minimal two-minute tooth-brushing timer for the Garmin Forerunner 255 and
Forerunner 255 Music.

The session is divided into six equal 20-second zones. The watch vibrates once
at each zone change and uses a distinct double vibration when the session is
complete.

## Controls

- **START** begins, pauses, or resumes the timer.
- **BACK** cancels an active session and returns to the ready screen.
- Press **BACK** again from the ready screen to exit the app.

The display shows the current zone, the seconds remaining in that zone, six
zone indicators, and the total remaining time while running.

## Supported devices

- Forerunner 255 (`fr255`)
- Forerunner 255 Music (`fr255m`)

The app deliberately targets only the 260 x 260 Forerunner 255 variants. The
255S has a different screen size and has not been laid out or tested here.

## Development setup

1. Install the [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/).
2. Install the official **Monkey C** extension in Visual Studio Code.
3. In the SDK Manager, download the current SDK and the Forerunner 255 device
   definition.
4. In Visual Studio Code, run **Monkey C: Generate a Developer Key** and keep
   that key private. The `.gitignore` excludes common developer-key filenames.
5. Open this repository in Visual Studio Code.

## Run in the simulator

Use **Run > Run Without Debugging**, choose the Monkey C configuration, and
select `fr255` when prompted.

The simulator can validate timing, drawing, and button behavior. It cannot tell
you whether the vibration feels right, so test that part on the physical watch.

## Unit tests

The pure timer state machine has Connect IQ `(:test)` tests covering:

- initial state;
- exact 20-second zone changes;
- exact two-minute completion;
- pause and resume behavior;
- rollover of Garmin's signed millisecond timer.

Run them from the Monkey C Test Explorer in Visual Studio Code. The Connect IQ
compiler removes annotated unit tests from normal application builds.

## Build and install on the watch

Run **Monkey C: Build for Device**, select the Forerunner 255 variant, and choose
an output directory. This produces a signed `.prg` file.

Connect the watch by USB and copy the `.prg` file into `GARMIN/APPS`. Garmin's
[first-app guide](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)
documents the same sideloading flow.

For a command-line build, once `monkeyc` is on your `PATH`:

```sh
mkdir -p bin
monkeyc -f monkey.jungle \
  -o bin/BrushTimer.prg \
  -y /path/to/developer_key \
  -d fr255
```

## Design notes

- Timing is derived from `System.getTimer()` rather than decrementing a counter,
  so delayed callbacks do not make the session run long.
- The model explicitly handles `System.getTimer()` rollover.
- A 200 ms callback checks boundaries, but the screen redraws only when the
  displayed second changes.
- The app requests no permissions, stores no data, and does not require a phone
  or network connection.

## Project structure

```text
manifest.xml                 App identity and supported devices
monkey.jungle                Connect IQ build entry point
resources/                   App name and launcher icon
source/BrushTimerApp.mc      Application entry point
source/BrushTimerModel.mc    Testable timer state machine
source/BrushTimerView.mc     Screen, timer callback, and vibrations
source/BrushTimerDelegate.mc START and BACK button handling
source/BrushTimerModelTests.mc
```

