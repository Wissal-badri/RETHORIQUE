import re
import json

with open('langue-francaise.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Pattern for {c:"...",t:"...",n:"...",h:`...`}
# Note that h is enclosed in backticks `...`
pattern = re.compile(r'\{\s*c\s*:\s*"([^"]+)"\s*,\s*t\s*:\s*"([^"]+)"\s*,\s*n\s*:\s*"([^"]+)"\s*,\s*h\s*:\s*`(.*?)`\s*\}', re.DOTALL)

lessons = []
for m in pattern.finditer(html):
    lessons.append({
        'categorie': m.group(1),
        'titre': m.group(2),
        'niveau': m.group(3),
        'html': m.group(4)
    })

print(f"Total parsed lessons: {len(lessons)}")
for i, l in enumerate(lessons):
    print(f"{i}: [{l['categorie']}] {l['titre']} ({l['niveau']})")

# Also parse EX
ex_match = re.search(r'var EX=\[\s*(.*?)\s*\];\s*function', html, re.DOTALL)
ex_raw = ex_match.group(1)

# In EX, each line is like:
# [['« Rapidement » est un…','nom|adverbe|adjectif',1],['Dans « les petits chats », « petits » est un…','adjectif|déterminant|pronom',0],['Quel mot est invariable ?','chat|beau|souvent',2]],
ex_groups = []
# split on line breaks or by regex
lines = [line.strip().rstrip(',') for line in ex_raw.strip().split('\n') if line.strip()]
print(f"Total EX lines: {len(lines)}")
