C.R.U.D.

INT             -- WHOLE NUMBER
DECIMAL(4,2)    -- 12,34
VARCHAR(1)      -- STRING OF TEXT OF LENGTH 1
BLOB            -- BINARY LARGE OBJECT
DATE            -- YYYY-MM-DD
TIMESTAMP       -- YYYY-MM-DD HH:MM:SS

CREATE TABLE student (
    student_id INT AUTO INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL OR UNIQUE,
    major VARCHAR(20) DEFAULT 'Undeclared',
    mgr_id INT,
    FOREIGN KEY (mgr_id) REFERENCES employee (emp_id) ON DELETE SET NULL
    -- PRIMARY KEY (student_id)
);

DESCRIBE student;

DROP TABLE student;

ALTER TABLE student ADD gpa DECIMAL(3,2);

ALTER TABLE student DROP COLUMN gpa;

INSERT INTO student VALUES(1, 'Jack', 'Biology');

SELECT * FROM student;

INSERT INTO student(student_id, name) VALUES(2, 'Jill'); -- NULL for major

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
WHERE student_id = 5;

SELECT *
FROM student
WHERE major = 'Biochemistry';

SELECT student.name, student.major
FROM student
ORDER BY major, student_id DESC
LIMIT 10;

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

<> -> !=

SELECT first_name AS forename, last_name AS surname
FROM employee;

SELECT DISTINCT sex
FROM employee;

SELECT COUNT(emp_id)
FROM employee;

SELECT COUNT(emp_id)
FROM employee
WHERE sex='F' AND birth_date > '1970-01-01';

SELECT AVG(salary)
FROM employee
WHERE sex='M';

SELECT SUM(salary)
FROM employee;

SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;
HAVING Count(*) > 1;

SELECT *
FROM client
WHERE client_name LIKE '%LLC%';  -- % = any number of characters, __ = double character

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

SELECT NAME
FROM STUDENTS
WHERE MARKS > 75
ORDER BY RIGHT(NAME, 3), ID

SELECT CEIL((SUM(Salary) - SUM(REPLACE(CAST(Salary AS CHAR), '0', '')))/COUNT(*))
FROM Employees;

