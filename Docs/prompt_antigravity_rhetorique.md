# PROMPT POUR ANTIGRAVITY — Application Flutter « Rhétorique — L'art de Molière »

> Joins le fichier `langue-francaise.html` à la conversation avant de coller ce prompt.

---

## Contexte

Tu es un développeur Flutter senior. Crée une application Android complète en **Flutter (Dart, Material 3)** appelée **« Rhétorique »**, avec le slogan **« L'art de Molière »**. C'est une application de langue française (grammaire, conjugaison, orthographe, vocabulaire, style) destinée aux élèves marocains.

Le nom vient du grec *rhêtorikê* : l'art de bien parler, bien écrire et convaincre. Autrefois, la « classe de rhétorique » était la dernière et la plus prestigieuse année d'études, celle où l'élève devenait maître de la langue. L'application doit transmettre cette idée d'excellence et d'élégance classique. L'auteur est **BADRI Chakib, professeur de français** (Groupe Scolaire Jean-Henri Lambert, Casablanca).

Le fichier HTML joint (`langue-francaise.html`) est la version web actuelle. Il contient :
- la liste des leçons (tableau `L` en JavaScript) : catégorie, titre, niveau, contenu HTML (règles, exemples, tableaux) ;
- des exercices QCM (tableau `EX`) : 3 questions par leçon.

**Reprends l'intégralité de ce contenu, sans rien perdre ni résumer**, puis enrichis-le comme décrit plus bas.

L'application doit fonctionner **100 % hors ligne** (pas de serveur, pas de compte, pas de pub), et produire un **APK installable**.

---

## 1. Structure de l'application

### Niveaux (extensibles)
- **3e année collège (3AC)** : toutes les leçons du fichier HTML (elles couvrent 1AC à 3AC et servent de programme et de révision), plus les nouveaux exercices.
- **1ère année Bac** : une section prête à recevoir le contenu. Génère un premier ensemble de leçons de **langue** adaptées au programme marocain de 1ère Bac (par exemple : connecteurs logiques, modalisation, discours rapporté, figures de style, registres de langue, types de textes, argumentation, temps du récit, valeurs des temps). Marque chaque leçon générée avec le champ `"aValider": true`, parce que le professeur doit la relire.
- **Tronc commun** : prévu dans le code et dans le fichier de données, mais vide pour l'instant. On doit pouvoir l'ajouter **seulement en ajoutant du contenu JSON**, sans toucher au code.

### Catégories (dans chaque niveau)
Grammaire · Conjugaison · Orthographe · Vocabulaire · Style et sens (même découpage que le HTML).

### Écrans
1. **Accueil** : en haut, le nom **« Rhétorique »** en grand, en calligraphie (Pinyon Script, animé comme écrit à la plume), puis le slogan *« L'art de Molière »* en Tinos italique, puis la mention « Par BADRI Chakib, professeur de français ». En dessous, le choix du niveau (cartes). Sur chaque carte : nombre de leçons et progression (%).
2. **Niveau** : barre de recherche (insensible aux accents et à la casse, comme la fonction `norm()` du HTML), filtres par catégorie (chips), liste des leçons regroupées par catégorie. Sur chaque leçon : badge du niveau (« 1AC–2AC »…), meilleur score obtenu, et une coche si la leçon est réussie (≥ 80 %).
3. **Leçon** : le cours complet, bien mis en forme (titres, gras, italique, encadrés d'exemples sur fond beige, **tableaux défilables horizontalement**, **schémas visuels** — voir la section 5), puis le bouton **« Faire les exercices »**.
4. **Exercices** : voir la section 3.
5. **Résultats / Correction** : voir la section 4.
6. **À propos** : le nom, le slogan, un court texte sur l'origine du mot « rhétorique » (voir le Contexte), l'auteur, l'établissement et la version.

---

## 2. Données : tout dans des fichiers JSON (séparés du code)

- Un fichier par niveau dans `assets/data/` : `3ac.json`, `1bac.json`, `tronc_commun.json`.
- Le contenu des leçons doit être stocké en **blocs structurés**, pas en HTML brut :

```json
{
  "id": "gram-fonctions",
  "categorie": "gram",
  "titre": "Les fonctions dans la phrase",
  "niveau": "1AC–2AC",
  "aValider": false,
  "contenu": [
    {"type": "paragraphe", "texte": "**Sujet** : celui qui fait l'action…"},
    {"type": "exemple", "texte": "*Hier, Sara a offert un livre à son frère.*\nHier (CC de temps) · …"},
    {"type": "tableau", "entetes": ["Valeur", "Conjonctions", "Exemple"], "lignes": [["Cause", "parce que…", "*Il est absent…*"]]}
  ],
  "exercices": [ … ]
}
```

- Mise en forme légère dans les textes : `**gras**`, `*italique*`, `\n` pour les sauts de ligne. Écris un petit moteur de rendu qui transforme ça en `RichText`.
- Écris un **script de conversion** (Dart ou Python, dans `tool/`) qui lit le HTML et produit le JSON. Vérifie ensuite que **les 32 leçons** et **toutes les questions existantes** sont bien présentes.
- Ajoute un fichier `CONTENU.md` qui explique au professeur comment ajouter une leçon, un exercice ou un niveau en modifiant le JSON.

---

## 3. Exercices : plusieurs par leçon, plusieurs types

Pour **chaque leçon**, il faut **au moins 3 exercices**, et chaque exercice compte **5 à 8 questions**. Le premier exercice reprend les questions du HTML et les complète. Tu rédiges les autres en restant **strictement fidèle au cours de la leçon** (mêmes règles, même niveau, exemples marocains bienvenus : prénoms, villes).

Types d'exercices à mettre en œuvre :

| Type | Description | Correction |
|---|---|---|
| `qcm` | une seule bonne réponse parmi 3 ou 4 | comparaison de l'index |
| `vrai_faux` | une affirmation à juger | booléen |
| `trous` | phrase avec un blanc à remplir au clavier (ex. : « Elles sont (partir) … ») | comparaison **normalisée** : on ignore les espaces en trop et la casse, et on traite ’ et ' comme identiques. Les accents **comptent** (c'est de l'orthographe). Le champ `acceptees` permet de donner plusieurs réponses valides. |
| `choix_dans_phrase` | choisir le bon homophone ou la bonne forme dans une liste déroulante, au sein de la phrase (a/à, et/est, ces/ses…) | index |
| `association` | relier des éléments (figure de style ↔ exemple, temps ↔ terminaison) | chaque paire est comptée séparément |
| `transformation` | réécrire une phrase (actif → passif, direct → indirect) | comparaison normalisée avec une ou plusieurs réponses acceptées |

**Chaque question doit avoir un champ `explication`** : une ou deux phrases qui rappellent la règle (ex. : « Avec l'auxiliaire être, le participe passé s'accorde avec le sujet *elles* → féminin pluriel : *parties*. »).

Format d'un exercice :

```json
{
  "id": "orth-pp-ex2",
  "titre": "Exercice 2 — Accorde le participe passé",
  "consigne": "Écris le participe passé correctement accordé.",
  "type": "trous",
  "questions": [
    {"enonce": "Les filles sont (arriver) ___ hier.", "reponse": "arrivées", "acceptees": ["arrivées"], "explication": "…"}
  ]
}
```

---

## 4. Déroulement et correction (le plus important)

1. L'élève répond à **toutes les questions de l'exercice** sur une seule page qui défile. **Aucune correction ne s'affiche pendant qu'il répond** : pas de vert ni de rouge.
2. Un compteur en haut indique « 4 / 6 questions répondues ».
3. En bas, un grand bouton **« Corriger »**. S'il reste des questions sans réponse, une boîte de dialogue demande : « Il reste 2 questions sans réponse. Corriger quand même ? »
4. Après un appui sur **Corriger** :
   - **Score de l'exercice** affiché en grand (ex. : **5 / 7 — 71 %**), avec une couleur (vert ≥ 80 %, orange 50–79 %, rouge < 50 %) et un message adapté (« Excellent ! », « Bien, mais revois… », « Relis la leçon et recommence »).
   - **Section « Tes erreurs »** : pour chaque question fausse ou sans réponse, on affiche l'énoncé, ❌ **ta réponse**, ✅ **la bonne réponse** et 💡 **l'explication**.
   - **Si tout est juste** : message de félicitations, puis la **liste de toutes les questions avec les bonnes réponses et leurs explications**, pour réviser.
   - Dans tous les cas, un bouton **« Voir toutes les réponses »** déplie la correction complète. Dans la liste des questions, chaque réponse est marquée en vert ou en rouge.
   - Boutons : **« Recommencer l'exercice »** (efface les réponses ; les questions et les options sont mélangées à nouveau), **« Exercice suivant »**, **« Retour à la leçon »**.
5. Quand tous les exercices d'une leçon sont faits : un **bilan de la leçon** (score de chaque exercice et score total).
6. **Sauvegarde locale** (`shared_preferences` ou `hive`) : meilleur score par exercice, date du dernier essai, progression par leçon et par niveau. Un bouton dans « À propos » permet de réinitialiser la progression, après confirmation.

---

## 5. Design

**Objectif : une application sobre, raffinée et classique, qui fasse « wow » dès l'ouverture.** L'ambiance recherchée est celle d'un beau livre ancien relié, d'une bibliothèque, d'un manuscrit élégant. Pas de couleurs vives ni d'effets « gadget ». Le luxe doit venir de la typographie, de l'espace, des détails et de la fluidité.

### Palette (sobre)

| Rôle | Couleur |
|---|---|
| Fond principal | blanc cassé `#FAF7F0` |
| Cartes et encadrés | beige clair `#F1E9DA` |
| Bordures, séparateurs | beige sable `#D9CBB0` |
| Titres, boutons principaux, barre du haut | bleu marine `#14284B` |
| Texte courant | marine très foncé `#1B2437` |
| Accent (à doser avec parcimonie : filets, ornements, lettrines, scores) | doré discret `#A8873A` |
| Bonne réponse / erreur (corrections uniquement) | vert sauge `#5E7F5B` / bordeaux `#8E3B3B` |

**Pas de mode sombre.** L'application reste toujours en thème clair, même si le téléphone est réglé en mode sombre. Force `themeMode: ThemeMode.light`, ne définis pas de `darkTheme` et n'ajoute aucun bouton de changement de thème.

### Typographie

- **Grands titres en calligraphie** : le nom « Rhétorique » sur l'écran d'accueil et l'écran de démarrage, les noms des niveaux et les titres de catégories. Utilise la police **Pinyon Script** (calligraphie anglaise classique, à la plume). Alternatives possibles : *Great Vibes* ou *Parisienne*. À l'ouverture de l'application, le mot « Rhétorique » doit **s'écrire progressivement**, comme tracé à la plume : une animation de révélation de gauche à droite, d'environ 1,5 seconde.
- **Tout le reste du texte en Times New Roman** : titres de leçons, cours, exercices, boutons. Times New Roman est une police propriétaire qu'on ne peut pas embarquer légalement dans une application. Utilise donc **Tinos** (Google Fonts), qui a exactement les mêmes formes et les mêmes dimensions, avec ses variantes normal, gras, italique et gras italique. Mets `Tinos` en police par défaut dans le `ThemeData`, avec `'Times New Roman'` en repli.
- **Toutes les polices sont embarquées dans `assets/fonts`**, pour un fonctionnement hors ligne. Ne fais aucun téléchargement à l'exécution.
- Hiérarchie claire : titres de leçons en petites capitales espacées, beaucoup d'espace blanc, et une première lettre de chaque cours **en lettrine dorée**, comme dans les livres anciens.
- Réglage de taille de police (A− / A+) dans les paramètres.

### Détails qui font « wow »

- Des **ornements typographiques** discrets (❦, ✦, filets dorés fins) pour séparer les sections, avec un double cadre fin sur les cartes importantes.
- Une **texture papier** très légère sur le fond (presque invisible), pour l'effet de page de livre.
- Des **transitions fluides** entre les écrans (fondu et léger glissement), et des cartes qui apparaissent en cascade.
- Une **barre de progression circulaire dorée** pour chaque niveau et chaque leçon.
- **Score parfait** : une animation élégante (fines particules dorées ou laurier qui se dessine) et le message « Excellence ! ». Rien de criard.
- Des **retours haptiques légers** au toucher des réponses et du bouton « Corriger ».
- La barre du haut en marine avec le titre calligraphié, qui se réduit avec élégance quand on fait défiler.

### Schémas visuels dans les cours

Ne te contente pas de texte et de tableaux. Crée des **widgets de schémas** réutilisables, dessinés en Flutter (`CustomPainter` ou widgets), dans la même palette :

- **Frise du temps des verbes** : passé, présent et futur sur une ligne, avec la position de chaque temps (plus-que-parfait, passé composé, imparfait, présent, futur antérieur, futur…). À utiliser dans les leçons de conjugaison et des temps composés.
- **Arbre de décision de l'accord du participe passé** : être ? → accord avec le sujet ; avoir ? → COD placé avant ? → oui ou non… Le schéma est cliquable et se déroule étape par étape.
- **Schéma de la phrase complexe** : des blocs colorés pour la proposition principale et la subordonnée, reliés par la conjonction.
- **Carte mentale des classes de mots** : variables d'un côté, invariables de l'autre.
- **Schéma des fonctions** : la phrase exemple avec chaque groupe souligné et étiqueté (sujet, COD, COI, CC).
- **Roue ou cartes des subordonnées circonstancielles** : cause, conséquence, but, temps, condition, concession, comparaison, chacune avec ses conjonctions et son mode.
- **Discours direct → indirect** : deux colonnes avec des flèches de transformation (présent → imparfait, demain → le lendemain…).
- **Cartes des figures de style** à retourner : la figure d'un côté, la définition et l'exemple de l'autre.

Dans le JSON, ajoute un type de bloc `"schema"` avec un identifiant (ex. : `{"type": "schema", "id": "arbre_participe_passe"}`). Ainsi, le professeur pourra placer un schéma où il veut dans une leçon.

### Icône et écran de démarrage

- **Icône** : un **R majuscule calligraphié** (Pinyon Script), doré, sur fond bleu marine `#14284B`, dans un fin cadre doré. Utilise `flutter_launcher_icons`, avec une version adaptative Android.
- **Écran de démarrage** (`flutter_native_splash`) : fond blanc cassé, puis transition vers l'accueil où « Rhétorique » s'écrit à la plume en marine, avec « L'art de Molière » qui apparaît en fondu en dessous, en Tinos italique.

### Divers

- Tout en français, accents corrects partout.
- Pied de page de l'écran À propos : « © BADRI Chakib, professeur de français · Groupe Scolaire Jean-Henri Lambert, Casablanca ».

---

## 6. Technique

- Flutter stable, Dart à jour, Material 3, null-safety.
- Architecture simple et propre : `models/`, `data/` (chargement JSON), `screens/`, `widgets/`, `services/` (progression). Gestion d'état avec `provider` ou `riverpod`.
- Logique de correction **isolée dans une classe testable**, avec des **tests unitaires** (`test/`) pour la normalisation des réponses et le calcul des scores.
- Aucune permission Android inutile (pas d'Internet).
- `applicationId` : `ma.badrichakib.rhetorique`. Nom affiché sous l'icône : « Rhétorique ». Nom du projet Flutter : `rhetorique`.
- Compatible Android 6.0+ (minSdk 23), téléphones et tablettes, portrait et paysage.

---

## 7. Livrables et vérifications

1. Le projet Flutter complet, qui compile sans erreur ni avertissement (`flutter analyze` propre).
2. Les fichiers JSON avec **toutes les leçons du HTML** et **au moins 3 exercices par leçon**.
3. Le script de conversion et le fichier `CONTENU.md`.
4. Un `README.md` avec les commandes exactes pour :
   - lancer l'application : `flutter run`
   - générer l'APK : `flutter build apk --release` (le fichier se trouve dans `build/app/outputs/flutter-apk/app-release.apk`)
   - générer un APK plus léger par architecture : `flutter build apk --split-per-abi`
5. Avant de terminer, **vérifie toi-même** : lance l'application sur l'émulateur, ouvre plusieurs leçons, fais un exercice de chaque type avec des erreurs volontaires, appuie sur **Corriger**, puis vérifie le score, la liste des erreurs, les explications et le cas « tout juste ».

Procède par étapes : (1) la structure et le modèle de données, (2) la conversion du contenu HTML, (3) les écrans du cours, (4) le moteur d'exercices et de correction, (5) la génération des nouveaux exercices, (6) le design, les schémas et les animations, (7) les tests et le build de l'APK. Montre-moi le résultat à chaque étape.
