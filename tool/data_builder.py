#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import re
import os
from html import unescape

def clean_inline_html(text):
    text = unescape(text)
    text = re.sub(r'<\/?(b|strong)>', '**', text)
    text = re.sub(r'<\/?(i|em)>', '*', text)
    text = re.sub(r'<br\s*\/?>', '\n', text)
    text = re.sub(r'<[^>]+>', '', text)
    text = re.sub(r'\*\*\s*\*\*', '', text)
    return text.strip()

def parse_html_table(table_html):
    headers = []
    rows = []
    th_matches = re.findall(r'<th[^>]*>(.*?)<\/th>', table_html, re.DOTALL | re.IGNORECASE)
    if th_matches:
        headers = [clean_inline_html(th) for th in th_matches]
    tr_matches = re.findall(r'<tr[^>]*>(.*?)<\/tr>', table_html, re.DOTALL | re.IGNORECASE)
    for tr in tr_matches:
        td_matches = re.findall(r'<td[^>]*>(.*?)<\/td>', tr, re.DOTALL | re.IGNORECASE)
        if td_matches:
            rows.append([clean_inline_html(td) for td in td_matches])
    return headers, rows

def html_to_blocks(html_str, schema_id=None):
    blocks = []
    pattern = re.compile(
        r'(<div class="tw"><table>.*?<\/table><\/div>|<div class="ex">.*?<\/div>|<p>.*?<\/p>|<table>.*?<\/table>)',
        re.DOTALL | re.IGNORECASE
    )
    parts = pattern.findall(html_str)
    if not parts:
        cleaned = clean_inline_html(html_str)
        if cleaned:
            blocks.append({"type": "paragraphe", "texte": cleaned})
        return blocks
        
    for part in parts:
        if '<table' in part.lower():
            headers, rows = parse_html_table(part)
            if headers or rows:
                blocks.append({
                    "type": "tableau",
                    "entetes": headers,
                    "lignes": rows
                })
        elif 'class="ex"' in part.lower():
            inner = re.sub(r'^<div[^>]*>', '', part, flags=re.IGNORECASE)
            inner = re.sub(r'<\/div>$', '', inner, flags=re.IGNORECASE)
            cleaned = clean_inline_html(inner)
            if cleaned:
                blocks.append({
                    "type": "exemple",
                    "texte": cleaned
                })
        elif part.lower().startswith('<p>'):
            inner = re.sub(r'^<p>', '', part, flags=re.IGNORECASE)
            inner = re.sub(r'<\/p>$', '', inner, flags=re.IGNORECASE)
            cleaned = clean_inline_html(inner)
            if cleaned:
                blocks.append({
                    "type": "paragraphe",
                    "texte": cleaned
                })
                
    if schema_id:
        blocks.append({
            "type": "schema",
            "id": schema_id
        })
        
    return blocks

SCHEMA_MAPPING = {
    0: "carte_classes_mots",
    1: "schema_fonctions",
    3: "schema_phrase_complexe",
    4: "roue_circonstancielles",
    6: "discours_direct_indirect",
    8: "frise_temps",
    12: "arbre_participe_passe",
    19: "cartes_figures_style",
    21: "roue_circonstancielles",
    27: "frise_temps",
    28: "arbre_participe_passe",
    33: "discours_direct_indirect"
}

ID_MAPPING = {
    0: "gram-classes",
    1: "gram-fonctions",
    2: "gram-types-formes",
    3: "gram-propositions",
    4: "gram-circonstancielles",
    5: "gram-pronoms",
    6: "gram-discours",
    7: "conj-groupes-present",
    8: "conj-imparfait-pc-ps",
    9: "conj-futur-cond",
    10: "conj-subjonctif",
    11: "conj-imperatif",
    12: "orth-participe-passe",
    13: "orth-homophones",
    14: "orth-pluriel-feminin",
    15: "orth-accents",
    16: "voc-prefixes-suffixes",
    17: "voc-synonymes-antonymes",
    18: "voc-champs-lexicaux",
    19: "voc-figures-style",
    20: "gram-temps",
    21: "gram-cause-consequence",
    22: "gram-but-condition",
    23: "gram-comparaison-concession",
    24: "gram-relatives",
    25: "gram-completives",
    26: "gram-ponctuation",
    27: "conj-temps-composes",
    28: "orth-participe-passe-cas-particuliers",
    29: "style-denotation-connotation",
    30: "style-melioratif-pejoratif",
    31: "style-explicite-implicite",
    32: "style-humour-ironie",
    33: "style-direct-indirect-libre"
}

with open('langue-francaise.html', 'r', encoding='utf-8') as f:
    html = f.read()

pattern = re.compile(r'\{\s*c\s*:\s*"([^"]+)"\s*,\s*t\s*:\s*"([^"]+)"\s*,\s*n\s*:\s*"([^"]+)"\s*,\s*h\s*:\s*`(.*?)`\s*\}', re.DOTALL)
lessons_raw = list(pattern.finditer(html))

ex_match = re.search(r'var EX=\[\s*(.*?)\s*\];\s*function', html, re.DOTALL)
ex_raw = ex_match.group(1).strip()
ex_lines = [l.strip().rstrip(',') for l in ex_raw.split('\n') if l.strip()]

def parse_html_ex_line(line_str):
    q_matches = re.findall(r"\[\s*'(.*?)'\s*,\s*'(.*?)'\s*,\s*(\d+)\s*\]", line_str)
    questions = []
    for enonce, opts, ans_idx in q_matches:
        options = [o.strip() for o in opts.split('|')]
        ans = int(ans_idx)
        # Améliorer l'explication spécifique
        questions.append({
            "enonce": enonce,
            "options": options,
            "reponse": ans,
            "explication": f"La réponse correcte est « {options[ans]} »."
        })
    return questions

# Enrichissements d'explications et questions complémentaires par leçon
EXTRA_EXERCISES = {
    # 0: Les classes grammaticales
    0: {
        "ex1_complement": [
            {"enonce": "Dans « Amina lit un roman captivant », « captivant » est un…", "options": ["adverbe", "nom", "adjectif qualificatif"], "reponse": 2, "explication": "« Captivant » s'accorde avec le nom roman : c'est un adjectif qualificatif."},
            {"enonce": "« Hélas ! » appartient à la classe des…", "options": ["interjections", "conjonctions", "prépositions"], "reponse": 0, "explication": "« Hélas ! » exprime un sentiment vif ou une émotion : c'est une interjection invariable."},
            {"enonce": "Parmi ces mots, lequel est une conjonction de coordination ?", "options": ["car", "parce que", "puisque"], "reponse": 0, "explication": "« Mais, ou, et, donc, or, ni, car » sont les sept conjonctions de coordination."}
        ],
        "ex2": {
            "titre": "Exercice 2 — Vrai ou Faux sur les classes de mots",
            "consigne": "Indique si l'affirmation est vraie ou fausse.",
            "type": "vrai_faux",
            "questions": [
                {"enonce": "Les prépositions sont des mots variables qui s'accordent en genre et en nombre.", "reponse": False, "explication": "Faux : les prépositions (à, de, pour, sans...) sont strictement invariables."},
                {"enonce": "Le pronom remplace généralement un nom ou un groupe nominal.", "reponse": True, "explication": "Vrai : le pronom évite les répétitions en reprenant un référent."},
                {"enonce": "Il existe cinq classes de mots variables et cinq classes de mots invariables.", "reponse": True, "explication": "Vrai : 5 variables (nom, dét., adj., pronom, verbe) et 5 invariables (adv., prép., conj. coord., conj. sub., interj.)."},
                {"enonce": "Dans « Nous voyageons », « Nous » est un déterminant.", "reponse": False, "explication": "Faux : « Nous » est un pronom personnel sujet."},
                {"enonce": "L'adverbe est un mot invariable qui modifie le sens d'un verbe, d'un adjectif ou d'un autre adverbe.", "reponse": True, "explication": "Vrai : exemple « Il court très vite »."}
            ]
        },
        "ex3": {
            "titre": "Exercice 3 — Identification et texte à trous",
            "consigne": "Indique la classe grammaticale exacte du mot entre parenthèses.",
            "type": "trous",
            "questions": [
                {"enonce": "Dans « Youssef marche (lentement) », le mot entre parenthèses est un ___", "reponse": "adverbe", "acceptees": ["adverbe", "un adverbe"], "explication": "« Lentement » indique la manière et est invariable : c'est un adverbe."},
                {"enonce": "Dans « Les élèves sont (dans) la cour », le mot entre parenthèses est une ___", "reponse": "préposition", "acceptees": ["préposition", "une préposition", "preposition"], "explication": "« Dans » est une préposition introduisant un complément de lieu."},
                {"enonce": "Dans « (Cette) histoire est belle », le mot entre parenthèses est un déterminant ___", "reponse": "démonstratif", "acceptees": ["démonstratif", "demonstratif"], "explication": "« Cette » désigne la chose dont on parle : déterminant démonstratif."},
                {"enonce": "Dans « Mehdi et Omar jouent (et) rient », « et » est une conjonction de ___", "reponse": "coordination", "acceptees": ["coordination"], "explication": "« et » relie deux propositions ou mots de même fonction : coordination."},
                {"enonce": "Dans « La maison (blanche) », le mot entre parenthèses est un ___ qualificatif.", "reponse": "adjectif", "acceptees": ["adjectif", "adjectif qualificatif"], "explication": "« blanche » qualifie le nom maison : c'est un adjectif qualificatif."}
            ]
        }
    },
    # 1: Les fonctions dans la phrase
    1: {
        "ex1_complement": [
            {"enonce": "Dans « Mehdi devient médecin », « médecin » est…", "options": ["COD", "attribut du sujet", "complément circonstanciel"], "reponse": 1, "explication": "« Devenir » est un verbe d'état : « médecin » est donc attribut du sujet."},
            {"enonce": "Dans « À Casablanca, la circulation est dense », « À Casablanca » est…", "options": ["sujet", "CC de lieu", "COI"], "reponse": 1, "explication": "« À Casablanca » est déplaçable et indique l'endroit : complément circonstanciel de lieu."},
            {"enonce": "Dans « Salma pense à ses vacances », « à ses vacances » est…", "options": ["COD", "COI", "attribut"], "reponse": 1, "explication": "Il répond à la question « à quoi ? » avec préposition : COI."}
        ],
        "ex2": {
            "titre": "Exercice 2 — Identifier la fonction syntaxique",
            "consigne": "Choisis la fonction correcte pour l'élément souligné.",
            "type": "choix_dans_phrase",
            "questions": [
                {"enonce": "Omar offre un bouquet à sa mère. « à sa mère » est [COD/COI/Sujet].", "options": ["COD", "COI", "Sujet"], "reponse": 1, "explication": "Répond à la question « à qui ? » : COI."},
                {"enonce": "Ce poème paraît magnifique. « magnifique » est [Attribut du sujet/COD/CC de manière].", "options": ["Attribut du sujet", "COD", "CC de manière"], "reponse": 0, "explication": "« Paraît » est un verbe d'état, donc l'adjectif est attribut du sujet."},
                {"enonce": "Chaque matin, Youssef court. « Chaque matin » est [CC de temps/COD/Sujet].", "options": ["CC de temps", "COD", "Sujet"], "reponse": 0, "explication": "Indique le moment et est déplaçable : complément circonstanciel de temps."},
                {"enonce": "Les enfants écoutent le conte. « le conte » est [COD/COI/Attribut].", "options": ["COD", "COI", "Attribut"], "reponse": 0, "explication": "Répond directement à « quoi ? » sans préposition : COD."},
                {"enonce": "Fatima ressemble à sa grand-mère. « à sa grand-mère » est [COI/COD/CC de manière].", "options": ["COI", "COD", "CC de manière"], "reponse": 0, "explication": "Introduit par la préposition « à » : COI."}
            ]
        },
        "ex3": {
            "titre": "Exercice 3 — Vrai ou Faux sur les fonctions",
            "consigne": "Indique si l'affirmation est vraie ou fausse.",
            "type": "vrai_faux",
            "questions": [
                {"enonce": "Le sujet fait ou subit l'action et commande l'accord du verbe.", "reponse": True, "explication": "Vrai : le verbe s'accorde toujours en personne et en nombre avec son sujet."},
                {"enonce": "Un verbe transitif direct se construit avec un COI.", "reponse": False, "explication": "Faux : un verbe transitif direct se construit avec un COD (sans préposition)."},
                {"enonce": "Les compléments circonstanciels sont généralement supprimables et déplaçables.", "reponse": True, "explication": "Vrai : exemple « Hier, je suis venu » = « Je suis venu hier »."},
                {"enonce": "L'attribut du sujet est relié au sujet par un verbe d'action.", "reponse": False, "explication": "Faux : l'attribut est relié au sujet par un verbe d'état (être, sembler, devenir...)."},
                {"enonce": "Dans « Il parle de son projet », « de son projet » est un COI.", "reponse": True, "explication": "Vrai : il répond à la question « de quoi ? »."}
            ]
        }
    }
}

print("Générateur d'exercices structuré initialisé.")
