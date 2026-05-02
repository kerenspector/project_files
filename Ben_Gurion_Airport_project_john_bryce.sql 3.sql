use master

go

/*
-- If the database 'Ben_Gurion_Airport' found, the database is switched to SINGLE_USER mode to disconnect all active users.
-- The with rollback immediate option forces any open transactions to be rolled back and immediately releases existing connections.
-- This ensures the database can be safely dropped and recreated without errors caused by active users.
*/
if exists (select * from sysdatabases where name='Ben_Gurion_Airport')
        alter database Ben_Gurion_Airport 
        set single_user
        with rollback immediate
		drop database Ben_Gurion_Airport
        

go

create database Ben_Gurion_Airport

go 
--returns the database to allow multi-user connections
alter database Ben_Gurion_Airport
set multi_user

go

/*
    Project: Airport Flight Booking Database

    This database stores information about airlines, airports,
    passengers, flights, and bookings for a flight reservation system.
    It supports tracking airline and airport details, passenger records,
    scheduled flights, and passenger bookings on flights.

    Tables:
    - Airlines: Contains airline codes and names.
    - Airports: Contains airport codes and location details.
    - Passengers: Stores passenger information.
    - Flights: Represents scheduled flights with times and routes.
    - Bookings: Links passengers to their booked flights.
*/

go

use Ben_Gurion_Airport

go

-- the table shows the information about the airlines operating in the airport
create table Airlines 
(airline_id int,--internal id only for the use in the db
iata_code varchar(2) not null,-- id of the airline given to every airline by international Air Transport Association
name varchar(100) not null,-- name of the airline
country varchar(100) not null,-- base country of the airline 
constraint Airlines_id_pk primary key (airline_id),
constraint Airlines_iata_code_uk UNIQUE (iata_code)) 

go

-- the table shows the information about the other airports in the world
create table Airports
(airport_id int, --internal id only for the use in the db
iata_code varchar(3) not null,-- id of the airport given to every airline by international Air Transport Association
city varchar(100) not null,--city of the airport
country varchar(100) not null,--country of the airport
name varchar(100) not null,-- name of the airport
timezone varchar(100) not null,-- timezone of the airport
constraint Airports_airport_id_pk primary key (airport_id),
constraint Airports_iata_code_uk unique (iata_code))

go

--the table shows the information about passengers
create table Passengers
(passenger_id int, --internal id only for the use in the db
 national_id varchar(20) not null, --passenger's personal national security id 
 full_name varchar(100) not null, -- passenger's full name
 passport_number varchar(20) not null, -- passenger's passport number
 email varchar(254) not null,-- passenger's email, can apear more than 1 because passenger can have more than 1 booking
 phone_number varchar(15) not null,-- passenger's phone, can apear more than 1 because passenger can have more than 1 booking
 birthdate date not null,--passenger's birthday
 constraint Passengers_id_PK primary key (passenger_id),
 constraint Passengers_national_id_uk unique(national_id),
 constraint Passengers_email_ck check(email like '%@%.%'),
 constraint Passengers_birthdate_ck check(birthdate<getdate())
)

go

create table Flights
(
 flight_id int,
 flight_number varchar(6) not null,
 departure_time datetime not null,
 arrival_time datetime not null,
 airline_id int,
 departure_airport_id int,
 destination_airport_id int,
 status varchar(10) not null,
 constraint Flights_id_pk primary key (flight_id),
 constraint Flights_airline_id_fk foreign key (airline_id) references Airlines(airline_id),
 constraint Flights_departure_airport_id_fk foreign key (departure_airport_id) references Airports(airport_id),
 constraint Flights_destination_airport_id_fk foreign key (destination_airport_id) references Airports(airport_id)
)

go 

--the table contains the information about all bookings, connect flights to passengers
create table Bookings
(
 booking_id int, 
 flight_id int,
 passenger_id int,
 booking_date date not null,--date of the booking
 seat_number varchar(4) not null,--seat number on the flight
 ticket_class char(1) not null,--the class the passanger  booked
 constraint Bookings_id_PK primary key (booking_id),
 constraint Bookings_passenger_id_fk foreign key (passenger_id) references Passengers(passenger_id),
 constraint Bookings_flight_id_fk foreign key (flight_id) references Flights(flight_id)
)

go 

insert into Airlines (airline_id, iata_code, name, country)
values
(1, 'AA', 'American Airlines', 'United States'),
(2, 'DL', 'Delta Air Lines', 'United States'),
(3, 'UA', 'United Airlines', 'United States'),
(4, 'BA', 'British Airways', 'United Kingdom'),
(5, 'AF', 'Air France', 'France'),
(6, 'LH', 'Lufthansa', 'Germany'),
(7, 'EK', 'Emirates', 'United Arab Emirates'),
(8, 'QR', 'Qatar Airways', 'Qatar'),
(9, 'SQ', 'Singapore Airlines', 'Singapore'),
(10, 'AC', 'Air Canada', 'Canada'),
(11, 'AI', 'Air India', 'India'),
(12, 'AR', 'Aerolineas Argentinas', 'Argentina'),
(13, 'AS', 'Alaska Airlines', 'United States'),
(14, 'AV', 'Avianca', 'Colombia'),
(15, 'AY', 'Finnair', 'Finland'),
(16, 'ET', 'Ethiopian Airlines', 'Ethiopia'),
(17, 'QF', 'Qantas', 'Australia'),
(18, 'NZ', 'Air New Zealand', 'New Zealand'),
(19, 'CI', 'China Airlines', 'Taiwan'),
(20, 'BR', 'Eva Airways', 'Taiwan'),
(21, 'LY', 'EL AL Israel Airlines', 'Israel')

go 

insert into Airports (airport_id, iata_code, city, country, name, timezone)
values
(1, 'TLV', 'Tel Aviv', 'Israel', 'Ben Gurion Airport', 'Asia/Jerusalem'),
(2, 'JFK', 'New York', 'United States', 'John F. Kennedy International Airport', 'America/New_York'),
(3, 'LHR', 'London', 'United Kingdom', 'Heathrow Airport', 'Europe/London'),
(4, 'CDG', 'Paris', 'France', 'Charles de Gaulle Airport', 'Europe/Paris'),
(5, 'DXB', 'Dubai', 'United Arab Emirates', 'Dubai International Airport', 'Asia/Dubai'),
(6, 'HND', 'Tokyo', 'Japan', 'Tokyo Haneda Airport', 'Asia/Tokyo'),
(7, 'SYD', 'Sydney', 'Australia', 'Sydney Kingsford Smith Airport', 'Australia/Sydney'),
(8, 'CAN', 'Guangzhou', 'China', 'Guangzhou Baiyun International Airport', 'Asia/Shanghai'),
(9, 'JNB', 'Johannesburg', 'South Africa', 'O. R. Tambo International Airport', 'Africa/Johannesburg'),
(10, 'YYZ', 'Toronto', 'Canada', 'Toronto Pearson International Airport', 'America/Toronto'),
(11, 'SFO', 'San Francisco', 'United States', 'San Francisco International Airport', 'America/Los_Angeles'),
(12, 'ORD', 'Chicago', 'United States', 'O''Hare International Airport', 'America/Chicago'),
(13, 'FRA', 'Frankfurt', 'Germany', 'Frankfurt Airport', 'Europe/Berlin'),
(14, 'AMS', 'Amsterdam', 'Netherlands', 'Amsterdam Schiphol Airport', 'Europe/Amsterdam'),
(15, 'MAD', 'Madrid', 'Spain', 'Adolfo Suárez Madrid–Barajas Airport', 'Europe/Madrid'),
(16, 'IST', 'Istanbul', 'Turkey', 'Istanbul Airport', 'Europe/Istanbul'),
(17, 'GRU', 'São Paulo', 'Brazil', 'São Paulo/Guarulhos–Governador André Franco Montoro Airport', 'America/Sao_Paulo'),
(18, 'MIA', 'Miami', 'United States', 'Miami International Airport', 'America/New_York'),
(19, 'BOM', 'Mumbai', 'India', 'Chhatrapati Shivaji Maharaj International Airport', 'Asia/Kolkata'),
(20, 'SEA', 'Seattle', 'United States', 'Seattle–Tacoma International Airport', 'America/Los_Angeles');


go 

insert into Passengers (passenger_id, national_id, full_name, passport_number, email, phone_number, birthdate)
values
(1, '123456789', 'Dana Cohen', 'P12345678', 'dana.cohen@egmail.com', '0541234567', '1990-05-12'),
(2, '987654321', 'Amir Levi', 'P87654321', 'amir.levi@gmail.com', '0557654321', '1985-11-03'),
(3, '456789123', 'Sarah Smith', 'P45678912', 'sarah.smith@gmail.com', '0509876543', '1995-02-20'),
(4, '321654987', 'John ann', 'P32165498', 'john.ann@gmail.co', '0523456789', '1988-07-15'),
(5, '741852963', 'Olivia Brown', 'P74185296', 'olivia.brown@gmail.com', '0531122334', '2001-09-28'),
(6, '159753486', 'Ethan Jones', 'P15975348', 'ethan.jones@gmail.com', '0549988776', '1992-12-05'),
(7, '258369147', 'Mia Davis', 'P25836914', 'mia.davis@gmail.com', '0556677889', '1998-04-18'),
(8, '369147258', 'Lucas Garcia', 'P36914725', 'lucas.garcia@gmail.com', '0505566778', '1983-08-30'),
(9, '147258369', 'Emma Martinez', 'P14725836', 'emma.martinez@gmail.com', '0522233445', '1997-01-22'),
(10, '753951456', 'Noah Wilson', 'P75395145', 'noah.wilson@gmail.co', '0539988771', '1994-10-11'),
(11, '258147369', 'Ava Anderson', 'P25814736', 'ava.anderson@gmail.com', '0543344556', '2000-06-07'),
(12, '147369258', 'Liam Thomas', 'P14736925', 'liam.thomas@gmail.com', '0552345678', '1989-03-14'),
(13, '369258147', 'Sophia Taylor', 'P36925814', 'sophia.taylor@gmail.com', '0509988776', '1996-11-19'),
(14, '951753852', 'Mason Moore', 'P95175385', 'mason.moore@gmail.com', '0527766554', '1987-09-25'),
(15, '852963741', 'Isabella Jackson', 'P85296374', 'isabella.jackson@gmail.com', '0534455667', '1993-02-28'),
(16, '963741852', 'Logan White', 'P96374185', 'logan.white@gmail.com', '0559988773', '1991-07-08'),
(17, '741258963', 'Charlotte Harris', 'P74125896', 'charlotte.harris@gmail.com', '0547788990', '1999-05-16'),
(18, '852147369', 'James Martin', 'P85214736', 'james.martin@gmail.com', '0506677889', '1986-12-26'),
(19, '963852741', 'Amelia Thompson', 'P96385274', 'amelia.thompson@gmail.com', '0523344558', '1995-08-09'),
(20, '741369852', 'Benjamin Lee', 'P74136985', 'benjamin.lee@gmail.com', '0539988772', '1993-04-02')

go 

insert into Flights (flight_id, flight_number, departure_time, arrival_time, airline_id, departure_airport_id, destination_airport_id, status)
values
(101, 'AA101', '2026-02-01 08:00:00', '2026-02-01 12:15:00', 1, 1, 2, 'Scheduled'),
(102, 'AA205', '2026-02-01 13:45:00', '2026-02-01 17:20:00', 1, 2, 3, 'Delayed'),
(103, 'DL110', '2026-02-02 09:30:00', '2026-02-02 13:10:00', 2, 3, 1, 'Landed'),
(104, 'DL220', '2026-02-02 15:00:00', '2026-02-02 19:50:00', 2, 1, 3, 'Cancelled'),
(105, 'UA301', '2026-02-03 07:20:00', '2026-02-03 11:30:00', 3, 3, 2, 'In Air'),
(106, 'UA402', '2026-02-03 18:15:00', '2026-02-03 22:05:00', 3, 2, 1, 'Scheduled'),
(107, 'BA500', '2026-02-04 10:00:00', '2026-02-04 14:30:00', 4, 1, 3, 'Boarding'),
(108, 'BA620', '2026-02-04 16:50:00', '2026-02-04 20:40:00', 4, 3, 2, 'Delayed'),
(109, 'AF701', '2026-02-05 11:00:00', '2026-02-05 15:30:00', 5, 2, 1, 'Diverted'),
(110, 'AF812', '2026-02-05 19:45:00', '2026-02-05 23:25:00', 5, 1, 3, 'Scheduled'),
(111, 'LH220', '2026-02-06 06:40:00', '2026-02-06 10:25:00', 6, 3, 2, 'Scheduled'),
(112, 'LH330', '2026-02-06 14:15:00', '2026-02-06 18:00:00', 6, 2, 1, 'Cancelled'),
(113, 'EK405', '2026-02-07 08:15:00', '2026-02-07 12:50:00', 7, 1, 2, 'Scheduled'),
(114, 'EK510', '2026-02-07 17:30:00', '2026-02-07 21:20:00', 7, 2, 3, 'Landed'),
(115, 'QR301', '2026-02-08 09:45:00', '2026-02-08 13:30:00', 8, 3, 1, 'Delayed'),
(116, 'QR418', '2026-02-08 15:10:00', '2026-02-08 19:10:00', 8, 1, 2, 'Scheduled'),
(117, 'SQ100', '2026-02-09 07:00:00', '2026-02-09 11:10:00', 9, 2, 3, 'Scheduled'),
(118, 'SQ215', '2026-02-09 13:55:00', '2026-02-09 17:30:00', 9, 3, 1, 'Boarding'),
(119, 'AC205', '2026-02-10 10:20:00', '2026-02-10 14:05:00', 10, 1, 2, 'In Air'),
(120, 'AC310', '2026-02-10 18:40:00', '2026-02-10 22:30:00', 10, 2, 3, 'Scheduled')

go

insert into Bookings (booking_id, flight_id, passenger_id, booking_date, seat_number, ticket_class)
values
(2001, 101, 1, '2025-12-01', '12A', 'Y'),
(2002, 101, 2, '2025-12-02', '12B', 'Y'),
(2003, 102, 3, '2025-12-03', '3C', 'J'),
(2004, 103, 4, '2025-12-04', '18F', 'Y'),
(2005, 104, 5, '2025-12-05', '14C', 'F'),
(2006, 105, 6, '2025-12-06', '22D', 'Y'),
(2007, 105, 7, '2025-12-06', '22E', 'Y'),
(2008, 106, 8, '2025-12-07', '7A', 'J'),
(2009, 107, 9, '2025-12-07', '5B', 'Y'),
(2010, 108, 10, '2025-12-08', '11C', 'Y'),
(2011, 109, 11, '2025-12-08', '1A', 'F'),
(2012, 110, 12, '2025-12-09', '9D', 'Y'),
(2013, 111, 13, '2025-12-10', '20F', 'Y'),
(2014, 112, 14, '2025-12-10', '10B', 'J'),
(2015, 113, 15, '2025-12-11', '15C', 'Y'),
(2016, 114, 16, '2025-12-11', '8A', 'Y'),
(2017, 115, 17, '2025-12-12', '4F', 'J'),
(2018, 116, 18, '2025-12-12', '13D', 'Y'),
(2019, 117, 19, '2025-12-13', '16A', 'Y'),
(2020, 118, 20, '2025-12-13', '6C', 'Y')

go

select * from bookings