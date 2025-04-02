select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503



--1) Find the artist who has contributed with the maximum no of albums.
--Display the artist name and the no of albums.
SELECT AR.NAME, COUNT(A.albumid) AS ALBUMCOUNT
FROM ARTIST AR
JOIN ALBUM A ON A.ARTISTID = AR.ARTISTID
GROUP BY AR.ARTISTID
ORDER BY ALBUMCOUNT DESC
LIMIT 1


with temp as
    (select alb.artistid
    , count(1) as no_of_albums
    , rank() over(order by count(1) desc) as rnk
    from Album alb
    group by alb.artistid)
select art.name as artist_name, t.no_of_albums
from temp t
join artist art on art.artistid = t.artistid
where rnk = 1;*/


--2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.
SELECT  CONCAT(C.FIRSTNAME,C.LASTNAME) AS NAME,
	C.EMAIL,
	C.COUNTRY,
	G.name
FROM CUSTOMER C
JOIN INVOICE I ON C.CUSTOMERID = I.CUSTOMERID
JOIN INVOICELINE IL ON IL.INVOICEID = I.INVOICEID
JOIN TRACK T ON T.TRACKID = IL.TRACKID
JOIN GENRE G ON G.GENREID = T.GENREID
WHERE G.name in('Jazz','Rock','Pop')


select  (c.firstname||' '||c.lastname) as customer_name
, c.email, c.country, g.name as genre
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
join Invoice i on i.invoiceid = il.invoiceid
join customer c on c.customerid = i.customerid
where g.name in ('Jazz', 'Rock', 'Pop');*/

--3) Find the employee who has supported the most no of customers. Display the employee name and designation
with cte as 
		(select C.supportrepid,count(1) as Customercount 
		from Customer C
		Group by C.supportrepid
		order by Customercount desc
		limit 1)
select distinct CONCAT(E.firstname, ' ', E.lastName) as EmpName,E.title as Designation from Employee E
inner join customer C on C.supportrepid = E.employeeid
join cte ct on ct.supportrepid = E.employeeid
--where E.employeeid = 3


select employee_name, title as designation
from (
    select (e.firstname||' '||e.lastname) as employee_name, e.title
    , count(1) as no_of_customers
    , rank() over(order by count(1) desc) as rnk
    from Customer c
    join employee e on e.employeeid=c.supportrepid
    group by e.firstname,e.lastname, e.title) x
where x.rnk=1; */

--4) Which city corresponds to the best customers?
--TFQ sln
select I.billingcity,sum(total)as Total_purchase 
from invoice I
join Customer c on c.customerid = I.customerid
group by I.billingcity
order by Total_purchase desc
limit 1

with temp as
    (select city, sum(total) total_purchase_amt
    , rank() over(order by sum(total) desc) as rnk
    from Invoice i
    join Customer c on c.Customerid = i.Customerid
    group by city)
select city
from temp
where rnk=1;


--5) The highest number of invoices belongs to which country?

select * from invoice

select  billingcountry,total
from Invoice
group by billingcountry,total
order by total desc
limit 1

select billingcountry, Count(1) as number_invoices from Invoice
group by billingcountry
order by 2 desc
limit 1


select country
from (
    select billingcountry as country, count(1) as no_of_invoice
    , rank() over(order by count(1) desc) as rnk
    from Invoice
    group by billingcountry) x
where x.rnk=1;

--6) Name the best customer (customer who spent the most money).
--siva
select c.CustomerId,
c.FirstName,
c.LastName,
sum(inv.UnitPrice) as invoices
from Invoice i
join InvoiceLine inv
on inv.Invoiceid = i.Invoiceid
join customer c
on c.customerid = i.customerid
group by c.CustomerId,c.FirstName,c.LastName,i.total
order by i.total desc
limit 1

--devi

SELECT CONCAT(C.FIRSTNAME,C.LASTNAME)AS CUSTOMERNAME,
	SUM(TOTAL)AS TOTAL
	FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMERID = I.CUSTOMERID
GROUP BY C.CUSTOMERID
ORDER BY TOTAL DESC
LIMIT 1


select (c.firstname||' '||c.lastname) as customer_name
from (
    select customerid, sum(total) total_purchase
    , rank() over(order by sum(total) desc) as rnk
    from Invoice
    group by customerid) x
join customer c on c.customerid = x.customerid
where rnk=1;
--7) Suppose you want to host a rock concert in a city and want to know which location should host it.
--consider a city that has a highest sum of total
select * from Track
select billingcity,sum(total)as sum_of_total
from invoice
group by 1
order by 2 desc
limit 1

--sln 2

select I.billingcity,count(*)
from Track T
join Genre G on G.genreid = T.genreid
join InvoiceLine IL on IL.trackid = T.trackid
join Invoice I on I.invoiceid = IL.invoiceid
where G.name='Rock'
group by I.billingcity
order by 2 desc



select I.billingcity, count(1)
from Track T
join Genre G on G.genreid = T.genreid
join InvoiceLine IL on IL.trackid = T.trackid
join Invoice I on I.invoiceid = IL.invoiceid
where G.name = 'Rock'
group by I.billingcity
order by 2 desc;

/*13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
    [Reason: Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
    Lets invite the artists who have written the most rock music in our dataset.]*/
	select * from Artist
	
	SELECT A.NAME as Artist,
	SUM(LI.UNITPRICE) as Total_Sold
FROM INVOICELINE LI,
	TRACK T,
	ALBUM AL,
	ARTIST A
WHERE LI.TRACKID = T.TRACKID
	AND AL.ALBUMID = T.ALBUMID
	AND A.ARTISTID = AL.ARTISTID
GROUP BY A.NAME
ORDER BY COUNT(A.ARTISTID) DESC
LIMIT 5

WITH  popular_genre AS
                (
                  SELECT 
                      g.name as genre,
                      SUM(il.trackid) tracks_sold,
					rank() over(order by count(1) desc) as rnk
				       FROM genre g 
                  INNER JOIN track t ON g.genreid = t.genreid
                  INNER JOIN invoiceline il ON il.trackid = t.trackid
                  INNER JOIN invoice i ON i.invoiceid = il.invoiceid
                  GROUP BY g.name
				  --order by 2 desc
                ),
	 popular_artist as
			(SELECT AR.NAME as Artist_name, 
			 COUNT(A.albumid) AS ALBUMCOUNT,
			 rank() over(order by count(1) desc) as rnk
				FROM ARTIST AR
				JOIN ALBUM A ON A.ARTISTID = AR.ARTISTID
			 where g.name in (select genre from popular_genre)
				GROUP BY AR.ARTISTID
				--ORDER BY ALBUMCOUNT DESC
				)
select Artist_name,ALBUMCOUNT from popular_artist
where 


with most_popular_genre as
            (select name as genre
            from (select g.name
                , count(1) as no_of_purchases
                , rank() over(order by count(1) desc) as rnk
                from InvoiceLine il
                join track t on t.trackid = il.trackid
                join genre g on g.genreid = t.genreid
                group by g.name
                order by 2 desc) x
            where rnk = 1),
        all_data as
            (select art.name as artist_name, count(1) as no_of_songs
            , rank() over(order by count(1) desc) as rnk
            from track t
            join album al on al.albumid = t.albumid
            join artist art on art.artistid = al.artistid
            join genre g on g.genreid = t.genreid
            where g.name in (select genre from most_popular_genre)
            group by art.name
            order by 2 desc)
    select artist_name, no_of_songs
    from all_data
    where rnk <= 5;


--11) Which is the most popular and least popular genre?
select * from genre
WITH  popular_genre AS
                (
                  SELECT 
                      g.name,
                      SUM(il.trackid) tracks_sold
				       FROM genre g 
                  INNER JOIN track t ON g.genreid = t.genreid
                  INNER JOIN invoiceline il ON il.trackid = t.trackid
                  INNER JOIN invoice i ON i.invoiceid = il.invoiceid
                  GROUP BY g.name
				  order by tracks_sold desc
                )
SELECT * FROM popular_genre	
where tracks_sold = (SELECT MAX(tracks_sold) FROM popular_genre)
OR tracks_sold = (SELECT MIN(tracks_sold) FROM popular_genre)
				


with temp as
        (select distinct g.name
        , count(1) as no_of_purchases
        , rank() over(order by count(1) desc) as rnk
        from InvoiceLine il
        join track t on t.trackid = il.trackid
        join genre g on g.genreid = t.genreid
        group by g.name
        order by 2 desc),
    temp2 as
        (select max(rnk) as max_rnk from temp)
select name as genre
, case when rnk = 1 then 'Most Popular' else 'Least Popular' end as popular
from temp
cross join temp2
where rnk = 1 or rnk = max_rnk;

/* 8)Identify all the albums who have less then 5 track under them.
    Display the album name, artist name and the no of tracks in the respective album.*/
select * from Track 
select * from Album 
select* from Artist

SELECT Al.title as Albumname,Ar.name as Artistname, Count(*) AS N0_of_tracks
FROM Track T
join Album Al on T.Albumid = Al.Albumid
join Artist Ar on Al.Artistid = Ar.Artistid
GROUP BY Al.AlbumId,Ar.name
HAVING COUNT (*) <5
order by Al.title


select al.title as album_name, art.name as artist_name, count(1) as no_of_tracks
from album al
join track t on t.albumid = al.albumid
join artist art on art.artistid = al.artistid
group by al.title, art.name
having count(1) < 5
--9) Display the track, album, artist and the genre for all tracks which are not purchased.

select * from Track 
select * from Album 
select * from genre 
select* from Artist
select * from Invoice
select* from Invoiceline

select T.trackid,T.name,Al.albumid,Al.title,Ar.artistid,ar.name,g.name
from Track T
join Album Al on T.Albumid = Al.Albumid
join Artist Ar on Al.Artistid = Ar.Artistid
join genre g on T.genreid = g.genreid
WHERE NOT EXISTS (SELECT 1 FROM  Invoiceline Il WHERE T.Trackid = Il.Trackid)


select t.name as track_name, al.title as album_title, art.name as artist_name, g.name as genre
from Track t
join album al on al.albumid=t.albumid
join artist art on art.artistid = al.artistid
join genre g on g.genreid = t.genreid
where not exists (select 1
                 from InvoiceLine il
                 where il.trackid = t.trackid);

--10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.
	WITH cte as 
	(
		select Al.artistid
	from Track T
	join Album Al on T.Albumid = Al.Albumid
	GROUP BY Al.artistid 
	HAVING COUNT(DISTINCT genreid)>1
	)
	select DISTINCT ar.name,g.name
	from Track T
	join Album Al on T.Albumid = Al.Albumid
	join Artist Ar on Al.Artistid = Ar.Artistid
	join genre g on T.genreid = g.genreid
	join cte c on c.Artistid = Ar.Artistid
	ORDER BY ar.Name, g.Name


with temp as
        (select distinct art.name as artist_name, g.name as genre
        from Track t
        join album al on al.albumid=t.albumid
        join artist art on art.artistid = al.artistid
        join genre g on g.genreid = t.genreid
        order by 1,2),
    final_artist as
        (select artist_name
        from temp t
        group by artist_name
        having count(1) > 1)
select t.*
from temp t
join final_artist fa on fa.artist_name = t.artist_name
order by 1,2;

--12) Identify if there are tracks more expensive than others. If there are then
--display the track name along with the album title and artist name for these expensive tracks.

select * from Track 
select * from Album 
select * from genre 
select* from Artist
select * from Invoice
select* from Invoiceline

select T.trackid,T.name as Track_name,T.albumid,T.unitprice,*
from Track T
join Album Al on T.albumid = Al.albumid
join Artist Ar on Ar.artistid = Al.artistid
where T.unitprice>(select min(unitprice)as Expensive_tracks from Track )
group by T.unitprice


--14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.

select * from Track 
select * from Album 
select * from genre 
select* from Artist

select Ar.artistid,Ar.name,count(1) as no_of_songs,
rank()over(order by count(1) desc ) 
from Track T
join Album Al on T.albumid=Al.albumid
join Artist Ar on Al.artistid=Ar.artistid
group by Ar.artistid,Ar.name
limit 1



select name from (
    select ar.name,count(1)
    ,rank() over(order by count(1) desc) as rnk
    from Track t
    join album a on a.albumid = t.albumid
    join artist ar on ar.artistid = a.artistid
    group by ar.name
    order by 2 desc) x
where rnk = 1;

--15) Are there any albums owned by multiple artist?
     select Al.albumid,
	 Al.title as Albumname,
	 Ar.artistid,
	 count(*) as NUM_OF_ALBUM
	 from Album Al
	 join Artist Ar on Al.artistid=Ar.artistid
	 group by Ar.artistid,Al.albumid
	 order by Ar.artistid,Al.albumid
	 having COUNT(*) > 1
	 

select albumid, count(1) 
from Album 
group by albumid 
having count(1) > 1;

--16) Is there any invoice which is issued to a non existing customer?

select * 
from Invoice inv
join Customer c on inv.customerid = c.customerid
where not exists (select customerid from Customer
				 where c.customerid = inv.customerid)


select * from Invoice I
where not exists (select 1 from customer c 
                where c.customerid = I.customerid);


--17) Is there any invoice line for a non existing invoice?
select * 
from InvoiceLine IL
where not exists
	(select invoiceid 
	 from invoice inv)
	 where inv.invoiceid = IL.invoiceid )
	 
	 select * from InvoiceLine IL
where not exists (select 1 from Invoice I where I.invoiceid = IL.invoiceid);

--18) Are there albums without a title?

select * from Album
where title ='NULL'

--19) Are there invalid tracks in the playlist?
Select * from Track
select * from Playlist; -- 18
select * from PlaylistTrack; 

select * 
from Playlist pl
join PlaylistTrack plt on pl.playlistid = plt.playlistid
