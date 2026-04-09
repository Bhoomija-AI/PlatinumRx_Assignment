
CREATE DATABASE hotel_db;
USE hotel_db;
SELECT DATABASE();


CREATE TABLE users (
  user_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  phone_number VARCHAR(20),
  mail_id VARCHAR(100),
  billing_address TEXT
);

CREATE TABLE bookings (
  booking_id VARCHAR(50) PRIMARY KEY,
  booking_date DATETIME,
  room_no VARCHAR(50),
  user_id VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE items (
  item_id VARCHAR(50) PRIMARY KEY,
  item_name VARCHAR(100),
  item_rate DECIMAL(10,2)
);

CREATE TABLE booking_commercials (
  id VARCHAR(50) PRIMARY KEY,
  booking_id VARCHAR(50),
  bill_id VARCHAR(50),
  bill_date DATETIME,
  item_id VARCHAR(50),
  item_quantity DECIMAL(10,2),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
  FOREIGN KEY (item_id) REFERENCES items(item_id)
);

SHOW TABLES;


INSERT INTO users VALUES
('u1','John Doe','97XXXXXXXX','john.doe@example.com','Street 1, City A'),
('u2','Jane Smith','98XXXXXXXX','jane.smith@example.com','Street 2, City B');



INSERT INTO bookings VALUES
('b1','2021-10-10 10:30:00','101','u1'),
('b2','2021-11-15 14:20:00','102','u1'),
('b3','2021-11-20 09:00:00','103','u2');


INSERT INTO items VALUES
('i1','Tawa Paratha',18),
('i2','Mix Veg',89),
('i3','Dal Fry',120);

INSERT INTO booking_commercials VALUES
('c1','b1','bill1','2021-10-10 12:00:00','i1',10),
('c2','b1','bill1','2021-10-10 12:00:00','i2',5),
('c3','b2','bill2','2021-11-15 15:00:00','i3',8),
('c4','b3','bill3','2021-11-20 10:00:00','i2',15);

SELECT * FROM booking_commercials;


SELECT u.user_id, b.room_no
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (
  SELECT MAX(b2.booking_date)
  FROM bookings b2
  WHERE b2.user_id = u.user_id
);


SELECT 
  bc.booking_id,
  SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 11
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.booking_id;



SELECT 
  bc.bill_id,
  SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING bill_amount > 1000;


SELECT 
  MONTH(bc.bill_date) AS month,
  i.item_name,
  SUM(bc.item_quantity) AS total_qty
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE YEAR(bc.bill_date) = 2021
GROUP BY MONTH(bc.bill_date), i.item_name
ORDER BY month, total_qty;

SELECT 
  MONTH(bc.bill_date) AS month,
  i.item_name,
  SUM(bc.item_quantity) AS total_qty
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE YEAR(bc.bill_date) = 2021
GROUP BY MONTH(bc.bill_date), i.item_name
ORDER BY month, total_qty;


SHOW DATABASES;
USE hotel_db;


SHOW TABLES;

