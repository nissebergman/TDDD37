/*
Lab 1 report <Nisse Bergman, nisbe033. Jacob Molin, jacmo699>
*/

/* All non code should be within SQL-comments like this */ 

/*
Drop all user created tables that have been created when solving the lab
*/

DROP TABLE IF EXISTS custom_table CASCADE;

/* Have the source scripts in the file so it is easy to recreate!*/

/*
SOURCE company_schema.sql;
SOURCE company_data.sql;
*/

/*
1) List all employees, i.e. all tuples in the jbemployee relation.
*/
SELECT *
FROM jbemployee;

/* 1)
id	name	salary	manager	birthyear	startyear
10	Ross, Stanley	15908	199	1927	1945
11	Ross, Stuart	12067	NULL	1931	1932
13	Edwards, Peter	9000	199	1928	1958
26	Thompson, Bob	13000	199	1930	1970
32	Smythe, Carol	9050	199	1929	1967
33	Hayes, Evelyn	10100	199	1931	1963
35	Evans, Michael	5000	32	1952	1974
37	Raveen, Lemont	11985	26	1950	1974
55	James, Mary	12000	199	1920	1969
98	Williams, Judy	9000	199	1935	1969
129	Thomas, Tom	10000	199	1941	1962
157	Jones, Tim	12000	199	1940	1960
199	Bullock, J.D.	27000	NULL	1920	1920
215	Collins, Joanne	7000	10	1950	1971
430	Brunet, Paul C.	17674	129	1938	1959
843	Schmidt, Herman	11204	26	1936	1956
994	Iwano, Masahiro	15641	129	1944	1970
1110	Smith, Paul	6000	33	1952	1973
1330	Onstad, Richard	8779	13	1952	1971
1523	Zugnoni, Arthur A.	19868	129	1928	1949
1639	Choy, Wanda	11160	55	1947	1970
2398	Wallace, Maggie J.	7880	26	1940	1959
4901	Bailey, Chas M.	8377	32	1956	1975
5119	Bono, Sonny	13621	55	1939	1963
5219	Schwarz, Jason B.	13374	33	1944	1959

*/ 

/*
2) List the name of all departments in alphabetical order. Note: by “name” we mean
the name attribute for all tuples in the jbdept relation
*/

SELECT * 
FROM jbdept ORDER BY name;

/* 2)
id	name	store	floor	manager
1	Bargain	5	0	37
35	Book	5	1	55
10	Candy	5	1	13
73	Children's	5	1	10
43	Children's	8	2	32
19	Furniture	7	4	26
99	Giftwrap	5	1	98
14	Jewelry	8	1	33
47	Junior Miss	7	2	129
65	Junior's	7	3	37
26	Linens	7	3	157
20	Major Appliances	7	4	26
58	Men's	7	2	129
60	Sportswear	5	1	10
34	Stationary	5	1	33
49	Toys	8	2	35
63	Women's	7	3	32
70	Women's	5	1	10
28	Women's	8	2	32

*/ 

/* 3) What parts are not in store, i.e. qoh = 0? (qoh = Quantity On Hand) */

SELECT *
FROM jbparts WHERE qoh = 0;

/* 3)
id	name	color	weight	qoh
11	card reader	gray	327	0
12	card punch	gray	427	0
13	paper tape reader	black	107	0
14	paper tape punch	black	147	0

*/ 

/* 4) Which employees have a salary between 9000 (included) and 10000 (included)? */

SELECT *
FROM jbemployee WHERE salary >= 9000 AND salary <= 10000;

/* 4)
id	name	salary	manager	birthyear	startyear
13	Edwards, Peter	9000	199	1928	1958
32	Smythe, Carol	9050	199	1929	1967
98	Williams, Judy	9000	199	1935	1969
129	Thomas, Tom	10000	199	1941	1962
*/ 

/* 5) What was the age of each employee when they started working (startyear)? */

SELECT id, name, (startyear-birthyear) AS "age started working"
FROM jbemployee;

/* 5)
id	name	age started working
10	Ross, Stanley	18
11	Ross, Stuart	1
13	Edwards, Peter	30
26	Thompson, Bob	40
32	Smythe, Carol	38
33	Hayes, Evelyn	32
35	Evans, Michael	22
37	Raveen, Lemont	24
55	James, Mary	49
98	Williams, Judy	34
129	Thomas, Tom	21
157	Jones, Tim	20
199	Bullock, J.D.	0
215	Collins, Joanne	21
430	Brunet, Paul C.	21
843	Schmidt, Herman	20
994	Iwano, Masahiro	26
1110	Smith, Paul	21
1330	Onstad, Richard	19
1523	Zugnoni, Arthur A.	21
1639	Choy, Wanda	23
2398	Wallace, Maggie J.	19
4901	Bailey, Chas M.	19
5119	Bono, Sonny	24
5219	Schwarz, Jason B.	15
*/

/* 6) Which employees have a last name ending with “son”? 
			QUESTION
*/ 
SELECT * 
FROM jbemployee WHERE substring_index(name, ',', 1) LIKE '%son';

/* 6)
id	name	salary	manager	birthyear	startyear
26	Thompson, Bob	13000	199	1930	1970

*/ 

/* 7) Which items (note items, not parts) have been delivered by a supplier called
Fisher-Price? Formulate this query using a subquery in the where-clause. */ 


SELECT name
FROM jbitem WHERE supplier = (SELECT id FROM jbsupplier WHERE name = 'Fisher-Price');


/* 7)
name
Maze
The 'Feel' Book
Squeeze Ball
*/ 

/* 8) Formulate the same query as above, but without a subquery. */ 

SELECT jbitem.name
FROM jbitem, jbsupplier WHERE jbsupplier.name = 'Fisher-Price' AND jbitem.supplier = jbsupplier.id;


/* 9) Show all cities that have suppliers located in them. Formulate this query using a
subquery in the where-clause. */ 

SELECT jbcity.name
FROM jbcity WHERE jbcity.id IN (SELECT city FROM jbsupplier);


/* 10) What is the name and color of the parts that are heavier than a card reader?
Formulate this query using a subquery in the where-clause. (The SQL query must
not contain the weight as a constant.)
*/

SELECT name, color
FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name = 'card reader');

/*11) Formulate the same query as above, but without a subquery. (The query must not
contain the weight as a constant.)
/*
AS INNER JOIN

SELECT E.name, E.color
FROM jbparts E INNER JOIN jbparts S
	ON (E.weight > S.weight AND S.name = 'card reader')
*/

/* AS SELF-JOIN */
SELECT A.name, A.color
FROM jbparts A, jbparts B WHERE A.weight > B.weight AND B.name = 'card reader';

/* 12) What is the average weight of black parts? */

SELECT AVG(weight) FROM jbparts
WHERE color = 'black';


/* 13) What is the total weight of all parts that each supplier in Massachusetts (“Mass”)
has delivered? Retrieve the name and the total weight for each of these suppliers.
Do not forget to take the quantity of delivered parts into account. Note that one
row should be returned for each supplier. 
*/

SELECT jbsupplier.name, SUM(jbparts.weight * jbsupply.quan) AS 'Total Weight'
FROM jbsupply JOIN jbparts ON jbsupply.part = jbparts.id
JOIN jbsupplier ON jbsupplier.id = jbsupply.supplier
WHERE jbsupplier.city IN (SELECT jbcity.id FROM jbcity WHERE jbcity.state = 'Mass')
GROUP BY jbsupplier.name;


/* 14) Create a new relation (a table), with the same attributes as the table items using
the CREATE TABLE syntax where you define every attribute explicitly (i.e. not
as a copy of another table). Then fill the table with all items that cost less than the
average price for items. Remember to define primary and foreign keys in your
table!
*/

DROP TABLE IF EXISTS jbitem_new CASCADE;

CREATE TABLE jbitem_new (
	id integer,
	name varchar(20),
	dept int not null,
    price int,
    qoh int unsigned,
    supplier int not null,
	constraint pk_item primary key (id),
    constraint fk_item_new_dept foreign key (dept) references jbdept(id),
    constraint fk_item_new_supplier foreign key (supplier) references jbsupplier(id));


SELECT AVG(price)
FROM jbitem;

INSERT INTO jbitem_new 
(SELECT *
 FROM jbitem
 WHERE price < (SELECT AVG(price) 
				FROM jbitem));
/*
SELECT *
FROM jbitem_new
*/


/*
15) Create a view that contains the items that cost less than the average price for
items. 
*/

/*

CREATE VIEW jbitem_view AS
	SELECT *
	FROM jbitem
	WHERE price < (SELECT AVG(price) 
				FROM jbitem)
                */
DROP VIEW IF EXISTS jbitem_view CASCADE;

CREATE VIEW jbitem_view AS
	SELECT *
	FROM jbitem_new;
  
SELECT *
FROM jbitem_view;
/*
UPDATE jbitem_new SET name = 'test' WHERE id = 11;

SELECT *
FROM jbitem_view;

SELECT *
FROM jbitem_new;
*/

/*
16) What is the difference between a table and a view? One is static and the other is
dynamic. Which is which and what do we mean by static respectively dynamic?

	- A view cannot be manipulated directly and independently, 
	only through the corresponding table

	- Views are dynamic because the values are updated depending 
	on what is updated in the corresponding table.
*/

/*
17) Create a view that calculates the total cost of each debit, by considering price and
quantity of each bought item. (To be used for charging customer accounts). The
view should contain the sale identifier (debit) and total cost. Use only the implicit
join notation, i.e. only use a where clause but not the keywords inner join, right
join or left join,
*/
DROP VIEW IF EXISTS totaldebit_view CASCADE;

CREATE VIEW totaldebit_view AS
	SELECT jbdebit.id AS 'debit_id', SUM(jbitem.price * jbsale.quantity) AS 'tot_cost'
	FROM jbsale, jbitem, jbdebit
    WHERE jbsale.item = jbitem.id
	AND jbsale.debit = jbdebit.id
	AND jbsale.item IN (SELECT jbitem.id FROM jbitem)
	GROUP BY jbdebit.id;
    
SELECT *
FROM totaldebit_view;

/*
18) Do the same as in (17), using only the explicit join notation, i.e. using only left,
right or inner joins but no join condition in a where clause. Motivate why you use
the join you do (left, right or inner), and why this is the correct one (unlike the
others).
*/

/* 
	ANSWER: 
	We use INNER JOIN because we want to use the 
    attributes that overlap between two tables. 
    With left/right join we add an entire table
    to either the left/right table, setting unshared
    values to NULL.
*/


DROP VIEW IF EXISTS totaldebit_view CASCADE;

CREATE VIEW totaldebit_view AS
	SELECT jbdebit.id AS 'debit_id', SUM(jbitem.price * jbsale.quantity) AS 'tot_cost'
	FROM jbsale INNER JOIN jbitem ON jbsale.item = jbitem.id
	INNER JOIN jbdebit ON jbsale.debit = jbdebit.id
	WHERE jbsale.item IN (SELECT jbitem.id FROM jbitem)
	GROUP BY jbdebit.id;
    
SELECT *
FROM totaldebit_view;


/*
19) Oh no! An earthquake!
a) Remove all suppliers in Los Angeles from the table jbsupplier. This will not
work right away (you will receive error code 23000) which you will have to
solve by deleting some other related tuples. However, do not delete more
tuples from other tables than necessary and do not change the structure of the
tables, i.e. do not remove foreign keys. Also, remember that you are only
allowed to use “Los Angeles” as a constant in your queries, not “199” or
“900”.
*/

/* Delete all sales from jbsale that have items which are supplied from a Los Angeles supplier */
DELETE FROM jbsale WHERE jbsale.item IN
	(SELECT jbitem.id FROM jbitem WHERE jbitem.supplier IN 
	(SELECT jbsupplier.id FROM jbsupplier WHERE jbsupplier.city = 
	(SELECT jbcity.id FROM jbcity WHERE jbcity.name = 'Los Angeles')));

/* Delete all items from jbitem that are supplied from a Los Angeles supplier */
DELETE FROM jbitem WHERE jbitem.supplier IN
	(SELECT jbsupplier.id FROM jbsupplier WHERE jbsupplier.city = 
	(SELECT jbcity.id FROM jbcity WHERE jbcity.name = 'Los Angeles'));

/* Delete all items from jbitem_new that are supplied from a Los Angeles supplier */    
DELETE FROM jbitem_new WHERE jbitem_new.supplier IN
	(SELECT jbsupplier.id FROM jbsupplier WHERE jbsupplier.city = 
	(SELECT jbcity.id FROM jbcity WHERE jbcity.name = 'Los Angeles'));

/* Delete all suppliers from jbsupplier that are located in Los Angeles */    
DELETE FROM jbsupplier WHERE jbsupplier.city = (SELECT jbcity.id FROM jbcity WHERE jbcity.name = 'Los Angeles');

SELECT *
FROM jbsupplier;

/*
b) Explain what you did and why.
	To be remove all Los Angeles suppliers, we must remove all
	rows with foreign keys that on some level depend on Los Angeles 
	suppliers.
      
	We do this by first deleting the sales in jbsales that contain 
    items from a Los Angeles supplier. Next we delete all items in 
    jbitem and jbitem_new that come from a Los Angeles supplier.
    Lastly we can delete all suppliers from Los Angeles.

*/

/*
20) An employee has tried to find out which suppliers that have delivered items that
have been sold. He has created a view and a query that shows the number of items
sold from a supplier.
mysql> CREATE VIEW jbsale_supply(supplier, item, quantity) AS
 -> SELECT jbsupplier.name, jbitem.name, jbsale.quantity
 -> FROM jbsupplier, jbitem, jbsale
 -> WHERE jbsupplier.id = jbitem.supplier
 -> AND jbsale.item = jbitem.id;
Query OK, 0 rows affected (0.01 sec)
mysql> SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
 -> GROUP BY supplier;
+--------------+---------------+
| supplier | sum(quantity) |
+--------------+---------------+
| Cannon | 6 |
| Levi-Strauss | 1 |
| Playskool | 2 |
| White Stag | 4 |
| Whitman's | 2 |
+--------------+---------------+
5 rows in set (0.00 sec)
11
The employee would also like include the suppliers which has delivered some 
items, although for whom no items have been sold so far. In other words he wants
to list all suppliers, which has supplied any item, as well as the number of these
items that have been sold. Help him! Drop and redefine jbsale_supply to
consider suppliers that have delivered items that have never been sold as well.
Hint: The above definition of jbsale_supply uses an (implicit) inner join that
removes suppliers that have not had any of their delivered items sold.*/

DROP VIEW IF EXISTS jbsale_supply CASCADE;


CREATE VIEW jbsale_supply(supplier, item, quantity) AS
	SELECT jbsupplier.name, jbitem.name , jbsale.quantity
	FROM jbsupplier
	LEFT JOIN jbitem ON jbsupplier.id = jbitem.supplier
    LEFT JOIN jbsale ON jbitem.id = jbsale.item
	AND jbsale.item = jbitem.id;

SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
GROUP BY supplier;