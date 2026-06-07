#!/usr/bin/env bash

set -euo pipefail

image_ref="${1:?Usage: scripts/smoke.sh <image-ref>}"
playwright_version="${PLAYWRIGHT_VERSION:-1.58.2}"

docker run --rm \
  -e PLAYWRIGHT_VERSION="${playwright_version}" \
  "${image_ref}" \
  bash -lc '
    set -euo pipefail

    node --version
    bun --version

    test -d /ms-playwright
    find /ms-playwright -maxdepth 1 -type d -name "chromium_headless_shell-*" | grep -q .
    find /ms-playwright -maxdepth 1 -type d -name "webkit-*" | grep -q .
    if find /ms-playwright -maxdepth 1 -type d -name "chromium-*" | grep -q .; then
      echo "Full Chromium browser payload should not be present" >&2
      exit 1
    fi
    if find /ms-playwright -maxdepth 1 -type d -name "firefox-*" | grep -q .; then
      echo "Firefox browser payload should not be present" >&2
      exit 1
    fi

    fc-match "Noto Sans CJK JP" >/dev/null

    tmp_dir="$(mktemp -d)"
    cd "${tmp_dir}"
    npm init -y >/dev/null
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install --silent "playwright@${PLAYWRIGHT_VERSION}"

    node <<'"'"'NODE'"'"'
const { chromium, webkit } = require("playwright");

(async () => {
  for (const browserType of [chromium, webkit]) {
    const browser = await browserType.launch({ headless: true });
    const page = await browser.newPage();
    await page.setContent("<main>narou_viewer playwright image smoke</main>");
    const text = await page.textContent("main");
    if (text !== "narou_viewer playwright image smoke") {
      throw new Error(`${browserType.name()} smoke text mismatch: ${text}`);
    }
    await browser.close();
  }
})();
NODE
  '
