CREATE EXTENSION postgis;

--Zadanie 4
--Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
--położonych w odległości mniejszej niż 1000 m od głównych rzek. Budynki spełniające to
--kryterium zapisz do osobnej tabeli tableB
CREATE TABLE tableB AS
	SELECT COUNT(DISTINCT b.gid) AS liczba_budynkow
	FROM popp as b, majrivers as rz
		WHERE ST_DISTANCE(b.geom, rz.geom) < 1000 
		AND f_codedesc = 'Building';

--DROP TABLE tableB;

--Zadanie 5
--Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
--geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.
--a) Znajdź lotniska, które położone jest najbardziej na zachód i najbardziej na wschód.
--b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie
--środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB.
--Wysokość n.p.m. przyjmij dowolną.

CREATE TABLE airportsNew AS 
SELECT name, geom, elev
FROM airports;

SELECT * FROM airportsNew as am
WHERE ST_X(am.geom) = (SELECT MAX(ST_X(a.geom)) FROM airportsNew as a)
OR ST_X(am.geom) = (SELECT MIN(ST_X(a.geom)) FROM airportsNew as a)

INSERT INTO airportsNew VALUES(
	'airportB', 
	(SELECT ST_CENTROID(ST_SHORTESTLINE((SELECT a.geom FROM airportsNew as a WHERE a.name='ATKA'),(SELECT a.geom FROM airportsNew as a WHERE a.name='ANNETTE ISLAND')))), 60);

SELECT * FROM airportsNew;

--Zadanie 6
--Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
--linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”
SELECT
	ST_Area(ST_Buffer(ST_SHORTESTLINE(ai.geom, lk.geom), 1000)) as powierzchnia
FROM airportsNew as ai, lakes as lk
WHERE
	lk.names = 'Iliamna Lake' and
	ai.name = 'AMBLER'

--Zadanie 7
--Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
--poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

--SELECT ST_INTERSECTION(tr.geom, ST_UNION(sw.geom, tu.geom)) FROM trees as tr, swamp as sw, tundra as tu 

SELECT
	t.vegdesc,
	SUM(ST_Area(t.geom))
FROM trees as t, tundra as tu, swamp as s
WHERE 
	ST_Contains(t.geom, tu.geom) AND
	ST_Contains(t.geom, s.geom)
GROUP BY t.vegdesc

DROP TABLE tundra;
DROP TABLE swamp;
DROP TABLE trees;



