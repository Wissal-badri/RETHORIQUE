#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import re
import os
from html import unescape

with open('langue-francaise.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Pattern for lessons
pattern = re.compile(r'\{\s*c\s*:\s*"([^"]+)"\s*,\s*t\s*:\s*"([^"]+)"\s*,\s*n\s*:\s*"([^"]+)"\s*,\s*h\s*:\s*`(.*?)`\s*\}', re.DOTALL)
lessons_raw = list(pattern.finditer(html))

# Parse EX
ex_match = re.search(r'var EX=\[\s*(.*?)\s*\];\s*function', html, re.DOTALL)
ex_raw = ex_match.group(1).strip()
# Each line in EX is like:
# [['« Rapidement » est un…','nom|adverbe|adjectif',1],['Dans « les petits chats », « petits » est un…','adjectif|déterminant|pronom',0],['Quel mot est invariable ?','chat|beau|souvent',2]]
# Let's extract items per line
ex_lines = [l.strip().rstrip(',') for l in ex_raw.split('\n') if l.strip()]

print(f"Loaded {len(lessons_raw)} lessons and {len(ex_lines)} exercise groups from HTML.")
