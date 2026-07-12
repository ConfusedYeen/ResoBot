# Resobot

API service that accepts Resonite `resdb://` asset URLs, downloads the image from the Resonite CDN, and posts it to a Telegram channel. Large images are compressed for Telegram's photo limit; the original file is sent separately as a document.

Built with **Rails 8** (API-only) and **Grape**.

## TODO

Provide a link to the Resonite asset that includes all the protoflux needed for Resobot to work.

## Requirements

- Ruby **4.0.5** (see `.ruby-version`)
- **libvips** (image compression)

```bash
# Arch Linux
sudo pacman -S libvips

# Debian / Ubuntu
sudo apt install libvips42
```

## Setup

```bash
git clone https://github.com/ConfusedYeen/ResoBot.git
cd resobot
bundle install
cp .env.example .env
```

Edit `.env` with your Telegram bot credentials:

| Variable | Description |
|---|---|
| `RESO_ASSETS_URL` | Resonite assets CDN base URL (default: `https://assets.resonite.com`) |
| `TELEGRAM_API_URL` | Telegram Bot API base URL (default: `https://api.telegram.org/bot`) |
| `TELEGRAM_BOT_TOKEN` | Bot token from [@BotFather](https://t.me/BotFather) |
| `TELEGRAM_CHAT_ID` | Target chat or channel ID |

## Running

```bash
bin/rails server
```
Or, simply 
```bash
bin/rails s
```

Health check: `GET http://localhost:3000/up` (Rails) or `GET http://localhost:3000/resobot/health` (Grape).

## API

Base path: `/resobot`

### `GET /resobot/health`

```json
{ "status": "ok" }
```

### `GET /resobot/resdb`

Smoke test for the Resdb mount.

```json
{ "status": "ok", "message": "Resdb is working" }
```

### `POST /resobot/resdb/image`

Submit a Resonite asset for processing.
For now, Resobot only works with images. Support for other asset types is planned, but there's no ETA yet.

**Parameters**

| Name | Type | Required | Description |
|---|---|---|---|
| `url` | String | yes | Asset URL, e.g. `resdb:///7b8672…e10e8.png` |
| `name` | String | no | Submitter name (shown in caption) |
| `datetime` | String | no | Submission timestamp (shown in caption) |
| `location` | String | no | Instance/world name (shown in caption) |

**Example**

```bash
curl -X POST http://localhost:3000/resobot/resdb/image \
  -H "Content-Type: application/json" \
  -d '{
    "url": "resdb:///7b867205e3ab9f67f967cb5566e5b766916fc519c580cf85caba1aa9925e10e8.png",
    "name": "Tofu",
    "location": "My World"
  }'
```

**Success response**

```json
{
  "status": "ok",
  "photo": { "status": "ok", "message": "..." },
  "document": { "status": "ok", "message": "..." }
}
```

**Error response**

```json
{ "error": "Invalid URL" }
```

## Testing

```bash
bundle exec rspec
```

With coverage:

```bash
COVERAGE=true bundle exec rspec
open coverage/index.html
```

Test images live in `spec/fixtures/files/`. Fixtures are auto-generated on first run; replace `small.png` / `large.png` there to test with your own assets.

## Linting

```bash
bin/rubocop
bin/brakeman
```

## Deployment

Docker and [Kamal](https://kamal-deploy.org) are configured, but **not** tested personally. The production image includes `libvips42`.

```bash
docker build -t resobot .
```

See `config/deploy.yml` for Kamal deployment settings.
