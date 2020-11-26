USE AdventureWorks2012;
GO

/*
	Создайте scalar-valued функцию, которая будет принимать в 
	качестве входного параметра id отдела 
	(HumanResources.Department.DepartmentID) и возвращать 
	количество сотрудников, работающих в отделе.
*/
CREATE FUNCTION HumanResources.getDepartmentEmployeeCount(@dID INT)
	RETURNS INT
	AS
		BEGIN
			RETURN (
				SELECT COUNT(*) 
				FROM EmployeeDepartmentHistory 
				WHERE EndDate IS NULL AND DepartmentID = @dID
			);
	END;
GO

PRINT HumanResources.getDepartmentEmployeeCount(1);
GO

SELECT *
	FROM HumanResources.EmployeeDepartmentHistory 
	WHERE EndDate IS NULL AND DepartmentID = 1;
GO

/*
	Создайте inline table-valued функцию, которая будет принимать 
	в качестве входного параметра id отдела 
	(HumanResources.Department.DepartmentID), а возвращать 
	сотрудников, которые работают в отделе более 11 лет.
*/
CREATE FUNCTION HumanResources.getDepartmentEmployees(@dID INT)
	RETURNS TABLE
	AS 
		RETURN (
			SELECT * FROM EmployeeDepartmentHistory
			WHERE DepartmentID = @dID AND 
				EndDate IS NULL AND 
				DATEDIFF(YEAR, StartDate, GETDATE()) > 11 
		);
GO

SELECT * FROM HumanResources.getDepartmentEmployees(1);
GO

/*
	Вызовите функцию для каждого отдела, применив оператор CROSS 
	APPLY. Вызовите функцию для каждого отдела, применив оператор 
	OUTER APPLY.
*/
SELECT 
	dep.DepartmentID,
	BusinessEntityID,
	ShiftID,
	StartDate, 
	EndDate,
	emps.ModifiedDate
		FROM
		HumanResources.Department AS dep
			CROSS APPLY
		HumanResources.getDepartmentEmployees(dep.DepartmentID) as emps
		ORDER BY dep.DepartmentID;
GO

SELECT 
	dep.DepartmentID,
	BusinessEntityID,
	ShiftID,
	StartDate, 
	EndDate,
	emps.ModifiedDate
		FROM
		HumanResources.Department AS dep
			OUTER APPLY
		HumanResources.getDepartmentEmployees(dep.DepartmentID) as emps
		ORDER BY dep.DepartmentID;
GO

/*
	Измените созданную inline table-valued функцию, сделав ее 
	multistatement table-valued (предварительно сохранив для 
	проверки код создания inline table-valued функции).
*/
CREATE FUNCTION HumanResources.getDepartmentEmployees2(@dID INT)
	RETURNS @emplyees TABLE (
		DepartmentID SMALLINT NOT NULL,
		BusinessEntityID INT NOT NULL,
		ShiftID TINYINT NOT NULL,
		StartDate DATE NOT NULL, 
		EndDate DATE NULL,
		ModifiedDate DATETIME NOT NULL
	) AS
		BEGIN
			INSERT INTO @emplyees
			SELECT *
				FROM EmployeeDepartmentHistory 
				WHERE DepartmentID = @dID AND 
					  EndDate IS NULL AND 
					  DATEDIFF(YEAR, StartDate, GETDATE()) > 11;
			RETURN;
		END;
GO

SELECT *
FROM HumanResources.getDepartmentEmployees2(1);
GO
