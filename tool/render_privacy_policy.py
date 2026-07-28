#!/usr/bin/env python3
"""Render docs/privacy-policy.md into the static site published by GitHub Pages.

The markdown file is the single source for the hosted policy, so the published
page cannot drift from it. Only the generated output is published — docs/ is
never served, because it also holds internal release planning documents.

Supports the subset of markdown the policy actually uses: a level-1 title, an
italic "last updated" line, level-2 headings, paragraphs, and inline `code`,
**bold** and _italic_. HTML comments (maintainer notes) are stripped.

Usage: python3 tool/render_privacy_policy.py <source.md> <output-dir>
"""

import html
import re
import sys
from pathlib import Path

PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="Privacy policy for the Fearless Inventory recovery companion app.">
<style>
  :root {{ color-scheme: light dark; }}
  body {{
    margin: 0 auto; padding: 2.5rem 1.25rem 4rem; max-width: 44rem;
    font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
          Helvetica, Arial, sans-serif;
    color: #1c1c1e; background: #fff;
  }}
  h1 {{ font-size: 1.9rem; line-height: 1.25; margin: 0 0 .5rem; }}
  h2 {{ font-size: 1.2rem; margin: 2.25rem 0 .6rem; }}
  p {{ margin: 0 0 1rem; }}
  code {{
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: .9em; background: rgba(127,127,127,.16);
    padding: .12em .35em; border-radius: .25rem;
  }}
  .updated {{ color: #6b6b70; font-size: .92rem; margin-bottom: 2rem; }}
  footer {{
    margin-top: 3rem; padding-top: 1.25rem;
    border-top: 1px solid rgba(127,127,127,.28);
    color: #6b6b70; font-size: .9rem;
  }}
  @media (prefers-color-scheme: dark) {{
    body {{ color: #e8e8ea; background: #131316; }}
    .updated, footer {{ color: #a0a0a8; }}
  }}
</style>
</head>
<body>
<main>
{body}
</main>
<footer>Fearless Inventory — a private companion for twelve-step recovery.</footer>
</body>
</html>
"""


def inline(text: str) -> str:
    """Escape HTML, then re-apply the inline markdown the policy uses."""
    out = html.escape(text, quote=False)
    out = re.sub(r"`([^`]+)`", r"<code>\1</code>", out)
    out = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", out)
    # Underscore italics, only when they wrap a run (avoids snake_case names).
    out = re.sub(r"(?<![\w`])_([^_]+)_(?![\w`])", r"<em>\1</em>", out)
    return out


def render(markdown: str) -> tuple[str, str]:
    # Drop maintainer notes so they never reach the published page.
    markdown = re.sub(r"<!--.*?-->", "", markdown, flags=re.S)

    title = "Privacy Policy"
    parts: list[str] = []
    buffer: list[str] = []

    def flush() -> None:
        if not buffer:
            return
        text = " ".join(line.strip() for line in buffer).strip()
        buffer.clear()
        if not text:
            return
        # The "_Last updated: …_" line gets its own styling.
        if text.startswith("_Last updated") and text.endswith("_"):
            parts.append('<p class="updated">%s</p>' % inline(text[1:-1]))
        else:
            parts.append("<p>%s</p>" % inline(text))

    for line in markdown.splitlines():
        stripped = line.strip()
        if not stripped:
            flush()
        elif stripped.startswith("## "):
            flush()
            parts.append("<h2>%s</h2>" % inline(stripped[3:].strip()))
        elif stripped.startswith("# "):
            flush()
            title = stripped[2:].strip()
            parts.append("<h1>%s</h1>" % inline(title))
        else:
            buffer.append(stripped)
    flush()

    return title, "\n".join(parts)


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    source, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    title, body = render(source.read_text(encoding="utf-8"))
    out_dir.mkdir(parents=True, exist_ok=True)
    page = PAGE.format(title=html.escape(title, quote=True), body=body)

    (out_dir / "privacy-policy.html").write_text(page, encoding="utf-8")
    # The policy is the only thing this site exists to serve, so it is also
    # the index — a bare repo-root URL should not 404.
    (out_dir / "index.html").write_text(page, encoding="utf-8")
    # Skip Jekyll; the HTML is already final.
    (out_dir / ".nojekyll").write_text("", encoding="utf-8")

    print("rendered %s -> %s (title: %s)" % (source, out_dir, title))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
