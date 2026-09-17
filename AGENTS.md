# RVM Menu Bar

- Keep the runtime native: Swift, AppKit, AVFoundation, CoreML, Core Image.
- Do not add Python dependencies or restore the old PyTorch training/inference tree.
- The app is currently preview-only; virtual camera output is intentionally out of scope.
- Feed recurrent outputs `r1o`–`r4o` into the next frame's `r1i`–`r4i`.
- Drop late frames; allow only one inference frame in flight.
- Build and profiling commands are in [README.md](README.md).
