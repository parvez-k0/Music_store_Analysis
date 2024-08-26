
/* Q1: Who is the senior most employee based on job title? */

Select top 1 * from employee
order by levels desc;


/* Q2: Which countries have the most Invoices? */

Select top 1 billing_country, count(total) as most_invoices
from invoice
group by billing_country
order by most_invoices desc;


/* Q3: What are top 3 values of total invoice? */

Select top 3 total as top3_invoice
 from invoice
 order by top3_invoice desc;

 /* Q4: Which 5 cities has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

Select top 5 SUM(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/


Select top 1
cust.first_name,
cust.last_name,
SUM(inv.total) as total
from customer as cust inner join
invoice as inv on cust.customer_id=inv.customer_id
group by cust.customer_id,
cust.first_name,
cust.last_name
order by total desc;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


Select 
Distinct(cust.email) as Email,
cust.first_name as FirstName,
cust.last_name as LastName
from customer as cust inner join
invoice as inv on cust.customer_id=inv.customer_id
inner join invoice_line as invl on inv.invoice_id=invl.invoice_id
where track_id IN(
				Select track_id
				from track inner join
				genre on track.genre_id=genre.genre_id
				where genre.name like 'Rock'
				)
order by cust.email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


Select top 10 
artist.artist_id,
artist.name,
COUNT(artist.artist_id) as Number_ofsongs
from track inner join 
album on track.album_id=album.album_id
inner join artist on album.artist_id=artist.artist_id
inner join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id,
artist.name
order by Number_ofsongs desc;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

Select name,milliseconds
from track
where milliseconds >(
					Select AVG(milliseconds) as Avg_song_length
					)
order by milliseconds desc;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


WITH best_selling_artist AS(
							Select top 1 artist.artist_id as Artist_ID,
							artist.name as Artist_Name,
							SUM(il.unit_price*il.quantity) as Total_sales
							from track as tr inner join 
							invoice_line as il on tr.track_id=il.track_id
							inner join album as al on tr.album_id=al.album_id
							inner join artist on al.artist_id=artist.artist_id
							group by artist.name,
							artist.artist_id
							order by Total_sales desc
							)
Select
cust.customer_id,
cust.first_name,
cust.last_name,
bsa.Artist_Name,
SUM(invl.unit_price*invl.quantity) as amount_spent
from customer as cust
inner join invoice as inv on cust.customer_id=inv.customer_id
inner join invoice_line as invl on inv.invoice_id=invl.invoice_id
inner join track on invl.track_id=track.track_id
inner join album on track.album_id=album.album_id
inner join best_selling_artist as bsa on album.artist_id=bsa.Artist_ID
group by 
cust.customer_id,
cust.first_name,
cust.last_name,
bsa.Artist_Name
order by amount_spent desc;


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS(
					Select cust.country,gen.name, gen.genre_id, COUNT(inl.quantity) as Purchase,
					ROW_NUMBER() over (partition by cust.country order by COUNT(inl.quantity) DESC ) as Row_num
					from customer as cust
					inner join invoice as inv on cust.customer_id=inv.customer_id
					inner join invoice_line as inl on inv.invoice_id=inl.invoice_id
					inner join track as tr on inl.track_id=tr.track_id
					inner join genre as gen on tr.genre_id=gen.genre_id
					group by 
					cust.country,
					gen.name,
					gen.genre_id
					)
Select * from popular_genre
where Row_num=1;

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_spent_most AS(
							Select cust.customer_id, cust.first_name, cust.last_name, inv.billing_country as Country,
							SUM(total) as Total_spending,
							ROW_NUMBER() over (partition by inv.billing_country order by SUM(total) DESC) as RowNum
							from customer as cust
							inner join invoice as inv on cust.customer_id=inv.customer_id
							group by 
							cust.customer_id,
							cust.first_name,
							cust.last_name,
							inv.billing_country
							)
Select * from Customer_spent_most
where RowNum <=1
order by Country ASC;

