USE AdventureWorks2012;
GO

/*
	добавьте в таблицу dbo.PersonPhone поле HireDate 
	типа date;
*/
ALTER TABLE dbo.PersonPhone ADD HireDate DATE;
GO

/*
	объявите табличную переменную с такой же структурой 
	как dbo.PersonPhone и заполните ее данными из 
	dbo.PersonPhone. Заполните поле HireDate значениями 
	из поля HireDate таблицы HumanResources.Employee;
*/
DECLARE @personPhone TABLE (
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NULL,
	PhoneNumberTypeID BIGINT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	ID BIGINT NOT NULL,
	HireDate DATE NULL);
INSERT INTO @personPhone 
	SELECT 
		pp.BusinessEntityID, 
		PhoneNumber,
		PhoneNumberTypeID,
		pp.ModifiedDate,
		ID,
		emp.HireDate
	FROM dbo.PersonPhone AS pp
		INNER JOIN HumanResources.Employee AS emp
	ON pp.BusinessEntityID = emp.BusinessEntityID;


/*
	обновите HireDate в dbo.PersonPhone данными из табличной 
	переменной, добавив к HireDate один день;
*/

	 UPDATE dbo.PersonPhone
		SET dbo.PersonPhone.HireDate = 
		DATEADD(DAY, 1, pPhone.HireDate)
	 FROM dbo.PersonPhone AS pp
		INNER JOIN @personPhone AS pPhone
	 ON pp.BusinessEntityID = pPhone.BusinessEntityID;

	 SELECT * FROM dbo.PersonPhone;
 GO	

 /*
	удалите данные из dbo.PersonPhone, для тех сотрудников, 
	у которых почасовая ставка в таблице 
	HumanResources.EmployeePayHistory больше 50;
 */
 DELETE FROM dbo.PersonPhone
	 WHERE EXISTS (
		SELECT BusinessEntityID
			FROM HumanResources.EmployeePayHistory AS eph
		WHERE dbo.PersonPhone.BusinessEntityID = 
		eph.BusinessEntityID AND Rate > 50
	);
GO

SELECT * FROM HumanResources.EmployeePayHistory 
	WHERE Rate > 50;
GO

 /*
	удалите все созданные ограничения и значения по умолчанию. 
	После этого, удалите поле ID.
*/

SELECT *
	FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
	WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone';
GO

SELECT *
	FROM AdventureWorks2012.INFORMATION_SCHEMA.CHECK_CONSTRAINTS
	WHERE CONSTRAINT_SCHEMA = 'dbo';
GO

ALTER TABLE dbo.PersonPhone 
	DROP CONSTRAINT 
	Check_PhoneNumber, DF_PhoneNumberTypeID, UQ__PersonPh__3214EC260E75607B;
GO

ALTER TABLE dbo.PersonPhone
	DROP COLUMN ID;
GO

/*
	удалите таблицу dbo.PersonPhone.
*/
DROP TABLE dbo.PersonPhone;
GO