INSERT INTO `test`.`employee` (uid, dept_id, user_name)
VALUES (1000, 1001, 'user-17');

SELECT e.user_name, d.salary
FROM test.dept d
         LEFT JOIN test.employee e on d.dept_id = e.dept_id
WHERE d.salary > 5000
   or e.user_name = 'user-17';
