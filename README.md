# DreamBot Remote

# Control your bot remotely!

DreamBot running in a full Ubuntu desktop, accessed entirely through
your browser. Java, the launcher, and autostart are baked into the
image, so there's nothing to set up after `docker compose up -d` —
it just boots straight into DreamBot.

This exists because running DreamBot's Jagex login inside a stripped
headless container is a nightmare — the embedded Chromium browser it
uses for login crashes constantly without a proper desktop around it.
Running a full desktop sidesteps the whole problem.

## Files

- `docker-compose.yml` — the service definition
- `Dockerfile` — builds the image
- `dreambot.desktop` — autostart entry that fires DreamBot on boot
- `ensure-dreambot.sh` — re-checks the launcher's in place on every start, just in case

Keep all four next to each other — `docker compose build` needs them all in the same folder.

## Setup

Open `docker-compose.yml` and change `PASSWORD` to something of your own — that's what you'll use to log into the web desktop (username is `abc`).

Build and start it:

```
docker compose up -d --build
```

First build takes a few minutes — it's installing Java and grabbing the DreamBot launcher. After that, starts are instant.

Open `http://localhost:5800` in your browser (swap in the host's IP if you're accessing it remotely), log in with `abc` and your password, and give it about 10 seconds. DreamBot opens on its own.

Log into your Jagex account through the launcher as you normally would — the browser login works fine here since it's a real desktop, not a stripped-down container.

That's the whole setup. From now on, every restart or `docker compose up -d` brings DreamBot straight up with you logged in.

## Persistence

Your DreamBot install, Jagex session, scripts and settings all live in the `dreambot-data` volume. They survive restarts and recreations — you only need to log into Jagex once.

## Why it's built this way

A real desktop instead of a headless image, because the embedded Chromium DreamBot uses for Jagex login just doesn't survive in a stripped-down container.

A few other bits worth knowing:

- `seccomp:unconfined` relaxes Docker's syscall filtering — Chromium needs this.
- `shm_size: 1gb` bumps shared memory past Docker's stingy 64MB default, which is enough to make Chromium crash or hang on its own.
- `mem_limit: 4g` caps how much RAM the container can use. Adjust to whatever your host can spare.
- Autostart comes from the `.desktop` file in `/config/.config/autostart/`, which XFCE reads on session start.
- `ensure-dreambot.sh` runs on every boot and recreates the launcher/autostart file if either's missing. This covers an annoying edge case: if a volume already has a partially-built `.config` folder from before, the image's normal first-boot copy can skip filling in the rest.

## Reinstalling the launcher

It self-updates on launch, so you normally won't need to touch this. If you ever want a clean reinstall:

```
docker compose down
docker volume rm dreambot-data
docker compose up -d --build
```

That wipes your saved login and scripts too, so only do it if you're fine logging back in.

## Stopping / removing

Stop without losing anything:

```
docker compose down
```

Wipe everything, including your saved login (irreversible):

```
docker compose down -v
```
