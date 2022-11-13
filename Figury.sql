CREATE EXTENSION postgis;


--Zadanie 1
--Utwórz tabelę obiekty. W tabeli umieść nazwy i geometrie obiektów przedstawionych poniżej. Układ odniesienia
--ustal jako niezdefiniowany. Definicja geometrii powinna odbyć się za pomocą typów złożonych, właściwych dla EWKT.

CREATE TABLE Obiekty (
	id INT PRIMARY KEY,
	nazwa VARCHAR(30),
	geom GEOMETRY
);

--Obiekt1
INSERT INTO Obiekty 
VALUES
(1, 'Obiekt1', ST_GeomFromEWKT('COMPOUNDCURVE((0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1), (5 1, 6 1))'));
							  
--Obiekt2
INSERT INTO Obiekty VALUES(
	2, 'Obiekt2', ST_GeomFromEWKT('CURVEPOLYGON(COMPOUNDCURVE((10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2), CIRCULARSTRING(14 2, 12 0, 10 2), (10 2, 10 6)), CIRCULARSTRING(11 2, 13 2, 11 2), CIRCULARSTRING(13 2, 11 2, 13 2) )')
);

--Version 2
INSERT INTO Obiekty 
VALUES
(2, 'Obiekt2', ST_GeomFromEWKT('CURVEPOLYGON(COMPOUNDCURVE((10 2, 10 6), (10 6, 14 6), 
							   CIRCULARSTRING(14 6, 16 4, 14 2), CIRCULARSTRING(14 2, 12 0, 10 2)), 
							   CIRCULARSTRING(11 2, 13 2, 11 2),
							   CIRCULARSTRING(13 2, 11 2, 13 2)')
							  );


--version 2 
(2, 'Obiekt2', ST_Union(ARRAY[ST_GeomFromEWKT('LINESTRING(10 2, 10 6)'),
							  ST_GeomFromEWKT('LINESTRING(10 6, 14 6)'),
							  ST_GeomFromEWKT('CIRCULARSTRING(14 6, 16 4, 14 2)'),
							  ST_GeomFromEWKT('CIRCULARSTRING(14 2, 12 0, 10 2)'),
							  ST_GeomFromEWKT('CIRCULARSTRING(11 2, 12 3, 13 2)'),
							  ST_GeomFromEWKT('CIRCULARSTRING(11 2, 12 1, 13 2)')]));

--Obiekt3
INSERT INTO Obiekty
VALUES
(3, 'Obiekt3', ST_GeomFromEWKT('COMPOUNDCURVE((7 15, 10 17, 12 13, 7 15))'));

--Obiekt4
INSERT INTO Obiekty
VALUES
(4, 'Obiekt4', ST_GeomFromEWKT('COMPOUNDCURVE((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5))'));

--Obiekt5
INSERT INTO Obiekty
VALUES
(5, 'Obiekt5', ST_GeomFromEWKT('MULTIPOINT Z((30 30 59), (38 32 234))'));


--Obiekt6
INSERT INTO Obiekty
VALUES
(6, 'Obiekt6', ST_Collect(ST_GeomFromEWKT('LINESTRING(1 1, 3 2)'), ST_GeomFromEWKT('POINT(4 2)')));

SELECT * FROM Obiekty;
TRUNCATE TABLE Obiekty;

--Zadanie 1
--Wyznacz pole powierzchni bufora o wielkości 5 jednostek, 
--który został utworzony wokół najkrótszej linii łączącej obiekt 3 i 4
SELECT 
	ST_Area(ST_Buffer(ST_Shortestline(Obiekt3.geom, Obiekt4.geom), 5)) As Area
FROM Obiekty as Obiekt3, Obiekty as Obiekt4
WHERE Obiekt3.id = 3 AND Obiekt4.id = 4;

--Zadanie 2
--Zamień obiekt4 na poligon. 
--Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te warunki.
--Musi być zamknięte 
SELECT 
	ST_MakePolygon(ST_AddPoint(ST_CurveToLine(geom), ST_StartPoint(geom)))
FROM Obiekty
WHERE Obiekty.id = 4;

--Zadanie 3
--W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4
INSERT INTO Obiekty
	VALUES(7, 'Obiekt7', (SELECT ST_Union(Obiekt3.geom, Obiekt4.geom)
						  FROM Obiekty as Obiekt3, Obiekty as Obiekt4
						  WHERE Obiekt3.id = 3 AND Obiekt4.id = 4))

--Zadanie 4
--Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, 
--które zostały utworzone wokół obiektów nie zawierających łuków.
SELECT ST_Area(St_Buffer(geom, 5)) AS area 
FROM Obiekty
WHERE  ST_HasArc(geom) = false;




