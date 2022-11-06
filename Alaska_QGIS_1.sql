CREATE EXTENSION postgis;

--Zadanie 2
--Podziel warstwę trees na trzy warstwy. Na każdej z nich umieść inny typ lasu. Zapisz wyniki do osobnych tabel.

SELECT * FROM Deciduous_1;
SELECT * FROM Mixed_trees_1;
SELECT * FROM Evergreen_1;

--Zadanie 5
--Utwórz warstwę (tabelę), na której znajdować się będą jedynie budynki położone w regionie Bristol Bay 
--(wykorzystaj warstwę popp). Podaj liczbę budynków.
SELECT COUNT(*) FROM popp_bristol_bay;
SELECT * FROM popp_bristol_bay;


--Zadanie 6
--W tabeli wynikowej z poprzedniego zadania zostaw tylko te budynki, które są położone nie dalej niż 100 km od rzek (rivers).
--Ile jest takich budynków?
SELECT * FROM rivers;

SELECT * FROM popp_bristol_bay AS b, rivers as r
WHERE ST_Distance(b.wkb_geometry,r.geom)<=100000;

--Zadanie 8
--Wydobądź węzły dla warstwy railroads. Ile jest takich węzłów? Zapisz wynik w postaci osobnej
--tabeli w bazie danych.
SELECT COUNT(*) FROM wezly_train;



--WHERE ST_CONTAINS(b.wkb_geometry, ST_BUFFER(r.geom, 100))