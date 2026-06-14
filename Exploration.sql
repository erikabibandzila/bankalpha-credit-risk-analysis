-- Créattion de la base de données
create EATE TABLE loans (
    person_age INTEGER,
    person_income INTEGER,
    person_home_ownership VARCHAR(20),
    person_emp_length FLOAT,
    loan_intent VARCHAR(30),
    loan_grade VARCHAR(5),
    loan_amnt INTEGER,
    loan_int_rate FLOAT,
    loan_status INTEGER,
    loan_percent_income FLOAT,
    cb_person_default_on_file VARCHAR(5),
    cb_person_cred_hist_length INTEGER
);
-- FLOAT = décimal ; INTEGER = entier ; VARCHAR(n) = texte limité à n ; TEXT = texte ilimité

-- Question 1. Quels profils clients présentent le plus de risque de défaut ?

-- a) Nombre total de prêts dans le portefeuille
select count(*) from loans;
-- Résultat : 32 581 prêts

-- b) Répartition des prêts remboursés vs défauts
select loan_status, count(*) as nombre_de_prêt from loans
group by loan_status;
-- résultat : Remboursés = 25 473 et Non remboursés = 7 108 (soit 22% de défauts du portefeuille) sur 32 581 prêts 

-- c) le nombre de défauts par grade
select count(case when loan_status = 1 then 1 end) as nb_defauts, loan_grade from loans
group by loan_grade
order by loan_grade;
-- résultat : voir tableau ci-dessous

-- le taux de défauts par grade
select loan_grade,
count(*) as total_pret,
count(case when loan_status = 1 then 1 end) as nb_defauts,
round(count(case when loan_status = 1 then 1 end)* 100.0 / count(*), 1) as taux_de_defauts
from loans 
group by loan_grade
order by loan_grade;

-- Réponse Question 1 : Les grades D, E, F, G sont clairement les profils les plus risqués

-- Question 2. Quels produits sont les plus rentables ?

-- 1 - Par grade = corresponds à la notation du risque du client (A,B,C,etc)

-- a) calculer le montant moyen des prêts 

select avg(loan_amnt) from loans;
-- le montant moyen est de 9,589

-- b) Le montant moyen des prêts par grade de risque

select avg(loan_amnt), loan_grade from loans
group by loan_grade 
order by loan_grade;
-- réponse : les grades les plus risqués sont E,F,G car les montants sont plus élevés. pq ? riqsque élevé = prêts élevés

-- d) taux d'intérêt moyen par grade 

select avg(loan_int_rate), loan_grade from loans
group by loan_grade
order by loan_grade;
-- BankAlpha compense ses riques par des taux élevé E = 17% F = 18,6% G = 20,5%

-- e) taux de défauts par grade de risque 

select loan_grade,
count(*) as total_prêt,
avg (loan_amnt) as montant_moyen_prêt,
avg(loan_int_rate) as taux_interêts,
count(case when loan_status = 1 then 1 end) as nb_défauts,
round(count(case when loan_status = 1 then 1 end) * 100.0 /count(*), 1) as taux_de_défauts
from loans 
group by loan_grade 
order by loan_grade;


-- 2 - Par motif — pourquoi le client emprunte.

-- a) Toutes les valeurs distinctes pour savoir quels motifs de prêt existent

select distinct(loan_intent) from loans;

-- b) On veut savoir pour chaque motif : combien de prêts, le taux d'intérêt moyen, et le taux de défaut
--- 1.b) pour chaque motif de prêt le total de prêt et le taux d'intérêt moyen

select loan_intent, count(*) as total_loans, avg(loan_int_rate) as average_rate from loans group by loan_intent;

-- réponse : les taux sont relativement très proche 10,9% et 11,2% cela ne nous permet pas de savoir lequel est le plus rentable il faut donc calculer le taux de défauts

-- 2.b) calculer le taux de défauts

select loan_intent,
count(*) as prêt_total,
avg (loan_int_rate) as taux_moyen,
count(case when loan_status = 1 then 1 end) as nb_defauts,
round(count(case when loan_status = 1 then 1 end) * 100.0 / count(*), 1) as taux_de_défaut
from loans
group by loan_intent
order by loan_intent;

-- réponse Par motif  : Les motifs les plus rentables sont VENTURE et EDUCATION — taux de défaut faibles (14.8% et 17.2%) pour un taux d'intérêt dans la moyenne. 
-- Les motifs les moins rentables sont DEBTCONSOLIDATION et MEDICAL — taux de défaut élevés (28.6% et 26.7%) sans compensation par un taux d'intérêt plus élevé.

-- Réponse Question 2 : 
--Les produits les plus rentables pour BankAlpha sont les prêts de grade A et B pour des motifs VENTURE et EDUCATION 
-- faible risque de défaut, montants raisonnables, taux d'intérêt dans la moyenne. 
-- Les produits à éviter sont les grades E, F, G pour des motifs DEBTCONSOLIDATION et MEDICAL.

--  à faire dans Power BI : croisement grade x motif

-- 3. Y a-t-il des signaux d'alerte détectables en amont ?

-- a) verifier si le client n'a pas un historique de défaut
select cb_person_default_on_file,
round(count(case when loan_status = 1 then 1 end ) * 100.0 / count (*), 1) as taux_de_défauts
from loans
group by cb_person_default_on_file
order by cb_person_default_on_file;
-- réponse : yes = 37,8% no = 18,4% donc il y a plus de client qui on un historique de défaut.
-- BankAlpha devra vérifier les clients avant la construction du dossier et appliquer des conditions plus strictes

-- b) Savoir le ratio de client qui emprunte un gros montant et qui ont du mal a rembourser
-- donc on va utiliser le ratio entre le montant emprunté et le revenu annuel du client
-- on va créer des tranche pour faciliter : Faible < 0,20, Moyen 0,20 et 0,40 et Élevé > 0,40
-- L'objectif c'est de vérifier : est-ce que les clients du groupe Élevé ont effectivement plus de défauts que ceux du groupe Faible
select 
case
	when loan_percent_income < 0.20 then 'faible'
	when loan_percent_income between 0.20 and 0.40 then 'moyen'
	else 'élevé'
	end as tranches,
round(count(case when loan_status = 1 then 1 end) * 100.0 / count (*), 1) as taux_de_défauts
from loans
group by tranches;
-- réponse : on remarque les clients qui emprunte un montant plus élévé ont du mal à rembouser = 74,2% de taux de défaut
-- donc BankAlpha doit refuser et ou limiter les prêts ou loan_percent_income qui dépasse 0,40