CREATE EXTENSION postgis;

--Zadanie 1
--Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
--pomiędzy 2018 a 2019)
SELECT * FROM T2019_KAR_BUILDINGS AS b2019, T2018_KAR_BUILDINGS AS b2018
WHERE ST_Equals(b2019.geom, b2018.geom) = false

CREATE TABLE nowe_budyneczki AS
(
	SELECT * FROM T2019_KAR_BUILDINGS AS b2019
	WHERE b2019.gid NOT IN (
		SELECT DISTINCT(b2019.gid) FROM T2019_KAR_BUILDINGS AS b2019, T2018_KAR_BUILDINGS AS b2018
		WHERE ST_Equals(b2019.geom, b2018.geom)
	)
)
SELECT * FROM nowe_budyneczki;

--Zadanie 2
--Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
--wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.
SELECT DISTINCT(poi2019.geom) FROM T2019_KAR_POI_TABLE as poi2019, nowe_budyneczki as nb
WHERE poi2019.poi_id NOT IN(
	SELECT poi2018.poi_id FROM T2018_KAR_POI_TABLE AS poi2018
) AND ST_DWithin(poi2019.geom, nb.geom, 500)

--Zadanie 3
--Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini (3068 - wujek google powiedział)
CREATE TABLE streets_reprojected AS
(
	SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel, ST_Transform(geom, 3068) as geom
	FROM T2019_KAR_STREETS
)
SELECT ST_SRID(geom) FROM streets_reprojected


--Zadanie 4
--Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
--Użyj następujących współrzędnych:
--X Y
--8.36093 49.03174
--8.39876 49.00644
--Przyjmij układ współrzędnych GPS - cyli 4326
CREATE TABLE input_points (
	id INT PRIMARY KEY,
	geom Geometry
)


INSERT INTO input_points(id, geom)
VALUES
	(0, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
	(1, ST_GeomFromText('POINT(8.39876 49.00644)', 4326));
	
SELECT * FROM input_points


--Zadanie 5
--Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
--DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().
UPDATE input_points SET geom = ST_Transform(geom, 3068);

SELECT ST_AsText(geom) FROM input_points;

--Zadanie 6
--Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej
--z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj
--reprojekcji geometrii, aby była zgodna z resztą tabel.
SELECT * FROM t2019_kar_street_node AS s2019 
WHERE
	ST_DWithin(ST_Transform(s2019.geom, 3068), (SELECT ST_MakeLine(p.geom) FROM input_points AS p), 200) AND
	s2019.intersect = 'Y';


--Zadanie 7
--Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się
--w odległości 300 m od parków (LAND_USE_A).
SELECT
	COUNT(DISTINCT(pt.gid))
FROM t2019_kar_poi_table as pt, t2019_kar_land_use_a as lu
WHERE
	pt.type = 'Sporting Goods Store' AND 
	lu.type = 'Park (City/County)' AND
	ST_DWithin(pt.geom, lu.geom, 300)
	
--sprawdzenie graficzne 
SELECT
	DISTINCT(pt.geom)
FROM t2019_kar_poi_table as pt, t2019_kar_land_use_a as lu
WHERE
	pt.type = 'Sporting Goods Store' AND
	lu.type = 'Park (City/County)' AND
	ST_DWithin(pt.geom, lu.geom, 300) 

--Zadanie 8
--Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz
--znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’
CREATE TABLE T2019_KAR_BRIDGES AS (
	SELECT DISTINCT(ST_Intersection(r.geom, w.geom))
	FROM t2019_kar_railways AS r,t2019_kar_water_lines AS w
)

SELECT * FROM T2019_KAR_BRIDGES




