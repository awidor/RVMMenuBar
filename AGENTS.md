# RVM Menu Bar

Native macOS/CoreML performance-test app for Robust Video Matting.

## Scope

- Keep the runtime native: Swift, AppKit, AVFoundation, CoreML, Core Image.
- Do not add Python dependencies or restore the old PyTorch training/inference tree.
- The app is currently preview-only; virtual camera output is intentionally out of scope.

## Build

```bash
cd macos/RVMMenuBar
./Scripts/build_app.sh
```

The script builds a release executable, compiles the CoreML model, and creates:

```text
macos/RVMMenuBar/.build/RVMMenuBar.app
```

## Runtime Pipeline

```text
AVFoundation camera
  -> 1920x1080 BGRA CVPixelBuffer
  -> CoreML RVM model
  -> fgr + pha + recurrent states
  -> Core Image compositing/rendering
  -> AppKit preview
```

RVM recurrent state is frame-to-frame:

```text
r1o -> r1i
r2o -> r2i
r3o -> r3i
r4o -> r4i
```

Late frames are dropped; only one inference frame should be in flight.
