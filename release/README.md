# release/

This folder is where `npm run pack:exe` writes the built artifacts.

The binaries themselves are deliberately **not** committed: a single Windows
build is about 97 MB, and once it is in the history every clone and every fork
carries that weight forever. Only this file is tracked, so the folder is
visible in the repository and its purpose is documented here.

## Build it yourself

Packaging needs Node 24.22.1 or newer (the packer says so up front instead of
failing late). 24.22.1 is a security floor, not a style choice: it is the Node
release whose internal undici carries the CVE-2026-109869 fix. Then:

```bash
npm install
npm test
npm run pack:exe
```

## What you get

| Target | Output |
|---|---|
| Windows x64, single file | `Forge-3.2-windows-x64.exe` |

The Windows build embeds the Node runtime, the web shell and the WebView2
native library, so it runs on any Windows x64 machine without a Node.js
install. The packer stamps the `forge.ico` icon and the `3.2.2` version
resources before injecting the payload. Windows SmartScreen asks for
"More info" then "Run anyway" on unsigned builds.

Every binary built by `v3.2.2` fixes CVE-2026-109869 in both HTTP layers: the
bundled undici is >= 8.12.2 and the embedded Node is >= 24.22.1 (internal
undici 7.30.1). A 3.2 / 3.2.1 binary has neither and can be crashed by any
endpoint it fetches from.

## Publishing a binary

Attach the built file to a GitHub Release rather than committing it:

```bash
gh release create v3.2.2 release/Forge-3.2-windows-x64.exe \
  --title "Forge 3.2.2" --notes "See CHANGELOG.md"
```

Four single-file artifacts, one per platform, all built natively on GitHub
Actions (SEA cannot cross-build):

| Runner | Command | Output |
|---|---|---|
| Windows x64 | `npm run pack:exe` | `Forge-3.2-windows-x64.exe` |
| Linux x64 | `npm run pack:bin -- --target=linux-x64` | `Forge-3.2-linux-x64` |
| macOS arm64 | `npm run pack:bin -- --target=darwin-arm64` | `Forge-3.2-macos-arm64` |
| macOS x64 | `npm run pack:bin -- --target=darwin-x64` | `Forge-3.2-macos-x64` |

With no `--target` the packer builds for its own host. macOS binaries are
ad-hoc signed (Gatekeeper still asks on first download — that needs a paid
Developer ID). On first launch the Linux binary checks for the WebKitGTK 4.1
runtime and installs it through the distro package manager (apt, dnf, pacman
or zypper — the system asks for permission first); without a supported
manager it prints manual instructions instead of linker-crashing.