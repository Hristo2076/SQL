--For this challenge you need to create a simple HAVING statement, you want to count how many people 
--have the same age and return the groups with 10 or more people who have that age.
SELECT age ,
  count(id) AS total_people
FROM people
GROUP BY age
HAVING count(id) >= 10;
