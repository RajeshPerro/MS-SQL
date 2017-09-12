--Task-1 : Create procedure to insert data to any free tables in the AdventureWorks database.
ALTER PROCEDURE Person.addNewPerson
			@personType nchar (2), @nameStyle bit, @title varchar(10),@firstName varchar (20), @lastName varchar (20), @emailPromotion int
as
begin
begin try
	if exists (select FirstName,LastName from Person.Person
               where FirstName=@firstName AND LastName =@lastName)
	begin
		print 'This person already available in database.'
	end
	else
	begin
		if(@personType IS NULL OR (upper(@personType)!='GC' OR upper(@personType)!='SP' OR upper(@personType)!='EM' OR upper(@personType)!='IN' OR upper(@personType)!='VC' OR upper(@personType)!='SC'))
				begin
					
					print 'Invalid Persontype.!'
					RAISERROR('Process not done! Because all if condition was not valid!',16,1)
					
				end
	
		begin transaction
			
			INSERT INTO Person.BusinessEntity
				VALUES(NEWID(),GETDATE())
				INSERT INTO Person.Person(BusinessEntityID,PersonType,NameStyle,Title,FirstName,LastName,EmailPromotion,rowguid,ModifiedDate)
					VALUES(SCOPE_IDENTITY(),@personType,@nameStyle,@title,@firstName,@lastName,@emailPromotion,NEWID(),GETDATE())
		commit transaction
	end
end try
begin catch
rollback transaction
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity,@ErrorState);
end catch
end

--Execute procedure

execute Person.addNewPerson 
	@personType = 'asd', @nameStyle = 0, @title='Mr.', @firstName='Mahdi', @lastName='Salha', @emailPromotion=1


go

--Task-4 Create a procedure to transfer products from one category to another one.
ALTER PROCEDURE Production.transferProduct 
	@oldCategoryId INT, @newCategoryId INT
as
begin
  begin try
	if not exists(SELECT * FROM Production.Product WHERE ProductSubcategoryID = @oldCategoryId)
	begin
		print 'Sorry.! there is no product exists with your given ID in Product table'
	end
	else
	  begin
	     if not exists(select * from Production.ProductSubcategory WHERE ProductSubcategoryID = @newCategoryId)
	     begin
		  print 'Sorry.! there is no subcategory exists with your given ID in Subcategory table'
	      end
	    
	  else
	    begin
		 begin transaction
		 	UPDATE Production.Product SET ProductSubcategoryID = @newCategoryId 
				WHERE Product.ProductSubcategoryID = @oldCategoryId
		 commit transaction
        end
	 
	end
 
 end try
	begin catch
	rollback transaction
	end catch
end

--Execute procedures
execute Production.transferProduct @oldCategoryId=9, @newCategoryId=0

--Task-5  CEATE new TABLES and some operations.
CREATE TABLE dbo.Student 
   (ID int IDENTITY NOT NULL,
    StudentID int  PRIMARY KEY NOT NULL,  
    FirstName varchar(30) NOT NULL,  
	LastName varchar(30) NOT NULL,  
	Department varchar(30) NULL,
    ) 

--INSERT INTO dbo.Student(StudentID,FirstName,LastName,Department)VALUES(101014007,'Rajesh','Ghosh','CSE')
--INSERT INTO dbo.Student(StudentID,FirstName,LastName,Department)VALUES(101014008,'Bogdan','Tokariev','CSE')
--SELECT * FROM dbo.Student

CREATE TABLE dbo.Course (
	ID int IDENTITY NOT NULL,
    CourseID int PRIMARY KEY NOT NULL,  
    Title varchar(30) NOT NULL,
	Price money NOT NULL,  
	Instructor varchar(30) NULL,  
	StartDate DATE NULL,
	EndDate DATE NULL
    )

--INSERT INTO dbo.Course(CourseID,Title,Price,Instructor,StartDate,EndDate)VALUES(102,'Database System',$120,'TBA',GETDATE(),DATEADD(month, 6, GETDATE()))
--SELECT * FROM dbo.Course

 CREATE TABLE dbo.StudentCourse(
	ID int IDENTITY NOT NULL,
	StudentID int NOT NULL,
	CourseID int NOT NULL,
	Grade int NULL
	constraint fk_StudentID foreign key(StudentID) references dbo.Student(StudentID),
	constraint fk_CourseID foreign key(CourseID) references dbo.Course(CourseID)
	)


GO

ALTER PROCEDURE dbo.addData
	@studentId INT, @fName VARCHAR (30), @lName VARCHAR(30)
as
begin
	
	--if not exists(SELECT * FROM dbo.Student WHERE StudentID = @studentId)
	begin try
	INSERT INTO dbo.Student (StudentID,FirstName,LastName) VALUES(@studentId,@fName,@lName)
	end try
	begin catch
	if ERROR_NUMBER()= 2627 
	print 'Sorry.!This Student ID is already exists try with new ID.'	
	end catch

end

--Execute procedure
execute dbo.addData @studentId=101, @fName='AA', @lName='BB'
SELECT * FROM dbo.Student

GO
CREATE PROCEDURE dbo.addCourseData
	@courseId INT, @title VARCHAR (30), @price money
as
begin
	
	begin try
	INSERT INTO dbo.Course(CourseID,Title,Price) VALUES(@courseId,@title,@price)
	end try
	begin catch
	if ERROR_NUMBER()= 2627 
	print 'Sorry.!This Course ID is already exists try with new ID.'	
	end catch

end

--Execute procedure
execute dbo.addCourseData @courseId=1011, @title='Web Developmetn', @price=$200
SELECT * FROM dbo.Course
GO

ALTER PROCEDURE dbo.addStudentCourse
	@studentId INT,@courseId INT
as
begin
	
	begin try
	if exists(SELECT * FROM dbo.Student, dbo.Course WHERE StudentID = @studentId AND CourseID = @courseId)
	begin transaction
	INSERT INTO dbo.StudentCourse(StudentID,CourseID) VALUES(@studentId,@courseId)
	commit transaction
	end try
	begin catch
	if XACT_STATE()=1 
	rollback 
	if ERROR_NUMBER()= 547 
	print 'Sorry.!somethig went wrong with StudentID or CourseID'	
	end catch

end

--Execute procedure
execute dbo.addStudentCourse @studentId=101014007, @courseId=102111

SELECT * FROM dbo.Student
SELECT * FROM dbo.Course
SELECT * FROM dbo.StudentCourse

GO
--Loop in SQL
DECLARE @cnt INT = 0;
WHILE @cnt < 10
BEGIN
   PRINT 'I just need to execute procedure here.!';
   SET @cnt = @cnt + 1;
END;

PRINT 'Done!';


GO

--Task-3 : Create a trigger that does not allow to increase salary by one third.
ALTER TABLE HumanResources.Employee
  ADD Salary money;
GO

ALTER trigger HumanResources.salaryIncrement
	on HumanResources.Employee
	after update
as
begin
	if  exists (select *
	           from inserted i join deleted d on i.BusinessEntityID=d.BusinessEntityID
			   where i.Salary >= d.Salary+d.Salary/3)
		begin
	print 'Sorry.! Can not increase salary by greater than 1/3'
			rollback transaction
		end
    else
		begin
				print 'Transaction was executed successfully.!'
		end	
end

GO
		--update HumanResources.Employee set 
				--HumanResources.Employee.Salary = i.Salary
			--from HumanResources.Employee as e join inserted as i on 
				--e.BusinessEntityID = i.BusinessEntityID
			--where e.BusinessEntityID= i.BusinessEntityID

--Task -2 : Create a procedure to hire an employee.
ALTER PROCEDURE HumanResources.hireAnEmployee
	@BusinessEntityID int,
	@NationalIDNumber nvarchar(15),
	@LoginID nvarchar(256),
	@OrganizationNode hierarchyid,
	@JobTitle nvarchar(50),
	@BirthDate date,
	@MaritalStauts nchar(1),
	@Gender nchar(1),
	@salary money,
	@FirstName nvarchar(50),
	@LastName nvarchar(50)
	
as
begin
	
	IF exists(SELECT BusinessEntityID FROM Person.Person
		WHERE BusinessEntityID=@BusinessEntityID)
		IF not exists(SELECT BusinessEntityID FROM HumanResources.Employee
		WHERE BusinessEntityID=@BusinessEntityID)
			begin
				begin try
					begin transaction
						INSERT INTO HumanResources.Employee VALUES (
							@BusinessEntityID,
							@NationalIDNumber,
							@LoginID,
							@OrganizationNode,
							@JobTitle,
							@BirthDate,
							@MaritalStauts,
							@Gender,
							GETDATE(),
							0,
							0,
							0,
							1,
							NEWID(),
							GETDATE(),
							@salary
						)
					commit transaction
				end try
				begin catch					
					rollback;
					--throw;
					if ERROR_NUMBER()= 2627 print 'Sorry.!The value already exists.!! Try with new value'					
				end catch;
			end
		else
			print 'Sorry.!!This BusinessEntityID is already taken.'
	else
		begin
			IF not exists(SELECT BusinessEntityID FROM Person.BusinessEntity
				WHERE BusinessEntityID=@BusinessEntityID)
				begin
					begin try
							begin transaction
								INSERT INTO Person.BusinessEntity default values
								INSERT INTO Person.Person (BusinessEntityID, FirstName, LastName)
								VALUES (scope_identity(), @FirstName, @LastName)
								INSERT INTO HumanResources.Employee VALUES (
									scope_identity(),
									@NationalIDNumber,
									@LoginID,
									@OrganizationNode,
									@JobTitle,
									@BirthDate,
									@MaritalStauts,
									@Gender,
									GETDATE(),
									0,
									0,
									0,
									1,
									NEWID(),
									GETDATE(),
									@salary
								)
							COMMIT TRANSACTION
					END TRY
					BEGIN CATCH					
						ROLLBACK;
						throw;				
					END CATCH;
				end
			
		END
END

--Execute procedures
execute HumanResources.hireAnEmployee @BusinessEntityID=291,@NationalIDNumber='AF1580315',
@LoginID='rajesh101',@OrganizationNode=0x, @JobTitle='Manager',@BirthDate='1990-02-10',@MaritalStauts='S',
@Gender='M',@salary=$1500, @FirstName='RAJESH',@LastName='GHOSH'

--SELECT * FROM HumanResources.Employee WHERE BusinessEntityID =291
--SELECT * FROM Person.BusinessEntity WHERE BusinessEntityID =291
--SELECT * FROM Person.Person WHERE BusinessEntityID =291
