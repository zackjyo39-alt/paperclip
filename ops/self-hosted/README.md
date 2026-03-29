# Self-Hosted Wrapper

This directory keeps local/VPS deployment helpers separate from the upstream Paperclip source tree.

## Layout

- `ops/self-hosted/scripts`: host-mode lifecycle scripts
- `ops/self-hosted/docker-compose.yml`: portable container deployment
- `ops/self-hosted/docker`: Docker entrypoint and image wrapper
- `ops/self-hosted/.paperclip-home`: embedded database, config, secrets, logs (ignored by Git)
- `ops/self-hosted/.codex-home`: Codex runtime state for container mode (ignored by Git)
- `ops/self-hosted/runtime`: local `paperclipai` CLI install for host mode (ignored by Git)

## Why This Lives Under `ops/`

The upstream repository already has its own root-level Docker and development setup. Keeping custom deployment files under `ops/self-hosted` reduces merge conflicts when you sync your fork with upstream.

The canonical project root remains the repository root, not this `ops` directory. That matters for local adapters such as Codex because they persist absolute workspace paths.

## Host Mode

Requirements:

- Node.js 20+

Start:

```bash
./ops/self-hosted/scripts/paperclip-start.sh
```

Status:

```bash
./ops/self-hosted/scripts/paperclip-status.sh
```

Stop:

```bash
./ops/self-hosted/scripts/paperclip-stop.sh
```

Host mode keeps the service loopback-only by default at `http://127.0.0.1:3100`.

## Docker Compose Mode

Run this from the repository root:

```bash
cp ops/self-hosted/.env.compose.example ops/self-hosted/.env
docker compose -f ops/self-hosted/docker-compose.yml up -d --build
```

The container uses a fixed in-container workspace path, `/workspace/paperclip`, so Codex-related absolute paths remain stable across VPS and Docker moves.

## Path Migration

If the repository root changes on the host, local adapter records in the embedded database may still point at the old absolute path. Repair them with:

```bash
PAPERCLIP_HOME="$(pwd)/ops/self-hosted/.paperclip-home" \
PAPERCLIP_INSTANCE_ID=demo \
node ./ops/self-hosted/scripts/paperclip-rewrite-paths.mjs <old-root> <new-root>
```

You can also automate the rewrite:

- Host mode: set `PAPERCLIP_REWRITE_FROM_ROOT=/previous/root` before `paperclip-start.sh`
- Docker mode: set `PAPERCLIP_REWRITE_FROM_ROOT=/previous/root` in `ops/self-hosted/.env`

## Upstream Sync

Because these files live under `ops/self-hosted`, future upstream syncs mostly affect the Paperclip source tree while your deployment wrapper stays isolated in one directory.
