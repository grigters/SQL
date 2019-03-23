#Specify the Database to use
USE sakila;

#Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

#Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT UPPER(CONCAT(first_name, ' ' ,last_name)) as 'Actor Name' FROM actor;

#You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name FROM actor
where first_name = 'Joe';

#Find all actors whose last name contain the letters GEN
SELECT first_name, last_name FROM actor
where last_name like '%gen%';

#Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT first_name, last_name FROM actor
where last_name like '%li%'
order by last_name, first_name;

#Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM Country
Where country IN ('Afghanistan', 'Bangladesh', 'China');

#create a column in the table actor named description and use the data type BLOB
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_update`;

#Delete the description column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `description`;

#List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as count FROM actor
group by last_name;

#List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as count FROM actor
group by last_name
having count > 1;

#The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE sakila.actor SET first_name = 'HARPO' WHERE actor_id = 172;

#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE sakila.actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';

#locate the schema of the address table
SHOW CREATE TABLE actor;

#statement to recreate table
CREATE TABLE `actor` (
  `actor_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`actor_id`),
  KEY `idx_actor_last_name` (`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8;

#Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT first_name, last_name, address FROM staff s
JOIN address a ON
s.address_id = a.address_id;

#Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
select s.staff_id, first_name, last_name, sum(p.amount) 'total amount' from staff s
join payment p on
s.staff_id = p.staff_id
where p.payment_date > '2005-08-01' and p.payment_date < '2005-09-01'
group by s.staff_id;

#List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title,  count(actor_id) 'number of actors' FROM film_actor a
inner join film f on 
a.film_id = f.film_id
group by title;

#How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(f.film_id) 'Copies' from film f
join inventory i on
f.film_id = i.film_id
where title like '%hunchback imp%'
group by title;

#Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
select first_name, last_name, sum(amount) 'total paid' from payment p
join customer c on
p.customer_id = c.customer_id
group by p.customer_id
order by last_name;

#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film
where (title like 'Q%' or title like 'K%') and language_id in (
select language_id from language where language_id = 1);

#Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name from actor where actor_id in (
select actor_id from film_actor where film_id in (
select film_id from film where title like '%Alone%'));

#You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
select first_name, last_name, email from customer where address_id in (
select address_id from address where city_id in(
select city_id from city where country_id in (
select country_id from country where country = 'Canada')));

#Identify all movies categorized as family films (using subqueries)
select title from film where film_id in (
select film_id from film_category where category_id in (
select category_id from category where name = 'Family'));

#Identify all movies categorized as family films (using joins)
select title from film f
join film_category fc on
f.film_id = fc.film_id
join category c on
fc.category_id = c.category_id
where name = 'Family';

#Display the most frequently rented movies in descending order.
select title, count(f.film_id) 'most freq. rented movies' from film f
join inventory i on
f.film_id = i.film_id
join rental r on
i.inventory_id = r.inventory_id
group by f.film_id
order by count(f.film_id) desc;

#Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) from store s
join customer c on 
s.store_id = c.store_id
join payment p on
c.customer_id = p.customer_id
group by s.store_id;

#Write a query to display for each store its store ID, city, and country
#my store table only has 2 store_ids, so I had to do a right join to display stores without an id
select store_id, city, country from store s
right join address a on
s.address_id = a.address_id
join city c on
a.city_id = c.city_id
join country co on
c.country_id = co.country_id
order by store_id desc;

#List the top five genres in gross revenue in descending order.
select name, sum(amount) 'gross revenue' from category c
join film_category fc on 
c.category_id = fc.category_id
join film f on
fc.film_id = f.film_id
join inventory i on
f.film_id = i.film_id
join rental r on
i.inventory_id = r.inventory_id
join payment p on
r.rental_id = p.rental_id
group by name
order by sum(amount) desc
limit 5;

#create a view
CREATE VIEW top_5_genres AS
select name, sum(amount) 'gross revenue' from category c
join film_category fc on 
c.category_id = fc.category_id
join film f on
fc.film_id = f.film_id
join inventory i on
f.film_id = i.film_id
join rental r on
i.inventory_id = r.inventory_id
join payment p on
r.rental_id = p.rental_id
group by name
order by sum(amount) desc
limit 5;

#How would you display the view that you created
use sakila;
SELECT * FROM top_5_genres;

#You find that you no longer need the view top_five_genres. Write a query to delete it.
use sakila;
DROP VIEW top_5_genres;
