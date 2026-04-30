# RVM Menu Bar

Native macOS performance-test app for the CoreML RVM model.

This app intentionally does not use Python. It captures camera frames with AVFoundation, runs the existing CoreML model with recurrent state, composites the foreground with Core Image, and displays a native AppKit preview from the menu bar.

## Build

```bash
./Scripts/build_app.sh
```

The script creates:

```text
macos/RVMMenuBar/.build/RVMMenuBar.app
```

Open the app from Finder, or run:

```bash
open .build/RVMMenuBar.app
```

## Controls

- Menu bar item: `RVM`
- `Start` / `Stop`: camera + inference loop
- `Show Preview`: opens the native preview window
- `Green Background` / `Checkerboard Background`: switches the compositor background
- `Profiling Debug`: enables detailed timing overlay, stdout logging, and Instruments signposts
- `Reset Recurrent State`: clears RVM memory states
- Preview overlay: FPS, CoreML inference time, and compositing time, or detailed profiling when debug mode is enabled

## CLI profiling

The packaged app executable accepts profiling flags, so it can be run directly from a terminal:

```bash
.build/RVMMenuBar.app/Contents/MacOS/RVMMenuBar \
  --profile-debug \
  --profile-jsonl /tmp/rvm-profile.jsonl \
  --profile-frames 300 \
  --no-preview
```

Useful options:

- `--start` / `--auto-start`: start capture and inference on launch
- `--profile`: enable profiling overlay and `os_signpost` intervals
- `--profile-debug`: print detailed per-frame timings to stdout
- `--profile-jsonl PATH`: write detailed per-frame timings as JSON Lines
- `--profile-every N`: log every Nth accepted frame
- `--profile-frames N`: auto-start and quit after N profiled frames
- `--no-preview`: keep the preview window closed during auto-start

Each JSONL frame includes queue wait, dropped-frame count, CoreML prediction, recurrent-state update, Core Image setup/rendering, AppKit display, preview draw, total frame time, accounted top-level time, and unaccounted time.

For Instruments, record the process with the Points of Interest template and filter subsystem `dev.local.RVMMenuBar`, category `Profiling`.

## Runtime

- Capture: AVFoundation, 1920x1080 BGRA, 30 FPS target
- Inference: CoreML `ComputeUnits.all`
- State: `r1o` through `r4o` are fed into the next frame as `r1i` through `r4i`
- Compositing: Core Image `blendWithMask`
- Backpressure: at most one frame is in flight; late camera frames are dropped

Virtual camera output is intentionally out of scope for this version.
