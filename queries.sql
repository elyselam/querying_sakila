USE sakila;


-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM  actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `Actor Name`
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name ASC, first_name ASC;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
    ADD middle_name VARCHAR(45);


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
    MODIFY COLUMN middle_name BLOB;


-- 3c. Now delete the middle_name column.
ALTER TABLE actor
    DROP COLUMN middle_name;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS multiples
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS multiples
FROM actor
GROUP BY last_name
    HAVING multiples > 1;


-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE actor_id = 172;


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = IF(first_name="HARPO", "GROUCHO", "MUCHO GROUCHO")
WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE address (
    address_id SMALLINT(4) AUTO_INCREMENT NOT NULL,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT(5) NOT NULL,
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (address_id)
);


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address, c.city, cy.country
FROM staff AS s
INNER JOIN address AS a
    ON s.address_id = a.address_id
INNER JOIN city AS c
    ON a.city_id = c.city_id
INNER JOIN country AS cy
    ON c.country_id = cy.country_id;



-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) AS total_rung_up
FROM payment AS p
INNER JOIN staff AS s
    ON p.staff_id = s.staff_id
WHERE p.payment_date >= '20050801' AND p.payment_date < '20050901'
GROUP BY s.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(f.title) AS num_actors
FROM film_actor AS fa
INNER JOIN film AS f
    ON fa.film_id = f.film_id
GROUP BY f.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(f.title) AS num_inventory
FROM film AS f
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible"
GROUP BY f.title;


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_paid
FROM payment AS p
INNER JOIN customer AS c
    ON p.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name, c.first_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE title LIKE "Q%" OR title LIKE "K%"
    AND language_id = (
        SELECT language_id
        FROM language
        WHERE name = 'English'
        );


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id = (
        SELECT film_id
        FROM film
        WHERE title =  "Alone Trip"
        )
    );


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email
FROM customer AS c
INNER JOIN address AS a
    ON c.address_id = a.address_id
INNER JOIN city AS cy
    ON a.city_id = cy.city_id
INNER JOIN country AS co
    ON cy.country_id = co.country_id
WHERE co.country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title
FROM film
WHERE film_id IN (

    SELECT film_id
    FROM film_category
    WHERE category_id = (

        SELECT category_id
        FROM category
        WHERE name = "Family"
        )
    );


-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(f.title) AS rent_count
FROM rental AS r
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
    ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY rent_count DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT a.address, cy.city, co.country, SUM(p.amount) AS total_revenue
FROM store AS s
INNER JOIN address AS a
    ON s.address_id = a.address_id
INNER JOIN customer AS c
    ON s.store_id=c.store_id
INNER JOIN payment AS p
    ON p.customer_id = c.customer_id
INNER JOIN city AS cy
    ON cy.city_id = a.city_id
INNER JOIN country AS co
    ON co.country_id = cy.country_id
GROUP BY a.address, cy.city, co.country;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, a.address, cy.city, co.country
FROM store AS s
INNER JOIN address AS a
    ON s.address_id = a.address_id
INNER JOIN city AS cy
    ON cy.city_id = a.city_id
INNER JOIN country AS co
    ON co.country_id = cy.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN inventory AS i
    ON fc.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
    ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5_genre_gross_revenue AS
SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN inventory AS i
    ON fc.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
    ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genre_gross_revenue;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top5_genre_gross_revenue;

