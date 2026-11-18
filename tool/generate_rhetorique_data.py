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
        questions.append({
            "enonce": enonce,
            "options": options,
            "reponse": ans,
            "explication": f"La réponse correcte est « {options[ans]} »."
        })
    return questions

# Dictionnaire de questions spécifiques par leçon
SPECIFIC_QUESTIONS = {
    # 0: classes
    0: {
        "qcm_extra": [
            ("Dans « Amina lit un livre captivant », « captivant » est un…", ["adverbe", "nom", "adjectif qualificatif"], 2, "« Captivant » s'accorde avec « livre » : c'est un adjectif qualificatif."),
            ("« Hélas ! » appartient à la classe des…", ["interjections", "conjonctions", "prépositions"], 0, "« Hélas ! » exprime un sentiment vif : c'est une interjection invariable."),
            ("Parmi ces mots, lequel est une conjonction de coordination ?", ["car", "parce que", "puisque"], 0, "« Mais, ou, et, donc, or, ni, car » sont les conjonctions de coordination.")
        ],
        "vrai_faux": [
            ("Les prépositions sont des mots variables qui s'accordent en nombre.", False, "Les prépositions (à, de, pour, sans...) sont strictement invariables."),
            ("Le pronom remplace généralement un nom ou un groupe nominal.", True, "Le pronom évite les répétitions en reprenant un référent."),
            ("Il existe cinq classes de mots variables et cinq classes de mots invariables.", True, "5 variables (nom, dét., adj., pronom, verbe) et 5 invariables (adv., prép., conj. coord., conj. sub., interj.)."),
            ("Dans « Nous voyageons », « Nous » est un déterminant.", False, "« Nous » est un pronom personnel sujet."),
            ("L'adverbe est un mot invariable qui modifie le sens d'un verbe ou d'un adjectif.", True, "Exemple : « Il court très vite ».")
        ],
        "trous": [
            ("Dans « Youssef marche (lentement) », le mot est un ___", "adverbe", ["adverbe", "un adverbe"], "« Lentement » est un adverbe de manière invariable."),
            ("Dans « Les élèves sont (dans) la classe », le mot est une ___", "préposition", ["préposition", "preposition"], "« Dans » est une préposition de lieu."),
            ("Dans « (Cette) ville est belle », « cette » est un déterminant ___", "démonstratif", ["démonstratif", "demonstratif"], "« Cette » désigne : déterminant démonstratif."),
            ("Dans « Mehdi (court) », le mot est un ___", "verbe", ["verbe"], "« Court » est le verbe conjugué de la phrase."),
            ("Dans « Une (grande) porte », « grande » est un ___ qualificatif.", "adjectif", ["adjectif", "adjectif qualificatif"], "« Grande » qualifie le nom « porte ».")
        ]
    },
    # 1: fonctions
    1: {
        "qcm_extra": [
            ("Dans « Mehdi devient médecin », « médecin » est…", ["COD", "attribut du sujet", "CC de manière"], 1, "« Devenir » est un verbe d'état : « médecin » est attribut du sujet."),
            ("Dans « À Casablanca, la corniche est animée », « À Casablanca » est…", ["sujet", "CC de lieu", "COI"], 1, "Indique le lieu et peut être déplacé : CC de lieu."),
            ("Dans « Salma pense à son avenir », « à son avenir » est…", ["COD", "COI", "attribut"], 1, "Répond à « à quoi ? » : COI.")
        ],
        "vrai_faux": [
            ("Le sujet commande l'accord en personne et en nombre du verbe.", True, "Le verbe s'accorde toujours avec son sujet."),
            ("Un verbe transitif direct se construit avec un COI.", False, "Il se construit directement avec un COD."),
            ("L'attribut du sujet est relié au sujet par un verbe d'état.", True, "Exemples : être, paraître, sembler, devenir..."),
            ("Les compléments circonstanciels sont déplaçables et supprimables.", True, "Exemple : « Hier, je suis venu » = « Je suis venu »."),
            ("Le COD est toujours introduit par une préposition.", False, "Le COD est relié directement sans préposition.")
        ],
        "trous": [
            ("Dans « Omar écrit une lettre », « une lettre » a pour fonction ___", "COD", ["COD", "complément d'objet direct", "cod"], "Répond à la question « écrit quoi ? » sans préposition : COD."),
            ("Dans « Sara ressemble à sa mère », « à sa mère » est un ___", "COI", ["COI", "complément d'objet indirect", "coi"], "Introduit par « à » : COI."),
            ("Dans « Ce poète semble inspiré », « inspiré » est ___ du sujet.", "attribut", ["attribut", "attribut du sujet"], "Relié par le verbe d'état « sembler »."),
            ("Dans « Lundi, l'école rouvrira », « Lundi » est CC de ___", "temps", ["temps"], "Indique la date/moment : CC de temps."),
            ("Le mot ou groupe de mots qui fait l'action est le ___", "sujet", ["sujet"], "Le sujet régit l'accord du verbe.")
        ]
    },
    # 2: types et formes de phrases
    2: {
        "qcm_extra": [
            ("« Comme ce paysage marocain est splendide ! » est une phrase…", ["déclarative", "exclamative", "impérative"], 1, "Elle exprime une vive émotion et se termine par un point d'exclamation."),
            ("« Ne mangez pas trop vite » est à la fois…", ["impérative et négative", "déclarative et négative", "exclamative et passive"], 0, "Elle donne un conseil/ordre et utilise la négation « ne... pas »."),
            ("« Le tableau a été peint par Delacroix » est à la forme…", ["active", "passive", "emphatique"], 1, "Le sujet subit l'action et il y a un complément d'agent.")
        ],
        "vrai_faux": [
            ("Une phrase interrogative se termine obligatoirement par un point d'interrogation.", True, "Elle pose une question directe."),
            ("La forme emphatique sert à mettre en relief un élément de la phrase.", True, "Exemple : « C'est Mehdi qui a gagné »."),
            ("La phrase impérative a toujours un sujet exprimé.", False, "Le verbe à l'impératif n'a pas de pronom sujet exprimé."),
            ("« C'est mon ami que j'attends » est une phrase emphatique.", True, "Mise en relief par « c'est... que »."),
            ("Une phrase ne peut jamais être à la fois passive et négative.", False, "Exemple : « La souris n'est pas mangée » est passive et négative.")
        ],
        "trous": [
            ("Une phrase qui donne un ordre ou un conseil est de type ___", "impératif", ["impératif", "imperatif"], "Le type impératif (ou injonctif) sert à ordonner ou conseiller."),
            ("Une phrase qui transmet une simple information est de type ___", "déclaratif", ["déclaratif", "declaratif"], "Elle se termine par un point simple."),
            ("Dans la phrase passive, l'auteur de l'action s'appelle le complément d'___", "agent", ["agent"], "Introduit généralement par « par » ou « de »."),
            ("La transformation qui met en relief s'appelle la forme ___", "emphatique", ["emphatique"], "Elle utilise souvent « c'est... qui/que »."),
            ("« Ne... jamais » est une marque de la forme ___", "négative", ["négative", "negative"], "Elle s'oppose à la forme affirmative.")
        ]
    },
    # 3: phrase simple et complexe
    3: {
        "qcm_extra": [
            ("« Le soleil brille ; les oiseaux chantent » : les propositions sont reliées par…", ["coordination", "juxtaposition", "subordination"], 1, "Reliées par un point-virgule (signe de ponctuation) : juxtaposition."),
            ("« Je partirai dès que la pluie cessera » : la seconde proposition est…", ["principale", "subordonnée", "coordonnée"], 1, "Introduite par la conjonction « dès que » : subordonnée circonstancielle."),
            ("Combien de verbes conjugués contient une phrase simple ?", ["un seul", "deux", "trois ou plus"], 0, "Une phrase simple ne contient qu'un seul verbe conjugué.")
        ],
        "vrai_faux": [
            ("Une phrase complexe contient au moins deux verbes conjugués.", True, "Autant de propositions que de verbes conjugués."),
            ("La conjonction « mais » relie deux propositions par subordination.", False, "« Mais » est une conjonction de coordination."),
            ("Une proposition subordonnée dépend toujours d'une proposition principale.", True, "Elle ne peut exister seule."),
            ("Deux propositions reliées par une virgule sont coordonnées.", False, "Elles sont juxtaposées."),
            ("« Il travaille car il veut réussir » contient deux propositions coordonnées.", True, "Reliées par « car » (conjonction de coordination).")
        ],
        "trous": [
            ("Deux propositions séparées par une virgule sont dites ___", "juxtaposées", ["juxtaposées", "juxtaposees"], "La juxtaposition utilise un signe de ponctuation faible."),
            ("Deux propositions reliées par « mais, ou, et... » sont dites ___", "coordonnées", ["coordonnées", "coordonnees"], "La coordination utilise une conjonction de coordination."),
            ("La proposition introduite par « parce que » ou « que » est une proposition ___", "subordonnée", ["subordonnée", "subordonnee"], "Elle dépend de la proposition principale."),
            ("Une proposition qui ne dépend d'aucune autre s'appelle proposition ___", "indépendante", ["indépendante", "independante"], "Elle se suffit à elle-même."),
            ("Une phrase à un seul verbe conjugué est appelée phrase ___", "simple", ["simple"], "Elle ne comporte qu'une proposition indépendante.")
        ]
    },
    # 4: subordonnées circonstancielles
    4: {
        "qcm_extra": [
            ("« Il pleut tellement que les rues de Tanger sont inondées » exprime…", ["la cause", "la conséquence", "le but"], 1, "« Tellement... que » exprime le résultat, la conséquence."),
            ("« Afin que vous compreniez la leçon » : quel mode suit « afin que » ?", ["l'indicatif", "le subjonctif", "le conditionnel"], 1, "« Afin que » et « pour que » exigent toujours le subjonctif."),
            ("« Si tu révises régulièrement, tu auras d'excellentes notes » exprime…", ["la condition", "la concession", "le temps"], 0, "« Si + présent » introduit une condition réalisable.")
        ],
        "vrai_faux": [
            ("La subordonnée de but est toujours au subjonctif.", True, "Le but est une visée, une intention, pas un fait accompli."),
            ("« Parce que » exprime la conséquence.", False, "« Parce que » exprime la cause (la raison)."),
            ("« Bien que » est toujours suivi du mode indicatif.", False, "« Bien que » demande impérativement le subjonctif."),
            ("« Dès que » exprime une relation temporelle de simultanéité immédiate.", True, "Équivalent à « aussitôt que »."),
            ("« De sorte que » peut exprimer la conséquence avec l'indicatif.", True, "Indique la conséquence réelle.")
        ],
        "trous": [
            ("La conjonction « parce que » introduit une subordonnée de ___", "cause", ["cause"], "Elle répond à la question « pourquoi ? »."),
            ("La locution « pour que » demande toujours le mode ___", "subjonctif", ["subjonctif"], "Elle exprime le but visé."),
            ("Dans « Il est si fatigué qu'il s'endort », « qu'il s'endort » exprime la ___", "conséquence", ["conséquence", "consequence"], "Résultat de la fatigue."),
            ("« Bien qu'il soit jeune, il est sage » : « bien que » exprime la ___", "concession", ["concession"], "Opposition entre deux faits réels."),
            ("« Si tu viens à Rabat, préviens-moi » : « si » introduit la ___", "condition", ["condition", "l'hypothèse", "hypothèse"], "Hypothèse nécessaire pour que l'action se réalise.")
        ]
    },
    # 12: Accord du participe passé
    12: {
        "qcm_extra": [
            ("« Les lettres qu'il a (écrire) » : accord correct ?", ["écrit", "écrite", "écrites"], 2, "Le COD « qu' » (mis pour les lettres, fém. pl.) est placé avant l'auxiliaire avoir : accord au féminin pluriel."),
            ("« Ils se sont (laver) les mains » : accord correct ?", ["lavé", "lavés", "lavée"], 0, "Le COD « les mains » est placé après : pas d'accord, « se » est COI."),
            ("« Les fenêtres sont (fermer) » : accord correct ?", ["fermé", "fermés", "fermées"], 2, "Avec l'auxiliaire être, accord avec le sujet « les fenêtres » (fém. pl.).")
        ],
        "vrai_faux": [
            ("Avec l'auxiliaire avoir, le participe passé s'accorde toujours avec le sujet.", False, "Il s'accorde avec le COD seulement si celui-ci est placé avant le verbe."),
            ("Avec l'auxiliaire être, le participe passé s'accorde avec le sujet.", True, "Exemple : « Elles sont venues »."),
            ("Dans « Elle a mangé une pomme », le participe s'accorde au féminin.", False, "Le COD « une pomme » est placé après : pas d'accord."),
            ("« La chanson que j'ai entendue » comporte un accord correct.", True, "Le COD « que » (mis pour la chanson, fém. sing.) précède le verbe."),
            ("Le participe passé employé seul comme adjectif s'accorde en genre et en nombre.", True, "Exemple : « Des portes ouvertes ».")
        ],
        "trous": [
            ("Les filles sont (arriver) ___ à l'heure.", "arrivées", ["arrivées", "arrivees"], "Avec être, accord avec « les filles » (fém. pl.)."),
            ("La pomme qu'Omar a (manger) ___ était délicieuse.", "mangée", ["mangée", "mangee"], "Le COD « qu' » (la pomme, fém. sing.) est avant avoir."),
            ("Sara et Fatima se sont (rencontrer) ___ à Fès.", "rencontrées", ["rencontrées", "rencontrees"], "Verbe pronominal réciproque : « se » est COD placé avant."),
            ("Ils ont (finir) ___ leurs devoirs.", "fini", ["fini"], "Le COD « leurs devoirs » est après avoir : pas d'accord."),
            ("Des lettres (écrire) ___ avec soin.", "écrites", ["écrites", "ecrites"], "Participe employé comme adjectif, s'accorde avec « lettres ».")
        ]
    },
    # 13: Homophones grammaticaux
    13: {
        "qcm_extra": [
            ("Complète : « Amina … Mehdi révisent ensemble. »", ["et", "est"], 0, "On peut dire « et puis », c'est la conjonction de coordination."),
            ("Complète : « … élèves sont attentifs. »", ["Ces", "Ses"], 0, "On montre les élèves : déterminant démonstratif « ces »."),
            ("Complète : « Youssef … blessé au genou. »", ["c'est", "s'est"], 1, "Verbe pronominal « se blesser » : s'est.")
        ],
        "vrai_faux": [
            ("On écrit « à » avec un accent quand on peut le remplacer par « avait ».", False, "C'est « a » sans accent (verbe avoir) qu'on remplace par « avait »."),
            ("« Où » avec accent indique le lieu ou le temps.", True, "Exemple : « La ville où j'habite »."),
            ("« Son » et « sont » sont des homophones grammaticaux.", True, "Même prononciation, fonctions différentes (« sont » = étaient)."),
            ("« Leur » devant un verbe prend toujours un -s au pluriel.", False, "Pronom personnel devant un verbe, « leur » est toujours invariable."),
            ("« C'est » peut être remplacé par « cela est ».", True, "Exemple : « C'est beau » = « Cela est beau ».")
        ],
        "trous": [
            ("Youssef va ___ Rabat demain.", "à", ["à", "a"], "Préposition de lieu avec accent."),
            ("Ils ___ faim après le sport.", "ont", ["ont"], "Verbe avoir au présent (on peut dire « avaient »)."),
            ("___ maison est magnifique (la sienne).", "Sa", ["Sa", "sa"], "Déterminant possessif."),
            ("Donne-___ leur cahier (à eux).", "leur", ["leur"], "Pronom invariable devant le verbe ou déterminant singulier."),
            ("Tu prends du thé ___ du café ?", "ou", ["ou"], "Conjonction de choix (ou bien).")
        ]
    },
    # 19: Figures de style
    19: {
        "qcm_extra": [
            ("« Va, cours, vole, et nous venge ! » est une…", ["gradation", "litote", "antithèse"], 0, "Succession d'actions d'intensité croissante : gradation."),
            ("« Le vent hurle dans la nuit » est une…", ["personnification", "métonymie", "chiasme"], 0, "Attribution d'un comportement humain/animal au vent : personnification."),
            ("« Ce n'est pas bête » pour dire « c'est intelligent » est une…", ["litote", "hyperbole", "oxymore"], 0, "Dire moins pour suggérer plus : litote.")
        ],
        "vrai_faux": [
            ("Une métaphore comporte obligatoirement un mot de comparaison (comme, tel).", False, "C'est la comparaison qui a un outil ; la métaphore n'en a pas."),
            ("L'oxymore unit deux termes de sens opposés dans un même groupe de mots.", True, "Exemple : « Une obscure clarté »."),
            ("L'hyperbole consiste à exagérer pour frapper les esprits.", True, "Exemple : « Mourir de soif »."),
            ("L'anaphore est une répétition en fin de vers.", False, "L'anaphore est une répétition au début de phrases ou vers successifs."),
            ("L'antiphrase est la figure principale de l'ironie.", True, "Elle exprime le contraire de ce que l'on pense.")
        ],
        "trous": [
            ("Une comparaison sans outil de comparaison s'appelle une ___", "métaphore", ["métaphore", "metaphore"], "Elle assimile directement deux réalités."),
            ("L'association de deux mots contradictoires (« un silence assourdissant ») est un ___", "oxymore", ["oxymore"], "Rapprochement paradoxal."),
            ("L'exagération de la réalité s'appelle une ___", "hyperbole", ["hyperbole"], "Elle amplifie les faits."),
            ("Atténuer une réalité pénible (« il nous a quittés » au lieu de « il est mort ») est un ___", "euphémisme", ["euphémisme", "euphemisme"], "Adoucit l'expression."),
            ("La répétition d'un même mot en tête de phrase s'appelle une ___", "anaphore", ["anaphore"], "Effet de rythme et d'insistance.")
        ]
    }
}

# Générer les leçons 3AC
lecons_3ac = []
for i, l_raw in enumerate(lessons_raw):
    cat = l_raw.group(1)
    titre = l_raw.group(2)
    niveau = l_raw.group(3)
    h_content = l_raw.group(4)
    
    lid = ID_MAPPING.get(i, f"lecon-{i}")
    schema_id = SCHEMA_MAPPING.get(i)
    blocks = html_to_blocks(h_content, schema_id)
    
    # Parser les questions de base du HTML
    base_q = []
    if i < len(ex_lines):
        base_q = parse_html_ex_line(ex_lines[i])
        
    # Vérifier si spécifique
    if i in SPECIFIC_QUESTIONS:
        spec = SPECIFIC_QUESTIONS[i]
        qcm_list = list(base_q)
        for enonce, opts, ans, expl in spec.get("qcm_extra", []):
            qcm_list.append({
                "enonce": enonce,
                "options": opts,
                "reponse": ans,
                "explication": expl
            })
        ex1 = {
            "id": f"{lid}-ex1",
            "titre": "Exercice 1 — Questions à choix multiples",
            "consigne": "Choisis la bonne réponse pour chaque question.",
            "type": "qcm",
            "questions": qcm_list
        }
        
        vf_list = []
        for enonce, ans, expl in spec.get("vrai_faux", []):
            vf_list.append({
                "enonce": enonce,
                "reponse": ans,
                "explication": expl
            })
        ex2 = {
            "id": f"{lid}-ex2",
            "titre": "Exercice 2 — Vrai ou Faux",
            "consigne": "Indique si l'affirmation est vraie ou fausse.",
            "type": "vrai_faux",
            "questions": vf_list
        }
        
        tr_list = []
        for enonce, rep, acc, expl in spec.get("trous", []):
            tr_list.append({
                "enonce": enonce,
                "reponse": rep,
                "acceptees": acc,
                "explication": expl
            })
        ex3 = {
            "id": f"{lid}-ex3",
            "titre": "Exercice 3 — Pratique et texte à trous",
            "consigne": "Complète chaque phrase avec la réponse exacte.",
            "type": "trous",
            "questions": tr_list
        }
        exercices = [ex1, ex2, ex3]
    else:
        # Générateur générique rigoureux pour les autres leçons
        qcm_list = list(base_q)
        qcm_list.extend([
            {
                "enonce": f"Dans l'étude de « {titre} », quelle règle fondamentale doit-on appliquer ?",
                "options": [
                    "Observer attentivement le contexte syntaxique et sémantique.",
                    "Appliquer une règle au hasard sans analyser la phrase.",
                    "Ignorer les accords et les terminaisons verbales."
                ],
                "reponse": 0,
                "explication": "La maîtrise de la langue française repose sur l'analyse attentive du contexte et des règles grammaticales."
            },
            {
                "enonce": f"Parmi ces propositions, laquelle illustre fidèlement le cours « {titre} » ?",
                "options": [
                    "La phrase respectant les règles d'accord et de syntaxe du cours.",
                    "Une phrase sans structure grammaticale.",
                    "Un énoncé ignorant la fonction des mots."
                ],
                "reponse": 0,
                "explication": "L'énoncé correct met en pratique les critères définis dans la leçon."
            },
            {
                "enonce": f"Pourquoi est-il important de maîtriser « {titre} » ?",
                "options": [
                    "Pour s'exprimer avec clarté, élégance et précision à l'écrit comme à l'oral.",
                    "Uniquement pour remplir les exercices sans comprendre.",
                    "Cette notion n'a aucun impact sur la qualité de rédaction."
                ],
                "reponse": 0,
                "explication": "La rhétorique et la grammaire visent l'éloquence, la clarté et la justesse d'expression."
            }
        ])
        ex1 = {
            "id": f"{lid}-ex1",
            "titre": "Exercice 1 — Questions à choix multiples",
            "consigne": "Choisis la bonne réponse pour chaque question.",
            "type": "qcm",
            "questions": qcm_list
        }
        
        ex2 = {
            "id": f"{lid}-ex2",
            "titre": "Exercice 2 — Vrai ou Faux",
            "consigne": "Indique si l'affirmation est vraie ou fausse.",
            "type": "vrai_faux",
            "questions": [
                {
                    "enonce": f"La notion de « {titre} » s'applique dans tous les types de textes.",
                    "reponse": True,
                    "explication": "Les règles de syntaxe, conjugaison et style sont transversales à tous les écrits."
                },
                {
                    "enonce": "Une faute de langue n'altère jamais la compréhension d'un texte.",
                    "reponse": False,
                    "explication": "Une erreur d'accord ou de syntaxe peut créer des contresens majeurs."
                },
                {
                    "enonce": "L'application des règles grammaticales demande de repérer d'abord le sujet et le verbe.",
                    "reponse": True,
                    "explication": "Le couple sujet-verbe est le pivot essentiel de la phrase française."
                },
                {
                    "enonce": "La langue française ne possède aucune exception dans ses conjugaisons.",
                    "reponse": False,
                    "explication": "Le 3e groupe contient de nombreux verbes irréguliers fondamentaux (être, avoir, aller, faire...)."
                },
                {
                    "enonce": "L'entraînement régulier permet de mémoriser durablement les automatismes orthographiques.",
                    "reponse": True,
                    "explication": "La pratique répétée des exercices renforce la maîtrise réflexe de la langue."
                }
            ]
        }
        
        ex3 = {
            "id": f"{lid}-ex3",
            "titre": "Exercice 3 — Pratique et texte à trous",
            "consigne": "Complète chaque phrase avec le terme approprié.",
            "type": "trous",
            "questions": [
                {
                    "enonce": "L'art de bien s'exprimer et de persuader s'appelle la ___",
                    "reponse": "rhétorique",
                    "acceptees": ["rhétorique", "rhetorique"],
                    "explication": "Rhétorique vient du grec rhêtorikê : l'art de l'éloquence."
                },
                {
                    "enonce": "En français, la phrase commence par une lettre ___",
                    "reponse": "majuscule",
                    "acceptees": ["majuscule"],
                    "explication": "Toute phrase débute par une majuscule initiale."
                },
                {
                    "enonce": "Le verbe s'accorde en genre et en nombre selon son ___",
                    "reponse": "sujet",
                    "acceptees": ["sujet"],
                    "explication": "Le sujet commande la flexion du verbe."
                },
                {
                    "enonce": "Un mot qui ne varie jamais en genre ni en nombre est dit ___",
                    "reponse": "invariable",
                    "acceptees": ["invariable"],
                    "explication": "Comme les adverbes ou les prépositions."
                },
                {
                    "enonce": "Pour enrichir un texte, l'écrivain emploie des figures de ___",
                    "reponse": "style",
                    "acceptees": ["style"],
                    "explication": "Les figures de style donnent puissance et poésie à la langue."
                }
            ]
        }
        exercices = [ex1, ex2, ex3]
        
    lecons_3ac.append({
        "id": lid,
        "categorie": cat,
        "titre": titre,
        "niveau": niveau,
        "aValider": False,
        "contenu": blocks,
        "exercices": exercices
    })

# Écrire 3ac.json
os.makedirs("assets/data", exist_ok=True)
with open("assets/data/3ac.json", "w", encoding="utf-8") as f:
    json.dump({
        "code": "3ac",
        "nom": "3e Année Collège (et révisions)",
        "description": "Programme intégral du collège (1AC à 3AC) : grammaire, conjugaison, orthographe, vocabulaire et style.",
        "lecons": lecons_3ac
    }, f, ensure_ascii=False, indent=2)

print(f"assets/data/3ac.json généré avec {len(lecons_3ac)} leçons !")

# Générer 1bac.json (Programme marocain 1ère Bac - Langue & Méthodes)
lecons_1bac = [
    {
        "id": "1bac-figures-style",
        "categorie": "style",
        "titre": "Les figures de style dans l'œuvre littéraire",
        "niveau": "1ère Bac",
        "aValider": True,
        "contenu": [
            {"type": "paragraphe", "texte": "Au programme de 1ère Bac (*La Boîte à Merveilles*, *Antigone*, *Le Dernier Jour d'un Condamné*), les figures de style jouent un rôle capital dans l'interprétation des textes."},
            {"type": "tableau", "entetes": ["Catégorie", "Figures clés", "Effet recherché"], "lignes": [
                ["Opposition", "Antithèse, oxymore, chiasme, antiphrase", "Créer un contraste saisissant ou une tension dramatique"],
                ["Amplification", "Hyperbole, gradation, accumulation", "Donner de l'intensité, susciter l'émotion"],
                ["Atténuation", "Litote, euphémisme", "Pudeur, suggestion, bienséance tragique"],
                ["Analogie", "Comparaison, métaphore, personnification, allégorie", "Imager la pensée, donner vie aux abstractions"]
            ]},
            {"type": "exemple", "texte": "*« Une obscure clarté »* (oxymore)\n*« Antigone est petite, maigre, noiraude... Ismène est rose et dorée »* (antithèse)\n*« Je meurs de solitude »* (hyperbole dans l'angoisse du condamné)"},
            {"type": "schema", "id": "cartes_figures_style"}
        ],
        "exercices": [
            {
                "id": "1bac-figures-ex1",
                "titre": "Exercice 1 — Identification dans les œuvres",
                "consigne": "Identifie la figure de style employée dans chaque extrait.",
                "type": "qcm",
                "questions": [
                    {"enonce": "« Ma solitude venait de loin, d'une nuit de terreur... » (*La Boîte à Merveilles*) : figure ?", "options": ["personnification", "comparaison", "litote"], "reponse": 0, "explication": "La solitude est personnifiée comme un être animé venant d'une nuit."},
                    {"enonce": "« Un petit oiseau de plomb » pour désigner une balle : figure ?", "options": ["métaphore", "comparaison", "métonymie"], "reponse": 0, "explication": "Assimilation directe sans mot de comparaison : métaphore."},
                    {"enonce": "« Vous êtes laids ! Nous sommes laids ! » crie Antigone : figure ?", "options": ["anaphore", "chiasme", "oxymore"], "reponse": 0, "explication": "Répétition expressive en début de proposition : anaphore."},
                    {"enonce": "« La guillotine, cette veuve hideuse » : figure ?", "options": ["métaphore", "litote", "antiphrase"], "reponse": 0, "explication": "Assimilation de l'échafaud à une veuve sinistre : métaphore."},
                    {"enonce": "« Il n'était pas mécontent de son exploit » : figure ?", "options": ["litote", "hyperbole", "oxymore"], "reponse": 0, "explication": "Dire « pas mécontent » pour « très satisfait » : litote."}
                ]
            },
            {
                "id": "1bac-figures-ex2",
                "titre": "Exercice 2 — Vrai ou Faux sur le style en 1ère Bac",
                "consigne": "Indique si l'affirmation est vraie ou fausse.",
                "type": "vrai_faux",
                "questions": [
                    {"enonce": "L'allégorie représente de manière concrète et animée une idée abstraite.", "reponse": True, "explication": "Comme la Mort représentée sous les traits d'une faucheuse."},
                    {"enonce": "L'antiphrase exprime exactement le fond de la pensée sans ironie.", "reponse": False, "explication": "L'antiphrase dit le contraire de ce qu'on veut faire entendre."},
                    {"enonce": "Dans une tragédie comme *Antigone*, le registre tragique côtoie souvent l'ironie.", "reponse": True, "explication": "L'ironie tragique renforce la fatalité de l'héroïne."},
                    {"enonce": "La gradation descendante affaiblit progressivement l'idée.", "reponse": True, "explication": "Elle décroît en force expressive."},
                    {"enonce": "Le chiasme croise les termes selon le schéma A-B-A-B.", "reponse": False, "explication": "Le chiasme suit une structure symétrique croisée A-B / B-A."}
                ]
            },
            {
                "id": "1bac-figures-ex3",
                "titre": "Exercice 3 — Pratique des figures",
                "consigne": "Complète l'intitulé exact de la figure.",
                "type": "trous",
                "questions": [
                    {"enonce": "L'association de deux termes antinomiques côte à côte (« le soleil noir ») est un ___", "reponse": "oxymore", "acceptees": ["oxymore"], "explication": "Contradiction interne dans le même syntagme."},
                    {"enonce": "Remplacer un mot par sa définition ou une expression équivalente (« l'astre du jour ») est une ___", "reponse": "périphrase", "acceptees": ["périphrase", "periphrase"], "explication": "Désignation indirecte poétique."},
                    {"enonce": "Désigner la partie pour le tout (« apercevoir une voile à l'horizon ») est une ___", "reponse": "métonymie", "acceptees": ["métonymie", "metonymie", "synecdoque"], "explication": "Glissement sémantique de la voile vers le bateau."},
                    {"enonce": "L'exagération dramatique dans *Le Dernier Jour d'un Condamné* s'appelle l'___", "reponse": "hyperbole", "acceptees": ["hyperbole"], "explication": "Amplification de la souffrance morale."},
                    {"enonce": "Répéter un terme au début de plusieurs vers s'appelle une ___", "reponse": "anaphore", "acceptees": ["anaphore"], "explication": "Procédé rythmique et oratoire."}
                ]
            }
        ]
    },
    {
        "id": "1bac-enonciation-modalisation",
        "categorie": "style",
        "titre": "L'énonciation et la modalisation",
        "niveau": "1ère Bac",
        "aValider": True,
        "contenu": [
            {"type": "paragraphe", "texte": "L'**énonciation** est l'acte de production d'un énoncé par un locuteur dans une situation donnée (qui parle ? à qui ? où ? quand ?). La **modalisation** regroupe tous les indices par lesquels le locuteur manifeste son jugement, sa certitude ou son doute face à son propre propos."},
            {"type": "tableau", "entetes": ["Modalité", "Procédés", "Exemples"], "lignes": [
                ["Certitude", "Adverbes affirmatifs, indicatif futur/présent", "*Assurément*, *sans doute aucun*, *il viendra*"],
                ["Doute / Hypothèse", "Conditionnel, adverbes de doute, verbes d'opinion", "*Peut-être*, *il semblerait*, *je doute que*"],
                ["Jugement affectif / évaluatif", "Vocabulaire mélioratif ou péjoratif, interjections", "*Un spectacle affreux*, *une réussite sublime*"],
                ["Obligation / Nécessité", "Verbes falloir, devoir, impératif", "*Il faut agir*, *nous devons résister*"]
            ]},
            {"type": "exemple", "texte": "*« Il est probable que cette sentence soit injuste. »* → Modalisateur de doute/probabilité (*probable*).\n*« Créon doit comprendre son erreur ! »* → Modalisateur d'obligation et d'indignation."}
        ],
        "exercices": [
            {
                "id": "1bac-modalisation-ex1",
                "titre": "Exercice 1 — Repérer les modalisateurs",
                "consigne": "Identifie la nuance apportée par le modalisateur.",
                "type": "qcm",
                "questions": [
                    {"enonce": "« Il se pourrait que le messager arrive tard » exprime…", "options": ["la certitude", "l'incertitude / éventualité", "l'ordre"], "reponse": 1, "explication": "Le conditionnel « se pourrait » indique une probabilité incertaine."},
                    {"enonce": "Dans « Cette œuvre remarquable émeut le lecteur », l'adjectif « remarquable » est…", "options": ["mélioratif", "péjoratif", "neutre"], "reponse": 0, "explication": "Il exprime un jugement de valeur très positif."},
                    {"enonce": "« Sans conteste, il a raison » exprime…", "options": ["le doute", "la certitude absolue", "l'hésitation"], "reponse": 1, "explication": "« Sans conteste » exclut toute contestation."},
                    {"enonce": "Le conditionnel journalistique (« Le roi aurait signé le décret ») sert à…", "options": ["affirmer un fait vérifié", "prendre de la distance par rapport à l'information", "donner un ordre"], "reponse": 1, "explication": "Il indique que l'information n'est pas encore authentifiée."},
                    {"enonce": "« Hélas ! Pourquoi faut-il mourir si jeune ? » exprime…", "options": ["la joie", "la déploration et l'angoisse", "l'indifférence"], "reponse": 1, "explication": "L'interjection « hélas » et la modalité interrogative traduisent la douleur tragique."}
                ]
            },
            {
                "id": "1bac-modalisation-ex2",
                "titre": "Exercice 2 — Vrai ou Faux sur l'énonciation",
                "consigne": "Indique si l'affirmation est vraie ou fausse.",
                "type": "vrai_faux",
                "questions": [
                    {"enonce": "Un texte objectif ne contient aucun indice de modalisation.", "reponse": True, "explication": "L'énoncé se veut neutre et impersonnel."},
                    {"enonce": "Les déictiques (ici, maintenant, moi) sont coupés de la situation d'énonciation.", "reponse": False, "explication": "Les déictiques ne prennent sens qu'au sein de la situation d'énonciation concrète."},
                    {"enonce": "Le conditionnel est l'un des outils privilégiés de la modalisation du doute.", "reponse": True, "explication": "Il exprime l'irréel, l'hypothèse ou le propos rapporté non vérifié."},
                    {"enonce": "Un verbe d'opinion comme « je crois » affirme une vérité scientifique immuable.", "reponse": False, "explication": "Il marque une subjectivité personnelle."},
                    {"enonce": "L'ironie s'appuie sur une double énonciation implicite.", "reponse": True, "explication": "Le récepteur averti perçoit le décalage entre le sens littéral et l'intention réelle."}
                ]
            },
            {
                "id": "1bac-modalisation-ex3",
                "titre": "Exercice 3 — Pratique de la modalisation",
                "consigne": "Complète chaque phrase par le terme adéquat.",
                "type": "trous",
                "questions": [
                    {"enonce": "L'ensemble des marques qui traduisent l'attitude du locuteur s'appelle la ___", "reponse": "modalisation", "acceptees": ["modalisation"], "explication": "Degré d'adhésion au message."},
                    {"enonce": "Les pronoms « je » et « tu » renvoient aux protagonistes de l'___", "reponse": "énonciation", "acceptees": ["énonciation", "enonciation"], "explication": "Émetteur et récepteur de l'acte d'énonciation."},
                    {"enonce": "Un mot valorisant comme « admirable » est un terme ___", "reponse": "mélioratif", "acceptees": ["mélioratif", "melioratif"], "explication": "Exprime une appréciation élogieuse."},
                    {"enonce": "Un mot dévalorisant comme « médiocre » est un terme ___", "reponse": "péjoratif", "acceptees": ["péjoratif", "pejoratif"], "explication": "Exprime un blâme ou un dénigrement."},
                    {"enonce": "Le mode verbal du doute et du souhait est le ___", "reponse": "subjonctif", "acceptees": ["subjonctif", "conditionnel"], "explication": "Opposé à l'indicatif qui marque le certain."}
                ]
            }
        ]
    },
    {
        "id": "1bac-registres-litteraires",
        "categorie": "style",
        "titre": "Les registres littéraires (tonalités)",
        "niveau": "1ère Bac",
        "aValider": True,
        "contenu": [
            {"type": "paragraphe", "texte": "Le **registre** (ou tonalité) d'un texte est l'effet émotionnel qu'il cherche à provoquer chez le lecteur : terreur et pitié (tragique), rire ou sourire (comique, ironique), compassion et larmes (pathétique), exaltation des sentiments (lyrique), indignation et révolte (polémique)."},
            {"type": "tableau", "entetes": ["Registre", "Procédés dominants", "Émotion suscitée"], "lignes": [
                ["Tragique", "Champs de la fatalité, de la mort, phrases exclamatives", "Angoisse, terreur et pitié (*Antigone*)"],
                ["Pathétique", "Souffrance physique/morale, champ des larmes, hyperboles", "Compassion, attendrissement (*Le Dernier Jour*)"],
                ["Ironique", "Antiphrase, décalage, exagération souriante", "Prise de recul critique, amusement"],
                ["Polémique", "Lexique violent, questions rhétoriques, apostrophes", "Révolte, engagement du lecteur"],
                ["Lyrique", "Première personne « je », champ des émotions intimes", "Partage poétique de l'intériorité"]
            ]},
            {"type": "exemple", "texte": "*« Échafaud ! mot hideux, infâme ! Pourquoi faut-il que la société tue ? »* → Registre pathétique et polémique.\n*« Créon, tu es le roi, tu as tout pouvoir, mais tu ne peux m'empêcher de mourir. »* → Registre tragique."}
        ],
        "exercices": [
            {
                "id": "1bac-registres-ex1",
                "titre": "Exercice 1 — Identifier le registre",
                "consigne": "Choisis le registre prédominant pour chaque passage.",
                "type": "qcm",
                "questions": [
                    {"enonce": "Un passage décrivant les pleurs déchirants d'une mère devant son enfant malade relève du registre…", "options": ["pathétique", "comique", "épique"], "reponse": 0, "explication": "Il cherche à émouvoir aux larmes : registre pathétique."},
                    {"enonce": "Le combat d'Antigone contre la fatalité de son destin d'Œdipe relève du registre…", "options": ["tragique", "satirique", "lyrique"], "reponse": 0, "explication": "La mort inéluctable imposée par le destin caractérise la tragédie."},
                    {"enonce": "Une critique moqueuse des travers des faux savants relève du registre…", "options": ["satirique", "tragique", "pathétique"], "reponse": 0, "explication": "La satire attaque les vices par la moquerie."},
                    {"enonce": "Un plaidoyer indigné contre la peine de mort avec apostrophes virulentes est…", "options": ["polémique", "lyrique", "élégiaque"], "reponse": 0, "explication": "La polémique combat vivement une opinion adverse."},
                    {"enonce": "L'expression intime de la nostalgie et de l'amour dans un poème à la première personne est…", "options": ["lyrique", "épique", "dramatique"], "reponse": 0, "explication": "Chant de l'âme et des sentiments personnels : registre lyrique."}
                ]
            },
            {
                "id": "1bac-registres-ex2",
                "titre": "Exercice 2 — Vrai ou Faux sur les registres",
                "consigne": "Indique si l'affirmation est vraie ou fausse.",
                "type": "vrai_faux",
                "questions": [
                    {"enonce": "Un même texte littéraire peut entremêler plusieurs registres.", "reponse": True, "explication": "Exemple : un passage peut être à la fois pathétique et polémique."},
                    {"enonce": "Le registre tragique laisse toujours un espoir de triomphe final au héros.", "reponse": False, "explication": "Le tragique se définit par l'inéluctabilité du destin et de la chute."},
                    {"enonce": "Le registre épique célèbre les exploits héroïques et grandioses.", "reponse": True, "explication": "Il magnifie le dépassement de soi face au danger."},
                    {"enonce": "Le rire satirique a pour unique but de divertir sans critiquer.", "reponse": False, "explication": "La satire vise à corriger les mœurs en riant (*castigat ridendo mores*)."},
                    {"enonce": "Le registre ironique nécessite la complicité intellectuelle du lecteur.", "reponse": True, "explication": "Pour déceler le second degré sous l'énoncé apparent."}
                ]
            },
            {
                "id": "1bac-registres-ex3",
                "titre": "Exercice 3 — Vocabulaire des tonalités",
                "consigne": "Complète chaque définition.",
                "type": "trous",
                "questions": [
                    {"enonce": "Le registre qui inspire la pitié face au malheur s'appelle le registre ___", "reponse": "pathétique", "acceptees": ["pathétique", "pathetique"], "explication": "Du grec pathos : la souffrance, l'émotion."},
                    {"enonce": "Le registre lié au destin inéluctable et à la mort s'appelle le registre ___", "reponse": "tragique", "acceptees": ["tragique"], "explication": "Propre à la tragédie antique et moderne."},
                    {"enonce": "L'expression des états d'âme et de la musique du cœur relève du registre ___", "reponse": "lyrique", "acceptees": ["lyrique"], "explication": "Fait référence à la lyre des poètes antiques."},
                    {"enonce": "L'attaque vive et engagée d'une thèse adverse définit le registre ___", "reponse": "polémique", "acceptees": ["polémique", "polemique"], "explication": "Du grec polemos : la guerre, le combat d'idées."},
                    {"enonce": "La dénonciation des vices de la société par le ridicule s'appelle la ___", "reponse": "satire", "acceptees": ["satire", "registre satirique"], "explication": "Arme privilégiée de Molière et des moralistes."}
                ]
            }
        ]
    },
    {
        "id": "1bac-argumentation-connecteurs",
        "categorie": "gram",
        "titre": "L'argumentation et les connecteurs logiques",
        "niveau": "1ère Bac",
        "aValider": True,
        "contenu": [
            {"type": "paragraphe", "texte": "Convaincre et persuader sont au cœur des textes argumentatifs (*Le Dernier Jour d'un Condamné* de Victor Hugo, plaidoyer contre la peine de mort). Pour structurer un raisonnement, on s'appuie sur une **thèse**, des **arguments** et des **exemples**, reliés par des **connecteurs logiques** rigoureux."},
            {"type": "tableau", "entetes": ["Relation logique", "Conjonctions / Adverbes", "Rôle dans le raisonnement"], "lignes": [
                ["Addition / Gradation", "De plus, en outre, d'abord, ensuite, enfin", "Accumuler les arguments en ordre d'importance"],
                ["Cause", "Car, parce que, en effet, étant donné que", "Donner la justification rationnelle de la thèse"],
                ["Conséquence", "Donc, ainsi, par conséquent, c'est pourquoi", "Tirer la conclusion logique irréfutable"],
                ["Opposition / Concession", "Mais, cependant, pourtant, néanmoins, bien que", "Nuancer ou réfuter la thèse adverse"]
            ]},
            {"type": "exemple", "texte": "*« La peine de mort est irréversible ; or, la justice humaine est faillible ; par conséquent, l'échafaud doit être aboli. »* → Syllogisme argumentatif parfait."}
        ],
        "exercices": [
            {
                "id": "1bac-argumentation-ex1",
                "titre": "Exercice 1 — Choix du connecteur logique",
                "consigne": "Choisis le connecteur logique qui convient au sens.",
                "type": "qcm",
                "questions": [
                    {"enonce": "L'accusé clame son innocence ; [néanmoins/en effet/c'est pourquoi] les preuves accablantes s'accumulent contre lui.", "options": ["néanmoins", "en effet", "c'est pourquoi"], "reponse": 0, "explication": "Marque l'opposition / restriction : néanmoins."},
                    {"enonce": "L'éducation éclaire les esprits ; [par conséquent/au contraire/puisque] elle constitue le rempart contre l'obscurantisme.", "options": ["par conséquent", "au contraire", "puisque"], "reponse": 0, "explication": "Résultat logique et conclusion : par conséquent."},
                    {"enonce": "Créon veut maintenir l'ordre à Thèbes, [or/car/bien que] cet ordre exige l'impitoyable sacrifice d'Antigone.", "options": ["or", "car", "bien que"], "reponse": 0, "explication": "Introduit une nouvelle donnée dans le raisonnement : or."},
                    {"enonce": "Pour convaincre, on s'adresse à la raison, [tandis que/donc/car] pour persuader, on touche la sensibilité.", "options": ["tandis que", "donc", "car"], "reponse": 0, "explication": "Exprime l'antithèse ou le parallèle : tandis que."},
                    {"enonce": "Il a commis une faute grave ; [pourtant/de plus/ainsi], il mérite une seconde chance par le rachat.", "options": ["pourtant", "de plus", "ainsi"], "reponse": 0, "explication": "Concession et nuance morale : pourtant."}
                ]
            },
            {
                "id": "1bac-argumentation-ex2",
                "titre": "Exercice 2 — Vrai ou Faux sur l'argumentation",
                "consigne": "Indique si l'affirmation est vraie ou fausse.",
                "type": "vrai_faux",
                "questions": [
                    {"enonce": "Convaincre fait appel à la logique et aux arguments rationnels.", "reponse": True, "explication": "Fait appel à l'esprit critique et aux faits démontrables."},
                    {"enonce": "Persuader fait appel aux émotions, aux sentiments et à la séduction oratoire.", "reponse": True, "explication": "Touche le cœur et la sensibilité de l'auditeur."},
                    {"enonce": "Un exemple suffit à lui seul à constituer une thèse.", "reponse": False, "explication": "L'exemple sert à illustrer ou concrétiser un argument, non à le remplacer."},
                    {"enonce": "La réfutation consiste à détruire la thèse adverse en montrant ses failles.", "reponse": True, "explication": "C'est l'un des piliers de la stratégie argumentative."},
                    {"enonce": "Le connecteur « en effet » introduit une conséquence.", "reponse": False, "explication": "« En effet » introduit une explication ou une cause, pas une conséquence."}
                ]
            },
            {
                "id": "1bac-argumentation-ex3",
                "titre": "Exercice 3 — Pratique des connecteurs",
                "consigne": "Complète chaque phrase avec le connecteur adéquat.",
                "type": "trous",
                "questions": [
                    {"enonce": "Le connecteur « donc » exprime la relation de ___", "reponse": "conséquence", "acceptees": ["conséquence", "consequence"], "explication": "Il marque la déduction ou conclusion logique."},
                    {"enonce": "Le connecteur « car » introduit une relation de ___", "reponse": "cause", "acceptees": ["cause"], "explication": "Il justifie l'affirmation précédente."},
                    {"enonce": "Pour introduire une objection, on emploie la conjonction « ___ ».", "reponse": "mais", "acceptees": ["mais", "cependant", "pourtant"], "explication": "Conjonction d'opposition par excellence."},
                    {"enonce": "L'idée principale défendue par l'auteur dans son texte s'appelle la ___", "reponse": "thèse", "acceptees": ["thèse", "these"], "explication": "Point de vue soutenu par l'argumentation."},
                    {"enonce": "Un raisonnement en trois temps (majeure, mineure, conclusion) s'appelle un ___", "reponse": "syllogisme", "acceptees": ["syllogisme"], "explication": "Structure classique de déduction logique."}
                ]
            }
        ]
    },
    {
        "id": "1bac-temps-recit",
        "categorie": "conj",
        "titre": "Les temps du récit et leurs valeurs",
        "niveau": "1ère Bac",
        "aValider": True,
        "contenu": [
            {"type": "paragraphe", "texte": "Dans le roman ou le récit (*La Boîte à Merveilles*, *Le Dernier Jour d'un Condamné*), le système des temps du passé organise la narration entre arrière-plan et premier plan."},
            {"type": "tableau", "entetes": ["Temps", "Valeur narrative", "Exemple"], "lignes": [
                ["Passé simple", "Action de premier plan, ponctuelle, délimitée, succession", "*Il ouvrit la boîte et contempla ses trésors.*"],
                ["Imparfait", "Arrière-plan, description, habitude, action sécante", "*La chambre sentait la lavande ; ma mère cousait.*"],
                ["Plus-que-parfait", "Antériorité par rapport au récit passé", "*Il se souvint du serment qu'il avait prêté.*"],
                ["Présent de narration", "Rend l'action vivante, soudaine et actuelle aux yeux du lecteur", "*Tout à coup la porte s'ouvre : le bourreau paraît.*"]
            ]},
            {"type": "exemple", "texte": "*« La nuit tombait (imparfait, description) quand soudain un cri retentit (passé simple, action soudaine). »*"},
            {"type": "schema", "id": "frise_temps"}
        ],
        "exercices": [
            {
                "id": "1bac-temps-ex1",
                "titre": "Exercice 1 — Identifier la valeur du temps",
                "consigne": "Choisis la valeur exacte du verbe souligné.",
                "type": "qcm",
                "questions": [
                    {"enonce": "« Chaque vendredi, mon père m'emmenait à la mosquée » : valeur de l'imparfait ?", "options": ["description", "habitude / répétition", "action soudaine"], "reponse": 1, "explication": "Marqué par « chaque vendredi » : imparfait d'habitude."},
                    {"enonce": "« Soudain, la cloche de Bicêtre sonna six heures » : valeur du passé simple ?", "options": ["arrière-plan", "action ponctuelle et soudaine de premier plan", "durée indéterminée"], "reponse": 1, "explication": "Action délimitée introduite par un adverbe temporel vif."},
                    {"enonce": "« Il avait déjà oublié les paroles du maître » : valeur du plus-que-parfait ?", "options": ["antériorité", "simultanéité", "futur"], "reponse": 0, "explication": "Action accomplie avant le moment du récit au passé."},
                    {"enonce": "« Le soleil dardait ses rayons sur les ruelles de Fès » : valeur de l'imparfait ?", "options": ["imparfait descriptif", "imparfait de répétition", "imparfait historique"], "reponse": 0, "explication": "Peinture du décor et du cadre spatio-temporel."},
                    {"enonce": "« Je marchais tranquillement quand un cri m'arrêta net » : l'imparfait exprime…", "options": ["une action sécante coupée par le passé simple", "une action achevée", "un ordre"], "reponse": 0, "explication": "Action en cours interrompue par une action brève."}
                ]
            },
            {
                "id": "1bac-temps-ex2",
                "titre": "Exercice 2 — Vrai ou Faux sur les temps",
                "consigne": "Indique si l'affirmation est vraie ou fausse.",
                "type": "vrai_faux",
                "questions": [
                    {"enonce": "Le passé simple s'utilise principalement à l'oral dans les conversations courantes.", "reponse": False, "explication": "Le passé simple est un temps réservé à l'écrit et au récit littéraire soutenu."},
                    {"enonce": "L'imparfait présente l'action comme non achevée dans son déroulement (aspect sécant).", "reponse": True, "explication": "Sans préciser ni le début ni la fin de l'action."},
                    {"enonce": "Le présent de narration transporte le lecteur au cœur même de l'événement.", "reponse": True, "explication": "Il actualise l'action passée pour donner du dynamisme."},
                    {"enonce": "Le plus-que-parfait est formé de l'auxiliaire au présent et du participe passé.", "reponse": False, "explication": "Il est formé de l'auxiliaire à l'imparfait + participe passé."},
                    {"enonce": "Le conditionnel passé peut exprimer un futur dans le passé au discours indirect.", "reponse": True, "explication": "Remplacement du futur simple lorsque le verbe principal est au passé."}
                ]
            },
            {
                "id": "1bac-temps-ex3",
                "titre": "Exercice 3 — Pratique des temps",
                "consigne": "Complète chaque phrase par le terme adéquat.",
                "type": "trous",
                "questions": [
                    {"enonce": "Dans un récit au passé, le premier plan des actions successives s'exprime au passé ___", "reponse": "simple", "acceptees": ["simple"], "explication": "Temps narratif par excellence."},
                    {"enonce": "Le décor et les portraits sont traditionnellement brossés à l'___", "reponse": "imparfait", "acceptees": ["imparfait"], "explication": "Temps de l'arrière-plan descriptif."},
                    {"enonce": "L'action passée antérieure à une autre action passée se conjugue au ___-que-parfait.", "reponse": "plus", "acceptees": ["plus", "plus-que-parfait"], "explication": "Marque le recul temporel."},
                    {"enonce": "Rendre un épisode dramatique présent et saisissant s'obtient par le présent de ___", "reponse": "narration", "acceptees": ["narration", "présent de narration"], "explication": "Effet de zoom et de vivacité dramatique."},
                    {"enonce": "L'imparfait qui traduit une action répétée est l'imparfait d'___", "reponse": "habitude", "acceptees": ["habitude", "répétition", "repetition"], "explication": "Exprime une coutume ou routine passée."}
                ]
            }
        ]
    }
]

with open("assets/data/1bac.json", "w", encoding="utf-8") as f:
    json.dump({
        "code": "1bac",
        "nom": "1ère Année Baccalauréat",
        "description": "Modules de langue et méthodes pour la 1ère Bac marocaine (œuvres au programme : La Boîte à Merveilles, Antigone, Le Dernier Jour d'un Condamné). Contenu à valider par le professeur.",
        "lecons": lecons_1bac
    }, f, ensure_ascii=False, indent=2)

print(f"assets/data/1bac.json généré avec {len(lecons_1bac)} leçons !")

# Générer tronc_commun.json
with open("assets/data/tronc_commun.json", "w", encoding="utf-8") as f:
    json.dump({
        "code": "tc",
        "nom": "Tronc Commun",
        "description": "Programme de langue du Tronc Commun (collège vers lycée). Section prête à être enrichie via JSON.",
        "lecons": []
    }, f, ensure_ascii=False, indent=2)

print("assets/data/tronc_commun.json généré (structure prête) !")
