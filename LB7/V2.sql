USE AdventureWorks2012;
GO

/*
	Вывести значения полей [ProductID], [Name], [ProductNumber] из таблицы 
	[Production].[Product] в виде xml, сохраненного в переменную. Формат 
	xml должен соответствовать примеру.
*/
DECLARE @xml XML;
	SET @xml = ( 
		SELECT TOP 2 ProductID AS [@ID], Name, ProductNumber FROM 
		Production.Product
		FOR XML PATH('Product'), ROOT('Products')
	);
	SELECT @xml;
GO

/*
	Создать хранимую процедуру, возвращающую таблицу, заполненную из xml 
	переменной представленного вида. Вызвать эту процедуру для заполненной 
	на первом шаге переменной.
*/
CREATE PROCEDURE ParseXML(@x XML)
AS
	BEGIN
		DECLARE @xml_doc INT;
		EXEC sp_xml_preparedocument @xml_doc OUTPUT, @x;
			SELECT * FROM 
			OPENXML(@xml_doc, '/Products/Product', 2)
				WITH (
					ProductID INT '@ID',
					Name NVARCHAR(50),
					ProductNumber NVARCHAR(50)
				);
			EXEC sp_xml_removedocument @xml_doc;
	END;
GO

DECLARE @xml XML;
	SET @xml = ( 
		SELECT TOP 2 
			ProductID AS [@ID], 
			Name, 
			ProductNumber 
		FROM Production.Product
		FOR XML PATH('Product'), ROOT('Products')
	);
	EXECUTE dbo.ParseXML @xml;
GO