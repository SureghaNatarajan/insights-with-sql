--find the hierarchy of employees under manager'Asha'
with recursive cte as
	(
		select * ,1 as lvl
		from emp_details where name='Asha'
		union all
		select e.*,(lvl+1)as lvl
		from cte
		join emp_details e on cte.id= e.manager_id
	)
select cte.id,cte.name,cte.manager_id,cte.*
from cte
