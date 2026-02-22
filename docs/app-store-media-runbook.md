# App Store Media Runbook

## 1. Generate screenshots

```bash
./scripts/media/capture_screenshots.sh
```

Output folder:

- `screenshots/generated/<timestamp>/iphone-6.9`
- `screenshots/generated/<timestamp>/ipad-13`

Generated screenshots:

1. `01-home.png`
2. `02-tasks.png`
3. `03-seasonal.png`
4. `04-history.png`
5. `05-settings.png`

## 2. Generate app preview videos (30fps)

```bash
./scripts/media/record_app_previews.sh
```

Output folder:

- `videos/generated/<timestamp>/iphone-6.9/homekeep-app-preview.mp4`
- `videos/generated/<timestamp>/ipad-13/homekeep-app-preview.mp4`

Default duration is 28 seconds. Override with:

```bash
VIDEO_DURATION_SECONDS=25 ./scripts/media/record_app_previews.sh
```

## 3. Sync latest generated media to appstore upload folder

```bash
./scripts/media/sync_latest_to_appstore.sh
```

This copies the most recent screenshot/video outputs into `appstore/media` using stable upload filenames.

## 4. How media mode works

The scripts launch the app with simulator-only arguments:

- `-media-mode`
- `-media-tab <home|tasks|seasonal|history|settings>`
- `-media-video` (for auto tab transitions in preview recordings)
- `-media-reset` (wipe and reseed demo data)

Media scripts force and validate `30fps` output using `ffmpeg` and `ffprobe`.
