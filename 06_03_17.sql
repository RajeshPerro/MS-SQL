--Create a procedure to insert a new department

create procedure HumanResources.addDepartment
               @departmentName varchar(60), @groupName varchar(80)
as
begin

insert into HumanResources.Department
    values(@departmentName,@groupName,getdate())

end

--run a procedure
execute HumanResources.addDepartment @departmentName='ABC',
							@groupName='ABC Group'
							
--check whether the department has been inserted
select * from HumanResources.Department
where Name='ABC'		

go
--create a procedure to change existing department
create procedure HumanResources.updateDepartment
	  @departmentId int, @name varchar(50), @groupName varchar(60)
as
begin
	if not exists (select DepartmentID from HumanResources.Department
               where DepartmentID=@departmentId)
	begin
		print 'There is no such department. Provide another id.'
	end
	else
		update HumanResources.Department
		set Name=@name,GroupName=@groupName,ModifiedDate=getdate()
		where DepartmentID=@departmentId
end
--invoking the procedure
exec HumanResources.updateDepartment @departmentId=17,
     @name='XYZ',@groupName='XYZ Group'

--changing the procedure and raising an exception
alter procedure HumanResources.updateDepartment
	  @departmentId int, @name varchar(50), @groupName varchar(60)
as
begin
	if not exists (select DepartmentID from HumanResources.Department
               where DepartmentID=@departmentId)
	begin
		throw 51000,'The department does not exists',1;
	end
	else
		update HumanResources.Department
		set Name=@name,GroupName=@groupName,ModifiedDate=getdate()
		where DepartmentID=@departmentId
end
exec HumanResources.updateDepartment @departmentId=2000,
     @name='XYZ',@groupName='XYZ Group'


--add the catch section to the procedure

alter procedure HumanResources.updateDepartment
	  @departmentId int, @name varchar(50), @groupName varchar(60)
as
begin
   begin try
	if not exists (select DepartmentID from HumanResources.Department
               where DepartmentID=@departmentId)
	begin
		throw 51000,'The department does not exists',1;
	end
	else
		update HumanResources.Department
		set Name=@name,GroupName=@groupName,ModifiedDate=getdate()
		where DepartmentID=@departmentId
   end try
   begin catch
		print 'The department identifier is not correct';
		--throw is used to raise the exception once again
		throw; 
   end catch
end


exec HumanResources.updateDepartment @departmentId=2000,
     @name='XYZ',@groupName='XYZ Group'


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
--2. Chceck whether there are rows in HumanResources.EmployeeDepartmentHistory
-- which are connected with the procedure parameter @departmentId
--3. If there are some then set departmentId to null
--4. Delet the row from the Department table
