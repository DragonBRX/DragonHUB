from pathlib import Path
import hashlib
import json
import re
import unicodedata

root = Path(__file__).parent
game = root / "Games" / "BloxFruits"
runtime = (game / "Source" / "Runtime.lua").read_text(encoding="utf-8")
source = game / "Source" / "Functions"
source.mkdir(parents=True, exist_ok=True)

titles = []
for title in re.findall(r'AddToggle\([^\n]*?Title\s*=\s*"([^"]+)"', runtime):
    if title not in titles:
        titles.append(title)

used = set()
entries = []
for title in titles:
    normalized = unicodedata.normalize("NFKD", title).encode("ascii", "ignore").decode().lower()
    slug = re.sub(r"[^a-z0-9]+", "-", normalized).strip("-") or "function"
    if slug in used:
        slug += "-" + hashlib.sha1(title.encode()).hexdigest()[:8]
    used.add(slug)
    body = f'''local M={{Name={json.dumps(title, ensure_ascii=False)},State=false}}
function M:Apply(Value,Callback)
self.State=Value==true
if Callback then
task.spawn(function()
local Success,Error=pcall(Callback,self.State)
if not Success then _G.DragonHubFunctionError=self.Name..": "..tostring(Error) end
end)
end
end
return M
'''
    (source / f"{slug}.lua").write_text(body, encoding="utf-8", newline="\n")
    entries.append((title, slug))

lines = ['local Root="https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Source/Functions/"', 'local Version="?v="..tostring(os.time())', 'return {']
for title, slug in entries:
    lines.append(f'[{json.dumps(title, ensure_ascii=False)}]=Root.."{slug}.lua"..Version,')
lines.append('}')
(game / "Functions.lua").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
print(len(entries))
