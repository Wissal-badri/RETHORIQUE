# Guide Pédagogique — Gestion du Contenu de l'application « Rhétorique »

Ce document explique à l'enseignant (**M. BADRI Chakib**) comment enrichir, modifier ou ajouter des leçons, des exercices et des niveaux directement dans les fichiers de données JSON, sans avoir à modifier le code de l'application.

---

## 1. Organisation des fichiers de données

Tous les fichiers de données se trouvent dans le dossier `assets/data/` :
- `3ac.json` : programme du collège (1AC, 2AC, 3AC et révisions de brevet).
- `1bac.json` : programme de langue et méthodes pour la 1ère Année du Baccalauréat.
- `tronc_commun.json` : niveau Tronc Commun (prêt à recevoir vos cours).

---

## 2. Structure d'un fichier de niveau

Chaque fichier JSON possède la structure générale suivante :

```json
{
  "code": "3ac",
  "nom": "3e Année Collège (et révisions)",
  "description": "Description du programme...",
  "lecons": [
    ...
  ]
}
```

Pour ajouter un nouveau niveau, il suffit de créer un nouveau fichier JSON dans `assets/data/` (par exemple `2bac.json`) avec un code unique et une liste de leçons.

---

## 3. Structure d'une leçon

Chaque leçon dans le tableau `"lecons"` se compose de :

```json
{
  "id": "gram-fonctions",
  "categorie": "gram",
  "titre": "Les fonctions dans la phrase",
  "niveau": "1AC–2AC",
  "aValider": false,
  "contenu": [
    {
      "type": "paragraphe",
      "texte": "**Sujet** : celui qui fait l'action. **COD** : répond à quoi / qui sans préposition."
    },
    {
      "type": "exemple",
      "texte": "*Hier, Sara a offert un livre à son frère.*\nHier (CC de temps) · Sara (sujet) · un livre (COD) · à son frère (COI)."
    },
    {
      "type": "tableau",
      "entetes": ["Fonction", "Question", "Exemple"],
      "lignes": [
        ["Sujet", "Qui est-ce qui ?", "*Sara* lit."],
        ["COD", "Quoi ? / Qui ?", "Elle lit *un livre*."]
      ]
    },
    {
      "type": "schema",
      "id": "schema_fonctions"
    }
  ],
  "exercices": [ ... ]
}
```

### Catégories disponibles :
- `"gram"` : Grammaire
- `"conj"` : Conjugaison
- `"orth"` : Orthographe
- `"voc"` : Vocabulaire
- `"style"` : Style et sens

### Types de blocs de contenu :
1. **`paragraphe`** : texte courant explicatif.
   - Utilisez `**gras**` pour le texte en gras.
   - Utilisez `*italique*` pour le texte en italique.
   - Utilisez `\n` pour un retour à la ligne.
2. **`exemple`** : encadré beige sur fond parchemin avec texte stylisé.
3. **`tableau`** : tableau élégant avec en-têtes dorés et lignes défilables horizontalement.
4. **`schema`** : insère l'un des schémas visuels interactifs de l'application :
   - `"carte_classes_mots"` : carte mentale des 10 classes de mots (variables vs invariables).
   - `"schema_fonctions"` : décomposition visuelle et étiquetage de la phrase.
   - `"schema_phrase_complexe"` : boîte principale et subordonnée reliées par la conjonction.
   - `"roue_circonstancielles"` : valeurs des circonstancielles (cause, conséquence, but, temps, etc.).
   - `"discours_direct_indirect"` : tableau des transpositions temporelles et spatiales.
   - `"frise_temps"` : frise chronologique des temps de l'indicatif (passé, présent, futur).
   - `"arbre_participe_passe"` : arbre de décision interactif pour l'accord du participe passé.
   - `"cartes_figures_style"` : cartes tournantes des figures de rhétorique.

### Mention `"aValider"` :
- Mettez `"aValider": true` lorsque le contenu a été rédigé ou généré par assistance et nécessite votre relecture finale.
- Mettez `"aValider": false` dès que vous avez validé la leçon.

---

## 4. Structure des exercices

Chaque leçon contient au moins 3 exercices, avec 5 à 8 questions par exercice. **Chaque question doit obligatoirement comporter un champ `explication`** pour guider l'élève lors de la correction.

### Format général d'un exercice :
```json
{
  "id": "orth-pp-ex1",
  "titre": "Exercice 1 — QCM d'application",
  "consigne": "Choisis la bonne réponse parmi les propositions.",
  "type": "qcm",
  "questions": [ ... ]
}
```

### Les 6 types d'exercices pris en charge :

#### 1. QCM (`"type": "qcm"`)
```json
{
  "enonce": "« Rapidement » est un…",
  "options": ["nom", "adverbe", "adjectif"],
  "reponse": 1,
  "explication": "« Rapidement » se termine par -ment et modifie le verbe : c'est un adverbe de manière invariable."
}
```
*Note : `reponse` est l'indice numérique (commençant à 0) de la bonne option dans `options`.*

#### 2. Vrai ou Faux (`"type": "vrai_faux"`)
```json
{
  "enonce": "Les prépositions sont des mots variables qui s'accordent en nombre.",
  "reponse": false,
  "explication": "Faux : les prépositions (à, de, pour, sans...) font partie des 5 classes de mots invariables."
}
```

#### 3. Texte à trous (`"type": "trous"`)
```json
{
  "enonce": "Les filles sont (arriver) ___ hier à Marrakech.",
  "reponse": "arrivées",
  "acceptees": ["arrivées", "arrivees"],
  "explication": "Avec l'auxiliaire être, le participe passé s'accorde avec le sujet « les filles » (féminin pluriel)."
}
```
*Note : le moteur de correction normalise la casse (majuscule/minuscule) et les espaces. Les accents sont strictement respectés dans `reponse`, mais vous pouvez spécifier des variantes dans `acceptees`.*

#### 4. Choix dans la phrase (`"type": "choix_dans_phrase"`)
```json
{
  "enonce": "Youssef [a/à] terminé ses exercices.",
  "options": ["a", "à"],
  "reponse": 0,
  "explication": "On peut remplacer par « avait » (verbe avoir au présent)."
}
```

#### 5. Association de paires (`"type": "association"`)
```json
{
  "enonce": "Relie chaque temps à sa terminaison au singulier :",
  "paires": [
    {"gauche": "Imparfait (je)", "droite": "-ais"},
    {"gauche": "Futur simple (je)", "droite": "-ai"},
    {"gauche": "Passé simple 1er gr. (je)", "droite": "-ai"}
  ],
  "explication": "L'imparfait prend toujours -ais, le futur simple prend -ai sans -s."
}
```

#### 6. Transformation de phrase (`"type": "transformation"`)
```json
{
  "enonce": "Mets au discours indirect : Youssef dit : « J'aime la poésie. »",
  "reponse": "Youssef dit qu'il aime la poésie.",
  "acceptees": [
    "Youssef dit qu'il aime la poésie.",
    "Youssef dit qu'il aime la poesie",
    "Youssef dit qu'il aime la poésie"
  ],
  "explication": "Le verbe introducteur est au présent : on retire les guillemets et on adapte le pronom sans changer le temps verbal."
}
```

---

## 5. Comment tester vos modifications

1. Ouvrez le fichier concerné (ex. : `assets/data/3ac.json`).
2. Effectuez vos ajouts ou modifications en respectant la syntaxe JSON (attention aux virgules entre les éléments).
3. Lancez le script de validation de données :
   ```bash
   python tool/verify_data.py
   ```
4. Lancez l'application Flutter pour voir vos changements en direct :
   ```bash
   flutter run
   ```
