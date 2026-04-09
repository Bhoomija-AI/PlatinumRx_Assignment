

CREATE DATABASE clinic_db;
USE clinic_db;

CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);


CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(15)
);


CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount DECIMAL(10,2),
    datetime DATETIME,
    sales_channel VARCHAR(50),
    FOREIGN KEY (uid) REFERENCES customer(uid),
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50),
    description VARCHAR(255),
    amount DECIMAL(10,2),
    datetime DATETIME,
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);


-- Clinics
INSERT INTO clinics VALUES
('cnc-0100001', 'XYZ Clinic', 'CityA', 'StateA', 'CountryX'),
('cnc-0100002', 'ABC Clinic', 'CityB', 'StateB', 'CountryX');

-- Customers
INSERT INTO customer VALUES
('cust-001', 'John Doe', '9700000000'),
('cust-002', 'Jane Smith', '9711111111');

-- Clinic Sales
INSERT INTO clinic_sales VALUES
('ord-001', 'cust-001', 'cnc-0100001', 25000, '2021-09-23 12:03:22', 'online'),
('ord-002', 'cust-002', 'cnc-0100002', 15000, '2021-09-24 14:15:00', 'walk-in');

-- Expenses
INSERT INTO expenses VALUES
('exp-001', 'cnc-0100001', 'Medical supplies', 500, '2021-09-23 07:36:48'),
('exp-002', 'cnc-0100002', 'Equipment', 1000, '2021-09-24 09:00:00');



SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;



SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;


SELECT 
    MONTH(cs.datetime) AS month,
    SUM(cs.amount) AS revenue,
    COALESCE(SUM(e.amount),0) AS expense,
    SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit,
    CASE 
        WHEN SUM(cs.amount) - COALESCE(SUM(e.amount),0) > 0 THEN 'Profitable'
        ELSE 'Not-profitable'
    END AS status
FROM clinic_sales cs
LEFT JOIN expenses e
    ON cs.cid = e.cid 
    AND MONTH(cs.datetime) = MONTH(e.datetime)
    AND YEAR(cs.datetime) = YEAR(e.datetime)
WHERE YEAR(cs.datetime) = 2021
GROUP BY MONTH(cs.datetime)
ORDER BY month;



WITH clinic_profit AS (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
        AND YEAR(cs.datetime) = YEAR(e.datetime)
    WHERE YEAR(cs.datetime) = 2021 AND MONTH(cs.datetime) = 9
    GROUP BY c.city, cs.cid
)
SELECT city, cid, profit
FROM clinic_profit cp1
WHERE profit = (
    SELECT MAX(profit)
    FROM clinic_profit cp2
    WHERE cp1.city = cp2.city
);




WITH state_clinic_profit AS (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
        AND YEAR(cs.datetime) = YEAR(e.datetime)
    WHERE YEAR(cs.datetime) = 2021 AND MONTH(cs.datetime) = 9
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY state ORDER BY profit ASC) AS rn
    FROM state_clinic_profit
)
SELECT state, cid, profit
FROM ranked
WHERE rn = 2;


