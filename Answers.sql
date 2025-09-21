--1. Who is the senior most employee based on job title?
SELECT first_name,last_name,title
FROM employee
ORDER BY levels DESC
LIMIT 1;

--2. Which countries have the most Invoices? 
SELECT billing_country, COUNT(billing_country) AS order_count 
FROM invoice
GROUP BY billing_country
ORDER BY order_count DESC ;

--3. What are top 3 values of total invoice? 
SELECT total 
FROM invoice
ORDER BY total DESC;

/*4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */
SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/*5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spending
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spending DESC
LIMIT 1;


/*1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */
SELECT DISTINCT c.first_name,c.last_name,c.email, g.name AS Genre
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line li ON li.invoice_id = i.invoice_id
JOIN track t ON t.track_id = li.track_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email;

/*2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */
SELECT a.artist_id,a.name AS Arist_name,COUNT(a.artist_id) AS number_of_songs
From artist a
JOIN album al ON al.artist_id=a .artist_id
JOIN track t ON t.album_id=al.album_id
JOIN genre g ON g.genre_id=t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/*3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/
SELECT t.name,t.milliseconds
FROM track t
WHERE t.milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track
	)
ORDER BY t.milliseconds DESC;


/*1. Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */
WITH best_selling_artist AS(
	SELECT  a.artist_id,a.name AS artist_name,
	SUM(il.unit_price * il.quantity) AS total_sales
	FROM artist a
	JOIN album al ON al.artist_id=a.artist_id
	JOIN track t ON t.album_id=al.album_id
	JOIN invoice_line il ON il.track_id=t.track_id
	GROUP BY 1
	ORDER BY 3 DESC
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price * il.quantity) AS amount_spent
FROM customer c 
JOIN invoice i ON i.customer_id=c.customer_id
JOIN invoice_line il ON il.invoice_id=i.invoice_id
JOIN track t ON t.track_id=il.track_id
JOIN album al On al.album_id=t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id=al.artist_id
GROUP BY 1,4
ORDER BY 5 DESC;

/*2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */
WITH popular_genre AS (
	SELECT c.country,g.name AS genre,g.genre_id,
	COUNT(il.quantity) AS purchases,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
	FROM customer c
	JOIN invoice i ON i.customer_id=c.customer_id
	JOIN invoice_line il ON il.invoice_id=i.invoice_id
	JOIN track t ON t.track_id=il.track_id
	JOIN genre g ON g.genre_id=t.genre_id
	GROUP BY 1,2,3
	ORDER BY 1 ASC ,4 DESC
)
SELECT * FROM popular_genre 
WHERE RowNo <=1;

/*3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/
WITH Customter_with_country AS (
	SELECT c.customer_id,c.first_name,c.last_name,i.billing_country,
	SUM(i.total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS RowNo 
	from customer c
	JOIN invoice i ON i.customer_id=c.customer_id
	GROUP BY 1,4
	ORDER BY 4 ASC,5 DESC
)
SELECT * FROM Customter_with_country 
WHERE RowNo <= 1;

