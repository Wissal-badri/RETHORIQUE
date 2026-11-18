import re
import json

with open('langue-francaise.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Extract L array
l_match = re.search(r'var L=\[\s*(.*?)\s*\];\s*var EX=', html, re.DOTALL)
if not l_match:
    print("Could not find var L")
    exit(1)

l_content = l_match.group(1)

# Extract EX array
ex_match = re.search(r'var EX=\[\s*(.*?)\s*\];\s*function', html, re.DOTALL)
if not ex_match:
    print("Could not find var EX")
    exit(1)

ex_content = ex_match.group(1)

print(f"L content length: {len(l_content)}, EX content length: {len(ex_content)}")
