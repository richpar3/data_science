/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name, membercost
    FROM country_club.Facilities
    WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) as no_fee_facilities_count
    FROM country_club.Facilities
    WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid,
		name as facilityname,
		membercost, 
		monthlymaintenance
  FROM country_club.Facilities
 WHERE membercost > 0
	AND membercost < (monthlymaintenance * .20)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
	FROM (SELECT * 
            FROM country_club.Facilities 
            WHERE facid = 1) as a
UNION ALL
SELECT * 
	FROM (SELECT * 
            FROM country_club.Facilities 
            WHERE facid = 5) as b

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, 
		monthlymaintenance,
		CASE WHEN monthlymaintenance > 100 THEN 'expensive'
		ELSE 'cheap' END as cheap_or_expensive
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate
	FROM country_club.Members
	WHERE joindate = (SELECT MAX(joindate)
                      	FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. 
1. Get all facid's for tennis courts
2. Get all bookings that contain these id's. Get the bookid, facid, and memid
3. Join the Facilities and Members Tables to the last query to get the names of the members and facilities
*/

SELECT DISTINCT (CONCAT (c.firstname, ' - ', b.name)) as output
	FROM (SELECT bookid, facid, memid
			FROM country_club.Bookings
			WHERE facid in (SELECT facid
								FROM country_club.Facilities
								WHERE lower(name) like 'tennis court%')) as a
	INNER JOIN country_club.Facilities as b on a.facid = b.facid
	INNER JOIN country_club.Members as c on c.memid = a.memid
	ORDER BY output

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. 

Notes:
    - Facility costs are per slot
    - User can reserve more than one slot at a time
    - User can go to club at multiple times in a day
*/
SELECT CONCAT (firstname, ' - ', name) as output,
		CASE WHEN Book.memid = 0 THEN guestcost * slots
			 WHEN membercost = 0 THEN 0
			 ELSE membercost * slots END as total_booking_cost, 
		slots,
		membercost, 
		guestcost, 
		starttime
	FROM country_club.Bookings as Book
	INNER JOIN country_club.Facilities as Facil on Facil.facid = Book.facid
	INNER JOIN country_club.Members as Mem on Mem.memid = Book.memid
	WHERE starttime like '2012-09-14%'
		AND (CASE WHEN Book.memid = 0 THEN guestcost * slots
			 WHEN membercost = 0 THEN 0
			 ELSE membercost * slots END) > 30
	GROUP BY output
	ORDER BY output


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT output,
		total_booking_cost,
		slots,
		membercost, 
		guestcost, 
		starttime
  FROM (SELECT Book.slots, Facil.membercost, Facil.guestcost, Book.starttime, Mem.firstname, Facil.name,
            CONCAT (firstname, ' - ', name) as output,
        	CASE WHEN Book.memid = 0 THEN guestcost * slots
			 	 WHEN membercost = 0 THEN 0
			 	 ELSE membercost * slots END as total_booking_cost
          FROM country_club.Bookings as Book
       	 INNER JOIN country_club.Facilities as Facil on Facil.facid = Book.facid
	   	 INNER JOIN country_club.Members as Mem on Mem.memid = Book.memid) a
 WHERE starttime like '2012-09-14%'
	AND total_booking_cost > 30
 GROUP BY output
 ORDER BY output

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name,
		SUM(total_booking_cost) as total_revenue
  FROM (SELECT Facil.name,
     		    CASE WHEN Book.memid = 0 THEN guestcost * slots
	 			     WHEN membercost = 0 THEN 0
	 			     ELSE membercost * slots END as total_booking_cost
      	  FROM country_club.Bookings as Book
         INNER JOIN country_club.Facilities as Facil on Facil.facid = Book.facid
	     INNER JOIN country_club.Members as Mem on Mem.memid = Book.memid) a
  GROUP BY name
    HAVING sum(total_booking_cost) < 1000 
  ORDER BY total_revenue DESC
