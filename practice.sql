/***
This is an exercise to improve my skills in writing SQL queries.

Skills applied:
- Filtering and sorting data
- Summarizing data
- Combining tables
- Writing subqueries
- Using window functions

***/


/*** Filtering and Sorting Data ***/

-- Find tracks that have a length of 5,000,000 milliseconds or more.
select trackid, milliseconds
from track
where milliseconds >=5000000;

-- Get the number of invoices whose total is between $5 and $15 dollars.
select count(invoiceid)
from invoice
where total between 5 and 15;

-- Show customers from the following States: RJ, DF, AB, BC, CA, WA, NY.
select firstname, lastname, company, state
from customer
where state in ('RJ', 'DF', 'AB', 'BC', 'CA', 'WA', 'NY');

-- Find tracks that starts with 'All'
select trackid, name
from track
where name like 'All%';

-- Get customer emails that start with 'J' and are from gmail.com.
select customerid, firstname, lastname, email
from customer
where email like 'J%gmail.com';

-- Find invoices from the billing city Brasília, Edmonton, and Vancouver
select *
from invoice
where billingcity in ('Brasilia', 'Edmonton', 'Vancouver');

-- Classify orders into high or low based on purchase amount, where at least 10 is considered high and less than 10 is low.
select invoiceid, total,
    case
        when total > 10 then 'High'
        else 'Low'
    end as total_category
from invoice;

-- Classify orders into high, medium or low based on purchase amount, where at least 10 is considered high, at least 5 but less 10 is medium, and less than 5 is low.
select invoiceid, total,
    case
        when total > 10 then 'High'
        when total > 5 and total <= 10 then 'Medium'
        when total <= 5 then 'Low'
        else 'Unknown'
    end as total_category
from invoice;

-- Classify tracks based on length, where at least 6 minutes is long, at least 4 mins but less than 6 minutes is mid, and less than 4 minutes is short.
select trackid, name, milliseconds/1000/60 as minutes,
    case
        when milliseconds/1000/60 >= 6 then 'Long'
        when milliseconds/1000/60 >= 4 then 'Mid length'
        when milliseconds/1000/60 < 4 then 'Short'
        else 'Unknown'
    end as length_category
from track;

-- Return the three longest tracks.
select trackid, name, milliseconds/1000/60 as minutes
from track
order by milliseconds desc
limit 3;

-- Sort the customers based on country in ascending order, but show Canada and USA first.
select customerid, firstname, lastname, country
from customer
order by
    (case country
         when 'Canada' then 1
         when 'USA' then 2
         else 3
     end), country;


/*** Summarizing Data ***/

-- Show the overall, average, maximum, and minimum purchase amount.
select sum(total) as overall,
    avg(total) as average,
    max(total) as maximum,
    min(total) as minimum
from invoice;

-- Count the total number of orders/invoices.
select count(*) as num_orders
from invoice;

-- Show the number of orders placed by each customer.
select customerid, count(*) as num_orders
from invoice
group by customerid
order by num_orders desc;

-- Count the number of tracks with composer listed.
select count(composer) as num
from track;

-- Count the number of tracks with missing composer.
select count(*) as num
from track
where composer is null;

-- Determine how long (in minutes) it takes to listen to all tracks that cost $1.99.
select sum(milliseconds/1000/60) as minutes
from track
where unitprice = 1.99;

-- Show the top five countries based on the number of invoices.
select billingcountry, count(*) as num_orders
from invoice
group by billingcountry
order by num_orders desc
limit 5;

-- Get the total number of orders and the average purchase amount in each US state.
select billingstate, count(*) as num_orders, avg(total) as avg_sale
from invoice
where billingcountry = 'USA'
group by billingstate;

-- Return the five best selling tracks based on the total purchase amount.
select trackid, count(*) as num_orders, sum(unitprice*quantity) as total_sales
from invoiceline
group by trackid
order by total_sales desc
limit 5;

-- Return the countries/states with more than 20 orders.
select billingcountry, billingstate, count(*) as num_orders, avg(total) as avg_sale
from invoice
group by billingcountry, billingstate
having count(*) > 20;

-- Get the states (not countries) with average purchase amount greated than $6.
select billingcountry, billingstate, avg(total) as avg_sale
from invoice
where billingstate is not null
group by billingcountry, billingstate
having avg(total) > 6;

-- Return albums with at least 12 tracks.
select albumid, count(*) as num_tracks
from track
group by albumid
having count(*) >= 12
order by num_tracks desc;


/*** Combining Tables ***/

-- Count the number of tracks of each genre.
select g.name, count(*) as num_tracks
from track t
join genre g on t.genreid = g.genreid
group by g.name
order by num_tracks desc;

-- Return the number of tracks and price of each album.
select a.albumid, a.title, count(t.trackid) as num_tracks, sum(t.unitprice) as price
from album a
join track t on a.albumid = t.albumid
group by a.albumid;

-- Show the managers of each employee.
select e1.employeeid, e1.firstname || ' ' || e1.lastname as employee, e2.firstname || ' ' || e2.lastname as manager
from employee e1, employee e2
where e1.reportsto = e2.employeeid;

select e1.employeeid, e1.firstname || ' ' || e1.lastname as employee, e2.firstname || ' ' || e2.lastname as manager
from employee e1
left join employee e2 on e1.reportsto = e2.employeeid;

-- Pair each customer with every other customer.
select c1.customerid, c1.firstname, c1.lastname, c2.customerid, c2.firstname, c2.lastname
from customer c1, customer c2
where c1.customerid <> c2.customerid;

select c1.customerid, c1.firstname, c1.lastname, c2.customerid, c2.firstname, c2.lastname
from customer c1
cross join customer c2
where c1.customerid != c2.customerid;

-- Count the number of times each song was purchased in 2013.
select t.trackid, t.name, count(*) as num_purchase
from track t
join invoiceline il on t.trackid = il.trackid
join invoice i on il.invoiceid = i.invoiceid
where i.invoicedate like '2013%'
group by t.trackid
order by num_purchase desc;

-- Show the running total of sales.
select i1.invoiceid, i1.invoicedate, i1.total, sum(i2.total) as running_total
from invoice i1
join invoice i2
on i1.invoiceid >= i2.invoiceid
group by i1.invoiceid, i1.invoicedate, i1.total;

-- Check if there are customers who have a different city listed as billing city.
select c.customerid, c.firstname, c.lastname, c.city, i.billingcity
from customer c, invoice i
where c.customerid = i.customerid and c.city != i.billingcity;


/*** Writing Subqueries ***/

-- Get the % share in the total sales of each country. 
select billingcountry, 100*sum(total)/(select sum(total) from invoice) as country_share
from invoice
group by billingcountry
order by country_share desc;

-- Identify the orders amounting to greater than 75% of the maximum purchase amount.
select *
from invoice
where total > (select max(total)*0.75 from invoice);

-- Identify the customers whose average purchase amount is higher than customer 5.
select customerid, avg(total)
from invoice
group by customerid
having avg(total) > (select avg(total) from invoice where customerid=5);

-- Return invoices where the customer's first name starts with A.
select *
from invoice
where customerid in (select customerid from customer where firstname like 'A%');

-- Get the title of all 'Led Zeppelin' albums.
select title
from album
where artistid in (select artistid from artist where name = 'Led Zeppelin')

-- Find all tracks for the album 'Californication'.
select name
from track
where albumid in (select albumid from album where title = 'Californication')

-- Display the first and last names of customers whose total purchase is less than $50.
select firstname, lastname
from customer
where customerid not in (select customerid
	from invoice
	group by customerid
	having sum(total) < 40);

-- Compute the average number of orders per country.
select avg(num_orders) as avg_num_order
from (select billingcountry, count(*) as num_orders
	from invoice
	group by billingcountry) i;

-- Return the first and last name of each customer and their average purchase amount.
select c.firstname, c.lastname, i.average
from customer c
join  (select customerid, avg(total) as average
	from invoice
	group by customerid) i
on c.customerid = i.customerid;

-- Get the average number of invoices per country per customer.
select i.billingcountry as country, i.invoice_count/ct.customer_count as avg_count_sale
from (select billingcountry, count(*) as invoice_count
	from invoice
	group by billingcountry) i
join (select country, count(*) as customer_count
	from customer
	group by country) ct
on i.billingcountry = ct.country
order by avg_count_sale desc;

-- Display all invoices where the total purchase amount is greater than the average pruchase amount in the same country.
select *
from invoice i1
where total > (select avg(total) 
	from invoice i2 
	where i1.billingcountry = i2.billingcountry);

-- Display tracks that have never been sold.
select *
from track t
where not exists (select *
	from invoiceline i
	where t.trackid = i.trackid);
    
select *
from track
where trackid not in (select distinct trackid
	from invoiceline);
	
-- Find artists who do not have albums.
select *
from artist at
where not exists (select * 
	from album ab where at.artistid = ab.artistid);

select *
from artist
where artistid not in (select distinct artistid 
	from album);

-- Display the first and last names of employees involved in transactions where the customers' total purchase is greater than $40.
select firstname, lastname
from employee
where employeeid in (select supportrepid
	from customer
	where customerid in (select customerid
		from invoice
		group by customerid
		having sum(total) > 40));
        
-- Get the invoices, their total purchase amount, and the total number of minutes of metal tracks purchased in the US.
select il.invoiceid, sum(il.unitprice*il.quantity) as total, sum(t.milliseconds)/1000/60 as minutes
from invoiceline il
join track t
on il.trackid = t.trackid
where t.genreid in (select genreid
	from genre
	where name like '%metal%')
and il.invoiceid in (select invoiceid 
	from invoice
	where billingcountry = 'USA')
group by il.invoiceid
order by il.invoiceid;

-- Use a CTE to get the first and last name of each customer and their average purchase amount..
with customer_avg as (
	select customerid, avg(total) as average
	from invoice
	group by customerid
)

select c.firstname, c.lastname, i.average
from customer c
join customer_avg as i
on c.customerid = i.customerid;

-- Use multiple CTEs to get the average purchase amount per country per customer.
with country_invoice_total as (
	select billingcountry, sum(total) as invoice_total
	from invoice
	group by billingcountry 
),
country_customer_count as (
	select country, count(*) as customer_count
    from customer
    group by country
)

select i.billingcountry, i.invoice_total/c.customer_count as avg_amt
from country_invoice_total i
join country_customer_count c
on i.billingcountry = c.country
order by avg_amt desc;

-- Use a recursive CTE to display the reporting line of each employee.
-- e.g. Andrew Adams <-- Nancy Edwards <-- Jane Peacock
with recursive managers (employeeid, line) as (
	select employeeid, firstname || ' ' || lastname as line
    from employee
    where reportsto is null
    
    union all
    
    select e.employeeid, m.line || ' <-- ' || e.firstname || ' ' || e.lastname as line
    from employee e
    join managers m
    on e.reportsto = m.employeeid
    where e.reportsto is not null 
)

select *
from managers;


/*** Using window functions ***/

-- Calculate the running total of sales.
select invoiceid, invoicedate, total, 
	sum(total) over (order by invoiceid) as running_total
from invoice;

-- Calculate the running total of sales by invoice id.
select invoicelineid, invoiceid, unitprice * quantity as amount,
	sum(unitprice * quantity) over (partition by invoiceid order by invoicelineid) as running_total_invoice
from invoiceline;

-- Create an identifier for each track purchased per invoice.
select invoiceid,
	row_number() over (partition by invoiceid order by invoicelineid) as order_line,
	trackid, unitprice * quantity as amount
from invoiceline;

-- Rank the customers based on their total spending. Customers with same spending should have the same rank.
select customerid, sum(total) as total_spending,
	rank() over (order by sum(total) desc) as ranking
from invoice
group by customerid;

select customerid, sum(total) as total_spending,
	dense_rank() over (order by sum(total) desc) as ranking
from invoice
group by customerid;

-- Get the daily sales increase/decrease.
select invoicedate, sum(total) as current_sales,
	sum(total) - lag(sum(total)) over (order by invoicedate) as diff
from invoice
group by invoicedate;