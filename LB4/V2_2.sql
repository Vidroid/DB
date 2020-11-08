USE AdventureWorks2012;
GO

/*
	Создайте представление VIEW, отображающее данные 
	из таблиц Production.Location и Production.ProductInventory, 
	а также Name из таблицы Production.Product. Сделайте 
	невозможным просмотр исходного кода представления. 
	Создайте уникальный кластерный индекс в представлении 
	по полям LocationID,ProductID.
*/
CREATE VIEW ProductInfoView 
	WITH SCHEMABINDING, ENCRYPTION AS 
		SELECT 
			l.LocationID,
			l.Name AS LocationName,
			l.CostRate,
			l.Availability,
			l.ModifiedDate AS LocationModifiedDate,
			ppi.ProductID,
			ppi.Shelf,
			ppi.Bin,
			ppi.Quantity,
			ppi.rowguid,
			ppi.ModifiedDate AS ProductInventoryModifiedDate,
			p.Name
		FROM Production.Location AS l
			INNER JOIN Production.ProductInventory AS ppi
		ON l.LocationID = ppi.LocationID
			INNER JOIN Production.Product AS p
		ON ppi.ProductID = p.ProductID;
GO

CREATE UNIQUE CLUSTERED INDEX ProductInfo_IX
	ON ProductInfoView(LocationID, ProductID); 
GO

/*
	Создайте три INSTEAD OF триггера для представления 
	на операции INSERT, UPDATE, DELETE. 
	Каждый триггер должен выполнять соответствующие 
	операции в таблицах Production.Location 
	и Production.ProductInventory для указанного Product Name. 
	Обновление и удаление строк производите только в 
	таблицах Production.Location и Production.ProductInventory
	, но не в Production.Product.
*/
CREATE TRIGGER ProductInfo_Ins_TR
	ON ProductInfoView
		INSTEAD OF INSERT AS
			BEGIN
				INSERT INTO Production.Location 
					SELECT 
						LocationName,
						CostRate,
						Availability,
						LocationModifiedDate
					FROM inserted 
						INNER JOIN Production.Product AS p
					ON inserted.Name = p.Name;
				INSERT INTO Production.ProductInventory
					SELECT
						p.ProductID,
						l.LocationID,
						Shelf,
						Bin,
						Quantity,
						inserted.rowguid,
						ProductInventoryModifiedDate
					FROM inserted
						INNER JOIN Production.Product AS p
					ON inserted.Name = p.Name
						INNER JOIN Production.Location AS l
					ON inserted.LocationName = l.Name;
			END;
GO

CREATE TRIGGER ProductInfo_Upd_TR
	ON ProductInfoView
		INSTEAD OF UPDATE AS 
			BEGIN
				IF UPDATE(LocationID) OR UPDATE(ProductID)
					BEGIN
						RAISERROR ('UPDATE of Primary Key through ProductInfoView is prohibited.', 16, 1);
						ROLLBACK;
					END
				ELSE
					BEGIN
						UPDATE Production.Location
						SET 
							Name = inserted.LocationName,
							CostRate = inserted.CostRate,
							Availability = inserted.Availability,
							ModifiedDate = inserted.LocationModifiedDate
						FROM Production.Location AS l
							INNER JOIN inserted
						ON inserted.LocationID = l.LocationID;
							UPDATE Production.ProductInventory
						SET 
							Shelf = inserted.Shelf,
							Bin = inserted.Bin,
							Quantity = inserted.Quantity,
							rowguid = inserted.rowguid,
							ModifiedDate = inserted.ProductInventoryModifiedDate
						FROM Production.ProductInventory AS ppi
							INNER JOIN inserted
						ON ppi.ProductID = inserted.ProductID;		
					END;
			END;
GO

CREATE TRIGGER ProductInfo_Del_TR
	ON ProductInfoView
		INSTEAD OF DELETE AS 
		BEGIN
			DECLARE @pID INT;
			SELECT @pID = (SELECT ProductID FROM deleted);
			CREATE TABLE #locations (
				LocationID SMALLINT NOT NULL
			);
			INSERT INTO #locations 
				SELECT DISTINCT p.LocationID 
				FROM Production.ProductInventory AS p
					INNER JOIN deleted
				ON deleted.ProductID = p.ProductID
				WHERE p.LocationID NOT IN (
					SELECT DISTINCT ppi.LocationID 
					FROM Production.ProductInventory as ppi 
					WHERE ppi.ProductID != @pID
				); 
			DELETE p
				FROM Production.ProductInventory AS p
				WHERE p.ProductID = @pID;
			DELETE l 
				FROM Production.Location AS l
				WHERE LocationID IN (SELECT * FROM #locations);
		END;
GO
/*
	Вставьте новую строку в представление, указав 
	новые данные для Location и ProductInventory, 
	но для существующего Product (например для ‘Adjustable Race’). 
	Триггер должен добавить новые строки в таблицы 
	Production.Location и Production.ProductInventory 
	для указанного Product Name. Обновите вставленные 
	строки через представление. Удалите строки.
*/
INSERT INTO ProductInfoView (
	LocationName,
	CostRate,
	Availability,
	LocationModifiedDate,
	Shelf,
	Bin,
	Quantity,
	rowguid,
	ProductInventoryModifiedDate,
	Name
) VALUES (
	'Oloe',
	20.1,
	0.5,
	CURRENT_TIMESTAMP,
	'A',
	5,
	445,
	NewID(),
	CURRENT_TIMESTAMP,
	'Lock Nut 5'
);
GO

SELECT * FROM Production.Location
	WHERE Name = 'Oloe';
GO

SELECT TOP 2 * FROM Production.ProductInventory
	ORDER BY ModifiedDate DESC;
GO

UPDATE ProductInfoView
	SET LocationID = 7
	WHERE Name = 'Lock Nut 5';
GO

UPDATE ProductInfoView
	SET CostRate = 5.4
	WHERE Name = 'Lock Nut 5';
GO

SELECT ppi.LocationID, p.Name, CostRate 
	FROM Production.Location
		INNER JOIN Production.ProductInventory AS ppi
	ON ppi.LocationID = Production.Location.LocationID
		INNER JOIN Production.Product AS p
	ON p.ProductID = ppi.ProductID
	WHERE p.Name = 'Lock Nut 5';
GO

UPDATE ProductInfoView
	SET Quantity = 7
	WHERE Name = 'Lock Nut 5';
GO

SELECT Name, Quantity
	FROM Production.ProductInventory AS ppi
		INNER JOIN Production.Product AS p
	ON ppi.ProductID = p.ProductID
	WHERE Name = 'Lock Nut 5';
GO

DELETE FROM ProductInfoView
	WHERE Name = 'Lock Nut 5';	
GO

SELECT COUNT(*) AS recCount
	FROM Production.Location AS l
		INNER JOIN Production.ProductInventory AS ppi
	ON ppi.LocationID = l.LocationID
		INNER JOIN Production.Product AS p
	ON p.ProductID = ppi.ProductID
	WHERE p.Name = 'Lock Nut 5';
GO
