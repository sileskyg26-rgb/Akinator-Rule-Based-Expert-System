# PyInstaller configuration for the Windows desktop distribution.
from pathlib import Path

from PyInstaller.utils.hooks import collect_data_files


root = Path(SPEC).parent
datas = [
    (str(root / "Backend"), "Backend"),
    *collect_data_files("Frontend", includes=["images/*.png", "images/*.gif"]),
]

a = Analysis(
    ["Frontend/__main__.py"],
    pathex=[str(root)],
    binaries=[],
    datas=datas,
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)
pyz = PYZ(a.pure)
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="stardew-akinator",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
)
