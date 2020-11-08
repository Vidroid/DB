USE AdventureWorks2012;
GO

/*
	Вывести на экран список отделов, отсортированных по названию отдела в порядке Z-A. 
	Вывести на экран только 5 строк, начиная с 3-ей строки.
*/
SELECT DepartmentID, Name
FROM HumanResources.Department 
ORDER BY Name DESC OFFSET 2 ROWS FETCH NEXT 5 ROWS ONLY;
GO


/*
	Вывести на экран список неповторяющихся позиций, которые соответствуют первому уровню позиций в организации (OrganizationLevel).
*/
SELECT DISTINCT JobTitle
FROM HumanResources.Employee 
WHERE OrganizationLevel = 1;
GO
	
/*
	Вывести на экран сотрудников, которым исполнилось 18 лет в тот год, когда их приняли на работу.
*/
SELECT TOP 5 BusinessEntityID, JobTitle, Gender, BirthDate, HireDate 
FROM HumanResources.Employee
WHERE DATEDIFF(YEAR, BirthDate, HireDate) > 18;
GO