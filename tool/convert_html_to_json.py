#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de conversion et d'enrichissement pédagogique pour Rhétorique.
Lit langue-francaise.html et génère :
  - assets/data/3ac.json (32 leçons complètes avec au moins 3 exercices de 5-8 questions)
  - assets/data/1bac.json (leçons conformes au programme marocain 1ère Bac avec 'aValider': true)
  - assets/data/tronc_commun.json (structure prête à recevoir du contenu)
"""

import json
import os
import re
from html import unescape

def clean_inline_html(text):
    text = unescape(text)
    # Remplacer <b>, <strong> par **
    text = re.sub(r'<\/?(b|strong)>', '**', text)
    # Remplacer <i>, <em> par *
    text = re.sub(r'<\/?(i|em)>', '*', text)
    # Nettoyer les sauts de ligne HTML
    text = re.sub(r'<br\s*\/?>', '\n', text)
    # Nettoyer les balises résiduelles
    text = re.sub(r'<[^>]+>', '', text)
    # Nettoyer les doubles étoiles consécutives vides ou espaces
    text = re.sub(r'\*\*\s*\*\*', '', text)
    return text.strip()

def parse_html_table(table_html):
    headers = []
    rows = []
    
    # Extraire th
    th_matches = re.findall(r'<th[^>]*>(.*?)<\/th>', table_html, re.DOTALL | re.IGNORECASE)
    if th_matches:
        headers = [clean_inline_html(th) for th in th_matches]
        
    # Extraire tr
    tr_matches = re.findall(r'<tr[^>]*>(.*?)<\/tr>', table_html, re.DOTALL | re.IGNORECASE)
    for tr in tr_matches:
        td_matches = re.findall(r'<td[^>]*>(.*?)<\/td>', tr, re.DOTALL | re.IGNORECASE)
        if td_matches:
            rows.append([clean_inline_html(td) for td in td_matches])
            
    return headers, rows

def html_to_blocks(html_str, schema_id=None):
    blocks = []
    
    # Découper les sections : tables, div.ex, p
    pattern = re.compile(
        r'(<div class="tw"><table>.*?<\/table><\/div>|<div class="ex">.*?<\/div>|<p>.*?<\/p>|<table>.*?<\/table>)',
        re.DOTALL | re.IGNORECASE
    )
    
    parts = pattern.findall(html_str)
    if not parts:
        # Fallback si pas de structure standard
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
            # exemple
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

print("Générateur de données Rhétorique démarré...")
