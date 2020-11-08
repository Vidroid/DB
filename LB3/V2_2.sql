USE AdventureWorks2012;
GO

/*
	a) выполните код, созданный во втором задании второй лабораторной работы. 
	Добавьте в таблицу dbo.PersonPhone поля JobTitle NVARCHAR(50), BirthDate DATE и HireDate DATE. 
	Также создайте в таблице вычисляемое поле HireAge, считающее количество лет, прошедших между BirthDate и HireDate.
*/
ALTER TABLE dbo.PersonPhone 
ADD 
	JobTitle NVARCHAR(50), 
	BirthDate DATE, 
	HireDate DATE,
	HireAge AS DATEDIFF(YEAR, BirthDate, HireDate
);
GO

/*
	b) создайте временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID.
	Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля HireAge.
*/
CREATE TABLE #PersonPhone (
	BusinessEntityID INT NOT NULL PRIMARY KEY,
	PhoneNumber NVARCHAR(25) NULL,
	PhoneNumberTypeID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	ID BIGINT NOT NULL,
	JobTitle NVARCHAR(25) NULL,
	BirthDate DATE NULL,
	HireDate DATE NULL
);
GO

/*
	c) заполните временную таблицу данными из dbo.PersonPhone. 
	Поля JobTitle, BirthDate и HireDate заполните значениями из таблицы HumanResources.Employee. 
	Выберите только сотрудников с JobTitle = ‘Sales Representative’. 
	Выборку данных для вставки в табличную переменную осуществите в Common Table Expression (CTE).
*/
WITH cte AS (
	SELECT 
		pp.BusinessEntityID,
		pp.PhoneNumber,
		pp.PhoneNumberTypeID,
		pp.ModifiedDate,
		pp.ID,
		emp.JobTitle, 
		emp.BirthDate, 
		emp.HireDate
	FROM dbo.PersonPhone AS pp
	INNER JOIN HumanResources.Employee AS emp
	ON emp.BusinessEntityID = pp.BusinessEntityID
	WHERE emp.JobTitle = 'Sales Representative'
)
INSERT INTO #PersonPhone  
SELECT * FROM cte;
GO

SELECT * FROM #PersonPhone;
GO

/*
	d) удалите из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 275)
*/

DELETE FROM dbo.PersonPhone
WHERE BusinessEntityID = 275;
GO

SELECT COUNT(*) FROM dbo.PersonPhone
WHERE BusinessEntityID = 275;
GO

/*
	e) напишите Merge выражение, использующее dbo.PersonPhone как target, а временную таблицу как source. 
	Для связи target и source используйте BusinessEntityID. Обновите поля JobTitle, BirthDate и HireDate, 
	если запись присутствует и в source и в target. Если строка присутствует во временной таблице,
	но не существует в target, добавьте строку в dbo.PersonPhone. Если в dbo.PersonPhone присутствует такая строка, 
	которой не существует во временной таблице, удалите строку из dbo.PersonPhone. 
*/		
SET IDENTITY_INSERT dbo.PersonPhone ON;
GO

MERGE dbo.PersonPhone AS t
USING #PersonPhone AS s
ON t.BusinessEntityID = s.BusinessEntityID
WHEN MATCHED THEN
UPDATE SET 
	t.JobTitle = s.JobTitle,
	t.BirthDate = s.BirthDate,
	t.HireDate = s.HireDate
WHEN NOT MATCHED BY TARGET THEN
INSERT (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	ID,
	JobTitle, 
	BirthDate, 
	HireDate
)
VALUES (
	s.BusinessEntityID,	
	s.PhoneNumber,
	s.PhoneNumberTypeID,
	s.ModifiedDate,
	s.ID,
	s.JobTitle, 
	s.BirthDate, 
	s.HireDate
)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;
GO

SET IDENTITY_INSERT dbo.PersonPhone OFF;
GO

SELECT COUNT(*) FROM dbo.PersonPhone
WHERE BusinessEntityID = 275;
GO