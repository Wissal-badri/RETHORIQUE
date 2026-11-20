# -*- coding: utf-8 -*-
import json
import os

data_1ac = {
    "code": "1ac",
    "nom": "1ère Année Collège",
    "description": "Programme de français de la 1ère Année de l'Enseignement Secondaire Collégial : étude du récit, du portrait et des outils de la narration.",
    "lecons": [
        {
            "id": "1ac-schema-narratif",
            "categorie": "recit",
            "titre": "Le schéma narratif d'un récit",
            "niveau": "1ère AC",
            "aValider": False,
            "contenu": [
                {
                    "type": "paragraphe",
                    "texte": "Le **schéma narratif** est la structure universelle qui permet de construire et d’analyser le déroulement chronologique et logique d’un récit (conte, nouvelle, fable)."
                },
                {
                    "type": "tableau",
                    "entetes": ["Étape du récit", "Définition & Rôle", "Indices / Connecteurs"],
                    "lignes": [
                        [
                            "1. Situation initiale (SI)",
                            "Présentation du cadre (qui, où, quand) dans un état d'équilibre ou de calme.",
                            "Il était une fois, un jour, jadis, verbes à l'imparfait"
                        ],
                        [
                            "2. Élément modificateur (EM)",
                            "Événement soudain qui vient rompre le calme initial et déclencher l'action.",
                            "Soudain, tout à coup, un beau matin, verbes au passé simple"
                        ],
                        [
                            "3. Péripéties (actions)",
                            "Ensemble des actions, épreuves, aventures vécues par le héros pour résoudre le problème.",
                            "D'abord, ensuite, alors, après cela, verbes d'action au passé simple"
                        ],
                        [
                            "4. Élément de résolution (ER)",
                            "L'action ou l'événement final qui met un terme aux difficultés ou au danger.",
                            "Enfin, grâce à, finalement, le triomphe"
                        ],
                        [
                            "5. Situation finale (SF)",
                            "Retour à un nouvel état d'équilibre stable (heureux ou malheureux).",
                            "Depuis ce jour, désormais, ils vécurent heureux"
                        ]
                    ]
                },
                {
                    "type": "exemple",
                    "texte": "**Exemple dans un conte classique :**\n• *Situation initiale :* Cendrillon vit soumise et silencieuse auprès de sa marâtre.\n• *Élément perturbateur :* Une invitation royale au grand bal du prince arrive au manoir.\n• *Péripéties :* La marraine fée transforme la citrouille, Cendrillon danse avec le prince, elle fuit à minuit et perd sa pantoufle de vair.\n• *Résolution :* Le prince fait essayer la pantoufle de verre à toutes les jeunes filles du royaume.\n• *Situation finale :* Cendrillon épouse le prince et quitte à jamais sa misérable condition."
                }
            ],
            "exercices": [
                {
                    "id": "1ac-ex-schema-1",
                    "type": "qcm",
                    "consigne": "Identifiez l'étape du schéma narratif correspondant à la phrase.",
                    "questions": [
                        {
                            "enonce": "« Soudain, un éclair déchira la nuit et le pont s’effondra dans le ravin. » De quelle étape s'agit-il ?",
                            "options": [
                                "La situation initiale",
                                "L'élément modificateur (perturbateur)",
                                "La situation finale",
                                "L'élément d'équilibre"
                            ],
                            "reponse": "L'élément modificateur (perturbateur)",
                            "explication": "Le mot 'Soudain' et l'apparition de l'éclair rompent l'état de calme : c'est un élément modificateur (passé simple à valeur d'action soudaine)."
                        },
                        {
                            "enonce": "Quelle étape présente le héros, le décor et l'époque dans un état de calme ?",
                            "options": [
                                "Les péripéties",
                                "La situation finale",
                                "La situation initiale",
                                "Le dénouement"
                            ],
                            "reponse": "La situation initiale",
                            "explication": "La situation initiale installe le décor, les personnages et le contexte avant tout bouleversement."
                        }
                    ]
                }
            ]
        },
        {
            "id": "1ac-portrait-description",
            "categorie": "recit",
            "titre": "Le portrait physique et moral",
            "niveau": "1ère AC",
            "aValider": False,
            "contenu": [
                {
                    "type": "paragraphe",
                    "texte": "Faire le **portrait** d'un personnage consiste à décrire son apparence et sa personnalité. On distingue le portrait physique, le portrait moral et les aspects vestimentaires."
                },
                {
                    "type": "tableau",
                    "entetes": ["Composante", "Éléments décrits", "Vocabulaire & Moyens grammaticaux"],
                    "lignes": [
                        [
                            "Portrait physique",
                            "Silhouette, taille, visage, yeux, teint, voix, démarche",
                            "Adjectifs qualificatifs (élancé, vermeil, voûté), comparaisons"
                        ],
                        [
                            "Portrait moral",
                            "Caractère, qualités, défauts, humeur, tempérament",
                            "Généreux, avare, bienveillant, sournois, colérique"
                        ],
                        [
                            "Tenue vestimentaire",
                            "Vêtements, accessoires, allure générale",
                            "Habits de velours, haillons déchirés, élégance, négligence"
                        ]
                    ]
                },
                {
                    "type": "paragraphe",
                    "texte": "**La visée du portrait :**\n• **Portrait mélioratif (valorisant) :** met en valeur les qualités du personnage par un lexique élogieux.\n• **Portrait péjoratif (dévalorisant) :** insiste sur les défauts, la laideur ou le ridicule par un lexique dépréciatif."
                },
                {
                    "type": "exemple",
                    "texte": "*« Ses yeux étincelants respiraient la bonté et l'intelligence »* ➔ Portrait mélioratif (physique et moral).\n*« Son regard fuyant et son rictus narquois inspiraient la méfiance »* ➔ Portrait péjoratif."
                }
            ],
            "exercices": [
                {
                    "id": "1ac-ex-portrait-1",
                    "type": "qcm",
                    "consigne": "Distinguez portrait mélioratif et portrait péjoratif.",
                    "questions": [
                        {
                            "enonce": "L'expression « un sourire radieux et une voix mélodieuse » relève d'un portrait :",
                            "options": [
                                "Péjoratif",
                                "Mélioratif (valorisant)",
                                "Neutre",
                                "Schématique"
                            ],
                            "reponse": "Mélioratif (valorisant)",
                            "explication": "'Radieux' et 'mélodieuse' sont des adjectifs élogieux mettant le personnage en valeur."
                        },
                        {
                            "enonce": "Lequel de ces termes relève du portrait moral ?",
                            "options": [
                                "Teint pâle",
                                "Regard noisette",
                                "Générosité d'âme",
                                "Chevelure bouclée"
                            ],
                            "reponse": "Générosité d'âme",
                            "explication": "La générosité renvoie à la personnalité et aux qualités intérieures (portrait moral), tandis que le teint et la chevelure sont physiques."
                        }
                    ]
                }
            ]
        },
        {
            "id": "1ac-temps-recit",
            "categorie": "conj",
            "titre": "Les temps du récit : Imparfait et Passé simple",
            "niveau": "1ère AC",
            "aValider": False,
            "contenu": [
                {
                    "type": "paragraphe",
                    "texte": "Dans un récit au passé, l'**imparfait** et le **passé simple** se partagent des rôles précis et complémentaires pour donner vie à la narration."
                },
                {
                    "type": "tableau",
                    "entetes": ["Temps verbal", "Rôle narratif majeur", "Exemples de valeurs"],
                    "lignes": [
                        [
                            "Imparfait de l'indicatif",
                            "Arrière-plan du récit (décor, état, durée non précisée)",
                            "• Description du paysage ou du personnage\n• Action habituelle / répétée\n• Action en cours d'accomplissement"
                        ],
                        [
                            "Passé simple de l'indicatif",
                            "Premier plan du récit (dynamique des événements)",
                            "• Action ponctuelle et soudaine\n• Succession d'actions achevées et limitées dans le temps"
                        ]
                    ]
                },
                {
                    "type": "exemple",
                    "texte": "*« La pluie tombait (imparfait : arrière-plan) à verse quand la porte claqua (passé simple : action soudaine). Aussitôt, Paul saisit (passé simple) son manteau et s'élança (passé simple : succession rapide) dans la nuit. »*"
                }
            ],
            "exercices": [
                {
                    "id": "1ac-ex-temps-1",
                    "type": "qcm",
                    "consigne": "Identifiez la valeur des temps du récit.",
                    "questions": [
                        {
                            "enonce": "Dans « Il marchait tranquillement dans la forêt quand un cri retentit », quelle est la valeur de 'marchait' ?",
                            "options": [
                                "Action soudaine achevée",
                                "Action d'arrière-plan en cours",
                                "Action répétée",
                                "Ordre impératif"
                            ],
                            "reponse": "Action d'arrière-plan en cours",
                            "explication": "L'imparfait 'marchait' décrit l'action en cours en toile de fond, interrompue par le cri ponctuel au passé simple."
                        }
                    ]
                }
            ]
        },
        {
            "id": "1ac-schema-actanciel",
            "categorie": "recit",
            "titre": "Le schéma actanciel",
            "niveau": "1ère AC",
            "aValider": False,
            "contenu": [
                {
                    "type": "paragraphe",
                    "texte": "Le **schéma actanciel** (élaboré par A.J. Greimas) permet de comprendre les forces, motivations et interactions entre les personnages d'un récit."
                },
                {
                    "type": "tableau",
                    "entetes": ["Rôle actanciel", "Définition", "Exemple type"],
                    "lignes": [
                        [
                            "Sujet (Héros)",
                            "Le personnage qui mène la quête ou poursuit un but",
                            "Le chevalier ou la princesse"
                        ],
                        [
                            "Objet (Quête)",
                            "Ce que le sujet cherche à obtenir ou délivrer",
                            "Le remède magique, la paix du royaume"
                        ],
                        [
                            "Destinateur",
                            "Celui qui donne la mission ou pousse le héros à agir",
                            "Le roi, le sage, le devoir moral"
                        ],
                        [
                            "Destinataire",
                            "Celui qui profitera du succès de la quête",
                            "Le peuple, le héros lui-même"
                        ],
                        [
                            "Adjuvant",
                            "Les personnes ou objets qui aident le héros",
                            "L'épée enchantée, le cheval ailé, le compagnon fidèle"
                        ],
                        [
                            "Opposant",
                            "Ceux qui créent des obstacles pour faire échouer le héros",
                            "Le dragon féroce, le sorcier machiavélique"
                        ]
                    ]
                }
            ],
            "exercices": [
                {
                    "id": "1ac-ex-actanciel-1",
                    "type": "qcm",
                    "consigne": "Identifiez les rôles actanciels.",
                    "questions": [
                        {
                            "enonce": "Dans un conte, un génie bienveillant qui remet une baguette enchantée au jeune paysan est :",
                            "options": [
                                "Un opposant",
                                "Un adjuvant",
                                "Le destinateur suprême",
                                "Le sujet"
                            ],
                            "reponse": "Un adjuvant",
                            "explication": "L'adjuvant apporte une aide matérielle ou magique pour faciliter la mission du sujet."
                        }
                    ]
                }
            ]
        }
    ]
}

os.makedirs('assets/data', exist_ok=True)
with open('assets/data/1ac.json', 'w', encoding='utf-8') as f:
    json.dump(data_1ac, f, ensure_ascii=False, indent=2)

print("1ac.json créé avec succès !")
