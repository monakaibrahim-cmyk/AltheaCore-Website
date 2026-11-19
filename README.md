# Dragon Nest Cap 60 WebServer (Patch HTTP Server)

Dockerized Nginx HTTP server for Dragon Nest launcher config, notice page, and incremental `.pak` patches.

## Layout

- `Dockerfile` — Builds an `nginx:1.27-alpine` image with custom patch-server rules and health check.
- `docker-compose.yml` — Runs `dn_cap60_webserver` on port `80` (configurable via `.env`) and bind-mounts `./www` read-only so manual patches take effect immediately without rebuilding.
- `nginx/default.conf` — Configures:
  - Case-insensitive `.MD5` / `.md5` lookup (`DNLauncher.exe` requests `.MD5` uppercase even when files on disk are `.md5`).
  - `Cache-Control: no-store` on `.xml`, `.cfg`, `.txt`, and `.md5` metadata files.
  - Byte-range resume support (`Range: bytes=...`) for `.pak` downloads.
  - `/health` endpoint and root fallback for `/PatchConfigList.xml` & `/PatchInfoServer.cfg`.
- `scripts/sync-patches.ps1` — Copies versioned patch folders and `PatchInfoServer.cfg` from `D:\laragon\www\Game\DragonNest\patch` into `./www/Game/DragonNest/patch`.
- `www/Game/DragonNest/patch/` — Serves `PatchConfigList.xml`, `PatchInfoServer.cfg`, and version folders (`00000354/`, `00000355/`, ...).
- `www/Game/DragonNest/launcher/index.html` — Local launcher notice/status page.

## Quick Start

```powershell
cd R:\Server\WebServer
docker compose up -d --build
```

Verify endpoints:

```powershell
curl.exe -s http://127.0.0.1/health
curl.exe -s http://127.0.0.1/Game/DragonNest/patch/PatchInfoServer.cfg
curl.exe -I http://127.0.0.1/Game/DragonNest/patch/00000354/Patch00000354.pak.MD5
```

## Adding Manual Patches

Drop a new zero-padded 8-digit folder (for example `00000356/`) containing `Patch00000356.pak`, `Patch00000356.pak.md5`, and `Patch00000356.txt` into `www\Game\DragonNest\patch\`, and update `www\Game\DragonNest\patch\PatchInfoServer.cfg` (`version 356`). Because `./www` is bind-mounted in `docker-compose.yml`, changes are served immediately.
