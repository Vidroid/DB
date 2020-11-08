USE AdventureWorks2012;
GO

/*
	Вывести на экран историю сотрудника, который 
	работает на позиции ‘Purchasing Manager’.
	В каких отделах компании он работал, 
	с указанием периодов работы в каждом отделе.
*/

SELECT emp.BusinessEntityID, JobTitle, dep.Name 
		AS DepartmentName, StartDate, EndDate
	FROM HumanResources.Employee AS emp
		INNER JOIN HumanResources.EmployeeDepartmentHistory AS eph
	ON emp.BusinessEntityID = eph.BusinessEntityID
		INNER JOIN HumanResources.Department AS dep
	ON eph.DepartmentID = dep.DepartmentID
		WHERE JobTitle = 'Purchasing Manager';
GO

/*
	Вывести на экран список сотрудников, у которых 
	почасовая ставка изменялась хотя бы один раз.
*/

SELECT emp.BusinessEntityID, JobTitle, COUNT(*) 
		AS RateCount
	FROM HumanResources.EmployeePayHistory AS eph
		INNER JOIN HumanResources.Employee AS emp
	ON emp.BusinessEntityID = eph.BusinessEntityID 
		GROUP BY emp.BusinessEntityID, JobTitle
	HAVING COUNT(*) > 1;
GO

/*
	Вывести на экран максимальную почасовую ставку 
	в каждом отделе. Вывести только актуальную информацию. 
	Если сотрудник больше не работает в отделе — не учитывать 
	такие данные
*/

SELECT dep.DepartmentID, dep.Name, MAX(eph.Rate) AS MaxRate
	FROM HumanResources.EmployeePayHistory AS eph
		INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
	ON edh.BusinessEntityID = eph.BusinessEntityID
		INNER JOIN HumanResources.Department AS dep
	ON dep.DepartmentID = edh.DepartmentID
		WHERE EndDate IS NULL
	GROUP BY dep.DepartmentID, dep.Name
		ORDER BY dep.DepartmentID;
GO