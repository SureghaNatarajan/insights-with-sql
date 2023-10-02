select * from paintings
select * from sales
union
select * from artists
--sln using subquery
select p.name as painting_name,(a.first_name|| ' '||a.last_name)as artistname
,case when x.no_of_painting > 1
		then (a.first_name|| ' '||a.last_name|| '**')
		else (a.first_name|| ' '||a.last_name)
		end as artist_name
,case when s.id is not null then 'sold'end as sold_or_not
from paintings p
full outer join artists a on p.artist_id=a.id
left join sales s on s.painting_id = p.id
left join( select artist_id,count(1) as no_of_painting
           from sales
           group by artist_id) x on x.artist_id=a.id
--sln using CTE


select p.name as painting_name
,(a.first_name||' '||a.last_name)as artistname
from paintings p
cross join artists a

--display each painting name with the tot no of artist in the db
select * from paintings
--group by artist_id
cross join ( select count(1) from artists) x

--display artists name and paintings name
--natural join doesn't need onkeyword
select a.first_name, s.painting_id
from sales s
 join artists a on a.id = s.id

create table employee_master
(
	id int,
	name varchar(20),
	salary int,
	manager_id int
)

select * from employee_master

insert into employee_master values(1, 'John smith', 1000, 3)
insert into employee_master values(2, 'Keerthy suresh', 2000, 4)
insert into employee_master values(3, 'Sivasakthi', 100090, null)
insert into employee_master values(4, 'devipriya', 5600, 2)
insert into employee_master values(5, 'kanmani', 99000, 2)

--find  the emp and their mng,display empname and their mng name
select emp.name as emp_name,mng.name as managername,mng.id
from employee_master emp
left join employee_master mng on emp.manager_id = mng.id

--replace null value in mng name
select emp.name as emp_name,coalesce (mng.name, 'CEO')as managername,coalesce(mng.id,0)
from employee_master emp
left join employee_master mng on emp.manager_id = mng.id

