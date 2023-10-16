C.R.U.D.

INT             -- WHOLE NUMBER
DECIMAL(4,2)    -- 12,34
VARCHAR(1)      -- STRING OF TEXT OF LENGTH 1
BLOB            -- BINARY LARGE OBJECT
DATE            -- YYYY-MM-DD
TIMESTAMP       -- YYYY-MM-DD HH:MM:SS

CREATE TABLE student (
    student_id INT AUTO INCREMENT PRIMARY KEY NOT NULL,
    exp char(2),  -- fixed length of 2
    name VARCHAR(20) NOT NULL OR UNIQUE,  -- variable length of 20 at max
    major VARCHAR(20) DEFAULT 'Undeclared',
    mgr_id INT,
    FOREIGN KEY (mgr_id) REFERENCES employee (emp_id) ON DELETE SET NULL
    -- PRIMARY KEY (student_id)
);

DESCRIBE student;

DROP TABLE student;

TRUNCATE TABLE student;  -- DELETE ALL ROWS BUT KEEP TABLE

ALTER TABLE student ADD COLUMN gpa DECIMAL(3,2);

ALTER TABLE student ALTER COLUMN gpa SET DATA TYPE CHAR(3);

ALTER TABLE student DROP COLUMN gpa;

INSERT INTO student VALUES(1, 'Jack', 'Biology');

SELECT * FROM student;

INSERT INTO student(student_id, name) VALUES(2, 'Jill')
                                            (3, 'Adam'); -- NULL for major

UPDATE student
SET major = 'Bio'
WHERE major = 'Biology';  -- <> !=

UPDATE student
SET major = 'Biochemistry'
WHERE major = 'Bio' OR major = 'Chemistry';

UPDATE student
SET name = 'Tom', major = 'undecided'
WHERE student_id = 1;

DELETE FROM student
WHERE student_id IN (1, 2);

SELECT *
FROM student
WHERE major = 'Biochemistry';

SELECT customerName,
CONCAT(UCASE(contactFirstName), ' ', UCASE(contactLastName)) AS contact,
phone,
FROM customers
WHERE country='USA'
ORDER BY customerName;

SELECT customerNumber,
customerName,
LCASE(SUBSTRING(country, 1, 3)) AS countryCode
FROM customers
ORDER BY customerName
LIMIT 10;

SELECT productCode, ROUND(Num)
FROM orderdetails
WHERE orderNumber = 10100;

SELECT customerNumber,
MAX(amount) as largestPayment,
MOUNT(paymentDate) as dateOfLargestPayment
FROM payments
WHERE EXTRACT(YEAR FROM paymentDate) = '2004'
GROUP BY customerNumber;

SELECT student.name, student.major
FROM student
ORDER BY major, student_id DESC
LIMIT 10
OFFSET 5;  -- SKIP FIRST 5 ROWS

SELECT TITLE, PAGES FROM BOOK
ORDER BY 2;  -- ORDER BY PAGES

SELECT *
FROM student
WHERE name IN ('Claire', 'Kate') AND major = 'Biochemistry';

SELECT Students.Sname
FROM Students
    JOIN Enrollment ON (Students.sid = Enrollment.sid)
    JOIN Courses ON (Enrollment.cid = Courses.cid)
WHERE Courses.Cname = 'Biology';

SELECT S.Sname
FROM Students S
    JOIN Enrollment E ON (S.sid = E.sid)
    JOIN Courses C ON (E.cid = C.cid)
WHERE C.Cname = 'Biology';

JOIN or LEFT JOIN or RIGHT JOIN or FULL JOIN

SELECT first_name AS forename, last_name AS surname
FROM employee;

SELECT DISTINCT sex
FROM employee;

SELECT COUNT(emp_id)
FROM employee;

SELECT COUNTRY, COUNT(COUNTRY) AS COUNT
FROM AUTHOR
GROUP BY COUNTRY
HAVING COUNT(COUNTRY) > 2;

SELECT COUNT(emp_id)
FROM employee
WHERE sex='F' AND birth_date > '1970-01-01';

SELECT TITLE, PAGES FROM BOOK
WHERE PAGES >= 300 AND PAGES <= 500;

SELECT TITLE, PAGES FROM BOOK
WHERE PAGES BETWEEN 300 AND 500;

SELECT name,
 CASE
  WHEN genre = 'romance' THEN 'Chill'
  WHEN genre = 'comedy' THEN 'Chill'
  ELSE 'Intense'
 END AS 'Mood'
FROM movies;

SELECT AVG(salary)
FROM employee
WHERE sex='M';

SELECT SUM(salary)
FROM employee;

SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;
HAVING Count(*) > 1;

SELECT UCASE(first_name), LCASE(last_name)
FROM employee;

SELECT DAY(RESCUEDATE) FROM PETRESCUE
WHERE ANIMAL='CAT';

SELECT (RESCUEDATE + 3 DAYS) FROM PETRESCUE;

SELECT (CURRENT_DATE - RESCUEDAY) FROM PETRESCUE;  -- Also CURRENT_TIME

SELECT *
FROM client
WHERE client_name LIKE '%LLC%';  -- % = any number of characters, __ = double character

SELECT E.Dno, D.Dnumber FROM Employees E, Departments D
WHERE E.Dno = D.Dnumber;

SELECT first_name AS names
FROM employee
UNION
SELECT branch_name
FROM branch;

SELECT client_name, client.branch_id
FROM client
UNION
SELECT supplier_name, branch_supplier.branch_id
FROM branch_supplier;

SELECT employee.emp_id, employee.first_name, branch.branch_name
FROM employee
JOIN branch or LEFT JOIN or RIGHT JOIN or FULL JOIN
ON employee.emp_id = branch.mgr_id;

SELECT * FROM Employees
WHERE SALARY > AVG(SALARY);  -- ERROR

SELECT * FROM Employees
WHERE SALARY > (SELECT AVG(SALARY) FROM Employees);

SELECT EMP_ID, SALARY, AVG(SALARY) AS AVG_SALARY
FROM Employees;  -- ERROR

SELECT EMP_ID, SALARY,
    (SELECT AVG(SALARY) FROM Employees) AS AVG_SALARY
FROM Employees;

SELECT * FROM
    (SELECT EMP_ID, F_NAME, L_NAME, DEP_ID FROM Employees) AS EMP;

SELECT employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (
    SELECT works_with.emp_id
    FROM works_with
    WHERE works_with.total_sales > 30000
);

SELECT client.client_name
FROM client
WHERE client.branch_id = (
    SELECT branch.branch_id
    FROM branch
    WHERE branch.mgr_id = 102
    LIMIT 1
);

with previous_query as (
  SELECT customer_id,
   COUNT(subscription_id) AS 'subscriptions'
FROM orders
GROUP BY customer_id
)
select 
    customers.customer_name,
    previous_query.subscriptions from 
    previous_query join customers ON 
    previous_query.customer_id = customers.customer_id;

ON DELETE SET NULL
ON DELETE CASCADE
ON DELETE RESTRICT
ON DELETE NO ACTION

DELETE FROM employee
WHERE emp_id = 102;

DELIMITER $$
CREATE
    TRIGGER my_trigger BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES('added new employee') or VALUES(NEW.first_name)
    END$$
DELIMITER ;

DELIMITER $$
CREATE
    TRIGGER my_trigger2 AFTER INSERT
    ON employee
    FOR EACH ROW BEGIN
        IF NEW.sex = 'M' THEN
            INSEER INTO trigger_test VALUES('added male employee')
        ELSEIF NEW.sex = 'F' THEN
            INSERT INTO trigger_test VALUES('added female employee')
        ELSE
            INSERT INTO trigger_test VALUES('added other employee')
        END IF
    END$$
DELIMITER ;

DROP TRIGGER my_trigger;

(SELECT CITY, LENGTH(CITY)
FROM STATION
ORDER BY LENGTH(CITY), CITY ASC
LIMIT 1)
UNION
(SELECT CITY, LENGTH(CITY)
FROM STATION
ORDER BY LENGTH(CITY) DESC, CITY ASC
LIMIT 1);

select distinct CITY
from STATION
where CITY RLIKE '^[AEIOU]' and CITY RLIKE '[aeiou]$'

SELECT DISTINCT CITY
FROM STATION
WHERE CITY NOT RLIKE '^[aeiou].*$'

SELECT CEIL((SUM(Salary) - SUM(REPLACE(CAST(Salary AS CHAR), '0', '')))/COUNT(*))
FROM Employees;

CREATE VIEW EMPINFO (EMP_ID, FIRSTNAME, LASTNAME, ADDRESS, JOB_ID,
MANAGER_ID, DEP_ID)
AS SELECT EMP_ID, F_NAME, L_NAME, ADDRESS, JOB_ID,
MANAGER_ID, DEP_ID
FROM Employees
WHERE DEP_ID = 5;
SELECT * FROM EMPINFO;

DROP VIEW EMPINFO;

CREATE PROCEDURE UPDATE_SAL (IN empNum CHAR(6), IN rating SMALLINT)
    LANGUAGE SQL
    BEGIN
        IF rating = 1 THEN
            UPDATE Employees
            SET SALARY = SALARY * 1.10
            WHERE EMP_ID = empNum;
        ELSE
            UPDATE Employees
            SET SALARY = SALARY * 1.05
            WHERE EMP_ID = empNum;
        END IF;
    END;
CALL UPDATE_SAL('E10001', 1);

-- ACID: Atomicity, Consistency, Isolation, Durability

--Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
(SELECT CITY, LENGTH(CITY)
FROM STATION
ORDER BY LENGTH(CITY), CITY ASC
LIMIT 1)

-- Query the Name of any student in STUDENTS who scored higher than 75 Marks. Order your output by the last three characters of each name. If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.
SELECT NAME
FROM STUDENTS
WHERE MARKS > 75
ORDER BY RIGHT(NAME, 3), ID

SELECT ceil(avg(Salary) - avg(REPLACE(Salary,'0',''))) FROM Employees;

select '* * *'
union
select '* *'
union
select '*';

SELECT DATE_FORMAT(something, '%Y-%m');