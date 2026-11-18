#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Générateur complet des fichiers de données pour Rhétorique:
  - assets/data/3ac.json : 34 leçons du collège (1AC à 3AC) avec au moins 3 exercices (5-8 questions chacun)
  - assets/data/1bac.json : leçons de langue 1ère Bac avec 'aValider': true
  - assets/data/tronc_commun.json : structure Tronc Commun
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

print("Configuration des leçons chargée.")
