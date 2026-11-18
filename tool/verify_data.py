import json

for fname in ['3ac.json', '1bac.json', 'tronc_commun.json']:
    path = f'assets/data/{fname}'
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f'=== {fname} ===')
    print('Code:', data['code'], '| Nom:', data['nom'], '| Leçons:', len(data['lecons']))
    for l in data['lecons']:
        assert len(l['exercices']) >= 3, f"Less than 3 exercises in {l['id']}"
        for ex in l['exercices']:
            assert 5 <= len(ex['questions']) <= 8, f"Question count not 5-8 in {ex['id']}: {len(ex['questions'])}"
            for q in ex['questions']:
                assert 'explication' in q and q['explication'], f"Missing explanation in {ex['id']}"
print('SUCCESS: All integrity assertions passed with 100% compliance!')
