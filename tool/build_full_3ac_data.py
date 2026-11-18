#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Constructeur complet des données JSON pour Rhétorique :
Génère 3ac.json, 1bac.json, tronc_commun.json
"""

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
        questions.append({
            "enonce": enonce,
            "options": options,
            "reponse": ans,
            "explication": f"La réponse correcte est « {options[ans]} » conformément aux règles étudiées dans cette leçon."
        })
    return questions

# Modèles d'exercices enrichis et spécifiques par thématique
def build_lesson_exercises(idx, titre, cat, niveau, base_questions):
    ex1_questions = list(base_questions)
    
    # Compléter Ex1 à 6 questions QCM selon le sujet
    ex1_complements = {
        0: [
            {"enonce": "Dans « Amina lit un livre captivant », « captivant » est un…", "options": ["adverbe", "nom", "adjectif qualificatif"], "reponse": 2, "explication": "« Captivant » s'accorde avec le nom livre : c'est un adjectif qualificatif."},
            {"enonce": "« Hélas ! » appartient à la classe des…", "options": ["interjections", "conjonctions", "prépositions"], "reponse": 0, "explication": "« Hélas ! » exprime un sentiment vif : c'est une interjection invariable."},
            {"enonce": "Parmi ces mots, lequel est une conjonction de coordination ?", "options": ["car", "parce que", "puisque"], "reponse": 0, "explication": "« Mais, ou, et, donc, or, ni, car » sont les conjonctions de coordination."}
        ],
        1: [
            {"enonce": "Dans « Mehdi devient médecin », « médecin » est…", "options": ["COD", "attribut du sujet", "CC de manière"], "reponse": 1, "explication": "« Devenir » est un verbe d'état : « médecin » est donc attribut du sujet."},
            {"enonce": "Dans « À Casablanca, il pleut souvent », « À Casablanca » est…", "options": ["sujet", "CC de lieu", "COI"], "reponse": 1, "explication": "Indique le lieu et peut être déplacé : complément circonstanciel de lieu."},
            {"enonce": "Dans « Salma pense à ses vacances », « à ses vacances » est…", "options": ["COD", "COI", "attribut"], "reponse": 1, "explication": "Introduit par la préposition « à » : COI."}
        ],
        2: [
            {"enonce": "« Comme cette ville est magnifique ! » est de type…", "options": ["déclaratif", "exclamatif", "interrogatif"], "reponse": 1, "explication": "Termine par un point d'exclamation et exprime l'admiration : type exclamatif."},
            {"enonce": "« Mehdi n'a rien oublié » est à la forme…", "options": ["affirmative", "négative", "passive"], "reponse": 1, "explication": "La locution « ne... rien » marque la négation."},
            {"enonce": "« Le devoir sera corrigé par le professeur » est à la forme…", "options": ["active", "passive", "pronominale"], "reponse": 1, "explication": "Le sujet subit l'action avec l'auxiliaire être et le complément d'agent « par le professeur »."}
        ]
    }
    
    # Complément générique adapté si non listé explicitement
    if idx in ex1_complements:
        ex1_questions.extend(ex1_complements[idx])
    else:
        # Questions complémentaires adaptées au titre
        ex1_questions.extend([
            {
                "enonce": f"Quelle affirmation est exacte concernant la leçon « {titre} » ?",
                "options": [
                    "Les règles s'appliquent systématiquement selon le contexte de la phrase.",
                    "Il n'existe aucune exception à la règle générale.",
                    "L'accord et le sens ne dépendent pas de la fonction grammaticale."
                ],
                "reponse": 0,
                "explication": "En français, l'application des règles grammaticales et stylistiques dépend toujours du contexte syntaxique et sémantique."
            },
            {
                "enonce": f"Dans l'analyse de « {titre} », que doit-on vérifier en premier lieu ?",
                "options": [
                    "Le sens global et la construction syntaxique de la phrase.",
                    "Uniquement le dernier mot de la phrase.",
                    "La longueur du paragraphe sans tenir compte de la ponctuation."
                ],
                "reponse": 0,
                "explication": "L'analyse rigoureuse exige de comprendre la structure syntaxique et le sens global."
            },
            {
                "enonce": f"Parmi ces exemples, lequel illustre le mieux le cours sur « {titre} » ?",
                "options": [
                    "L'exemple respectant scrupuleusement la règle fondamentale exposée dans la leçon.",
                    "Une phrase sans verbe conjugué ni ponctuation.",
                    "Un énoncé ignorant les accords de base."
                ],
                "reponse": 0,
                "explication": "L'exemple pertinent applique fidèlement la règle enseignée dans le cours."
            }
        ])
        
    ex1 = {
        "id": f"{ID_MAPPING.get(idx, f'lecon-{idx}')}-ex1",
        "titre": "Exercice 1 — Questions à choix multiples",
        "consigne": "Choisis la bonne réponse pour chaque question.",
        "type": "qcm",
        "questions": ex1_questions
    }
    
    # Ex 2: Vrai / Faux (5 questions)
    ex2 = {
        "id": f"{ID_MAPPING.get(idx, f'lecon-{idx}')}-ex2",
        "titre": "Exercice 2 — Vrai ou Faux",
        "consigne": "Indique si chaque affirmation est vraie ou fausse.",
        "type": "vrai_faux",
        "questions": [
            {
                "enonce": f"La maîtrise de « {titre} » est indispensable pour bien s'exprimer et rédiger sans faute.",
                "reponse": True,
                "explication": "C'est un des points clés du programme de français au collège et au lycée."
            },
            {
                "enonce": f"Dans « {titre} », on peut négliger les règles d'accord sans modifier le sens de la phrase.",
                "reponse": False,
                "explication": "Les accords et les fonctions sont essentiels à la cohérence et à la clarté du texte."
            },
            {
                "enonce": "L'analyse grammaticale et stylistique permet de mieux comprendre les textes littéraires.",
                "reponse": True,
                "explication": "La grammaire et le style donnent les clés de l'interprétation des textes."
            },
            {
                "enonce": "En français, tous les mots sont variables.",
                "reponse": False,
                "explication": "Il existe 5 classes de mots invariables (adverbes, prépositions, conjonctions de coordination, de subordination, interjections)."
            },
            {
                "enonce": "Le contexte d'une phrase permet souvent de lever les ambiguïtés d'homophones ou de fonctions.",
                "reponse": True,
                "explication": "Le sens global et la syntaxe précisent le rôle de chaque terme."
            }
        ]
    }
    
    # Ex 3: Textes à trous / Choix / Application (5 questions)
    ex3 = {
        "id": f"{ID_MAPPING.get(idx, f'lecon-{idx}')}-ex3",
        "titre": "Exercice 3 — Application pratique",
        "consigne": "Complète ou réponds avec précision selon la règle du cours.",
        "type": "trous",
        "questions": [
            {
                "enonce": "L'art de bien parler et d'écrire avec éloquence s'appelle la ___",
                "reponse": "rhétorique",
                "acceptees": ["rhétorique", "rhetorique", "la rhétorique"],
                "explication": "Du grec rhêtorikê, la rhétorique est l'art du discours et de la persuasion."
            },
            {
                "enonce": "La phrase commence par une majuscule et se termine par un ___",
                "reponse": "point",
                "acceptees": ["point", "un point"],
                "explication": "Le point (. ! ? …) délimite graphiquement et sémantiquement la phrase."
            },
            {
                "enonce": "Le verbe s'accorde toujours en personne et en nombre avec son ___",
                "reponse": "sujet",
                "acceptees": ["sujet", "son sujet"],
                "explication": "Le sujet régit l'accord du verbe."
            },
            {
                "enonce": "Un mot invariable ne change jamais ni de genre ni de ___",
                "reponse": "nombre",
                "acceptees": ["nombre", "de nombre"],
                "explication": "Les mots invariables n'ont ni féminin ni pluriel."
            },
            {
                "enonce": "Les figures de style donnent du relief, des images et de la force à l'___",
                "reponse": "expression",
                "acceptees": ["expression", "l'expression", "ecriture", "écriture"],
                "explication": "Elles enrichissent l'expression et touchent la sensibilité du lecteur."
            }
        ]
    }
    
    return [ex1, ex2, ex3]

print("Module de génération des exercices configuré.")
