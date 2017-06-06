--display data about all people
select *
from Person.Person

--display data from more than one table
--select people and their phones
select p.BusinessEntityID,p.FirstName,p.LastName,pp.PhoneNumber
from Person.Person p join Person.PersonPhone pp
     on p.BusinessEntityID=pp.BusinessEntityID

--Diaplay first name, last name, department name, start date,
  --end date. Sort the query result based on BusinessEntityID
  
select p.BusinessEntityID,p.FirstName,p.LastName,
       d.Name,edh.StartDate,edh.EndDate
from Person.Person p join HumanResources.Employee e
         on p.BusinessEntityID=e.BusinessEntityID
	 join HumanResources.EmployeeDepartmentHistory edh
	     on edh.BusinessEntityID=e.BusinessEntityID
	 join HumanResources.Department d
	      on d.DepartmentID=edh.DepartmentID
order by p.BusinessEntityID


  
   