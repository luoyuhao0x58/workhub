#! /usr/bin/env python3
"""Pin the selkies web client's document.body to the viewport size.

selkies derives the session resolution it asks the server for from
`document.body.offsetWidth/offsetHeight` (multiplied by devicePixelRatio), but
it sizes the stream element by fitting that same aspect ratio inside the
viewport. When the body overflows the viewport the two sizes drift apart, while
the pointer math maps element pixels straight to server pixels with no
compensating scale - so every click lands proportionally short of its target,
and window decoration buttons become unclickable.

Clamping the body removes the divergence at its source. Verified on a 1304x746
viewport: body.offsetHeight was 876 against a 746 viewport, a 16% error that
grew with distance from the top edge (which is why the top bar stayed clickable
and everything below it did not).

The style block is added idempotently so the build can be re-run.
"""

import pathlib
import re
import sys

STYLE_ID = "workhub-body"
CSS = """<style id="workhub-body">
/* Keep document.body the size of the viewport. selkies derives the session
   resolution from body.offsetWidth/Height and sizes the stream element from
   the same aspect ratio; if the body overflows, the two diverge and pointer
   coordinates land proportionally off target. */
html, body {
  height: 100% !important;
  max-height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
  overflow: hidden !important;
}
</style>
"""


def patch(path: pathlib.Path) -> bool:
    html = path.read_text()
    html = re.sub(rf'<style id="{STYLE_ID}">.*?</style>\s*', "", html, flags=re.S)
    if "</head>" not in html:
        print(f"{path}: no </head>, skipped", file=sys.stderr)
        return False
    path.write_text(html.replace("</head>", CSS + "</head>", 1))
    return True


def main() -> int:
    pattern = "/opt/pipx/venvs/selkies/lib/python*/site-packages/selkies/selkies_web/index.html"
    targets = sorted(pathlib.Path("/").glob(pattern.lstrip("/")))
    if not targets:
        print(f"selkies web index.html not found under {pattern}", file=sys.stderr)
        return 1
    for path in targets:
        ok = patch(path)
        print(f"{path}: {'patched' if ok else 'skipped'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
