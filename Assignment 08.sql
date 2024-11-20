/*=========================== Part 01 (StoredProcedure) ===========================*/
--Part 01
--1.	Create a stored procedure to show the number of students per department.[use ITI DB] 
Use ITI

GO
Create Procedure ShoeNumOfStudentsPerDepartment
AS
	Select D.Dept_Name , COUNT(S.St_Id) [Number Of Students]
	From Department D ,Student S
	Where D.Dept_Id = S.St_Id
	Group By D.Dept_Name
GO
--Run

ShoeNumOfStudentsPerDepartment

--2.	Create a stored procedure that will check for the Number of employees in the project 100 if they are more than 3 print message to the user “'The number of employees in the project 100 is 3 or more'” if they are less display a message to the user “'The following employees work for the project 100'” in addition to the first name and last name of each one. [MyCompany DB] 

Use MyCompany
GO
Create Proc CheckNumberOfEmployees
As
	Declare @x int 
	Select @x = COUNT(ESSn)
	From Works_for 
	Where Pno = 100

	if(@x > 3)
		Select 'The number of employees in the project 100 is 3 or more'
	else
		Select 'The following employees work for the project 100: '
		Select Fname + ' ' + Lname [Full Name]
		From Employee E , Works_for W
		Where E.SSN = W.ESSn and W.Pno = 100
GO

--Run

CheckNumberOfEmployees

--3.	Create a stored procedure that will be used in case an old employee has left the project and a new one becomes his replacement. The procedure should take 3 parameters (old Emp. number, new Emp. number and the project number) and it will be used to update works_on table. [MyCompany DB]
GO
Create Proc SP_UpdateNewEmployee @OldEmp int , @NewEmp int , @PNum int
As
	Update Works_for
		Set ESSn = @NewEmp
		Where ESSn = @OldEmp  and Pno = @PNum

GO

Exec SP_UpdateNewEmployee 1111 , 2222 , 2
/*========================================================================================================*/
--Part 02
--1.	Create a stored procedure that calculates the sum of a given range of numbers
Go
Create Procedure SP_CalculateSum @StartNumber int , @EndNumber int , @Sum int Output
AS
Begin
	Set @Sum = 0

	While @StartNumber <= @EndNumber
		Begin
			Set @Sum = @Sum + @StartNumber
			Set @StartNumber = @StartNumber + 1
		End
End
GO

Declare @Result int
Exec SP_CalculateSum @StartNumber = 1 , @EndNumber = 10 , @Sum = @Result Output
Select @Result

--2.	Create a stored procedure that calculates the area of a circle given its radius
GO
Create Proc CalculateCircleArea @Radius Float , @Area Float Output 
AS
	Begin
		Set @Area = PI() * POWER(@Radius,2)
	End
Go

Declare @Result Float
Exec CalculateCircleArea @Radius = 5 , @Area = @Result Output
Select @Result

--3.	Create a stored procedure that calculates the age category based on a person's age ( Note: IF Age < 18 then Category is Child and if  Age >= 18 AND Age < 60 then Category is Adult otherwise  Category is Senior)
Go
Create Proc CalculateAgeCategory @Age int , @Category Varchar(max) Output 
As
Begin
	if @Age < 18
		Set @Category = 'Child'
	else if @Age >= 18 and @Age < 60
		Set @Category = 'Adult'
	else
		Set @Category = 'Senior'
End
GO

Declare @Category Varchar(max)
Exec CalculateAgeCategory @Age = 45 , @Category  = @Category Output
Select @Category

--4.	Create a stored procedure that determines the maximum, minimum, and average of a given set of numbers ( Note : set of numbers as Numbers = '5, 10, 15, 20, 25')
GO
Create Proc CalculateStatistics 
	@Numbers Varchar(max),
	@MaxValue int Output,
	@MinValue int Output,
	@Average Float output

As
Begin
	Create Table #TempNumbers (Value int)

	Insert Into #TempNumbers (Value)
	Select Value
	From string_split (@Numbers , ',')


	Select @MaxValue = MAX(Value) , @MinValue = MIN(Value) , @Average = AVG(Value)
	From #TempNumbers

	Drop Table #TempNumbers

End
GO

Declare @MaxValue int
Declare @MinValue int
Declare @Average Float

Exec CalculateStatistics  @Numbers  = '5,10,15,20,25' , @MaxValue = @MaxValue Output , @MinValue = @MinValue Output , @Average = @Average Output 

Select @MaxValue as MaxValue , @MinValue As MinValue , @Average As AverageValue


SELECT @@VERSION;

SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'MyCompany';

ALTER DATABASE MyCompany
SET COMPATIBILITY_LEVEL = 130;

SELECT value
FROM STRING_SPLIT('a,b,c,d', ',');
/*========================================================================================================*/
--Part 03
--Use ITI DB
use ITI
--1.	Create a trigger to prevent anyone from inserting a new record in the Department table ( Display a message for user to tell him that he can’t insert a new record in that table )
GO
Create Trigger PreventInsertInDepartment
on Department 
instead of insert
as
	Select 'You can’t insert a new record in that table'
GO

insert into Department (Dept_Id , Dept_Name)
Values (2 , 'aaa')
--2.	Create a table named “StudentAudit”. Its Columns are (Server User Name , Date, Note) 

--Server User Name   --	Date 	Note

Create Table StudentAudit
(
	ServerUserName varChar(max),
	Date date,
	Note Varchar(Max)
)
		


--3.	Create a trigger on student table after insert to add Row in StudentAudit table 
		--•	 The Name of User Has Inserted the New Student  
		--•	Date
		--•	Note that will be like ([username] Insert New Row with Key = [Student Id] in table [table name]
GO
Create Trigger AfterInsertInStudent
On Student
After insert
AS
	declare @Note varchar(Max) , @ST_Id int
	Select @ST_Id =  St_Id From inserted

	Select @Note = CONCAT(SUSER_NAME() , ' Insert New Row with Key ' , @ST_Id , ' in table Student')

	insert into StudentAudit
	Values (SUSER_NAME() , GETDATE() , @Note)
GO

insert into Student (St_Id) Values(2024)

Select * From StudentAudit


--4.	Create a trigger on student table instead of delete to add Row in StudentAudit table 
		--○	 The Name of User Has Inserted the New Student
		--○	Date
		--○	Note that will be like “try to delete Row with id = [Student Id]” 

GO
Create Trigger DeleteStudent
on Student
Instead Of Delete
AS
	Declare @Note Varchar(Max) , @St_Id int
	Select @St_Id = St_Id from deleted

	insert into StudentAudit
	Values (SUSER_NAME() , GETDATE() , CONCAT(' try to delete Row with id = ' , @St_Id))
GO

Delete From Student Where St_Id = 2024

Select * From StudentAudit


------------------------------------------------------------------------------------------------------------------------

/*========================================================================================================*/
--Part 04

--Use MyCompany DB:
use MyCompany
--1.	Create a trigger that prevents the insertion Process for Employee table in March.
GO
Create Trigger PreventInsertInEmployee
On Employee
instead of Insert
AS
	Begin
		if FORMAT(GETDATE() , 'MMMM') = 'March'
			Select 'You cannot insert a new record in that table in march month'
		Else
			insert into Employee
			Select * From inserted
	End
Go

insert into Employee (SSN , Lname) Values (1 , 'Ali')
------------------------------------------------------------------------------------------------------------------------
--Use IKEA_Company:
use [IKEA_Company]
--6.	Create an Audit table with the following structure 

--ProjectNo		UserName 	ModifiedDate 	Budget_Old 		Budget_New 
--p2			Dbo			2008-01-31			95000		200000

--This table will be used to audit the update trials on the Budget column (Project table, Company DB)
--If a user updated the budget column then the project number, username that made that update,  the date of the modification and the value of the old and the new budget will be inserted into the Audit table
--(Note: This process will take place only if the user updated the budget column)
Create Table AuditUpdateOnBudget
(
	ProjectNo int , 
	UserName varchar(Max),
	ModifiedDate date,
	Budget_Old int ,
	Budget_New int
)
GO
Create Trigger HR.UpdateBudget
on HR.Project
After Update
AS
	if Update(Budget)

	Begin
		Declare @PNum int , @OldBudget int , @NewBudget int
		Select @OldBudget =  Budget From deleted
		Select @NewBudget = Budget From inserted
		Select @PNum = ProjectNo From inserted

		insert into AuditUpdateOnBudget
		Values (@PNum , SUSER_NAME() , GETDATE() , @OldBudget , @NewBudget)
	End

GO

Update HR.Project
	Set Budget = 223
	Where ProjectNo = 1


Select * From AuditUpdateOnBudget

----------------------------------------------------------------------------------------------------

--Part 05

--Use ITI DB :
use ITI
--•	Create an index on column (Hiredate) that allows you to cluster the data in table Department. What will happen?
use iti 

create clustered index myindex
on Department(Manager_hiredate)

--•	Create an index that allows you to enter unique ages in the student table. What will happen?
create unique index myIndex02
on student(st_age)

--- can't create unique index because  there is duplicate key in the colunm (St_Age)

--•	Try to Create Login Named(RouteStudent) who can access Only student and Course tables from ITI DB then allow him to select and insert data into tables and deny Delete and update

----------------------------------------------------------------------------------------------------


Alter Schema HR
Transfer [dbo].[Student]

Alter Schema HR
Transfer [dbo].[Course]



