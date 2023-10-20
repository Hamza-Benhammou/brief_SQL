--Tous les titres des films
SELECT title
FROM film;

--Nombre de films par catégories
SELECT category_id, COUNT(*) AS nombre_de_films_par_categorie
FROM film_category
GROUP BY category_id;

--Liste des films dont la durée est supérieure à 120 minutes
SELECT length, title 
FROM film 
WHERE length >= 120;

--Liste des films de catégorie "Action" ou "Comedy"
SELECT film_id, category_id
FROM film_category 
WHERE category_id = 1;

--Nombre total de films (définissez l'alias 'nombre de film' pour la valeur calculée)
SELECT SUM (language_id) AS nombre_de_films
FROM film;

--Les notes moyennes par catégorie
SELECT AVG (rental_rate), name
FROM film
JOIN film_category
ON film.film_id = film_category.film_id
JOIN category 
ON film_category.category_id = category.category_id
GROUP BY name;

--Liste des 10 films les plus loués. (SELECT, JOIN, GROUP BY, ORDER BY, LIMIT)
SELECT title, COUNT() AS nb
FROM film f 
JOIN inventory i 
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY nb DESC 
LIMIT 10;

--Acteurs ayant joué dans le plus grand nombre de films. (JOIN, GROUP BY, ORDER BY, LIMIT)
SELECT first_name, last_name, COUNT (film_id) AS acteurs_avec_le_plus_de_films
FROM film_actor 
JOIN actor 
ON film_actor.actor_id = actor.actor_id
GROUP BY film_actor.actor_id
ORDER BY acteurs_avec_le_plus_de_films DESC;

--Revenu total généré par mois
SELECT strftime ('%Y-%m', payment_date) AS mois, SUM (amount) AS revenu_total_par_mois
FROM payment
GROUP BY mois;

--Revenu total généré par chaque magasin par mois pour l'année 2005. (JOIN, SUM, GROUP BY, DATE functions)
SELECT strftime ('%Y-%m', payment_date) AS annee, SUM (amount) AS revenu_total_par_magasin_par_mois, store.store_id 
FROM payment 
JOIN customer 
ON payment.customer_id = customer.customer_id 
JOIN store 
ON customer.store_id = store.store_id
GROUP BY store.store_id;

--Les clients les plus fidèles, basés sur le nombre de locations. (SELECT, COUNT, GROUP BY, ORDER BY)
SELECT COUNT (rental.customer_id) AS nombre_de_locations, first_name, last_name AS nom_du_client
FROM rental  
JOIN customer 
ON rental.customer_id = customer.customer_id 
GROUP BY rental.customer_id;

--Films qui n'ont pas été loués au cours des 6 derniers mois. (LEFT JOIN, WHERE, DATE functions, Sub-query)
WITH date_6_mois_avant AS ( 
SELECT date(MAX(rental_date), '-6 months') AS value
FROM rental
), 
recent_rental AS (
SELECT *
FROM film
JOIN inventory
ON film.film_id = inventory.film_id 
JOIN rental
ON inventory.inventory_id = rental.inventory_id 
WHERE rental.rental_date > (SELECT value FROM date_6_mois_avant)
) 
SELECT film.title
FROM film
LEFT JOIN recent_rental
ON film.film_id = recent_rental.film_id
WHERE recent_rental.rental_date IS NULL

--Le revenu total de chaque membre du personnel à partir des locations. (JOIN, GROUP BY, ORDER BY, SUM)
SELECT SUM (payment.amount), staff.first_name, staff.last_name 
FROM payment  
JOIN rental 
ON payment.rental_id = rental.rental_id 
JOIN staff 
ON rental.staff_id = staff.staff_id 
GROUP BY rental.staff_id 
ORDER BY rental.staff_id DESC 

--Catégories de films les plus populaires parmi les clients. (JOIN, GROUP BY, ORDER BY, LIMIT)
SELECT category.name, COUNT() AS total
FROM category 
JOIN film_category
ON category.category_id = film_category.category_id 
JOIN film 
ON film_category.film_id = film.film_id 
JOIN inventory 
ON film.film_id = inventory.film_id 
JOIN rental
ON inventory.inventory_id = rental.inventory_id 
GROUP BY category.name
ORDER BY total DESC


--Durée moyenne entre la location d'un film et son retour. (SELECT, AVG, DATE functions)
SELECT AVG (JULIANDAY(return_date) - JULIANDAY(rental_date)) AS duree_moyenne_de_location
FROM rental
WHERE rental_date >= '2005-05-24' AND return_date <= '2006-02-14';


--Acteurs qui ont joué ensemble dans le plus grand nombre de films. Afficher l'acteur 1, l'acteur 2 et le nombre de films en commun. 
--Trier les résultats par ordre décroissant. Attention aux répétitons. (JOIN, GROUP BY, ORDER BY, Self-join)
SELECT actor_id, COUNT (film_id) AS nombre_de_films_joues_par_acteur
FROM film_actor 
GROUP BY actor_id
ORDER BY nombre_de_films_joues_par_acteur

WITH acteurs_qui_jouent_ensemble AS (
 SELECT fa1.actor_id AS acteur_1, fa2.actor_id AS acteur_2, COUNT(fa1.film_id) AS nombre_de_films_en_commun
 FROM film_actor fa1
 JOIN film_actor fa2
 ON fa1.film_id = fa2.film_id 
 WHERE fa1.actor_id < fa2.actor_id 
 GROUP BY acteur_1, acteur_2
 ORDER BY nombre_de_films_en_commun DESC 
 LIMIT 1
)
SELECT acteur_1, acteur_2, nombre_de_films_en_commun
FROM acteurs_qui_jouent_ensemble;


--Bonus : Clients qui ont loué des films mais n'ont pas fait au moins une location dans les 30 jours qui suivent. (JOIN, WHERE, DATE functions, Sub-query)
WITH derniere_location AS (
SELECT rental.customer_id, MAX(rental.rental_date) AS date_derniere_location
FROM rental 
GROUP BY rental.customer_id 
)
SELECT customer.first_name, customer.last_name 
FROM customer
INNER JOIN rental
ON customer.customer_id = rental.customer_id 
LEFT JOIN derniere_location ON customer.customer_id = derniere_location.customer_id
WHERE rental.rental_date <= DATE('now', '-30 days')
 AND (derniere_location.date_derniere_location IS NULL
 OR rental.rental_date > DATE(derniere_location.date_derniere_location, '+30 days'));

--Refaite la même question pour un interval de 15 jours pour le mois d'août 2005.
WITH derniere_location AS (
SELECT rental.customer_id, MAX(rental.rental_date) AS date_derniere_location
FROM rental 
GROUP BY rental.customer_id 
)
SELECT customer.first_name, customer.last_name 
FROM customer
INNER JOIN rental
ON customer.customer_id = rental.customer_id 
LEFT JOIN derniere_location ON customer.customer_id = derniere_location.customer_id
WHERE rental.rental_date <= DATE('2005-08-31', '-15 days')
 AND (derniere_location.date_derniere_location IS NULL
 OR rental.rental_date > DATE(derniere_location.date_derniere_location, '+15 days'));


INSERT INTO film (title, release_year, length) VALUES ('Sunset Odyssey', '2023', '125')
INSERT INTO film_category (category_id) VALUES ('7')



