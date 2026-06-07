ARG NODE_VERSION=20
ARG PLAYWRIGHT_VERSION=1.58.2
ARG BUN_VERSION=1.3.11

FROM node:${NODE_VERSION}-bookworm-slim

ARG NODE_VERSION
ARG PLAYWRIGHT_VERSION
ARG BUN_VERSION

LABEL org.opencontainers.image.title="Playwright Chromium headless shell and WebKit image"
LABEL org.opencontainers.image.description="Playwright runtime image with Chromium headless shell, WebKit, Bun, and Noto CJK fonts."
LABEL org.opencontainers.image.source="https://github.com/iuill/narou-viewer-playwright-images"
LABEL org.opencontainers.image.licenses="MIT"
LABEL io.playwright-lite.playwright-version="${PLAYWRIGHT_VERSION}"
LABEL io.playwright-lite.node-version="${NODE_VERSION}"
LABEL io.playwright-lite.bun-version="${BUN_VERSION}"
LABEL io.playwright-lite.browser-set="chromium-headless-shell,webkit"

ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      fontconfig \
      fonts-noto-cjk \
 && npm install -g "bun@${BUN_VERSION}" \
 && npx -y "playwright@${PLAYWRIGHT_VERSION}" install --with-deps --only-shell chromium webkit \
 && fc-cache -f \
 && npm cache clean --force \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /root/.cache /root/.npm
