USE sakila;

-- =========================================================
-- 1) Number of copies of the film "Hunchback Impossible" in inventory
-- =========================================================
SELECT
  f.title,
  COUNT(i.inventory_id) AS number_of_copies
FROM film f
JOIN inventory i
  ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.film_id, f.title;


-- =========================================================
-- 2) Films longer than the average length of all films
-- =========================================================
SELECT
  title,
  length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC, title ASC;


-- =========================================================
-- 3) Actors who appear in the film "Alone Trip" 
-- =========================================================
SELECT
  a.actor_id,
  a.first_name,
  a.last_name
FROM actor a
WHERE a.actor_id IN (
  SELECT fa.actor_id
  FROM film_actor fa
  WHERE fa.film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
  )
)
ORDER BY a.last_name, a.first_name;


-- =========================================================
-- BONUS
-- =========================================================

-- 4) Identify all movies categorized as family films
SELECT
  f.film_id,
  f.title
FROM film f
WHERE f.film_id IN (
  SELECT fc.film_id
  FROM film_category fc
  WHERE fc.category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'Family'
  )
)
ORDER BY f.title;


-- 5) Name + email of customers from Canada using both joins and a subquery
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
  c.email
FROM customer c
JOIN address a
  ON c.address_id = a.address_id
JOIN city ci
  ON a.city_id = ci.city_id
WHERE ci.country_id = (
  SELECT country_id
  FROM country
  WHERE country = 'Canada'
)
ORDER BY c.last_name, c.first_name;


-- 6) Films starred by the most prolific actor (actor in the most films)
-- Step A: find most prolific actor_id
-- Step B: list films for that actor_id
SELECT
  f.film_id,
  f.title
FROM film f
JOIN film_actor fa
  ON f.film_id = fa.film_id
WHERE fa.actor_id = (
  SELECT fa2.actor_id
  FROM film_actor fa2
  GROUP BY fa2.actor_id
  ORDER BY COUNT(*) DESC
  LIMIT 1
)
ORDER BY f.title;


-- 7) Films rented by the most profitable customer (largest SUM(payment.amount))
-- Step A: find customer_id with max total payments
-- Step B: list distinct films they rented
SELECT DISTINCT
  f.film_id,
  f.title
FROM film f
JOIN inventory i
  ON f.film_id = i.film_id
JOIN rental r
  ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (
  SELECT p.customer_id
  FROM payment p
  GROUP BY p.customer_id
  ORDER BY SUM(p.amount) DESC
  LIMIT 1
)
ORDER BY f.title;


-- 8) client_id and total_amount_spent for clients who spent more than the average spent per client
-- Step A: totals per client
-- Step B: filter totals > average of those totals
SELECT
  client_totals.customer_id AS client_id,
  client_totals.total_amount_spent
FROM (
  SELECT
    customer_id,
    SUM(amount) AS total_amount_spent
  FROM payment
  GROUP BY customer_id
) AS client_totals
WHERE client_totals.total_amount_spent > (
  SELECT AVG(t.total_amount_spent)
  FROM (
    SELECT
      customer_id,
      SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
  ) AS t
)
ORDER BY client_totals.total_amount_spent DESC, client_totals.customer_id ASC;
