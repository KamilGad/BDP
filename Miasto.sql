CREATE EXTENSION postgis;
--DROP TABLE points;
--DROP TABLE buildings;
--DROP TABLE roads;

--Tworzenie tabel

--Tabela budynki

--Tabela drogi
CREATE TABLE Roads(id INT PRIMARY KEY, name VARCHAR(40), geom GEOMETRY);

--wprowadzanie wartości do tabeli drogi
INSERT INTO Roads VALUES
(0, 'RoadX', ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 0)),
(1, 'RoadY', ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)', 0));

--sprawdzenie
SELECT * FROM Roads;

--Tabela punkty
CREATE TABLE Points(id INT PRIMARY KEY, name char(1), geom GEOMETRY, liczprac INT);

--wprowadzanie wartości do tabeli punkty
INSERT INTO Points VALUES
(0, 'K', ST_GeomFromText('POINT(6 9.5)', 0),1),
(1, 'J', ST_GeomFromText('POINT(6.5 6)', 0),3),
(2, 'I', ST_GeomFromText('POINT(9.5 6)', 0),5),
(3, 'G', ST_GeomFromText('POINT(1 3.5)', 0),6),
(4, 'H', ST_GeomFromText('POINT(5.5 1.5)', 0),7);

--sprawdzenie
SELECT * FROM points;

--Tabela budynki
CREATE TABLE Buildings(id INT PRIMARY KEY, name varchar(30), geom GEOMETRY, wysokosc INT);

--wprowadzenie wartości do tabeli budynki
INSERT INTO Buildings VALUES
(0, 'BuildingA', ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 0), 4),
(1, 'BuildingB', ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 0),6),
(2, 'BuildingC', ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 0), 8),
(3, 'BuildingD', ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 0),10),
(4, 'BuildingF', ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 0), 16);

SELECT * FROM Buildings;

--ZADANIA
--Zad 1
--Wyznacz całkowitą długość dróg w analizowanym mieście.
SELECT sum(ST_LENGTH(geom)) FROM roads;

--Zad 2
--Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego BuildingA.
SELECT ST_AsText(geom), ST_Area(geom),  ST_Perimeter(geom) FROM buildings WHERE name = 'BuildingA'; 

--Zad 3
--Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj 
--alfabetycznie.
SELECT name, ST_AREA(geom) FROM Buildings ORDER BY name;

--Zad 4
--Wypisz nazwy i obwody 2 budynków o największej powierzchni.
SELECT name, ST_Perimeter(geom) FROM Buildings ORDER BY ST_Area(geom) DESC LIMIT 2;

--Zad 5
--Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G. 
SELECT ST_DISTANCE(geom_b.geom, geom_p.geom)
FROM Buildings as geom_b, points as geom_p 
WHERE geom_b.name = 'BuildingC' AND geom_p.name = 'G';

--Zad 6
--Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej 
--niż 0.5 od budynku BuildingB.  
SELECT ST_area(ST_DIFFERENCE(ST_Union(bc.geom, bb.geom),ST_Buffer(bb.geom, 0.5)))
FROM Buildings as bc, Buildings as bb 
WHERE
bc.name = 'BuildingC' AND 
bb.name = 'BuildingB';

SELECT * FROM Buildings;

--Zad 7
--Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi RoadX.
SELECT * FROM Buildings, Roads
WHERE ST_Y(ST_Centroid(Buildings.geom))>ST_Y(ST_Centroid(Roads.geom));

--Zad 8
--Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 
--4 8, 4 7), które nie są wspólne dla tych dwóch obiektów
SELECT ST_area(ST_SymDifference(Buildings.geom, ST_PolygonFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0)))
FROM Buildings
WHERE name = 'BuildingC';



