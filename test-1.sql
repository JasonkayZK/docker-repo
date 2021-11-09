SELECT e.user_name, d.salary FROM test.dept d LEFT JOIN test.employee e on d.dept_id = e.dept_id WHERE d.salary > 5000;
