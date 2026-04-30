# RVM Menu Bar

Native macOS menu bar preview app for Robust Video Matting running through CoreML.

The app captures camera frames with AVFoundation, runs the bundled CoreML RVM model with recurrent state, composites with Core Image, and shows a live AppKit preview. There is no Python runtime in the app.

Original model: [PeterL1n/RobustVideoMatting](https://github.com/PeterL1n/RobustVideoMatting).

## Requirements

- macOS 13+
- Xcode command line tools
- Camera permission when the app starts

## Build

```bash
cd macos/RVMMenuBar
./Scripts/build_app.sh
```

The generated app bundle is ignored by git:

```text
macos/RVMMenuBar/.build/RVMMenuBar.app
```

Run it with:

```bash
open macos/RVMMenuBar/.build/RVMMenuBar.app
```

## Controls

- `Start` / `Stop`: camera and inference loop
- `Show Preview`: opens the preview window
- `Preview Composite`: final matted output
- `Preview Raw Camera`: camera input for capture debugging
- `Preview Foreground`: model foreground output
- `Preview Alpha`: model alpha output
- `Green Background` / `Checkerboard Background`: compositor background
- `Reset Recurrent State`: clears RVM memory

## Project Layout

```text
.
├── LICENSE
├── README.md
├── models/
│   └── rvm_mobilenetv3_1920x1080_s0.25_fp16.mlmodel
└── macos/
    └── RVMMenuBar/
        ├── Package.swift
        ├── README.md
        ├── Scripts/build_app.sh
        └── Sources/RVMMenuBar/
```

Virtual camera output is intentionally out of scope for this performance-test version.
