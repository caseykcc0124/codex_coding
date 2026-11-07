#!/usr/bin/env python3
"""Validate KA-DMM's exact missing wheel set against official PyPI release digests.

This script only reads public wheel metadata, installed files and the official
https://pypi.org/pypi/<name>/<version>/json API. It never touches KA sources.
Requires Python stdlib only.
"""
import argparse
import email
import hashlib
import json
import pathlib
import re
import urllib.parse
import urllib.request
import zipfile


def canonical(value):
    return re.sub(r"[-_.]+", "-", value).lower()


def requirements(path):
    result = {}
    for line in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.count("==") != 1:
            raise ValueError("Invalid pinned requirement: " + line)
        name, version = line.split("==")
        key = canonical(name.strip())
        if key in result:
            raise ValueError("Duplicate distribution: " + key)
        result[key] = version.strip()
    if len(result) != 18:
        raise ValueError("Expected exactly 18 requirements, got " + str(len(result)))
    return result


def wheel_metadata(path):
    with zipfile.ZipFile(path, "r") as zf:
        matches = [p for p in zf.namelist() if p.endswith(".dist-info/METADATA")]
        if len(matches) != 1:
            raise ValueError("Expected one METADATA in " + str(path))
        msg = email.message_from_bytes(zf.read(matches[0]))
        return msg.get("Name"), msg.get("Version"), msg.get("Requires-Python")


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def official_release(name, version):
    url = "https://pypi.org/pypi/{}/{}/json".format(
        urllib.parse.quote(name, safe=""), urllib.parse.quote(version, safe="")
    )
    with urllib.request.urlopen(
        urllib.request.Request(url, headers={"User-Agent": "KA-DMM-E9-Wheel-Verifier/1.0"}),
        timeout=35,
    ) as response:
        return json.load(response)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--requirements", required=True)
    ap.add_argument("--wheelhouse", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()
    locked = requirements(args.requirements)
    folder = pathlib.Path(args.wheelhouse)
    files = sorted(folder.glob("*.whl"))
    if len(files) != len(locked):
        raise ValueError("Expected 18 wheel files, got " + str(len(files)))
    actual = {}
    for path in files:
        name, version, python = wheel_metadata(path)
        key = canonical(name)
        if key in actual:
            raise ValueError("Duplicate wheel for " + key)
        if key not in locked or locked[key] != version:
            raise ValueError("Unexpected package/version: {} {}".format(name, version))
        release = official_release(key, version)
        matching = [u for u in release.get("urls", []) if u["filename"] == path.name]
        if len(matching) != 1 or matching[0]["packagetype"] != "bdist_wheel":
            raise ValueError("Official PyPI wheel absent: " + path.name)
        item = matching[0]
        computed = sha256(path)
        published = item["digests"]["sha256"]
        if computed != published:
            raise ValueError("SHA256 mismatch for " + path.name)
        if item.get("yanked"):
            raise ValueError("Wheel is yanked: " + path.name)
        info = release.get("info", {})
        actual[key] = {
            "name": key,
            "version": version,
            "filename": path.name,
            "sha256": computed,
            "size_bytes": path.stat().st_size,
            "requires_python_wheel": python,
            "requires_python_pypi": item.get("requires_python"),
            "license_expression": info.get("license_expression"),
            "license_metadata": (info.get("license") or "")[:120],
            "origin": item["url"],
            "upstream": "https://pypi.org/project/{}/{}/".format(key, version),
            "pypi_metadata_verified": True,
            "wheel_bytes_verified": True,
        }
    if set(actual) != set(locked):
        raise ValueError("Missing: " + repr(set(locked) - set(actual)))
    report = {
        "status": "PUBLIC_PYPI_FILES_SHA256_VERIFIED",
        "target": "CPython 3.12 win_amd64",
        "rc": "54745fd733e52744c9b5728bcbbc91d337ecdbbc",
        "count": len(actual),
        "note": "Only missing wheels verified. No offline clean install or product Gate performed.",
        "files": [actual[k] for k in sorted(actual)],
    }
    out = pathlib.Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("Verified 18 exact wheel bytes against official PyPI SHA256; total MB:",
          round(sum(x["size_bytes"] for x in actual.values()) / (1024 * 1024), 1))


if __name__ == "__main__":
    main()
