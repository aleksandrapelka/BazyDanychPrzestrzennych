-- 1) Utworzenie bazy danych:
CREATE DATABASE cwiczenie1;

-- 2) Dodanie funkcjonalnosci postGISa do bazy:
CREATE EXTENSION postgis;

-- 3) Utworzenie tabel: 
CREATE TABLE buildings (id INT PRIMARY KEY, geometry GEOMETRY NOT NULL, name VARCHAR(20));
CREATE TABLE roads (id INT PRIMARY KEY, geometry GEOMETRY NOT NULL, name VARCHAR(20));
CREATE TABLE poi (id INT PRIMARY KEY, geometry GEOMETRY NOT NULL, name VARCHAR(20));

-- 4) Wypelnienie tabel:
INSERT INTO buildings VALUES(1, ST_GeometryFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 0), 'BuildingA');
INSERT INTO buildings VALUES(2, ST_GeometryFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 0), 'BuildingB');
INSERT INTO buildings VALUES(3, ST_GeometryFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 0), 'BuildingC');
INSERT INTO buildings VALUES(4, ST_GeometryFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 0), 'BuildingD');
INSERT INTO buildings VALUES(5, ST_GeometryFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 0), 'BuildingF');

INSERT INTO roads VALUES(1, ST_GeometryFromText('LINESTRING(0 4.5, 12 4.5)', 0), 'RoadX');
INSERT INTO roads VALUES(2, ST_GeometryFromText('LINESTRING(7.5 0, 7.5 10.5)', 0), 'RoadY');

INSERT INTO poi VALUES(5, ST_GeometryFromText('POINT(1 3.5)', 0), 'G');
INSERT INTO poi VALUES(4, ST_GeometryFromText('POINT(5.5 1.5)', 0), 'H');
INSERT INTO poi VALUES(3, ST_GeometryFromText('POINT(9.5 6)', 0), 'I');
INSERT INTO poi VALUES(2, ST_GeometryFromText('POINT(6.5 6)', 0), 'J');
INSERT INTO poi VALUES(1, ST_GeometryFromText('POINT(6 9.5)', 0), 'K');

--SELECT name, ST_AsText(geometry) FROM poi;

-- 5) Wykonanie polecen:
-- a) Wyznacz calkowita dlugosc drog w analizowanym miescie:
SELECT SUM(ST_Length(geometry)) AS CalkowitaDlugoscDrog FROM roads;

-- b) Wypisz geometrie(WKT), pole powierzchni oraz obwod poligonu reprezentujacego budynek o nazwie BuildingA:
SELECT ST_AsText(geometry) AS Geometria, ST_Area(geometry) AS PolePowierzchni, ST_Perimeter(geometry) AS ObwodPoligonu 
FROM buildings WHERE name = 'BuildingA';

-- c) Wypisz nazwy i pola powierzchni wszystkich poligonow w warstwie budynki. Wyniki posortuj alfabetycznie:
SELECT name AS NazwaBudynku, ST_Area(geometry) AS PolePowierzchni 
FROM buildings ORDER BY name;

-- d) Wypisz nazwy i obwody 2 budynkow o najwiekszej powierzchni:
SELECT name AS NazwaBudynku, ST_Perimeter(geometry) AS ObwodBudynku
FROM buildings ORDER BY ST_Area(geometry) DESC LIMIT 2;

-- e) Wyznacz najkrotsza odleglosc miedzy budynkiem BuildingC a punktem G:
SELECT ST_Distance(buildings.geometry, poi.geometry) AS NajkrotszaOdleglosc 
FROM buildings, poi WHERE buildings.name = 'BuildingC' AND poi.name = 'G';

SELECT ST_ShortestLine(buildings.geometry, poi.geometry)
FROM buildings, poi WHERE buildings.name = 'BuildingC' AND poi.name = 'G'
union 
SELECT buildings.geometry FROM buildings WHERE buildings.name = 'BuildingC'
union 
SELECT poi.geometry FROM poi WHERE poi.name = 'G';

-- f) Wypisz pole powierzchni tej czesci budynku BuildingC, ktora znajduje sie w odleglosci wiekszej niz 0.5 od budynku BuildingB:
SELECT ROUND(CAST(ST_Area(ST_Difference(bC.geometry, ST_Buffer(bB.geometry, 0.5))) AS numeric), 4) AS PoleWycinka
FROM buildings AS bB, buildings AS bC WHERE bB.name = 'BuildingB' AND bC.name = 'BuildingC';

SELECT ST_Area(
			   (SELECT ST_Difference(geometry, 
									 (SELECT ST_Buffer(geometry, 0.5)
									  FROM buildings WHERE name = 'BuildingB'))
			   FROM buildings WHERE name = 'BuildingC'));
									 


-- g) Wybierz te budynki ktorych centroid (ST_Centroid) znajduje sie powyzej drogi o nazwie RoadX. 
SELECT buildings.name, ST_AsText(buildings.geometry) FROM buildings, roads 
WHERE roads.name = 'RoadX' AND ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_Centroid(roads.geometry));

SELECT buildings.name, ST_AsText(buildings.geometry) FROM buildings
WHERE ST_Y(ST_Centroid(buildings.geometry)) > (SELECT ST_Y(ST_Centroid(geometry))
										FROM roads WHERE roads.name = 'RoadX');
										

-- h) Oblicz pole powierzchni tych czesci budynku BuildingC i poligonu o wspolrzednych (4 7, 6 7, 6 8, 4 8, 4 7), ktore nie sa wspolne dla tych dwoch obiektow
SELECT ST_Area(ST_SymDifference(geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) 
FROM buildings WHERE name = 'BuildingC';

SELECT ST_Area(ST_Difference(geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) AS WycinekC, ST_Area(ST_Difference(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'), geometry))  AS WycinekPoligonu,
ST_Area(ST_Union(ST_Difference(geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')), ST_Difference(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'), geometry))) AS SumaWyznaczonegoObszaru
FROM buildings WHERE name = 'BuildingC';

SELECT ST_Area(ST_Union(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'), geometry))  AS SumaPoligonow, ST_Area(ST_Intersection(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'), geometry)) AS wycinek,
ST_Area(ST_Difference(ST_Union(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'), geometry), ST_Intersection(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'), geometry))) AS SumaWyznaczonegoObszaru
FROM buildings WHERE name = 'BuildingC';

SELECT * FROM buildings
UNION
SELECT * FROM roads
UNION
SELECT * FROM poi
