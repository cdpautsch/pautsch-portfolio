/* ------- IS 420, Group Project, Setup Script ------- */
/* ------- Deliverable 1 ------- */

/* This script first destroys all sequences and tables if they were created by a previous run of the script, then creates all necessary tables and sequences for the HGI project. Representative sample data is then inserted into all tables. */

/* Table Order of Creation (reversed for deletion)
- hotels
- customers
- services
- rooms
- reservations
- reserved_rooms
- service_lines */


/* ------- DELETE OLD TABLES ------- */
-- drop all tables and sequences in the current schema and
-- suppress any error messages that may displayed
-- if these objects don't exist
DROP SEQUENCE service_line_id_seq;
DROP SEQUENCE reserved_room_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE room_id_seq;
DROP SEQUENCE room_number_seq;
DROP SEQUENCE service_id_seq;
DROP SEQUENCE customer_id_seq;
DROP SEQUENCE hotel_id_seq;


DROP TABLE service_lines;
DROP TABLE reserved_rooms;
DROP TABLE reservations;
DROP TABLE rooms;
DROP TABLE services;
DROP TABLE customers;
DROP TABLE hotels;


/* ------- CREATE NEW TABLES ------- */

CREATE TABLE hotels (
    hotel_id        NUMBER(6),
    hotel_name        VARCHAR2(50)    NOT NULL    UNIQUE,
    hotel_address    VARCHAR2(50)    NOT NULL,
    hotel_city        VARCHAR2(25)    NOT NULL,
    hotel_state    CHAR(2)        NOT NULL,
    hotel_zip        CHAR(5)        NOT NULL,
    hotel_phone    CHAR(13)        NOT NULL,
    hotel_status    VARCHAR2(10)    NOT NULL,
    CONSTRAINT hotels_pk PRIMARY KEY (hotel_id),
    CONSTRAINT hotel_status_check CHECK (hotel_status IN ('Under Construction','Active','Sold'))
);

CREATE TABLE customers (
    customer_id    NUMBER(9),
    customer_fname    VARCHAR2(25)    NOT NULL,
    customer_lname    VARCHAR2(50)    NOT NULL,
    customer_address    VARCHAR2(50)    NOT NULL,
    customer_city    VARCHAR2(25)    NOT NULL,
    customer_state    CHAR(2)        NOT NULL,
    customer_zip    CHAR(5)        NOT NULL,
    customer_phone    CHAR(13)        NOT NULL,
    customer_card_number        VARCHAR2(16)    NOT NULL,
    customer_card_sec_code    VARCHAR2(4)    NOT NULL,
    customer_card_exp_date    DATE            NOT NULL,
    CONSTRAINT customers_pk PRIMARY KEY (customer_id)
);

CREATE TABLE services (
    service_id        NUMBER(9),
    service_name    VARCHAR2(25)    NOT NULL,
    service_type    VARCHAR2(13)    NOT NULL,
    service_cost    NUMBER(9,2),
    CONSTRAINT services_pk PRIMARY KEY (service_id),
    CONSTRAINT service_type_check CHECK (service_type IN ('Food', 'Entertainment', 'Service', 'Other'))
);

CREATE TABLE rooms (
    room_id        NUMBER(9),
    hotel_id        NUMBER(6)        NOT NULL,
    room_type        VARCHAR2(15)    NOT NULL,
    room_max_guests NUMBER(4)        DEFAULT 2        NOT NULL,
    room_number    VARCHAR(4)        NOT NULL,
    room_nonsmoking    VARCHAR(3)        DEFAULT 'Yes'    NOT NULL,
    CONSTRAINT rooms_pk PRIMARY KEY (room_id),
    CONSTRAINT rooms_fk_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (hotel_id),
    CONSTRAINT room_type_check CHECK (room_type IN ('Single', 'Double', 'Suite', 'Conference')),
    CONSTRAINT room_nonsmoking_check CHECK (room_nonsmoking IN ('Yes', 'No'))
);

CREATE TABLE reservations (
    reservation_id    NUMBER(9),
    customer_id    NUMBER(9)        NOT NULL,
    reservation_rate        NUMBER(9,2)    NOT NULL,
    reservation_guest_count    NUMBER(4)    DEFAULT 1    NOT NULL,
    reservation_status    VARCHAR2(11)    DEFAULT 'Reserved'    NOT NULL,
    reservation_made_date        DATE        DEFAULT SYSDATE    NOT NULL,
    reservation_start_date    DATE        NOT NULL,
    reservation_end_date        DATE        NOT NULL,
    reservation_actual_end_date    DATE,
    CONSTRAINT reservations_pk PRIMARY KEY (reservation_id),
    CONSTRAINT reservations_fk_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT reservation_status_check CHECK (reservation_status IN ('Reserved', 'Checked-In', 'Checked-Out', 'Cancelled')),
    CONSTRAINT reservation_end_date_check CHECK (reservation_end_date > reservation_start_date)
);

CREATE TABLE reserved_rooms (
    reserved_room_id        NUMBER(9),
    reservation_id        NUMBER(9)        NOT NULL,
    room_id            NUMBER(9)        NOT NULL,
    CONSTRAINT reserved_rooms_pk PRIMARY KEY (reserved_room_id),
    CONSTRAINT reserved_rooms_fk_reservation FOREIGN KEY (reservation_id) REFERENCES reservations (reservation_id),
    CONSTRAINT reserved_rooms_fk_room FOREIGN KEY (room_id) REFERENCES rooms (room_id),
    CONSTRAINT reserved_rooms_unique UNIQUE (reservation_id, room_id)
);

CREATE TABLE service_lines (
    service_line_id        NUMBER(9),
    service_id            NUMBER(9)        NOT NULL,
    reservation_id        NUMBER(9)        NOT NULL,
    service_line_quantity    NUMBER(4)        DEFAULT 1    NOT NULL,
    service_line_date    DATE            DEFAULT SYSDATE    NOT NULL,
    CONSTRAINT service_lines_pk PRIMARY KEY (service_line_id),
    CONSTRAINT service_lines_fk_service FOREIGN KEY (service_id) REFERENCES services (service_id),
    CONSTRAINT service_lines_fk_reservation FOREIGN KEY (reservation_id) REFERENCES reservations (reservation_id)
);


/* ------- CREATE SEQUENCES ------- */

CREATE SEQUENCE hotel_id_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE customer_id_seq
START WITH 100
INCREMENT BY 1;

CREATE SEQUENCE service_id_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE room_id_seq
START WITH 1
INCREMENT BY 1;

-- Room numbers represent regular hotel rooms across 30 floors
CREATE SEQUENCE room_number_seq
START WITH 25
INCREMENT BY 5
MAXVALUE 270
CYCLE;

CREATE SEQUENCE reservation_id_seq
START WITH 100
INCREMENT BY 1;

CREATE SEQUENCE reserved_room_id_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE service_line_id_seq
START WITH 1
INCREMENT BY 1;


/* ------- INSERT STATEMENTS ------- */


/* --- HOTELS & ROOMS --- */
-- Hotel 1
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Atlanta Marquis', '265 Peachtree Ave NE', 'Atlanta', 'GA', '30303', '(404)521-0000','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');


-- Hotel 2
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Spring Hill Suites', '14325 Crossing Pl', 'Woodbridge', 'VA', '22192', '(866)546-6920','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');


-- Hotel 3
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'The Governor Morris', '2 Whippany Rd', 'Morristown', 'NJ', '07960', '(973)539-7300','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');


-- Hotel 4
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Valley Forge Suites', '888 Chesterbrook Blvd', 'Wayne', 'PA', '19087', '(610)647-6700','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');


-- Hotel 5
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'The Lodges at Gettysburg', '685 Camp Gettysburg Rd', 'Gettysburg', 'PA', '17325', '(717)642-2500','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');


-- Hotel 6
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'The Kennebunkport Inn', '1 Dock Square', 'Kennebunkport', 'ME', '04046', '(207)967-2621','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');


-- Hotel 7
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Weber''s Hotel', '3050 Jackson Ave', 'Ann Arbor', 'MI', '48103', '(734)769-2500','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');

-- Hotel 8
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Hilton Atlanta', '255 Courtland St NE', 'Atlanta', 'GA', '30303', '(404)659-2000','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');

-- Hotel 9
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Live! Hotel', '7002 Arundel Mills Cir', 'Hanover', 'MD', '21076', '(443)459-4247','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');

-- Hotel 10
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Embassy Suites by Hilton Atlanta Buckhead', '3285 Peachtree Road NE', 'Atlanta', 'GA', '30305', '(404)261-7733','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');

-- Hotel 11
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Gettysburg Inn-Dobbin House', '89 Steinwehr Ave', 'Gettysburg', 'PA', '17325', '(717)334-2100','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');



-- Hotel 12
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Captain Lord Mansion', '6 Pleasant St', 'Kennebunkport', 'ME', '04046', '(207)967-3141','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');

-- Hotel 13
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Kimpton Hotel Monaco', '700 F St NW', 'Washington', 'DC', '20004', '(202)628-7177','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');

-- Hotel 14
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'The St. Gregory Hotel', '2033 M St. NW', 'Washington', 'DC', '20036', '(202)530-3600','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 25, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');

-- Hotel 15
INSERT INTO hotels (hotel_id, hotel_name, hotel_address, hotel_city, hotel_state, hotel_zip, hotel_phone, hotel_status) VALUES (hotel_id_seq.NEXTVAL, 'Fairmont Washington-Georgetown', '2401 M St. NW', 'Washington', 'DC', '20037', '(202)429-2400','Active');

INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 20, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 10, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Conference', 15, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Single', 2, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'No');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 6, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 8, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Double', 4, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');
INSERT INTO rooms VALUES (room_id_seq.NEXTVAL, hotel_id_seq.CURRVAL, 'Suite', 7, TO_CHAR(room_number_seq.NEXTVAL,'000'), 'Yes');



/* --- CUSTOMERS --- */
INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Wilson', 'Contreras', '622 Line Drive', 'Waco','TX', '76633', '(336)225-8864', '1234567891011121', TO_DATE('2019-09-01', 'YYYY-MM-DD'),'223' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Tomas', 'Johansson', '812 Quaker Lane', 'Florence','FL', '82654', '(224)856-7894', '0908070605040302', TO_DATE('2022-11-01', 'YYYY-MM-DD'),'557' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Jannette', 'Scott', '4568 Russell Ave', 'Valley','AL', '33654', '(155)889-7897', '1122334455667788', TO_DATE('2022-02-01', 'YYYY-MM-DD'),'554' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Cereza', 'Aesir', '9874 Abbey Street', 'Oakland','CA', '88454', '(456)489-1385', '1234567890123456', TO_DATE('2018-12-01', 'YYYY-MM-DD'),'666' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Bobby', 'Hall', '355 Westpark Drive', 'Gaithersburg','MD', '20877', '(800)273-8255', '3434567896771121', TO_DATE('2022-09-10', 'YYYY-MM-DD'),'678' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Lesane', 'Cooks', '909 Las Vegas Boulevard', 'Oakland','CA', '94577', '(703)883-8775', '3468057896786191', TO_DATE('2020-07-11', 'YYYY-MM-DD'),'690' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Michael', 'Scott', '696 Shised Road', 'Scranton','PA', '18503', '(431)532-9993', '6905367802537815', TO_DATE('2023-12-09', 'YYYY-MM-DD'),'334' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Ron', 'Swanson', '453 Woodsmen Road', 'Pawnee','IN', '74058', '(950)876-3293', '6906543272537867', TO_DATE('2020-01-19', 'YYYY-MM-DD'),'800' );

INSERT INTO customers (customer_id, customer_fname, customer_lname, customer_address, customer_city, customer_state, customer_zip, customer_phone, customer_card_number, customer_card_exp_date, customer_card_sec_code) VALUES (customer_id_seq.NEXTVAL, 'Leslie', 'Knope', '100 Main St', 'Pawnee','IN', '74058', '(950)980-1123', '9392375393482347', TO_DATE('2024-03-13', 'YYYY-MM-DD'),'223' );



/* --- SERVICES --- */
INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Restaurant Services', 'Food', 20.00);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Pay-per-View Movie', 'Entertainment', 5.00);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Laundry Services', 'Service', 10.00);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Valet Services', 'Service', 7.00);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Fast WiFi', 'Entertainment', 14.99);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Mini Bar', 'Entertainment', 15.00);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Car Renting', 'Service', 7.00);

INSERT INTO services (service_id, service_name, service_type, service_cost) VALUES (service_id_seq.NEXTVAL, 'Massage and Spa Services', 'Service', 25.00);


/* --- RESERVATIONS --- */
-- Reservation 1
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 100, 200.00, 1, 'Reserved', '06-MAR-18', SYSDATE + 30, SYSDATE + 35, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 2);

-- Reservation 2
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 101, 200.00, 1, 'Checked-In', '01-MAR-18', SYSDATE - 1, SYSDATE + 6, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 6);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 1, reservation_id_seq.CURRVAL, 1, SYSDATE - 1);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 2, reservation_id_seq.CURRVAL, 1, SYSDATE);

-- Reservation 3
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 102, 300.00, 2, 'Checked-Out', '15-JUL-17', '20-AUG-17', '22-AUG-17', '23-AUG-17');

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 10);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 3, reservation_id_seq.CURRVAL, 1, '21-AUG-17');

-- Reservation 4
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 103, 200.00, 4, 'Checked-Out', '07-OCT-17', '27-DEC-17', '01-JAN-18', '01-JAN-18');

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 14);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 4, reservation_id_seq.CURRVAL, 1, '31-DEC-17');

-- Reservation 5
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 104, 200.00, 1, 'Checked-In', '15-MAR-18', SYSDATE - 2, SYSDATE + 8, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 75);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 5, reservation_id_seq.CURRVAL, 1, SYSDATE - 1);

-- Reservation 6
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 105, 300.00, 1, 'Checked-In', '07-JULY-18', SYSDATE - 4, SYSDATE + 5, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 113);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 6, reservation_id_seq.CURRVAL, 1, SYSDATE - 2);

-- Reservation 7
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 106, 300.00, 1, 'Checked-Out', '06-JAN-18', '16-MAR-18', '29-MAR-18', '29-MAR-18');

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 190);

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 7, reservation_id_seq.CURRVAL, 1, '18-MAR-18');

INSERT INTO service_lines (service_line_id, service_id, reservation_id, service_line_quantity, service_line_date) VALUES (service_line_id_seq.NEXTVAL, 8, reservation_id_seq.CURRVAL, 1, '25-MAR-18');

-- Reservation 8
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 107, 200.00, 1, 'Reserved', '02-JAN-18', SYSDATE + 30, SYSDATE + 33, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 209);


-- Reservation 9
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 107, 300.00, 1, 'Checked-In', '24-FEB-18', SYSDATE, SYSDATE + 6, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 291);

-- Reservation 10
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 108, 200.00, 1, 'Reserved', '15-DEC-17', SYSDATE + 69, SYSDATE + 77, NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 314);

-- Reservation 11
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 100, 200.00, 4, 'Reserved', '05-MAR-18', '07-OCT-18', '13-OCT-18', NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 47);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 48);

-- Reservation 12
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 108, 200.00, 4, 'Reserved', '13-NOV-17', '15-JUL-18', '21-JUL-18', NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 2);

-- Reservation 13
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 107, 200.00, 4, 'Cancelled', '05-APR-18', '19-JUL-18', '23-JUL-18', NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 2);

-- Reservation 14
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 104, 200.00, 4, 'Reserved', '01-SEP-18', '15-OCT-18', '18-OCT-18', NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 49);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 48);

-- Reservation 15
INSERT INTO reservations (reservation_id, customer_id, reservation_rate, reservation_guest_count, reservation_status, reservation_made_date, reservation_start_date, reservation_end_date, reservation_actual_end_date) VALUES (reservation_id_seq.NEXTVAL, 105, 200.00, 6, 'Reserved', '24-JUN-18', '09-OCT-18', '13-OCT-18', NULL);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 45);

INSERT INTO reserved_rooms (reserved_room_id, reservation_id, room_id) VALUES (reserved_room_id_seq.NEXTVAL, reservation_id_seq.CURRVAL, 46);

