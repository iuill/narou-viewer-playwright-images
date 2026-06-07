# narou-viewer-playwright-images

Chromium headless shell と WebKit だけを入れた Playwright コンテナイメージです。

標準イメージには Chromium headless shell / WebKit、Bun、curl、Noto CJK フォントを入れます。
Firefox と full Chromium は意図的に含めません。headless CI で Chromium と WebKit だけを使うケースの
image pull コストを抑えることを目的にしています。

## 公開イメージ

イメージは GitHub Container Registry へ publish します。

```text
ghcr.io/iuill/narou-viewer-playwright:<playwright>-node<node>-bookworm-slim-chromium-headless-shell-webkit-curl-amd64
```

例:

```text
ghcr.io/iuill/narou-viewer-playwright:1.58.2-node20-bookworm-slim-chromium-headless-shell-webkit-curl-amd64
```

毎日の rebuild では、日付付き tag も publish します。

```text
ghcr.io/iuill/narou-viewer-playwright:1.58.2-node20-bookworm-slim-chromium-headless-shell-webkit-curl-amd64-20260607
```

日付付き tag の package version は、workflow 内で直近 14 個だけ残します。
固定 tag と当日の tag は cleanup 対象から外します。

## ローカルビルド

```bash
docker build \
  --build-arg PLAYWRIGHT_VERSION=1.58.2 \
  --build-arg NODE_VERSION=20 \
  --build-arg BUN_VERSION=1.3.11 \
  -t ghcr.io/iuill/narou-viewer-playwright:1.58.2-node20-bookworm-slim-chromium-headless-shell-webkit-curl-amd64 \
  .
```

## Smoke Test

```bash
PLAYWRIGHT_VERSION=1.58.2 \
  scripts/smoke.sh ghcr.io/iuill/narou-viewer-playwright:1.58.2-node20-bookworm-slim-chromium-headless-shell-webkit-curl-amd64
```

smoke test では次を確認します。

- Node / Bun が利用できること。
- curl が利用できること。
- Chromium headless shell / WebKit の browser payload が存在すること。
- full Chromium の browser payload が存在しないこと。
- Firefox の browser payload が存在しないこと。
- Noto CJK フォントが利用できること。
- Chromium / WebKit を起動して小さなページを render できること。

## バージョン方針

イメージは Playwright version 固定で扱います。daily schedule では Playwright 自体を自動更新しません。
daily rebuild の目的は、固定済み Playwright version のまま OS package 更新を取り込むことです。

利用側で `@playwright/test` を更新するときは、このリポジトリの `PLAYWRIGHT_VERSION` も合わせて更新し、
生成された image を smoke test で確認します。

## メモ

- Chromium は headless shell のみを入れます。headed Chromium が必要な用途には向きません。
- 現時点では linux/amd64 のみを対象にします。
- Playwright の WebKit / Firefox build は glibc 前提のため、この用途では Alpine を base にしません。
- `FROM mcr.microsoft.com/playwright` してから Firefox を削除しても、親 image layer に Firefox が残るため pull size は小さくなりません。
- ローカル測定では、`mcr.microsoft.com/playwright:v1.58.2-noble` の `docker save | gzip` が約 899MB、この image が約 787MB でした。
- GitHub Container Registry の storage / bandwidth は現時点では無料ですが、日付付き tag は増え続けないように cleanup します。

## License

このリポジトリは MIT License です。

公開するコンテナイメージには、Playwright、Node.js、Bun、Debian packages、browser binaries、fonts などの
third-party software が含まれます。これらの component は、それぞれの license に従います。
Playwright 自体は Apache-2.0 license です。
