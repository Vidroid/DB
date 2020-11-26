USE AdventureWorks2012;
GO

/*
	Создайте хранимую процедуру, которая будет возвращать сводную таблицу 
	(оператор PIVOT), отображающую данные о максимальном весе 
	(Production.Product.Weight) продукта в каждой подкатегории 
	(Production.ProductSubcategory) для определенного цвета. 
	Список цветов передайте в процедуру через входной параметр.

	Таким образом, вызов процедуры будет выглядеть следующим образом:

	EXECUTE dbo.SubCategoriesByColor ‘[Black],[Silver],[Yellow]’
*/
CREATE PROCEDURE SubCategoriesByColor @colors NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @query NVARCHAR(MAX);
			SET @query = 'SELECT * FROM (
								SELECT ps.Name, p.Weight, p.Color
								FROM Production.ProductSubcategory AS ps
									INNER JOIN Production.Product AS p
								ON p.ProductSubcategoryID = ps.ProductSubcategoryID) 
								AS s
						  PIVOT(
								MAX(Weight) for Color IN (' +
									@colors
								+ ')
						  ) piu;';
		EXECUTE sp_executesql  @query;
	END;
GO

EXECUTE dbo.SubCategoriesByColor '[Black],[Silver],[Yellow]';
GO
