alter procedure HumanResources.deleteDepartment @departmentId int
as
begin

	begin try
	  delete from HumanResources.Department
	  where DepartmentID=@departmentId
    end try
	begin catch
		print 'There are some employees working in this department'
		print 'I cannot delete it'

	end catch
	
	 
end

exec HumanResources.deleteDepartment @departmentId=1

--Homework
--1. Change the procedure
--2. Check whether there are rows in HumanResources.EmployeeDepartmentHistory
-- which are connected with the procedure parameter @departmentId
--3. If there are some then set departmentId to null
--4. Delete the row from the Department table

select * from HumanResources.EmployeeDepartmentHistory

alter table HumanResources.EmployeeDepartmentHistory 
add lastDepId int

alter procedure HumanResources.deleteDepartment @departmentId int
as
begin
	begin try
	 begin transaction
	  if exists (select * from HumanResources.EmployeeDepartmentHistory
	             where DepartmentID=@departmentId)
	  begin
	    delete from HumanResources.EmployeeDepartmentHistory
		where DepartmentID=@departmentId
	  end
	  delete from HumanResources.Department
	  where DepartmentID=@departmentId
     commit transaction
    end try
	begin catch
		rollback transaction;
		throw;
	end catch
end

exec HumanResources.deleteDepartment @departmentId=1


--transactions

use tempdb

create table Person(personId int identity primary key,
                    lastName varchar(50))

create table Car
(carId int identity primary key,
mark varchar(50),
model varchar(50),
personId int,
constraint fk_personId foreign key(personId) references Person(personId)
)

delete from Person

--here we have two independnet tranactions (each insert statement
--is a standalone transaction
insert into Person values('Smith')
insert into Car values('BMW','X5',scope_identity())

select * from Person
select * from Car

--the second insert will fail (too many characters)
insert into Person values('Norris')
insert into Car values(
  'BMW',
  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
   scope_identity())


delete from Person where personId=3
--our goal is to create a transaction to ensure that both statements
--will success or none of them

--the following code does not cancel the first insert if the second
--insert fails
begin transaction
  insert into Person values('Norris')
  insert into Car values(
    'BMW',
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
     aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
   scope_identity())
commit transaction

select * from Person
delete from Person where personId=4

--complete transaction
begin try
  begin transaction
    insert into Person values('Norris')
    insert into Car values(
      'BMW',
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
       aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    scope_identity())
  commit transaction
end try
begin catch
 rollback transaction
end catch

select * from Person


--it is also a good practise to check whether there are open transactions
--before you type rollback

begin try
  begin transaction
    insert into Person values('Norris')
    insert into Car values(
      'BMW',
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
       aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    scope_identity())
  commit transaction
end try
begin catch
 if XACT_STATE()=1  --there is open transaction
    rollback transaction
end catch

select * from Person
go
--create a procedure to insert a new person (the procedure shuold
--take one paramater - person last name


--create a procedure to create a new car (the procedure should take 3 
--parameters: personId, mark and model
--If personId is not valid you should print some message to the user (e.g.
--there is no person with such identifier)

--solution
create procedure addNewPerson @lastName varchar(60)
as
begin
  insert into Person(lastName) values(@lastName)
end

execute addNewPerson @lastName='Smith'
select * from Person

--http://www.math.uni.lodz.pl/~bleja/dbs/

alter procedure addNewCar @personID int, @mark varchar(50),
                          @model varchar(50)
as
begin
if exists (select * from Person where personId=@personID)
  insert into Car(mark,model,personId)
     values(@mark,@model,@personID)
else
  select 'There is no person with such identifier: '+
      cast(@personId as varchar(50)) as result
end

exec addNewCar @personId=10,@mark='BMW',@model='X5'

exec addNewCar @personId=1,@mark='BMW',@model='X5'

create procedure addNewPersonAndCar @lastName varchar(60),
       @mark varchar(50),@model varchar(50)
as
begin
declare @personId int
begin try
   begin transaction
	insert into Person(lastName) values(@lastName)
    set @personId = SCOPE_IDENTITY() --retrieve the last personId
	insert into Car(mark,model,personId)
     values(@mark,@model,@personID)
   commit transaction 
end try
begin catch
  rollback --if some errors occur then cancel the transaction 
end catch
end

exec addNewPersonAndCar @lastName='Terry',@mark='Toyota',@model='RAV 4'















