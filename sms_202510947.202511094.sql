SELECT current_database(), CURRENT_USER, NOW();

DROP TABLE IF EXISTS soldier_missions CASCADE;
DROP TABLE IF EXISTS soldiers CASCADE;
DROP TABLE IF EXISTS missions CASCADE;
DROP TABLE IF EXISTS units CASCADE;
DROP TABLE IF EXISTS ranks CASCADE;
DROP VIEW IF EXISTS v_soldier_profile;

CREATE TABLE ranks (
    rank_id INT PRIMARY KEY,
    rank_name VARCHAR(50) NOT NULL UNIQUE,
    rank_level INT NOT NULL CHECK (rank_level BETWEEN 1 AND 6)
);

CREATE TABLE units (
    unit_id INT PRIMARY KEY,
    unit_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL
);

CREATE TABLE missions (
    mission_id INT PRIMARY KEY,
    mission_name VARCHAR(100) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    CONSTRAINT chk_mission_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE soldiers (
    soldier_id SERIAL PRIMARY KEY,
    service_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    enlistment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'On Leave', 'Retired')),
    rank_id INT NOT NULL,
    unit_id INT NOT NULL,
    FOREIGN KEY (rank_id) REFERENCES ranks(rank_id),
    FOREIGN KEY (unit_id) REFERENCES units(unit_id),
    CONSTRAINT chk_enlistment CHECK (enlistment_date > date_of_birth)
);

CREATE TABLE soldier_missions (
    soldier_id INT NOT NULL,
    mission_id INT NOT NULL,
    mission_role VARCHAR(100) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id),
    FOREIGN KEY (soldier_id) REFERENCES soldiers(soldier_id),
    FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
);

INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
(1, 'Private', 1),
(2, 'Corporal', 2),
(3, 'Sergeant', 3),
(4, 'Lieutenant', 4),
(5, 'Captain', 5),
(6, 'Major', 6);

INSERT INTO units (unit_id, unit_name, location) VALUES
(1, 'Alpha Company', 'North Camp'),
(2, 'Bravo Company', 'South Camp'),
(3, 'Charlie Company', 'East Camp'),
(4, 'Delta Company', 'West Camp'),
(5, 'Signals Unit', 'Central Camp'),
(6, 'Medical Unit', 'Central Camp');

INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
(1, 'Exercise Falcon', '2025-02-03', '2025-02-28'),
(2, 'Flood Relief', '2025-04-14', '2025-05-30'),
(3, 'Border Patrol', '2025-07-01', NULL),
(4, 'Peace Support', '2025-09-15', NULL),
(5, 'Field Medical Camp', '2026-01-12', '2026-01-23');

INSERT INTO soldiers (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id) VALUES
(31, 'ST-202510947', 'Leen', 'Mohamed', '2004-05-09', '2024-01-15', 'Active', 1, 6),
(32, 'ST-202511094-2', 'Zeinab', 'Shaker', '2003-08-20', '2023-06-10', 'Active', 2, 6),
(33, 'ST-202510947-3', 'David', 'Jones', '2002-11-12', '2022-03-01', 'Active', 2, 1);

INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
(31, 3, 'Scout'),
(32, 3, 'Medic');

SELECT * FROM soldiers 
ORDER BY soldier_id DESC 
LIMIT 10;

SELECT * FROM (
    SELECT * FROM soldiers 
    ORDER BY soldier_id DESC 
    LIMIT 10
) AS recent_soldiers
ORDER BY soldier_id ASC;

SELECT * FROM soldiers 
WHERE soldier_id IN (10, 15, 20);

SELECT * FROM soldiers 
WHERE soldier_id IN (17, 22, 27);

SELECT * FROM soldiers 
WHERE status = 'Active' 
  AND soldier_id BETWEEN 10 AND 20;

SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name, r.rank_level
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
ORDER BY r.rank_level DESC, s.last_name ASC;

SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.location
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
JOIN units u ON s.unit_id = u.unit_id
WHERE s.status = 'Active' AND s.unit_id = 6;

SELECT m.mission_name, CONCAT(s.first_name, ' ', s.last_name) AS soldier_name, sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN soldiers s ON sm.soldier_id = s.soldier_id
JOIN missions m ON sm.mission_id = m.mission_id
JOIN units u ON s.unit_id = u.unit_id
WHERE sm.mission_id = 3;

SELECT s.*
FROM soldiers s
LEFT JOIN soldier_missions sm ON s.soldier_id = sm.soldier_id
WHERE sm.soldier_id IS NULL;

SELECT u.unit_name, COUNT(s.soldier_id) AS number_of_soldiers
FROM units u
LEFT JOIN soldiers s ON u.unit_id = s.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY number_of_soldiers DESC;

EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

CREATE INDEX idx_soldiers_last_name ON soldiers(last_name);

EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

CREATE VIEW v_soldier_profile AS
SELECT 
    s.soldier_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    r.rank_name,
    u.unit_name,
    u.location,
    s.status
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
JOIN units u ON s.unit_id = u.unit_id;

SELECT * FROM v_soldier_profile
WHERE unit_name = 'Medical Unit'
ORDER BY full_name ASC;