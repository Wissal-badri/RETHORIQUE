# COMPLÉMENT AU PROMPT — Back-end Supabase, mode professeur, IA et PDF

> Ce texte complète le prompt principal de l'application « Rhétorique — L'art de Molière ».
> **En cas de contradiction, ce complément l'emporte.** En particulier, l'application n'est plus « 100 % hors ligne sans Internet » : elle se synchronise avec un back-end, tout en restant utilisable hors ligne.

---

## 1. Pourquoi un back-end

Le professeur doit pouvoir **ajouter, modifier et publier des leçons et des exercices sans qu'on réinstalle un nouvel APK**. Il doit aussi pouvoir **générer de nouveaux exercices avec l'IA** et **les exporter en PDF**. Le contenu ne doit donc plus être figé dans l'application : il vit dans une base de données en ligne, que l'application télécharge et garde en cache.

## 2. Architecture

- **Back-end : Supabase** (base PostgreSQL, authentification, Edge Functions).
- **Application Flutter** : `supabase_flutter`. Pour le cache local, `hive` ou `drift`.
- **Les fichiers JSON du prompt principal restent embarqués dans l'APK**, comme **contenu de secours** au tout premier lancement sans connexion. Ils servent aussi à **remplir la base au départ** (script de seed).
- **Fonctionnement hors ligne conservé** :
  - au démarrage, si Internet est disponible, l'application télécharge seulement ce qui a changé (les lignes dont `updated_at` est plus récent que la dernière synchronisation) et met à jour le cache ;
  - sans Internet, elle utilise le cache, ou le JSON embarqué si le cache est vide ;
  - un petit indicateur discret affiche « Contenu à jour » ou « Hors ligne », et on peut tirer vers le bas pour synchroniser.
- Ajoute la permission Android `INTERNET`.
- Mets l'URL Supabase et la clé `anon` dans la configuration, via `--dart-define` ou un fichier `env` ignoré par git. **Aucune autre clé dans l'application.**

## 3. Base de données (migrations SQL versionnées dans `supabase/migrations/`)

| Table | Colonnes principales |
|---|---|
| `niveaux` | id, code (`3ac`, `1bac`, `tc`), nom, ordre, actif |
| `lecons` | id, niveau_id, categorie (`gram`, `conj`, `orth`, `voc`, `style`), titre, badge_niveau, contenu (jsonb : les mêmes blocs que le prompt principal), ordre, statut (`brouillon` / `publie`), a_valider, updated_at |
| `exercices` | id, lecon_id, titre, consigne, type, questions (jsonb), ordre, statut (`brouillon` / `publie`), source (`manuel` / `ia`), updated_at |
| `app_config` | version_min, version_actuelle, lien_apk, message |

- Un **trigger** met à jour `updated_at` à chaque modification.
- **Sécurité (RLS)** :
  - **lecture** par tout le monde (anon) des lignes `statut = 'publie'` seulement ;
  - **écriture** réservée au compte professeur (un rôle `admin`, stocké dans une table `profils` ou dans les métadonnées de l'utilisateur).
- Les **élèves n'ont pas de compte**. Leur progression et leurs scores restent **en local** sur le téléphone, comme dans le prompt principal.
- Un **script de seed** importe dans Supabase tout le contenu converti depuis le HTML (les leçons et tous les exercices).

## 4. Mode professeur (dans l'application)

- **Accès discret** : un appui long sur le titre « Rhétorique » de l'écran À propos ouvre la connexion professeur (e-mail et mot de passe Supabase Auth). Les élèves ne voient pas ce mode.
- Écrans du mode professeur, dans le même design élégant :
  1. **Tableau de bord** : nombre de leçons et d'exercices par niveau, brouillons à valider.
  2. **Leçons** : créer, modifier, réordonner, publier ou dépublier. Un éditeur simple par blocs (paragraphe, exemple, tableau, schéma), avec un **aperçu** exactement comme l'élève le verra.
  3. **Exercices** : créer ou modifier à la main (tous les types du prompt principal), publier ou dépublier.
  4. **Générer avec l'IA** (voir la section 5).
  5. **Exporter en PDF** (voir la section 6).
- Toute publication est visible chez les élèves **à leur prochaine synchronisation**, sans nouvel APK.

## 5. Génération d'exercices par l'IA

- Une **Edge Function Supabase `generer-exercices`** (TypeScript) :
  - vérifie que l'appelant est bien le professeur connecté (JWT avec le rôle admin) ;
  - reçoit : `lecon_id`, type(s) d'exercice, nombre de questions, difficulté (facile / moyen / difficile) et une consigne libre facultative ;
  - lit le contenu de la leçon dans la base et l'envoie à l'IA, avec un prompt système strict : rester fidèle à la règle de la leçon, niveau collège ou lycée marocain, français soutenu et sans faute, une explication par question, **réponse uniquement en JSON** au format exact des exercices ;
  - **valide le JSON reçu** (schéma, bonne réponse présente parmi les options, aucun champ vide). En cas d'échec, elle refait une tentative, puis renvoie une erreur claire ;
  - enregistre le résultat comme exercice en **`statut = 'brouillon'`** et **`source = 'ia'`**.
- **Fournisseur d'IA** : utilise l'**API Gemini** (`gemini-2.5-flash`, qui a une offre gratuite) par défaut. Prévois une variable pour passer facilement à l'API Claude d'Anthropic. **La clé API est stockée uniquement dans les secrets Supabase** (`supabase secrets set`), **jamais dans l'application**.
- Dans l'application, le professeur voit les questions générées. Il peut **modifier, supprimer ou régénérer une question**, puis **valider et publier**. Rien de généré par l'IA n'arrive chez les élèves sans sa validation.
- Prévois une limite simple (par exemple 30 générations par jour) pour éviter un usage excessif.

## 6. Export PDF (sur le téléphone, sans back-end)

- Utilise les paquets `pdf` et `printing` (avec `share_plus` pour partager par WhatsApp ou par e-mail).
- Trois types de documents :
  1. **Fiche de leçon** : le cours complet avec les exemples et les tableaux.
  2. **Fiche d'exercices pour les élèves** : les consignes et les questions **sans les réponses**, avec des lignes ou des cases pour répondre, plus des champs « Nom », « Classe » et « Date » en haut.
  3. **Corrigé pour le professeur** : les réponses et les explications.
- On peut aussi composer une **fiche personnalisée** : choisir plusieurs exercices d'une ou plusieurs leçons, et donner un titre (« Contrôle n° 2 — 3AC »).
- **Style du PDF identique à l'application** : fond blanc, titres en calligraphie Pinyon Script marine, texte en Tinos (équivalent de Times New Roman), filets et ornements ❦ dorés, encadrés beige. En-tête : « Rhétorique — L'art de Molière ». Pied de page : « BADRI Chakib, professeur de français · Groupe Scolaire Jean-Henri Lambert, Casablanca », avec la pagination.
- L'export de la fiche de leçon est **accessible aux élèves aussi**. Les fiches d'exercices et les corrigés sont réservés au mode professeur.

## 7. Mises à jour de l'application elle-même

Le contenu se met à jour tout seul. Pour le cas où le **code** de l'application change :
- au démarrage, l'application lit la table `app_config` ;
- si sa version est inférieure à `version_actuelle`, une fenêtre élégante s'affiche : « Une nouvelle version de Rhétorique est disponible », avec un bouton qui ouvre `lien_apk` (par exemple un lien Google Drive) ;
- si sa version est inférieure à `version_min`, la mise à jour est obligatoire.

## 8. Livrables supplémentaires

- Le dossier `supabase/` : migrations, politiques RLS, seed, Edge Function `generer-exercices`.
- Dans le `README.md`, un **guide pas à pas pour une débutante** :
  - créer le projet Supabase ;
  - lancer les migrations et le seed ;
  - créer le compte professeur et lui donner le rôle admin ;
  - obtenir une clé API Gemini et la mettre dans les secrets ;
  - déployer l'Edge Function ;
  - renseigner l'URL et la clé anon dans l'application, puis générer l'APK.
- Tests : la logique de synchronisation (cache et repli) et la validation du JSON de l'IA.

## 9. Ordre de travail (remplace celui du prompt principal)

1. Modèle de données et JSON embarqué.
2. Conversion du contenu HTML.
3. Supabase : migrations, RLS, seed.
4. Synchronisation et cache dans l'application.
5. Écrans des cours et schémas.
6. Moteur d'exercices et de correction.
7. Mode professeur (leçons et exercices).
8. Edge Function d'IA et écran de génération.
9. Export PDF.
10. Design final, animations, vérification de version, tests et APK.

Montre-moi le résultat et attends ma validation à la fin de chaque étape.
