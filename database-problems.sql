-- All solutions are written in PostgreSQL unless otherwise specified

/*
175. Combine Two Tables

Table: Person

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| personId    | int     |
| lastName    | varchar |
| firstName   | varchar |
+-------------+---------+
personId is the primary key (column with unique values) for this table.
This table contains information about the ID of some persons and their first and last names.

Table: Address

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| addressId   | int     |
| personId    | int     |
| city        | varchar |
| state       | varchar |
+-------------+---------+
addressId is the primary key (column with unique values) for this table.
Each row of this table contains information about the city and state of one person with ID = PersonId.

Write a solution to report the first name, last name, city, and state of each person in the Person table. If the address of a personId is not present in the Address table, report null instead.

Return the result table in any order.
*/

SELECT p.firstName, p.lastName, a.city, a.state FROM Person p
LEFT JOIN Address a ON a.personId = p.personId;

/*
176. Second Highest Salary

Table: Employee
+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| salary      | int  |
+-------------+------+
id is the primary key (column with unique values) for this table.
Each row of this table contains information about the salary of an employee.

If there is no second highest salary return NULL
*/

SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);

-- Can also do

SELECT (
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1 -- Must do inner select statement, because inner select statement alone will not return NULL if second highest DNE
) AS SecondHighestSalary;

/*
177. Nth Highest Salary

Table: Employee

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| salary      | int  |
+-------------+------+
id is the primary key (column with unique values) for this table.
Each row of this table contains information about the salary of an employee.
 

Write a solution to find the nth highest distinct salary from the Employee table. If there are less than n distinct salaries, return null.
*/

-- MySQL Solution
CREATE OR REPLACE FUNCTION NthHighestSalary(N INT) RETURNS TABLE (Salary INT) AS $$
BEGIN
SET N = N - 1
    RETURN QUERY (
        SELECT DISTINCT(salary) FROM Employee
        ORDER BY salary DESC
        LIMIT 1 OFFSET N
    );
END;

-- PostgreSQL solution
CREATE OR REPLACE FUNCTION NthHighestSalary(N INT) RETURNS TABLE (Salary INT) AS $$
BEGIN
IF N < 1 THEN -- Handling for negative N
    RETURN QUERY (SELECT NULL::INT AS salary);
ELSE
    RETURN QUERY (
        SELECT DISTINCT e.salary
        FROM Employee e
        ORDER BY salary DESC
        LIMIT 1
        OFFSET N - 1 -- Pass N for OFFSET
    );
END IF;
END;
$$ LANGUAGE plpgsql;

/*
178. Rank Scores

Table: Scores

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| score       | decimal |
+-------------+---------+
id is the primary key (column with unique values) for this table.
Each row of this table contains the score of a game. Score is a floating point value with two decimal places.
 
Write a solution to find the rank of the scores. The ranking should be calculated according to the following rules:

The scores should be ranked from the highest to the lowest.
If there is a tie between two scores, both should have the same ranking.
After a tie, the next ranking number should be the next consecutive integer value. In other words, there should be no holes between ranks.
Return the result table ordered by score in descending order.
*/

SELECT s1.score,
(
    SELECT COUNT(DISTINCT s2.score)
    FROM Scores s2
    WHERE s2.score >= s1.score -- Count how many distinct scores are smaller than or equal to the current score
) AS rank 
FROM Scores s1
ORDER BY s1.score DESC;

-- Alternatively, use a Window Function
SELECT score,
DENSE_RANK() OVER (ORDER BY score DESC) AS rank
FROM Scores;

/*
180. Consecutive Numbers

Table: Logs

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
In SQL, id is the primary key for this table.
id is an autoincrement column starting from 1.
 

Find all numbers that appear at least three times consecutively.

Return the result table in any order.

The result format is in the following example.
*/

SELECT DISTINCT(l.num) ConsecutiveNums
FROM Logs l 
LEFT JOIN Logs l2 ON l.id = l2.id + 1
LEFT JOIN Logs l3 ON l.id = l3.id + 2
WHERE l.num = l2.num AND l2.num = l3.num