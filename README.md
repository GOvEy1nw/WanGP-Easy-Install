# WanGP Easy Install

Portable one-click installer for [WanGP (Wan2GP)](https://github.com/deepbeepmeep/Wan2GP) on Windows with NVIDIA GPU.

## Requirements

### Operating System
- Windows 10 (22H2+) or Windows 11

### Hardware

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| GPU | NVIDIA RTX 20xx | RTX 30xx / 40xx / 50xx |
| VRAM | 8 GB | 12 GB+ |
| RAM | 16 GB | 32 GB+ |
| Storage | 25 GB free | 40 GB+ (for models) |

> **GTX 10xx / 16xx:** Not officially supported. This installer targets Python 3.11 / Torch 2.10 for RTX 20 series and newer.

### NVIDIA Driver

| Driver version | Stack installed |
|---------------|-----------------|
| 580 or newer | PyTorch 2.10.0 + CUDA 13.0 (recommended) |
| Below 580 | PyTorch 2.7.1 + CUDA 12.8 (legacy fallback — driver update strongly recommended) |

The installer detects your driver automatically and selects the appropriate stack.

### Software
- Internet connection (~8 GB downloaded on first install)
- Git (installed automatically via winget if missing)
- Microsoft Edge WebView2 (required for WanGP-EZi desktop mode; included with Windows 10 1803+)

---

## Quick Start

1. Place **`WanGP-Easy-Install.bat`** and **`Helper-WEI.zip`** in the same folder.
2. Use a folder **without spaces** — not inside `Program Files` or the drive root (`C:\`).
3. Do **not** run as Administrator.
4. Double-click **`WanGP-Easy-Install.bat`**.

Install time is typically 10–30 minutes depending on connection speed.

### After Install

| Launcher | Path | Description |
|----------|------|-------------|
| Browser mode | `WanGP-Easy-Install\WanGP-Browser.bat` | Runs WanGP and opens it in your default browser |
| Desktop app | `WanGP-Easy-Install\WanGP-EZi.bat` | Standalone window with built-in console, update menu, and open-in-browser |

---

## Install Layout

```
WanGP-Easy-Install/
├── python_embedded/       Python 3.11.9 runtime + dev headers (include/, libs/)
├── WanGP/                 Upstream git clone (deepbeepmeep/Wan2GP)
├── WanGP-Browser.bat
├── WanGP-EZi.bat
└── _EziData/
    ├── Config/
    │   ├── args.txt        Extra CLI flags passed to wgp.py
    │   └── lib/            install_helper.py, stack_config.json
    └── _Extras/
        ├── Add-Ons/        Optional kernel installers
        ├── Torch-Pack/     Switch between PyTorch builds
        ├── Tools/          Long-Paths-Enabler.bat, Helper-WEI/ (EZi desktop source)
        └── Update/         Update WanGP.bat, Update Easy-Install.bat
```

---

## Default Stack

| Component | Version |
|-----------|---------|
| Python (embedded) | 3.11.9 |
| PyTorch + CUDA | 2.10.0 + cu130 |
| SageAttention | v2.2.0 |
| SpargeAttention | v0.1.0 |
| FlashAttention | v2.8.3 |
| Nunchaku | v1.2.1 |
| GGUF CUDA kernels | llamacpp_gguf_cuda 1.0.2 |
| Triton | triton-windows |

Kernels are installed automatically based on detected GPU generation:

| GPU generation | Auto-installed kernels |
|----------------|------------------------|
| RTX 50xx | triton, sage2, sparge, flash, gguf, nunchaku, lightx2v |
| RTX 40xx | triton, sage2, sparge, flash, gguf, nunchaku |
| RTX 30xx | triton, sage2, sparge, flash, gguf, nunchaku |
| RTX 20xx | triton, sage2, flash, gguf, nunchaku |
| GTX 10xx | (none — base install only) |

> **Legacy stack (driver < 580):** Falls back to Torch 2.7.1 + cu128. Some kernel wheels target Python 3.10 and may not install on Python 3.11.

> **GGUF kernels:** WanGP uses the `llamacpp_gguf_cuda` wheel from [deepbeepmeep/kernels](https://github.com/deepbeepmeep/kernels/releases/tag/GGUF_Kernels), not `llama-cpp-python`.

> **Python dev headers:** The python.org embed zip omits `Python.h`. `Helper-WEI.zip` bundles headers under `python_embedded\include` and `python_embedded\libs`, merged into the runtime during install (required by Triton).

---

## Add-Ons

Run any script from `WanGP-Easy-Install\_EziData\_Extras\Add-Ons\` to install optional kernels individually. Close WanGP before running any add-on.

| Script | Installs |
|--------|----------|
| `Triton.bat` | triton-windows (JIT compiler for attention kernels) |
| `SageAttention.bat` | SageAttention v2.2 (RTX 20+; v3 not supported on Torch 2.10) |
| `SpargeAttention.bat` | SpargeAttention v0.1 |
| `FlashAttention.bat` | FlashAttention v2.8.3 |
| `GGUF-Kernels.bat` | llamacpp_gguf_cuda (GGUF model support) |
| `Nunchaku.bat` | Nunchaku INT4/FP4 quantization |
| `Lightx2v-NVP4.bat` | Lightx2v NVFP4 kernels (RTX 50xx only) |
| `Bitsandbytes-NF4.bat` | bitsandbytes NF4 quantization |
| `1. Easy-System-Checker.bat` | Print GPU, driver, Python, PyTorch, and installed kernel versions |

**Torch-Pack:** `WanGP-Easy-Install\_EziData\_Extras\Torch-Pack\` — switch between cu130 and cu128 PyTorch builds and automatically reinstall compatible kernel wheels.

---

## Extra CLI Flags

Edit `WanGP-Easy-Install\_EziData\Config\args.txt` (one line of flags), e.g.:

```
--advanced
```

`--open-browser` only works in `WanGP-Browser.bat`. WanGP-EZi manages its own window and strips that flag automatically.

---

## Updates

- **Update WanGP** (git pull + pip): `WanGP-Easy-Install\_EziData\_Extras\Update\Update WanGP.bat`
- **Update Easy-Install** (re-extract Helper-WEI.zip): `WanGP-Easy-Install\_EziData\_Extras\Update\Update Easy-Install.bat`
  Requires `Helper-WEI.zip` to be placed next to the main installer. Merges updated `_EziData\`, dev headers, and launcher files.

Both are also accessible from the **Settings** menu in WanGP-EZi.

---

## Reinstall After a Stack Change

If you installed with a previous Python version (e.g. 3.12), delete the entire `WanGP-Easy-Install` folder and re-run `WanGP-Easy-Install.bat`.

---

## Building Helper-WEI.zip (Developers)

From a full repository clone, run **`Build Helper-WEI.bat`** to pack `WanGP-Easy-Install\` into `Helper-WEI.zip`.

The build script validates that:
- `stack_config.json` is present
- Python dev headers (`Python.h`) are bundled
- The Python runtime itself is **not** bundled (it is downloaded fresh on each install)

---

## License

MIT — see [LICENSE](LICENSE).

WanGP itself is licensed separately; see the [upstream repository](https://github.com/deepbeepmeep/Wan2GP).
