# RVM Menu Bar

Native macOS camera preview with background matting. Swift, AppKit, and local Core ML inference.

Preview only; no virtual camera output or Python runtime.

## Build

- macOS 13+ and Xcode with Swift 5.10+ and `coremlcompiler`.
- Camera access and preview tested on macOS 27.

```bash
./macos/RVMMenuBar/Scripts/build_app.sh
open macos/RVMMenuBar/.build/RVMMenuBar.app
```

- Choose **Start** from the **RVM** menu and allow camera access.
- Switch between composite, camera, foreground, and alpha previews.
- Choose a green or checkerboard background; **Stop** ends capture.

## Profiling

```bash
macos/RVMMenuBar/.build/RVMMenuBar.app/Contents/MacOS/RVMMenuBar \
  --profile-debug --profile-jsonl /tmp/rvm-profile.jsonl \
  --profile-frames 300 --no-preview
```

Use `--help` for options, or **Profiling Debug** in the menu. Instruments: Points of Interest, subsystem `dev.local.RVMMenuBar`.

## Attribution

- Native app: awidor; [GPL-3.0](LICENSE).
- Bundled model: Shanchuan Lin, [Robust Video Matting v1.0.0](https://github.com/PeterL1n/RobustVideoMatting/releases/tag/v1.0.0), unchanged. Its metadata declares [Apache-2.0](models/LICENSE).
