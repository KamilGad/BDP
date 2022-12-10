CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

CREATE SCHEMA rasters; 
CREATE SCHEMA vectors;

-- C:\Program Files\PostgreSQL\14\bin\raster2pgsql" -s 27700 -N 32767 -t 100x100 -I -C -M -d ./ras250_gb/data/*.tif rasters.uk_250k > ./uk_250k.sql

--Zadanie 2
--Załaduj te dane do tabeli o nazwie uk_250k
SELECT * FROM rasters.uk_250k;

-- a. Dodanie serial primary key
ALTER TABLE rasters.uk_250k
ADD COLUMN rid SERIAL PRIMARY KEY;

-- b. Utworzenie indeksu przestrzennego
CREATE INDEX idx_uk_250k ON rasters.uk_250k
USING gist (ST_ConvexHull(rast));

-- c. Dodanie raster constraints
SELECT AddRasterConstraints('rasters'::name,
'uk_250k'::name,'rast'::name);

--Zadanie 3
--Połącz te dane (wszystkie kafle) w mozaikę, a następnie wyeksportuj jako GeoTIFF.
CREATE TABLE rasters.uk_250k_union AS
SELECT ST_Union(r.rast)
FROM rasters.uk_250k AS r

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM rasters.uk_250k_union;

-- Zapisywanie pliku na dysku 
SELECT lo_export(loid, 'C:/Users/kamil/Documents/AGH/Semestr_5/Bazy_DanychP/Lab_7/uk_250k_union.tif')
FROM tmp_out;

-- Usuwanie obiektu
SELECT lo_unlink(loid)
FROM tmp_out;

-- Usuniecie tabeli 
DROP TABLE tmp_out;

--Zadanie 5
--Załaduj do bazy danych tabelę reprezentującą granice parków narodowych.
SELECT * FROM uk_national_parks;


--Zadanie 6
--Utwórz nową tabelę o nazwie uk_lake_district, do której zaimportujesz mapy rastrowe
--z punktu 1., które zostaną przycięte do granic parku narodowego Lake District.
CREATE TABLE rasters.uk_lake_district AS
SELECT ST_Clip(r.rast, u.wkb_geometry, true) AS rast, u.id
FROM rasters.uk_250k AS r, public.uk_national_parks AS u
WHERE ST_Intersects(r.rast, u.wkb_geometry) AND u.id = 1;

DROP TABLE rasters.uk_lake_district

--Zadanie 7
--Wyeksportuj wyniki do pliku GeoTIFF
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM rasters.uk_lake_district;

-- Zapisywanie pliku na dysku 
SELECT lo_export(loid, 'C:/Users/public/uk_lake_district.tif')
FROM tmp_out;

-- Usuwanie obiektu
SELECT lo_unlink(loid)
FROM tmp_out;

-- Usuniecie tabeli 
DROP TABLE tmp_out;

--Zadanie 8
--Pobierz dane z satelity Sentinel-2 wykorzystując portal: https://scihub.copernicus.eu
--Wybierz dowolne zobrazowanie, które pokryje teren parku Lake District oraz gdzie parametr
--cloud coverage będzie poniżej 20%


--Zadanie 9
--Załaduj dane z Sentinela-2 do bazy danych.
SELECT * FROM rasters.sentinel2_lake_district

--Zadanie 10
--Policz indeks NDWI oraz przytnij wyniki do granic Lake District.
CREATE TABLE rasters.lake_district_ndvi AS
WITH r AS (
	SELECT r.rid, r.rast AS rast
	FROM rasters.sentinel2_lake_district AS r
)
SELECT
	r.rid, ST_MapAlgebra(
		r.rast, 1,
		r.rast, 4,
		'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
	) AS rast
FROM r;

--Zadanie 11
--Wyeksportuj obliczony i przycięty wskaźnik NDWI do GeoTIFF.

-- a. Dodanie serial primary key
ALTER TABLE rasters.lake_district_ndvi
ADD COLUMN rid SERIAL PRIMARY KEY;

-- b. Utworzenie indeksu przestrzennego
CREATE INDEX idx_sentinel2_ndvi ON rasters.lake_district_ndvi
USING gist (ST_ConvexHull(rast));

-- c. Dodanie raster constraints
SELECT AddRasterConstraints('rasters'::name,
'lake_district_ndvi'::name,'rast'::name);


CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM rasters.lake_district_ndvi;

-- Zapisywanie pliku na dysku 
SELECT lo_export(loid, 'C:/Users/public/lake_district_ndvi.tif')
FROM tmp_out;

-- Usuwanie obiektu
SELECT lo_unlink(loid)
FROM tmp_out;

DROP TABLE tmp_out;