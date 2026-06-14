# BankAlpha — Analyse du risque crédit

Projet d'analyse de portefeuille de crédit pour une banque fictive (BankAlpha), réalisé dans le cadre de la préparation à une alternance Business Analyst / Data Analyst.

## Contexte

BankAlpha souhaite mieux piloter son portefeuille de prêts personnels. Le directeur des risques mandate une analyse pour répondre à 3 questions business :

1. Quels profils clients présentent le plus de risque de défaut ?
2. Quels produits sont les plus rentables ?
3. Y a-t-il des signaux d'alerte détectables en amont ?

## Données

Dataset : [Credit Risk Dataset](https://www.kaggle.com/datasets/laotse/credit-risk-dataset) (Kaggle) — 32 581 prêts personnels.

## Outils utilisés

- **PostgreSQL** + **DBeaver** pour le stockage et l'analyse SQL
- **Tableau Public** pour la visualisation et le dashboard interactif

## Résultats clés

- 22% de défaut global sur le portefeuille
- Le grade G atteint 98.4% de taux de défaut, contre 10% pour le grade A
- Les motifs VENTURE et EDUCATION sont les plus rentables (14.8% et 17.2% de défaut)
- Un ratio prêt/revenu supérieur à 40% multiplie le risque de défaut par 5 (74.2% vs 13.4%)

## Dashboard

Le dashboard interactif est disponible sur Tableau Public : https://public.tableau.com/app/profile/erika.bibandzila/viz/BankAlpha-projet/Tableaudebord1

## Contenu du repository

- `sql/exploration.sql` — toutes les requêtes SQL avec commentaires
- `rapport/` — rapport d'analyse complet (questions, raisonnement, conclusions)
