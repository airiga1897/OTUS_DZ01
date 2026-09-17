"""Установка инструментов Windows в проект из официальных источников."""
import hashlib
import io
from pathlib import Path
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERSION = "1.16.3"


def fetch(url):
    with urllib.request.urlopen(url, timeout=120) as response:
        return response.read()


def install():
    target = ROOT / ".tools"
    target.mkdir(exist_ok=True)
    filename = f"terraform_{VERSION}_windows_amd64.zip"
    base = f"https://releases.hashicorp.com/terraform/{VERSION}/"
    archive = fetch(base + filename)
    checksums = fetch(base + f"terraform_{VERSION}_SHA256SUMS").decode()
    expected = next(line.split()[0] for line in checksums.splitlines() if line.split()[-1] == filename)
    if hashlib.sha256(archive).hexdigest() != expected:
        raise RuntimeError("Terraform checksum mismatch")
    with zipfile.ZipFile(io.BytesIO(archive)) as package:
        (target / "terraform.exe").write_bytes(package.read("terraform.exe"))
    archive = fetch("https://storage.yandexcloud.net/yandexcloud-yc/release/yc_windows_amd64.zip")
    with zipfile.ZipFile(io.BytesIO(archive)) as package:
        executable = next(n for n in package.namelist() if n.endswith("yc.exe"))
        (target / "yc.exe").write_bytes(package.read(executable))
    print("Installed Terraform (SHA256 verified) and yc (official HTTPS distribution) into .tools")


if __name__ == "__main__":
    install()
