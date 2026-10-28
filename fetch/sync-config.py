import json
import os
import re
import sys

CONFIG = os.path.expanduser("~/.config/fastfetch/config.jsonc")
OUT = os.path.expanduser("~/.config/fetch/config")

FIELD_MAP = {
    "os": "os",
    "host": "host",
    "kernel": "kernel",
    "uptime": "uptime",
    "packages": "packages",
    "shell": "shell",
    "display": "display",
    "displaymanager": "displaymanager",
    "wm": "wm",
    "wmtheme": "theme",
    "theme": "theme",
    "icons": "icons",
    "font": "font",
    "terminalfont": "font",
    "cursor": "cursor",
    "terminal": "terminal",
    "cpu": "cpu",
    "gpu": "gpu",
    "memory": "memory",
    "swap": "swap",
    "disk": "disk",
    "physicaldisk": "disk",
    "localip": "ip",
    "publicip": "ip",
    "battery": "battery",
    "poweradapter": "powerprofile",
    "powerprofile": "powerprofile",
    "locale": "locale",
    "colors": "colors",
    "separator": "---",
    "break": "---",
}


def strip_jsonc(text):
    out = []
    i = 0
    in_string = False
    escape = False
    while i < len(text):
        ch = text[i]
        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue
        if ch == "/" and i + 1 < len(text):
            nxt = text[i + 1]
            if nxt == "/":
                i += 2
                while i < len(text) and text[i] not in "\r\n":
                    i += 1
                continue
            if nxt == "*":
                i += 2
                while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                    i += 1
                i += 2
                continue
        out.append(ch)
        i += 1
    return "".join(out)


def module_type(module):
    if isinstance(module, str):
        return module
    if isinstance(module, dict):
        kind = module.get("type")
        return kind if isinstance(kind, str) else None
    return None


def main():
    try:
        with open(CONFIG, "r", encoding="utf-8-sig") as f:
            text = f.read()
    except OSError:
        return

    try:
        text = strip_jsonc(text)
        text = re.sub(r",(\s*[}\]])", r"\1", text)
        data = json.loads(text)
    except Exception as exc:
        print(f"fetch sync: {exc}", file=sys.stderr)
        return

    fields = []
    seen = set()
    for module in data.get("modules", []):
        field = FIELD_MAP.get(module_type(module))
        if not field or field in seen:
            continue
        if field == "---" and not fields:
            continue
        seen.add(field)
        fields.append(field)

    if not fields:
        return

    fields.extend(["label_color=green", "separator=:"])
    content = "\n".join(fields) + "\n"

    try:
        with open(OUT, "r", encoding="utf-8") as f:
            if f.read() == content:
                return
    except OSError:
        pass

    try:
        with open(OUT, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)
    except OSError as exc:
        print(f"fetch sync: {exc}", file=sys.stderr)


if __name__ == "__main__":
    main()
