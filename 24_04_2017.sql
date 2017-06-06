--Example 1 - transactions without try and catch

create table Person(
  id int primary key,
  lName varchar(40) not null,
  fName varchar(30) not null)

--Inserting data to the Person table 
begin transaction
 insert into Person values(1,'Smith','John') --it is ok
 insert into Person values(2,'Noris',null) --it will fail beacuse fName cannot bu null
 insert into Person values(3,'Parker','Martin') --it is ok
commit

--The question is whether the first insert statament will be canceled.

select * from Person

--Example 2 - transactions with try and catch (recommended solution)
begin try
 begin transaction
  insert into Person values(5,'Smith1','John1') --it is ok
  insert into Person values(6,'Noris1',null) --it will fail beacuse fName cannot bu null
  insert into Person values(7,'Parker1','Martin1') --it is ok
 commit
end try
begin catch 
  rollback; --it is used to cancel the transaction in case when there 
            --is some errors
  throw; --it is used to see an exception
end catch

select * from Person

--Example 3 - transactions with XACT_STATE

SET XACT_ABORT ON
 begin transaction
  insert into Person values(8,'Smith2','John2') --it is ok
  insert into Person values(9,'Noris2',null) --it will fail beacuse fName cannot bu null
  insert into Person values(10,'Parker2','Martin2') --it is ok
 commit

select * from Person

/*You can implement the following procedures:
1. Insert a new customer
   a) Insert a new row to Person.BusinessEntity
   b) Insert a new row to Person.Person
   c) Insert a new row to Sales.Customer

*/
go
create procedure Sales.insertCustomer @personType nchar(2),
      @fName varchar(50),@lName varchar(50)
as
begin
declare @BusinessEntityID int
begin try 
 begin transaction
   insert into Person.BusinessEntity default values
   set @BusinessEntityID = SCOPE_IDENTITY()
   --scope_identity is used to retrieve the last genereated value
   INSERT INTO [Person].[Person]([BusinessEntityID],[PersonType],
                [FirstName],[LastName])
     VALUES (@BusinessEntityID,@personType,@fName,@lName)
   INSERT INTO Sales.Customer(PersonID) values (@BusinessEntityID)
 commit
end try
begin catch
 rollback;
end catch
end

execute Sales.insertCustomer 'EM','Mike','Bleja'

select top 1 * from Person.BusinessEntity order by BusinessEntityID desc

select * from Person.Person where BusinessEntityID=20781
select * from Sales.Customer where PersonID=20781


--2. Insert a new product