-- DROPPING --
DROP TABLE IF EXISTS reservation_contact CASCADE;
DROP TABLE IF EXISTS passenger_reservation CASCADE;
DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS contact CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS flight CASCADE;
DROP TABLE IF EXISTS weeklyschedule CASCADE;
DROP TABLE IF EXISTS weekday CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS year CASCADE;
DROP TABLE IF EXISTS airport CASCADE;

DROP VIEW IF EXISTS allFlights CASCADE;

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;

DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

-- TABLES --
CREATE TABLE airport
   (airportcode VARCHAR(3),
    airportname VARCHAR(30),
    country VARCHAR(30),
    CONSTRAINT pk_airport PRIMARY KEY(airportcode)) ENGINE=InnoDB;
    
CREATE TABLE year
	(year INTEGER,
	profitfactor DOUBLE,
    CONSTRAINT pk_year PRIMARY KEY(year)) ENGINE=InnoDB;

CREATE TABLE route
	(departure VARCHAR(3),
    arrival VARCHAR(3),
    year INTEGER,
    routeprice DOUBLE,
    CONSTRAINT pk_route PRIMARY KEY(departure, arrival, year)) ENGINE=InnoDB;
    
CREATE TABLE weekday
	(year INTEGER,
    day VARCHAR(10),
    weekdayfactor DOUBLE,
    CONSTRAINT pk_weekday PRIMARY KEY(day, year)) ENGINE=InnoDB;

CREATE TABLE weeklyschedule
	(id INT NOT NULL AUTO_INCREMENT,
    departure VARCHAR(3),
	arrival VARCHAR(3),
    year INTEGER,
    weekday VARCHAR(10),
	departuretime TIME,
    CONSTRAINT pk_weeklyschedule PRIMARY KEY(id)) ENGINE=InnoDB;
    
CREATE TABLE flight
	(id INT NOT NULL AUTO_INCREMENT,
    weeknr INTEGER,
    weeklyscheduleid INTEGER,
    CONSTRAINT pk_flight PRIMARY KEY(id)) ENGINE=InnoDB;

CREATE TABLE passenger
	(passportnumber INTEGER,
    name VARCHAR(30),
    CONSTRAINT pk_passenger PRIMARY KEY(passportnumber)) ENGINE=InnoDB;
    
CREATE TABLE payment
	(id INT NOT NULL AUTO_INCREMENT,
    cc_holder VARCHAR(30),
    cc_number BIGINT,
    CONSTRAINT pk_payment PRIMARY KEY(id)) ENGINE=InnoDB;
    
CREATE TABLE reservation
	(reservationnumber INTEGER,
    flightid INTEGER,
    number_of_passengers INTEGER,
    CONSTRAINT pk_reservation PRIMARY KEY(reservationnumber)) ENGINE=InnoDB;
    
CREATE TABLE booking
	(reservationnumber INTEGER,
    price DOUBLE,
    paymentid INTEGER,
    CONSTRAINT pk_booking PRIMARY KEY(reservationnumber)) ENGINE=InnoDB;

CREATE TABLE ticket
	(ticketnr INT AUTO_INCREMENT,
    reservationnumber INTEGER,
    passportnumber INTEGER,
    CONSTRAINT pk_ticket PRIMARY KEY(ticketnr)) ENGINE=InnoDB;

CREATE TABLE contact
	(passportnumber INTEGER,
    phone BIGINT,
    email VARCHAR(30),
    CONSTRAINT pk_contact PRIMARY KEY(passportnumber)) ENGINE=InnoDB;
    
CREATE TABLE passenger_reservation
	(passportnumber INTEGER,
    reservationnumber INTEGER,
    CONSTRAINT pk_passportnumber PRIMARY KEY(passportnumber, reservationnumber)) ENGINE=InnoDB;
    
CREATE TABLE reservation_contact
	(reservationnumber INTEGER,
    contact INTEGER,
    CONSTRAINT pk_passbook PRIMARY KEY(reservationnumber)) ENGINE=InnoDB;

   
-- FOREIGN KEYS --
ALTER TABLE route ADD CONSTRAINT fk_route_arrival FOREIGN KEY (arrival) REFERENCES airport(airportcode) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE route ADD CONSTRAINT fk_route_departure FOREIGN KEY (departure) REFERENCES airport(airportcode) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE route ADD CONSTRAINT fk_route_year FOREIGN KEY (year) REFERENCES year(year) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE weekday ADD CONSTRAINT fk_weekday_year FOREIGN KEY (year) REFERENCES year(year) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE weeklyschedule ADD CONSTRAINT fk_weeklyschedule_arrival FOREIGN KEY (arrival) REFERENCES route(arrival) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE weeklyschedule ADD CONSTRAINT fk_weeklyschedule_departure FOREIGN KEY (departure) REFERENCES route(departure) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE weeklyschedule ADD CONSTRAINT fk_weeklyschedule_year FOREIGN KEY (year) REFERENCES weekday(year) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE weeklyschedule ADD CONSTRAINT fk_weeklyschedule_weekday FOREIGN KEY (weekday) REFERENCES weekday(day) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE flight ADD CONSTRAINT fk_flight_weeklyscheduleid FOREIGN KEY (weeklyscheduleid) REFERENCES weeklyschedule(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE reservation ADD CONSTRAINT fk_reservation_flightid FOREIGN KEY (flightid) REFERENCES flight(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE booking ADD CONSTRAINT fk_booking_reservationnumber FOREIGN KEY (reservationnumber) REFERENCES reservation(reservationnumber) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE booking ADD CONSTRAINT fk_booking_paymentid FOREIGN KEY (paymentid) REFERENCES payment(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE contact ADD CONSTRAINT fk_contact_passportnumber FOREIGN KEY (passportnumber) REFERENCES passenger(passportnumber) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE passenger_reservation ADD CONSTRAINT fk_passenger_reservation_passportnumber FOREIGN KEY (passportnumber) REFERENCES passenger(passportnumber) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE passenger_reservation ADD CONSTRAINT fk_passenger_reservation_reservationnumber FOREIGN KEY (reservationnumber) REFERENCES reservation(reservationnumber) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE reservation_contact ADD CONSTRAINT fk_reservation_contact_contact FOREIGN KEY (contact) REFERENCES contact(passportnumber) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE reservation_contact ADD CONSTRAINT fk_reservation_contact_reservationnumber FOREIGN KEY (reservationnumber) REFERENCES reservation(reservationnumber) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ticket ADD CONSTRAINT fk_ticket_reservationnumber FOREIGN KEY (reservationnumber) REFERENCES booking(reservationnumber) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ticket ADD CONSTRAINT fk_ticket_passportnumber FOREIGN KEY (passportnumber) REFERENCES passenger(passportnumber) ON UPDATE CASCADE ON DELETE CASCADE;


-- PROCEDURES AND HELP FUNCTIONS --
delimiter //
CREATE PROCEDURE addYear(IN year INT, IN factor DOUBLE)
BEGIN
	INSERT INTO year VALUES (year, factor);
END;

CREATE PROCEDURE addDay(IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
	INSERT INTO weekday VALUES (year, day, factor);
END;

CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
	INSERT INTO airport VALUES (airport_code, name, country);
END;


CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN routeprice DOUBLE)
BEGIN
	INSERT INTO route VALUES (departure_airport_code, arrival_airport_code, year, routeprice);
END;


CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
	DECLARE w INT;
	SET w = 1;
	INSERT INTO weeklyschedule VALUES (NULL, departure_airport_code, arrival_airport_code, year, day, departure_time);

	WHILE w <= 52 DO
		INSERT INTO flight VALUES (NULL, w, (SELECT MAX(id) FROM weeklyschedule)); -- LAST_INSERT_ID()
		SET w = w + 1;
	END WHILE;
END;


CREATE FUNCTION calculateFreeSeats(flightnumber INT)
RETURNS INT
BEGIN
	DECLARE n INT;

	SELECT SUM(number_of_passengers) INTO n 
	FROM reservation AS r1 WHERE reservationnumber IN
					(SELECT reservationnumber FROM booking WHERE reservationnumber IN 
					(SELECT reservationnumber 
					FROM reservation AS r2 WHERE flightid = flightnumber));

	IF n IS NULL THEN
		SET n = 0;
	END IF;

	RETURN (40-n);
END;


CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN week INT, IN day VARCHAR(10), IN departure_time TIME,
	IN number_of_passengers INT, OUT output_reservation_number INT)
BEGIN
	DECLARE reservationnumber INT;
	DECLARE fid INT;
    
	SELECT id INTO fid
	FROM flight
	WHERE weeknr = week AND weeklyscheduleid = (
		SELECT id
		FROM weeklyschedule
		WHERE departure = departure_airport_code AND arrival = arrival_airport_code
		AND year = year AND weekday = day AND departuretime = departure_time);
    
	IF (fid IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There exist no flight for the given route, date and time';
	END IF;
    
	IF (calculateFreeSeats(fid) >= number_of_passengers) THEN
		SET reservationnumber = 1000*rand();
		INSERT INTO reservation VALUES(reservationnumber, fid, number_of_passengers);
		SELECT reservationnumber INTO output_reservation_number;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough seats available on the chosen flight';
	END IF;
END;


CREATE PROCEDURE addPassenger(IN reservation_nr INT, IN passport_number INT, IN name VARCHAR(30))
BEGIN
	
    IF EXISTS (SELECT reservationnumber FROM booking WHERE reservationnumber = reservation_nr)
    THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The booking has already been payed and no further passengers can be added';
	END IF;

	IF NOT EXISTS (SELECT passportnumber FROM passenger WHERE passportnumber = passport_number)
	THEN
		INSERT INTO passenger VALUES(passport_number, name);
	END IF;

	IF NOT EXISTS (SELECT reservationnumber FROM reservation WHERE reservationnumber = reservation_nr) 
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The given reservation number does not exist';
	ELSE
		INSERT INTO passenger_reservation VALUES(passport_number, reservation_nr);
	END IF;
END;


CREATE PROCEDURE addContact(IN reservation_nr INT, IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN

	IF NOT EXISTS (SELECT reservationnumber FROM reservation WHERE reservationnumber = reservation_nr)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The given reservation number does not exist';
	END IF;

	IF NOT EXISTS (SELECT passportnumber FROM passenger_reservation WHERE passportnumber = passport_number AND reservationnumber = reservation_nr)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The person is not a passenger of the reservation';
	END IF;

	IF NOT EXISTS (SELECT passportnumber FROM contact WHERE passportnumber = passport_number)
	THEN
		INSERT INTO contact VALUES(passport_number, phone, email);
	END IF;
		INSERT INTO reservation_contact VALUES(reservation_nr, passport_number);
END;


CREATE PROCEDURE addPayment(IN reservation_nr INT, IN cardholder_name VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
	DECLARE c INT;
	DECLARE freeSeats INT;
	DECLARE nrPass INT;
	DECLARE price INT;
	DECLARE k INT;
	DECLARE i INT;
    
	IF NOT EXISTS (SELECT reservation_nr FROM reservation WHERE reservationnumber = reservation_nr) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The given reservation number does not exist';
	END IF;

	IF NOT EXISTS (SELECT reservation_nr FROM reservation_contact WHERE reservationnumber = reservation_nr) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The reservation has no contact yet';
	END IF;

	-- Check number of passengers on reservation
	-- SELECT number_of_passengers INTO nrPass FROM reservation WHERE reservationnumber = reservation_nr;
	SELECT COUNT(*) INTO nrPass FROM passenger_reservation WHERE reservationnumber = reservation_nr;
	
    -- Check number of free seats on flight
    SET freeSeats = calculateFreeSeats((SELECT flightid FROM reservation WHERE reservationnumber = reservation_nr));
    
    IF (nrPass <= freeSeats) THEN
		SET price = nrPass * calculatePrice((SELECT flightid FROM reservation WHERE reservationnumber = reservation_nr));
        
        -- SELECT sleep(5); #Sleeping to make overbookings possible
		
        INSERT INTO payment VALUES (NULL, cardholder_name, credit_card_number);
        INSERT INTO booking VALUES(reservation_nr, price, LAST_INSERT_ID()); -- (SELECT MAX(id) FROM payment)
        
		INSERT INTO ticket (reservationnumber, passportnumber)
		SELECT reservationnumber, passportnumber 
		FROM passenger_reservation WHERE reservationnumber = reservation_nr;
	ELSE
		DELETE FROM reservation WHERE reservationnumber = reservation_nr;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough seats available on the flight anymore, deleting reservation';
	END IF;
END;


CREATE FUNCTION calculatePrice(flightnumber INT)
RETURNS DOUBLE
BEGIN
	DECLARE wid INT;
	DECLARE y INT;
	DECLARE r DOUBLE;
	DECLARE wf DOUBLE;
	DECLARE booked INT;
	DECLARE pf DOUBLE;

	SELECT weeklyscheduleid INTO wid FROM flight WHERE id = flightnumber;
 	SELECT year INTO y FROM weeklyschedule WHERE id = wid;

 	SELECT routeprice INTO r
 	FROM route WHERE year = y AND (departure, arrival) IN 
 			(SELECT departure, arrival
 			 FROM weeklyschedule WHERE id = wid);
 									
	SELECT weekdayfactor INTO wf
	FROM weekday WHERE year = y AND day IN 
			(SELECT weekday
			 FROM weeklyschedule WHERE id = wid);

	SET booked = 40 - calculateFreeSeats(flightnumber);
         
	SELECT profitfactor INTO pf
	FROM year WHERE year = y;

	RETURN ROUND((r * wf * (booked + 1) / 40 * pf), 3);
END;

-- TRIGGER --
CREATE TRIGGER CreateTicketNr
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
	DECLARE t INT;
    SET t = 10000*rand();
    
    WHILE ((SELECT ticketnr FROM ticket WHERE ticketnr = t)) DO
    SET t = 10000*rand();
    END WHILE;
    SET NEW.ticketnr = t;
END;
//
delimiter ;
   
-- VIEW --
CREATE VIEW allFlights AS
	SELECT a1.airportname AS 'departure_city_name', a2.airportname AS 'destination_city_name', 
		ws.departuretime AS 'departure_time', ws.weekday AS 'departure_day',
		f.weeknr AS 'departure_week', ws.year AS 'departure_year', 
		calculateFreeSeats(f.id) AS 'nr_of_free_seats', calculatePrice(f.id) AS 'current_price_per_seat'
    FROM airport AS a1, airport AS a2, weeklyschedule AS ws, flight AS f
    WHERE a1.airportcode = ws.departure
    AND a2.airportcode = ws.arrival
    AND ws.id = f.weeklyscheduleid;

    
# ANSWERS LAB 4
-- ## 8
-- a) How can you protect the credit card information in the database from hackers? 

-- 		- You can protect the CC info by encrypting the information and/or password protect access to the database

-- b) Give three advantages of using stored procedures in the database (and thereby execute them on the server) 
-- 	  instead of writing the same functions in the front-end of the system (in for example java-script on a web-page)? 

-- 		- The procedures are all contained on the server and therefore you only need to change them in one location if needed. 
-- 		- You get better security as the stored procedures can ensure that statements gets executed in the correct way. 
-- 		- One statement can trigger several statements inside the procedure, making for simpler, more efficient queries.


-- ## 9
-- b) Is this reservation visible in session B? Why? Why not?

-- 		- No, because when working with transactions you have 
-- 		  to commit the transaction for it to actually be written to the database.

-- c) What happens if you try to modify the reservation from A in B? Explain what 
-- 	happens and why this happens and how this relates to the concept of isolation of transactions.

-- 		- Session B keeps waiting for session A to commit the changes to the table reservation before it 
-- 		  tries to make any changes to the same table. Since the transaction in session A never commits this
-- 		  will go on until there's a session time out. This happens because transactions are considered
-- 		  atomic and isolated from eachother.


-- ## 10
-- a) Did overbooking occur when the scripts were executed? If so, why? If not, why not?

-- 		- No, but overreservation did. It's because the number of available seats on the 
-- 		  plane is checked first when trying to make a payment.

-- b) Can an overbooking theoretically occur? If an overbooking is possible, in what 
-- 	  order must the lines of code in your procedures/functions be executed.

-- 		- Yes, if session B calls the function 'calculateFreeSeats()' before session A adds
-- 		  it's new booking to the booking-table.

-- c) Try to make the theoretical case occur in reality by simulating that multiple sessions 
-- 	  call the procedure at the same time. To specify the order in which the lines of code are 
-- 	  executed use the MySQL query SELECT sleep(5); which makes the session sleep for 5 seconds.
-- 	  Note that it is not always possible to make the theoretical case occur, if not, motivate why.

-- 		- By inserting SELECT sleep(5); after 'calculateFreeSeats()' but before the payment and 
-- 		  booking occurs, we are able to overbook.

-- d) Modify the testscripts so that overbookings are no longer possible using (some of) the commands 
-- 	  START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK TABLES, ROLLBACK, SAVEPOINT, and SELECT...FOR UPDATE. 
-- 	  Motivate why your solution solves the issue, and test that this also is the case using the sleep 
-- 	  implemented in 10c. Note that it is not ok that one of the sessions ends up in a deadlock scenario. 
--    Also, try to hold locks on the common resources for as short time as possible to allow multiple 
-- 	  sessions to be active at the same time.

-- 		- We wrap all the calls to the database in one transaction. We add locks to all the tables that 
--  	  are accessed in 'addPayment()' or in some way are affected by calling 'addPayment()'. 
-- 		  We lock the tables just before calling 'addPayment()' and unlock them right after. 
-- 		  We use Write locks only on the tables that we need write access to and read locks on the 
-- 		  tables we only need reading access to. The calls 'addReservation()', 'addPassanger()' and 
-- 		  'addContact()' have no need for tables to be locked, since it's internally set up in a way that 
-- 		  duplicates cannot be added to the tables.



-- ---------------- SECONDARY INDEX ----------------

-- We chose to do a secondary index design on the passenger relation. If the airline has many passengers
-- many of them will probably have the same name. We use a secondary index with the field Name and a 
-- pointer to the block that contains the corresponing row. The secondary index is sorted on Name and 
-- this leads to us being able to use binary search to more efficiently find the correct row in the relation.