import json

files = [
    'assets/data/1ac.json',
    'assets/data/2ac.json',
    'assets/data/3ac.json',
    'assets/data/tronc_commun.json',
    'assets/data/1bac.json'
]

total_lecons = 0
total_ex = 0
total_q = 0

for fpath in files:
    with open(fpath, encoding='utf-8') as f:
        d = json.load(f)
    n_l = len(d['lecons'])
    total_lecons += n_l
    for l in d['lecons']:
        assert len(l['exercices']) >= 3, f"{l['id']} has < 3 exercices"
        total_ex += len(l['exercices'])
        for ex in l['exercices']:
            assert 5 <= len(ex['questions']) <= 8, f"{ex['id']} question count {len(ex['questions'])}"
            total_q += len(ex['questions'])
            for q in ex['questions']:
                assert 'explication' in q and q['explication'], f"Missing explication in {ex['id']}"
    print(f"{fpath}: {n_l} lecons, code={d['code']}, nom={d['nom']}")

print(f"\n==========================================")
print(f"TOTAL: {total_lecons} leçons complètes, {total_ex} exercices interactifs, {total_q} questions pédagogiques avec explications détaillées.")
print(f"TOUS LES CRITÈRES D'INTÉGRITÉ SONT RESPECTÉS À 100% !")
print(f"==========================================")
