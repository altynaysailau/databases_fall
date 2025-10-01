--LAB03

--PART A

--1
create  database advanced_lab;

create table employees(
    emp_id serial primary key ,
    first_name varchar,
    last_name varchar,
    department varchar,
    salary integer,
    hire_date date,
    status varchar default 'Active'
);

create table departments(
    dept_id serial primary key ,
    dept_name varchar,
    budget integer,
    manager_id integer
);
create table projects(
    project_id serial primary key ,
    project_name varchar,
    dept_id integer,
    start_date date,
    end_date date,
    budget integer
);


--PART B

--2
insert into employees (first_name,last_name,department) values (
                        'Meir', 'Saken', 'IT');

--3
insert into employees (first_name, last_name, department, salary, hire_date, status) values (
                        'Abl', 'Edil', 'Logistics', default, '2025-10-29', default
                             );


--4
insert into departments (dept_name, budget) values
                                                            ('IT',200000),
                                                            ('Finance', 1000000),
                                                            ('Sales', 60000000);

--5
insert into employees(first_name, last_name, department, salary, hire_date)
    values('Almat','Tolebiev','Medicine',50000*1.1,current_date);

--6
create table temp_employees as select * from employees where department = 'IT';


--PART C

--7
update employees set salary = salary * 1.1;


-- insert into employees (first_name, last_name, department, salary, hire_date) values ('Dias','Akhmetzhanov','Sales',800000,'2019-04-18')
--8
update employees set status = 'Senior' where salary > 60000 and hire_date < '2020-01-01';

--9
update employees set department = case
                                        when salary > 80000 then 'Management'
                                        when salary between 50000 and 80000 then 'Senior'
                                        else 'Junior'
                                            end;

--10
update employees set status = default where status = 'Inactive';


--11

update departments set budget = (
    select avg(salary) * 1.2 from employees where department = dept_name
    );


--12
update employees set salary = salary * 1.15 , status = 'Promoted' where department = 'Sales';


--PART D
--13
insert into employees (emp_id,first_name, last_name, department, salary, hire_date, status) values (1000, 'sffs','sf','fs',23442,current_date, 'Terminated');

delete from employees where status = 'Terminated';


--14
insert into employees (emp_id,first_name, last_name, department, salary, hire_date) values (10001,'dgfgd','dfgdfg',null, 500, '2024-01-01');
delete from employees where salary < 40000 and hire_date > '2023-01-01' and department is null;

--15
insert into departments (dept_name, budget, manager_id) values ('sfddf',12,1000);
delete from departments where dept_name not in (select distinct department from employees);
select * from departments;

--16
insert into projects (project_name, dept_id, start_date, end_date) values ('SDFSDFSFSD',1,'2000-02-02','2022-01-01'),
                                                                            ('JKHGLDF',2,'1999-01-01','2000-01-01'),
                                                                            ('QERTRR', 3, '2024-02-01',current_date);

delete from projects where end_date < '2023-01-01' returning *;


--PART E
--17
insert into employees (first_name, last_name, department, salary, hire_date, status) values ('Zhanerke', 'Saken',null,null,current_date,current_date);


--18
update employees set department = 'Unassigned' where department is null;


--19
delete from employees where salary is null or department is null ;
select * from employees;


--PART F

--20
insert into employees(first_name, last_name, department, salary, hire_date, status) values ('Forexample','for','IT',333333,'2020-01-01',default)
returning emp_id ,first_name || ' ' || last_name as full_name;

--21

update employees set salary = salary + 5000 where department = 'IT'
returning emp_id,salary -5000 as old_salary ,salary as new_salary;

--22

delete from employees where hire_date < '2020-01-01'
returning *;

--PART G
--23

insert into employees (first_name, last_name) select 'Tima' ,'Moldabaev' where not exists(select 1 from employees where first_name = 'Tima' and last_name = 'Moldabaev' ) ;


--24

update employees e set salary = salary *
                                case
                                    when d.budget > 100000 then 1.1
                                    else 1.05
end from departments d where d.dept_name = e.department;

select * from employees;


--25

insert into employees (first_name, last_name, department, salary, hire_date) values
                                                                                         ('Sanji','Vismoke','Pirate',1000000,'1997-01-01'),
                                                                                         ('Luffi','Monkey d ','Pirate', 3000000,'1997-01-01'),
                                                                                         ('Zoro', 'Roronoa','Pirate', 1000000,'1997-01-01'),
                                                                                         ('Nami','Nami','Pirate',500000,'1997-01-01'),
                                                                                         ('Frank','Cola','Pirate',500000,'1997-01-01');
update employees set salary = salary *1.1 where emp_id in (select emp_id from employees order by emp_id desc limit 5) ;


insert into employees (first_name,status) values ('etrtes','Inactive');
insert into employees (first_name,status) values ('llglgl','Inactive');
insert into employees (first_name,status) values ('lllll','Inactive');
--26
create table employee_archive as select * from employees where status = 'Inactive';

delete from employees where emp_id in (select emp_id from employee_archive) returning *;

--27
update projects set end_date = end_date + 30 where budget > 50000 and dept_id in (select d.dept_id from departments d where (select count(*) from employees e where e.department =d.dept_name) >3);