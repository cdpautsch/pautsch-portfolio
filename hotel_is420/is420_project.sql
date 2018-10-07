/* Christian Pautsch, IS 420, Group Project, Excerpt */

/* 11 - Change a Reservation Date */

/*
	Input the reservation ID and change reservation start and end date, if there is availability in the same room type for the new date interval
*/

CREATE OR REPLACE FUNCTION changeReservationDate
	(r_id IN reservations.reservation_id%type,
	r_start_date IN reservations.reservation_start_date%type,
	r_end_date IN reservations.reservation_end_date%type)
RETURN BOOLEAN
IS
	r_made_date reservations.reservation_made_date%type;
	r_status reservations.reservation_status%type;
	r_rate reservations.reservation_rate%type;
	h_id hotels.hotel_id%type;
	
	CURSOR room_cursor_var IS
		SELECT rm.room_id AS rm_id FROM rooms rm, reserved_rooms rr, reservations r
		WHERE r.reservation_id = r_id
		AND r.reservation_id = rr.reservation_id
		AND rr.room_id = rm.room_id;
		
	room_row_var room_cursor_var%rowtype;
	found_room_count NUMBER(2);
	
	rooms_not_available EXCEPTION;
	invalid_update_data EXCEPTION;
BEGIN
	-- Creates savepoint
	SAVEPOINT update_reservation_date_sp;
	
	-- Finds out when the reservation was originally made
	-- Finds out which hotel they're staying at
	-- Finds out the current status of the reservation
	SELECT DISTINCT h.hotel_id, r.reservation_made_date, r.reservation_status INTO h_id, r_made_date, r_status
	FROM hotels h, rooms rm, reserved_rooms rr, reservations r
	WHERE h.hotel_id = rm.hotel_id
	AND rm.room_id = rr.room_id
	AND rr.reservation_id = r.reservation_id
	AND r.reservation_id = r_id;
	
	-- Checks that dates aren't out of order
	IF (r_start_date > r_end_date) THEN
		RAISE invalid_update_data;
	END IF;
	
	-- Checks that reservation isn't cancelled or already checked in
	IF r_status != 'Reserved' THEN
		RAISE invalid_update_data;
	END IF;
	
	-- Recalculates rate
	r_rate := getRoomRate(r_made_date, r_start_date);
	
	-- Checks if getRoomRate threw an exception
	IF (r_rate = -1) THEN
		RAISE invalid_update_data;
	END IF;
	
	-- If there are multiple rooms associated with the reservation, each one must be checked
	-- Finds each room_id, and then checks if it is free on the given date
	FOR room_row_var IN room_cursor_var
	LOOP
		-- For the current room, looks to see if any other reservations occupy the room in the target date range
		SELECT COUNT(*) INTO found_room_count
		FROM rooms rm, reserved_rooms rr, reservations r
			WHERE ((r.reservation_end_date > r_start_date
			AND r.reservation_end_date <= r_end_date)
			OR (r.reservation_start_date < r_end_date
			AND r.reservation_start_date >= r_start_date))
			AND NOT r.reservation_id = r_id
			AND NOT r.reservation_status = 'Cancelled'
			AND NOT r.reservation_status = 'Checked-out'
			AND r.reservation_id = rr.reservation_id
			AND rr.room_id = rm.room_id
			AND rm.hotel_id = h_id
			AND rm.room_id = room_row_var.rm_id;
		
		-- If the room is occupied in the target range, the count will be nonzero
		-- In this case, an exception is raised
		IF (found_room_count != 0) THEN
			RAISE rooms_not_available;
		END IF;
	END LOOP;
	
	-- Updates reservation
	UPDATE reservations
	SET
		reservation_rate = r_rate,
		reservation_start_date = r_start_date,
		reservation_end_date = r_end_date
	WHERE reservation_id = r_id;
	
	COMMIT;
	
	-- indicates to calling problem that report was successful
	RETURN TRUE;
EXCEPTION
	WHEN invalid_update_data THEN
		-- bad parameter data
		DBMS_OUTPUT.PUT_LINE('There was a problem with the data supplied.');
		ROLLBACK TO SAVEPOINT update_reservation_date_sp;
		RETURN FALSE;
	WHEN rooms_not_available THEN
		-- the rooms are reserved at the requested date
		DBMS_OUTPUT.PUT_LINE('There is insufficient availability for the new dates.');
		ROLLBACK TO SAVEPOINT update_reservation_date_sp;
		RETURN FALSE;
	WHEN OTHERS THEN
		-- catch-all exception handler
		ROLLBACK TO SAVEPOINT update_reservation_date_sp;
		RETURN FALSE;
END;


-- Shows reservation before
SELECT reservation_id, reservation_start_date, reservation_end_date
FROM reservations
WHERE reservation_id = 118;

-- Tests Function
SET SERVEROUTPUT ON;

BEGIN
	IF (changeReservationDate(118, '17-JUL-18', '23-JUL-18')) THEN
		DBMS_OUTPUT.PUT_LINE('The reservation was updated successfully.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('The reservation was NOT updated successfully.');
	END IF;
END;

-- Shows reservation after
SELECT reservation_id, reservation_start_date, reservation_end_date
FROM reservations
WHERE reservation_id = 118;


-- utility function
CREATE OR REPLACE FUNCTION getRoomRate (
	reservation_made_date DATE,
	reservation_start_date DATE)
RETURN reservations.reservation_rate%type
IS
	monthNumber NUMBER(2);
	calculatedRate reservations.reservation_rate%type;
BEGIN
	monthNumber := EXTRACT(month FROM reservation_start_date);
	
	IF ((monthNumber >= 5) AND (monthNumber <= 8)) THEN
		calculatedRate := 300.00;
	ELSE
		calculatedRate := 200.00;
	END IF;
	
	IF (MONTHS_BETWEEN(reservation_start_date,reservation_made_date) >= 2) THEN
		calculatedRate := calculatedRate * 0.90;
	END IF;
	
	RETURN calculatedRate;
EXCEPTION
	WHEN OTHERS THEN
		RETURN -1;
END;



/* 12 - Change a reservation room type */

/*
	Input the reservation ID and change reservation room type if there is availability for that room type during the reservation’s date interval
*/

CREATE OR REPLACE FUNCTION changeReservationRoomType (
	r_id reservations.reservation_id%type,
	rm_type rooms.room_type%type)
RETURN BOOLEAN
IS
	h_id hotels.hotel_id%type;
	start_date reservations.reservation_start_date%type;
	end_date reservations.reservation_end_date%type;
	r_status reservations.reservation_status%type;
	
	guests_per_room NUMBER(2);
	
	CURSOR room_cursor_var IS
		SELECT rm.room_id AS old_rm_id
		FROM rooms rm, reserved_rooms rr, reservations r
		WHERE r.reservation_id = r_id
		AND r.reservation_id = rr.reservation_id
		AND rr.room_id = rm.room_id;
		
	room_row_var room_cursor_var%rowtype;
	new_rm_id rooms.room_id%type;
	
	reservation_found BOOLEAN;
	invalid_update_data EXCEPTION;
	reservation_status_wrong EXCEPTION;
BEGIN
	-- Creates savepoint
	SAVEPOINT update_res_room_type_sp;
	
	-- initializes variable for indicating stage of execution
	reservation_found := FALSE;
	
	-- check that type is valid
	IF NOT (validateRoomType(rm_type)) THEN
		RAISE invalid_update_data;
	END IF;
	
	-- Finds hotel, start date, end date, status, guest count
	-- This also confirms that the reservation ID is valid
	SELECT DISTINCT h.hotel_id, r.reservation_start_date, r.reservation_end_date, r.reservation_status INTO h_id, start_date, end_date, r_status
	FROM hotels h, rooms rm, reserved_rooms rr, reservations r
	WHERE r.reservation_id = r_id
	AND r.reservation_id = rr.reservation_id
	AND rr.room_id = rm.room_id
	AND rm.hotel_id = h.hotel_id;
	
	-- finds average number of guests per room (rounded up)
	guests_per_room := getGuestsPerRoom(r_id);
	
	-- raises exception fi guests_per_room had an issue
	IF (guests_per_room = -1) THEN
		RAISE invalid_update_data;
	END IF;
	
	-- If the program reaches this point without exception, it marks that the reservation was successfully located
	reservation_found := TRUE;
	
	-- Checks that reservation isn't cancelled or already checked in
	IF r_status = 'Cancelled' OR r_status = 'Checked-Out' THEN
		RAISE reservation_status_wrong;
	END IF;
	
	-- Goes through every room in reservation
	FOR room_row_var IN room_cursor_var
	LOOP
		
		-- Finds the first available room 1) of the selected type 2) at that hotel 3) with enough guest capacity and 4) where that room is NOT:
			-- belonging to a not-cancelled reservation in the same date range
			-- belonging to the same hotel
			-- belonging to the same reservation (e.g. not already reserved for this reservation)
		SELECT room_id
			INTO new_rm_id
			FROM rooms
			WHERE hotel_id = h_id
			AND room_type = rm_type
			AND room_max_guests >= guests_per_room
			AND ROWNUM = 1
			AND room_id NOT IN (
				SELECT rm.room_id
				FROM rooms rm, reserved_rooms rr, reservations r
				WHERE rm.room_id = rr.room_id
				AND rr.reservation_id = r.reservation_id
				AND NOT r.reservation_status = 'Cancelled'
				AND rm.hotel_id = h_id
				AND rm.room_type = rm_type
				AND ((r.reservation_start_date < end_date
				OR r.reservation_end_date > start_date)
				OR (r.reservation_id = r_id)));
		
		-- updates the correct reserved rooms
		UPDATE reserved_rooms
			SET room_id = new_rm_id
			WHERE reservation_id = r_id
			AND room_id = room_row_var.old_rm_id;
	END LOOP;
	
	COMMIT;
	
	-- indicates to calling problem that report was successful
	RETURN TRUE;
EXCEPTION
	WHEN invalid_update_data THEN
		-- bad input information
		DBMS_OUTPUT.PUT_LINE('There was a problem with the data supplied.');
		ROLLBACK TO SAVEPOINT update_res_room_type_sp;
		RETURN FALSE;
	WHEN reservation_status_wrong THEN
		-- reservation is cancelled
		DBMS_OUTPUT.PUT_LINE('The reservation is cancelled or has already checked out.');
		ROLLBACK TO SAVEPOINT update_res_room_type_sp;
		RETURN FALSE;
	WHEN no_data_found THEN
		-- this exception may be called at two different points
		-- the exception prints out a different message by referencing a boolean value triggered at a particular point in the function
		IF (reservation_found) THEN
			DBMS_OUTPUT.PUT_LINE('There is insufficient availability for the requested room type.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('There was an error. Please check your reservation ID.');
		END IF;
		ROLLBACK TO SAVEPOINT update_res_room_type_sp;
		RETURN FALSE;
	WHEN OTHERS THEN
		-- catch-all exception
		DBMS_OUTPUT.PUT_LINE('There was an unspecified error. Please try again.');
		ROLLBACK TO SAVEPOINT update_res_room_type_sp;
		RETURN FALSE;
END;

-- Test function

SELECT r.reservation_id AS reservation_id, rm.room_id AS room_id, rm.hotel_id AS hotel_id, rm.room_type AS room_type
FROM reservations r, reserved_rooms rr, rooms rm
WHERE r.reservation_id = rr.reservation_id
AND rr.room_id = rm.room_id
AND r.reservation_id = 114;

BEGIN
	IF (changeReservationRoomType(114,'Suite')) THEN
        DBMS_OUTPUT.PUT_LINE('Good!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Bad!');
    END IF;
END;

SELECT r.reservation_id AS reservation_id, rm.room_id AS room_id, rm.hotel_id AS hotel_id, rm.room_type AS room_type
FROM reservations r, reserved_rooms rr, rooms rm
WHERE r.reservation_id = rr.reservation_id
AND rr.room_id = rm.room_id
AND r.reservation_id = 114;



-- utility function
CREATE OR REPLACE FUNCTION validateRoomType (
	check_type rooms.room_type%type)
RETURN BOOLEAN
IS
	type_valid BOOLEAN;
BEGIN
	type_valid := FALSE;
	
	IF (check_type = 'Conference' OR check_type = 'Suite' OR check_type = 'Double' OR check_type = 'Single') THEN
		type_valid := TRUE;
	END IF;
	
	RETURN type_valid;
EXCEPTION
	WHEN OTHERS THEN
		RETURN FALSE;
END;


-- utility function
CREATE OR REPLACE FUNCTION getGuestsPerRoom (
	r_id reservations.reservation_id%type)
RETURN NUMBER
IS
	guests_per_room NUMBER(3);
	total_guests NUMBER(3);
	room_count NUMBER(2);
BEGIN
	SELECT r.reservation_guest_count, COUNT(rm.room_id)
		INTO total_guests, room_count
		FROM reservations r, reserved_rooms rr, rooms rm
		WHERE r.reservation_id = rr.reservation_id
		AND rr.room_id = rm.room_id
		AND r.reservation_id = r_id
		GROUP BY r.reservation_guest_count;
	
	guests_per_room := CEIL(total_guests / room_count);
	
	RETURN guests_per_room;
EXCEPTION
	WHEN OTHERS THEN
		RETURN -1;
END;



/* 13 - Show Single Hotel Reservations */

/*
	Given a hotel ID, show all reservations for that hotel
*/

CREATE OR REPLACE FUNCTION showSingleHotelReservations (
	h_id IN hotels.hotel_id%type)
RETURN BOOLEAN
IS
	CURSOR cursor_var IS
		SELECT r.reservation_id AS reservation_id, r.customer_id AS customer_id, rm.room_id AS room_id, rm.room_type AS room_type, r.reservation_start_date AS checkin_date, r.reservation_end_date AS checkout_date, r.reservation_status AS status
		FROM rooms rm, reserved_rooms rr, reservations r
		WHERE rm.hotel_id = h_id
		AND rm.room_id = rr.room_id
		AND rr.reservation_id = r.reservation_id
		ORDER BY checkin_date;
		
	row_var cursor_var%rowtype;
	rowCounter NUMBER(9);
	hotel_not_found EXCEPTION;
	no_reservations_found EXCEPTION;
BEGIN
	-- Checks if hotel ID is valid
	IF NOT (validateHotelID(h_id)) THEN
		RAISE hotel_not_found;
	END IF;

	-- column printout formatting
	DBMS_OUTPUT.PUT_LINE(RPAD('Reservation ID',15) || RPAD('Customer ID',15) || RPAD('Room ID',10) || RPAD('Check-in Date',15) || RPAD('Check-out Date',16) || RPAD('Status',10));
	DBMS_OUTPUT.PUT_LINE(RPAD('=',80,'='));
	
	-- initializes counter for loop
	rowCounter := 0;
	
	-- loops through every reservation for specific hotel
	FOR row_var IN cursor_var
	LOOP
		-- prints information on record w/ formatting
		DBMS_OUTPUT.PUT_LINE(RPAD(row_var.reservation_id,15) || RPAD(row_var.customer_id,15) || RPAD((row_var.room_id || ' - ' || getRoomCode(row_var.room_type)),10) || RPAD(row_var.checkin_date,15) || RPAD(row_var.checkout_date,16) || RPAD(row_var.status,15));
		
		-- increments counter
		rowCounter := rowCounter + 1;
	END LOOP;
	
	-- raises exception if no reservation records found
	IF (rowCounter = 0) THEN
		RAISE no_reservations_found;
	END IF;
	
	-- indicates to calling problem that report was successful
	RETURN TRUE;
EXCEPTION
	WHEN hotel_not_found THEN
		-- bad hotel ID
		DBMS_OUTPUT.PUT_LINE('The hotel ID was not found.');
		RETURN FALSE;
	WHEN no_reservations_found THEN
		-- no reservations found
		DBMS_OUTPUT.PUT_LINE('No reservations found for this hotel.');
		RETURN FALSE;
	WHEN OTHERS THEN
		-- catch-all exception handler
		DBMS_OUTPUT.PUT_LINE('An error has occurred.');
		RETURN FALSE;
END;

-- Test Program
SET SERVEROUTPUT ON;

DECLARE
	h_id hotels.hotel_id%type;
BEGIN
	h_id := 1;
	
	IF (showSingleHotelReservations(h_id)) THEN
		DBMS_OUTPUT.PUT_LINE('Search for Hotel ID = ' || h_id || ' reservations success');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Search for Hotel ID = ' || h_id || ' reservations FAILED');
	END IF;
END;


-- utility function
CREATE OR REPLACE FUNCTION getRoomCode (
	full_type rooms.room_type%type)
RETURN VARCHAR2
IS
	room_code VARCHAR2(2);
BEGIN
	CASE full_type
		WHEN 'Conference' THEN room_code := 'Cf';
		WHEN 'Suite' THEN room_code := 'St';
		WHEN 'Single' THEN room_code := 'SR';
		WHEN 'Double' THEN room_code := 'DR';
		ELSE room_code := '';
	END CASE;
	
	RETURN room_code;
EXCEPTION
	WHEN OTHERS THEN
		RETURN '';
END;


-- utility function
CREATE OR REPLACE FUNCTION validateHotelID (
	h_id hotels.hotel_id%type)
RETURN BOOLEAN
IS
	hotelFound hotels.hotel_id%type;
BEGIN
	SELECT hotel_id INTO hotelFound
		FROM hotels
		WHERE hotel_id = h_id;
	
	RETURN true;
EXCEPTION
	WHEN OTHERS THEN
		RETURN FALSE;
END;



/* 14 - Show single guest reservations */

/*
	Given a guest name, find all reservations under that name
*/

CREATE OR REPLACE FUNCTION showSingleGuestReservations (
	c_first_name customers.customer_fname%type,
	c_last_name customers.customer_lname%type)
RETURN BOOLEAN
IS
	c_id customers.customer_id%type;
	
	CURSOR cursor_var IS
		SELECT DISTINCT r.reservation_id AS reservation_id, h.hotel_name AS hotel_name, r.reservation_start_date AS checkin_date, r.reservation_end_date AS checkout_date, r.reservation_status AS status
		FROM customers c, reservations r, reserved_rooms rr, rooms rm, hotels h
		WHERE c.customer_id = c_id
		AND c.customer_id = r.customer_id
		AND r.reservation_id = rr.reservation_id
		AND rr.room_id = rm.room_id
		AND rm.hotel_id = h.hotel_id
		ORDER BY r.reservation_start_date;
		
	row_var cursor_var%rowtype;
	rowCounter NUMBER(9);
	no_reservations_found EXCEPTION;
BEGIN
	-- Selects customer ID using given first name and last name
	SELECT customer_id INTO c_id
	FROM customers
	WHERE customer_fname = c_first_name
	AND customer_lname = c_last_name;
	-- If the customer does not exist, this will throw a no_data_found exception automatically
	
	-- Displays guest name and ID
	DBMS_OUTPUT.PUT_LINE(RPAD('Guest Name:',15) || c_first_name || ' ' || c_last_name);
	DBMS_OUTPUT.PUT_LINE(RPAD('Guest ID:',15) || c_id);
	
	-- Column formatting
	DBMS_OUTPUT.PUT_LINE(RPAD('Reservation ID',20) || RPAD('Hotel Name',50) || RPAD('Check-in Date',20) || RPAD('Check-out Date',20) || RPAD('Reservation Status',20));
	DBMS_OUTPUT.PUT_LINE(RPAD('=',129,'='));
	
	-- initializes counter
	rowCounter := 0;
	
	-- Loops through every reservation for specific guest
	FOR row_var IN cursor_var
	LOOP
		-- displays information on record w/ formatting
		DBMS_OUTPUT.PUT_LINE(RPAD(row_var.reservation_id,20) || RPAD(row_var.hotel_name,50) || RPAD(row_var.checkin_date,20) || RPAD(row_var.checkout_date,20) || RPAD(row_var.status,20));
		
		-- increments counter
		rowCounter := rowCounter + 1;
	END LOOP;
	
	-- Raises exception if no reservations discovered
	IF (rowCounter = 0) THEN
		RAISE no_reservations_found;
	END IF;
	
	-- indicates to calling problem that report was successful
	RETURN TRUE;
EXCEPTION
	WHEN no_data_found THEN
		-- bad input data
		DBMS_OUTPUT.PUT_LINE('No customers found by that name.');
		RETURN FALSE;
	WHEN no_reservations_found THEN
		-- no reservations found
		DBMS_OUTPUT.PUT_LINE('No reservations found for that customer.');
		RETURN FALSE;
	WHEN OTHERS THEN
		-- catch-all exception handler
		DBMS_OUTPUT.PUT_LINE('An error has occured.');
		RETURN FALSE;
END;


-- Tests function
SET SERVEROUTPUT ON;

BEGIN
	IF (showSingleGuestReservations('Ron', 'Swanson')) THEN
		DBMS_OUTPUT.PUT_LINE('Report successful.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Report encountered an error.');
	END IF;
END;



/* 15 - Total Monthly Income Report */

/* Calculate and display total income from all sources of all hotels. Totals must be printed by month, and for each month by room type, service type. Include discounts. */
CREATE OR REPLACE FUNCTION totalMonthlyIncomeReport
RETURN BOOLEAN
IS
	-- locals
	-- room type income cursor
	/* Inner select assembles room type, month number, reservation rate, and how many rooms fit into each. The outer select multiplies the room count by the reservation rate, then sorts that into the appropriate aggregate column by looking at the month number. */
	CURSOR room_cursor_var IS
		SELECT
			room_type,
			SUM(CASE WHEN month_num = 01 THEN res_rate * room_count * day_count ELSE 0 END) AS jan,
			SUM(CASE WHEN month_num = 02 THEN res_rate * room_count * day_count ELSE 0 END) AS feb,
			SUM(CASE WHEN month_num = 03 THEN res_rate * room_count * day_count ELSE 0 END) AS mar,
			SUM(CASE WHEN month_num = 04 THEN res_rate * room_count * day_count ELSE 0 END) AS apr,
			SUM(CASE WHEN month_num = 05 THEN res_rate * room_count * day_count ELSE 0 END) AS may,
			SUM(CASE WHEN month_num = 06 THEN res_rate * room_count * day_count ELSE 0 END) AS jun,
			SUM(CASE WHEN month_num = 07 THEN res_rate * room_count * day_count ELSE 0 END) AS jul,
			SUM(CASE WHEN month_num = 08 THEN res_rate * room_count * day_count ELSE 0 END) AS aug,
			SUM(CASE WHEN month_num = 09 THEN res_rate * room_count * day_count ELSE 0 END) AS sep,
			SUM(CASE WHEN month_num = 10 THEN res_rate * room_count * day_count ELSE 0 END) AS octo,
			SUM(CASE WHEN month_num = 11 THEN res_rate * room_count * day_count ELSE 0 END) AS nov,
			SUM(CASE WHEN month_num = 12 THEN res_rate * room_count * day_count ELSE 0 END) AS dece
		FROM (
			SELECT
				rm.room_type AS room_type,
				TO_CHAR(r.reservation_actual_end_date,'MM') AS month_num,
				r.reservation_rate AS res_rate,
				COUNT(rm.room_id) AS room_count,
				(r.reservation_actual_end_date - r.reservation_start_date) AS day_count
			FROM reservations r, reserved_rooms rr, rooms rm
			WHERE r.reservation_id = rr.reservation_id
			AND rr.room_id = rm.room_id
			GROUP BY rm.room_type,
			TO_CHAR(r.reservation_actual_end_date,'MM'),
			r.reservation_rate, (r.reservation_actual_end_date - r.reservation_start_date)
		)
		GROUP BY room_type;
	
	-- service type income cursor
	/* Inner select assembles service type, month number, service cost, and how many services were ordered by summing service line quantity. The outer select multiplies the service count by the service cost, then sorts that into the appropriate aggregate column by looking at the month number. */
	CURSOR serv_cursor_var IS
		SELECT
			service_type,
			SUM(CASE WHEN month_num = 01 THEN serv_cost * serv_count ELSE 0 END) AS jan,
			SUM(CASE WHEN month_num = 02 THEN serv_cost * serv_count ELSE 0 END) AS feb,
			SUM(CASE WHEN month_num = 03 THEN serv_cost * serv_count ELSE 0 END) AS mar,
			SUM(CASE WHEN month_num = 04 THEN serv_cost * serv_count ELSE 0 END) AS apr,
			SUM(CASE WHEN month_num = 05 THEN serv_cost * serv_count ELSE 0 END) AS may,
			SUM(CASE WHEN month_num = 06 THEN serv_cost * serv_count ELSE 0 END) AS jun,
			SUM(CASE WHEN month_num = 07 THEN serv_cost * serv_count ELSE 0 END) AS jul,
			SUM(CASE WHEN month_num = 08 THEN serv_cost * serv_count ELSE 0 END) AS aug,
			SUM(CASE WHEN month_num = 09 THEN serv_cost * serv_count ELSE 0 END) AS sep,
			SUM(CASE WHEN month_num = 10 THEN serv_cost * serv_count ELSE 0 END) AS octo,
			SUM(CASE WHEN month_num = 11 THEN serv_cost * serv_count ELSE 0 END) AS nov,
			SUM(CASE WHEN month_num = 12 THEN serv_cost * serv_count ELSE 0 END) AS dece
		FROM (
			SELECT
				s.service_type AS service_type,
				TO_CHAR(r.reservation_actual_end_date,'MM') AS month_num,
				s.service_cost AS serv_cost,
				SUM(sl.service_line_quantity) AS serv_count
			FROM reservations r, service_lines sl, services s
			WHERE r.reservation_id = sl.reservation_id
			AND sl.service_id = s.service_id
			GROUP BY s.service_type,
			TO_CHAR(r.reservation_actual_end_date,'MM'),
			s.service_cost
		)
		GROUP BY service_type;
	
	-- rowtype variables for cursors
	room_row_var room_cursor_var%rowtype;
	serv_row_var serv_cursor_var%rowtype;
	
	-- variables for storing various totals that will be tracked along the way
	-- month totals for room type income
	janRTotal NUMBER;
	febRTotal NUMBER;
	marRTotal NUMBER;
	aprRTotal NUMBER;
	mayRTotal NUMBER;
	junRTotal NUMBER;
	julRTotal NUMBER;
	augRTotal NUMBER;
	sepRTotal NUMBER;
	octRTotal NUMBER;
	novRTotal NUMBER;
	decRTotal NUMBER;
	
	-- month totals for service type income
	janSTotal NUMBER;
	febSTotal NUMBER;
	marSTotal NUMBER;
	aprSTotal NUMBER;
	maySTotal NUMBER;
	junSTotal NUMBER;
	julSTotal NUMBER;
	augSTotal NUMBER;
	sepSTotal NUMBER;
	octSTotal NUMBER;
	novSTotal NUMBER;
	decSTotal NUMBER;
	
	-- total for each row
	rowTypeTotal NUMBER;
	
	-- totals for room types and service types
	roomTotal NUMBER;
	serviceTotal NUMBER;
	
	-- grand total of all income
	grandTotal NUMBER;
BEGIN
	-- initializes room month variables
	janRTotal := 0;
	febRTotal := 0;
	marRTotal := 0;
	aprRTotal := 0;
	mayRTotal := 0;
	junRTotal := 0;
	julRTotal := 0;
	augRTotal := 0;
	sepRTotal := 0;
	octRTotal := 0;
	novRTotal := 0;
	decRTotal := 0;
	
	-- initializes service month variables
	janSTotal := 0;
	febSTotal := 0;
	marSTotal := 0;
	aprSTotal := 0;
	maySTotal := 0;
	junSTotal := 0;
	julSTotal := 0;
	augSTotal := 0;
	sepSTotal := 0;
	octSTotal := 0;
	novSTotal := 0;
	decSTotal := 0;
	
	-- Header formatting
	DBMS_OUTPUT.PUT_LINE('TOTAL MONTHLY SERVICES REPORT');
	
	-- Room report header
	DBMS_OUTPUT.PUT_LINE(RPAD('-',126,'-'));
	DBMS_OUTPUT.PUT_LINE(RPAD('ROOMS',18) || 'JAN     FEB     MAR     APR     MAY     JUN     JUL     AUG     SEP     OCT     NOV     DEC       TYPE TOTAL');
	
	-- loops through each room type category
	FOR room_row_var IN room_cursor_var
	LOOP
		-- increments each month total
		janRTotal := janRTotal + room_row_var.jan;
		febRTotal := febRTotal + room_row_var.feb;
		marRTotal := marRTotal + room_row_var.mar;
		aprRTotal := aprRTotal + room_row_var.apr;
		mayRTotal := mayRTotal + room_row_var.may;
		junRTotal := junRTotal + room_row_var.jun;
		julRTotal := julRTotal + room_row_var.jul;
		augRTotal := augRTotal + room_row_var.aug;
		sepRTotal := sepRTotal + room_row_var.sep;
		octRTotal := octRTotal + room_row_var.octo;
		novRTotal := novRTotal + room_row_var.nov;
		decRTotal := decRTotal + room_row_var.dece;
		
		-- calculates total for row
		-- each row represents a room type, so the total of the row is the total for that type
		rowTypeTotal := room_row_var.jan + room_row_var.feb + room_row_var.mar + room_row_var.apr + room_row_var.may + room_row_var.jun + room_row_var.jul + room_row_var.aug + room_row_var.sep + room_row_var.octo + room_row_var.nov + room_row_var.dece;
		
		-- prints income for current room type by month, and the grand total of the room type
		DBMS_OUTPUT.PUT_LINE(' ' || RPAD(room_row_var.room_type,17) || RPAD(room_row_var.jan,8) || RPAD(room_row_var.feb,8) || RPAD(room_row_var.mar,8) || RPAD(room_row_var.apr,8) || RPAD(room_row_var.may,8) || RPAD(room_row_var.jun,8) || RPAD(room_row_var.jul,8) || RPAD(room_row_var.aug,8) || RPAD(room_row_var.sep,8) || RPAD(room_row_var.octo,8) || RPAD(room_row_var.nov,8) || RPAD(room_row_var.dece,10) || RPAD(rowTypeTotal,8));
	END LOOP;
	
	-- calculates total for all room income
	roomTotal := janRTotal + febRTotal + marRTotal + aprRTotal + mayRTotal + junRTotal + julRTotal + augRTotal + sepRTotal + octRTotal + novRTotal + decRTotal;
	
	-- checks if no room results returned
	IF (roomTotal = 0) THEN
		DBMS_OUTPUT.PUT_LINE(' (no room income to display)');
	END IF;
	
	-- prints income for all room types by month, and the grand total of room type income
	DBMS_OUTPUT.PUT_LINE(RPAD('-',126,'-'));
	DBMS_OUTPUT.PUT_LINE(RPAD('ROOM TOTALS',18) || RPAD(janRTotal,8) || RPAD(febRTotal,8) || RPAD(marRTotal,8) || RPAD(aprRTotal,8) || RPAD(mayRTotal,8) || RPAD(junRTotal,8) || RPAD(julRTotal,8) || RPAD(augRTotal,8) || RPAD(sepRTotal,8) || RPAD(octRTotal,8) || RPAD(novRTotal,8) || RPAD(decRTotal,10) || RPAD(roomTotal,8));
	
	-- Service report
	DBMS_OUTPUT.PUT_LINE(RPAD('-',126,'-'));
	DBMS_OUTPUT.PUT_LINE(RPAD('SERVICES',18) || 'JAN     FEB     MAR     APR     MAY     JUN     JUL     AUG     SEP     OCT     NOV     DEC       TYPE TOTAL');
	
	-- loops through each service type category
	FOR serv_row_var IN serv_cursor_var
	LOOP
		-- increments each month total
		janSTotal := janSTotal + serv_row_var.jan;
		febSTotal := febSTotal + serv_row_var.feb;
		marSTotal := marSTotal + serv_row_var.mar;
		aprSTotal := aprSTotal + serv_row_var.apr;
		maySTotal := maySTotal + serv_row_var.may;
		junSTotal := junSTotal + serv_row_var.jun;
		julSTotal := julSTotal + serv_row_var.jul;
		augSTotal := augSTotal + serv_row_var.aug;
		sepSTotal := sepSTotal + serv_row_var.sep;
		octSTotal := octSTotal + serv_row_var.octo;
		novSTotal := novSTotal + serv_row_var.nov;
		decSTotal := decSTotal + serv_row_var.dece;
		
		-- calculates total for row
		-- each row represents a service type, so the total of the row is the total for that type
		rowTypeTotal := serv_row_var.jan + serv_row_var.feb + serv_row_var.mar + serv_row_var.apr + serv_row_var.may + serv_row_var.jun + serv_row_var.jul + serv_row_var.aug + serv_row_var.sep + serv_row_var.octo + serv_row_var.nov + serv_row_var.dece;
		
		-- prints income for current service type by month, and the grand total of the service type
		DBMS_OUTPUT.PUT_LINE(' ' || RPAD(serv_row_var.service_type,17) || RPAD(serv_row_var.jan,8) || RPAD(serv_row_var.feb,8) || RPAD(serv_row_var.mar,8) || RPAD(serv_row_var.apr,8) || RPAD(serv_row_var.may,8) || RPAD(serv_row_var.jun,8) || RPAD(serv_row_var.jul,8) || RPAD(serv_row_var.aug,8) || RPAD(serv_row_var.sep,8) || RPAD(serv_row_var.octo,8) || RPAD(serv_row_var.nov,8) || RPAD(serv_row_var.dece,10) || RPAD(rowTypeTotal,8));
	END LOOP;
	
	-- calculates total for all service income
	serviceTotal := janSTotal + febSTotal + marSTotal + aprSTotal + maySTotal + junSTotal + julSTotal + augSTotal + sepSTotal + octSTotal + novSTotal + decSTotal;
	
	-- checks if no service results returned
	IF (serviceTotal = 0) THEN
		DBMS_OUTPUT.PUT_LINE(' (no service income to display)');
	END IF;
	
	-- prints income for all service types by month, and the grand total of service type income
	DBMS_OUTPUT.PUT_LINE(RPAD('-',126,'-'));
	DBMS_OUTPUT.PUT_LINE(RPAD('SERVICE TOTALS',18) || RPAD(janSTotal,8) || RPAD(febSTotal,8) || RPAD(marSTotal,8) || RPAD(aprSTotal,8) || RPAD(maySTotal,8) || RPAD(junSTotal,8) || RPAD(julSTotal,8) || RPAD(augSTotal,8) || RPAD(sepSTotal,8) || RPAD(octSTotal,8) || RPAD(novSTotal,8) || RPAD(decSTotal,10) || RPAD(serviceTotal,8));
	
	-- calculates grand total for ALL 
	grandTotal := roomTotal + serviceTotal;
	
	-- Grand total
	DBMS_OUTPUT.PUT_LINE(RPAD('=',126,'='));
	DBMS_OUTPUT.PUT_LINE(RPAD('GRAND TOTAL',18) || RPAD(janSTotal + janRTotal,8) || RPAD(febSTotal + febRTotal,8) || RPAD(marSTotal + marRTotal,8) || RPAD(aprSTotal + aprRTotal,8) || RPAD(maySTotal + mayRTotal,8) || RPAD(junSTotal + junRTotal,8) || RPAD(julSTotal + julRTotal,8) || RPAD(augSTotal + augRTotal,8) || RPAD(sepSTotal + sepRTotal,8) || RPAD(octSTotal + octRTotal,8) || RPAD(novSTotal + novRTotal,8) || RPAD(decSTotal + decRTotal,10) || RPAD(grandTotal,10));
	DBMS_OUTPUT.PUT_LINE(RPAD('=',126,'='));
	
	RETURN TRUE;
EXCEPTION
	/* in general, the report should not encounter errors. It takes no parameters and has checking for 0 results within the body of the function. */
	WHEN OTHERS THEN
		-- catch-all exception
		DBMS_OUTPUT.PUT_LINE('There was an error.');
		RETURN FALSE;
END;


-- Tests function
SET SERVEROUTPUT ON;

BEGIN
	IF (totalMonthlyIncomeReport()) THEN
		DBMS_OUTPUT.PUT_LINE('Report successful.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Report encountered an error.');
	END IF;
END;