CREATE DATABASE cwiczenie3;
CREATE EXTENSION postgis;

--1. Dla warstwy trees zmień ustawienia tak, aby lasy liściaste, iglaste i mieszane wyświetlane były innymi kolorami. 
--   Podaj pole powierzchni wszystkich lasów o charakterze mieszanym.
SELECT vegdesc, ST_Union(geom) FROM trees GROUP BY vegdesc;
SELECT SUM(area_km2) AS pole FROM trees WHERE vegdesc = 'Mixed Trees';
--SELECT SUM(ST_Area(geom)) AS pole FROM trees WHERE vegdesc = 'Mixed Trees';


--2. Podziel warstwę trees na trzy warstwy. Na każdej z nich umieść inny typ lasu.
SELECT vegdesc, COUNT(vegdesc) FROM trees GROUP BY vegdesc;
SELECT * INTO Deciduous FROM trees WHERE vegdesc = 'Deciduous'; 
SELECT * INTO MixedTrees FROM trees WHERE vegdesc = 'Mixed Trees';
SELECT * INTO Evergreen FROM trees WHERE vegdesc = 'Evergreen';

SELECT * FROM Deciduous
UNION
SELECT * FROM MixedTrees
UNION
SELECT * FROM Evergreen


--3. Oblicz długość linii kolejowych dla regionu Matanuska-Susitna. 

--CONTAINS
SELECT railroads.geom FROM railroads, regions WHERE ST_Contains(regions.geom, railroads.geom) AND regions.name_2 = 'Matanuska-Susitna'
UNION
SELECT geom FROM regions WHERE name_2 = 'Matanuska-Susitna';

--INTERSECTS
SELECT railroads.geom FROM railroads, regions WHERE ST_Intersects(regions.geom, railroads.geom) AND regions.name_2 = 'Matanuska-Susitna'
UNION
SELECT geom FROM regions WHERE name_2 = 'Matanuska-Susitna';

--INTERSECTION
SELECT ST_Intersection(railroads.geom, regions.geom) FROM railroads, regions WHERE regions.name_2 = 'Matanuska-Susitna'
UNION
SELECT geom FROM regions WHERE name_2 = 'Matanuska-Susitna';

--długość linii kolejowych----
SELECT SUM(ST_Length(ST_Intersection(regions.geom, railroads.geom))) AS dlugoscLiniiKolejowych FROM railroads, regions 
WHERE regions.name_2 = 'Matanuska-Susitna';


--4. Oblicz, na jakiej średniej wysokości nad poziomem morza położone są lotniska 
--   o charakterze militarnym. Ile jest takich lotnisk? Usuń z warstwy airports lotniska 
--   o charakterze militarnym, które są dodatkowo położone powyżej 1400 m n.p.m. Ile było takich lotnisk?

--SELECT elev, name, use FROM airports WHERE use LIKE '%Military%'
SELECT elev, name, use FROM airports WHERE use LIKE 'Military'
SELECT ROUND(AVG(elev), 2) AS ŚredniaWysokość, COUNT(use) AS LiczbaLotnisk FROM airports WHERE use LIKE 'Military';

SELECT elev, name, use FROM airports WHERE use LIKE 'Military' AND elev > 1400;
SELECT COUNT(elev) AS ileUsuń FROM airports WHERE use LIKE 'Military' AND elev > 1400;
DELETE FROM airports WHERE use LIKE 'Military' AND elev > 1400;


--5. Utwórz warstwę, na której znajdować się będą jedynie budynki położone 
--   w  regionie  Bristol  Bay(wykorzystaj warstwę popp). Podaj liczbę budynków. 
--   Na warstwie zostaw tylko te budynki, które są położone nie dalej niż 100 km od rzek (rivers). 
--   Ile jest takich budynków?
SELECT geom FROM regions WHERE regions.name_2 = 'Bristol Bay'
UNION
SELECT popp.geom FROM regions INNER JOIN popp ON ST_Contains(regions.geom, popp.geom)
WHERE regions.name_2 = 'Bristol Bay' AND popp.f_codedesc = 'Building';

SELECT popp.* INTO BristolBayBuilding FROM regions INNER JOIN popp ON ST_Contains(regions.geom, popp.geom)
WHERE regions.name_2 = 'Bristol Bay' AND popp.f_codedesc = 'Building';

SELECT * FROM BristolBayBuilding;

SELECT COUNT(BristolBayBuilding.geom) AS LiczbaBudynków FROM BristolBayBuilding;

---------------------------------------------------------------------------
SELECT DISTINCT BristolBayBuilding.* INTO BristolBayBuilding2
FROM BristolBayBuilding INNER JOIN rivers ON ST_DWithin(BristolBayBuilding.geom, rivers.geom, 328084)
	
SELECT geom FROM BristolBayBuilding2
UNION
SELECT rivers.geom FROM rivers, regions WHERE ST_Intersects(regions.geom, rivers.geom) AND regions.name_2 = 'Bristol Bay'
UNION
SELECT geom FROM regions WHERE regions.name_2 = 'Bristol Bay';

SELECT COUNT(BristolBayBuilding2.geom) AS LiczbaBudynków FROM BristolBayBuilding2;
---------------------------------------------------------------------------
SELECT ST_Buffer(rivers.geom, 328084) FROM regions, rivers 
WHERE regions.name_2 = 'Bristol Bay' AND ST_Intersects(regions.geom, rivers.geom)
UNION
SELECT geom FROM BristolBayBuilding2
UNION
SELECT rivers.geom FROM rivers, regions WHERE ST_Intersects(regions.geom, rivers.geom) AND regions.name_2 = 'Bristol Bay'
UNION
SELECT geom FROM regions WHERE regions.name_2 = 'Bristol Bay';


-- 6. Sprawdź w ilu miejscach przecinają się rzeki (majrivers) z liniami kolejowymi (railroads).
SELECT DISTINCT ST_Intersection(majrivers.geom, railroads.geom) FROM majrivers, railroads
UNION
SELECT DISTINCT railroads.geom FROM majrivers INNER JOIN railroads ON ST_Intersects(majrivers.geom, railroads.geom)
UNION
SELECT DISTINCT majrivers.geom FROM majrivers, railroads WHERE ST_Intersects(majrivers.geom, railroads.geom);

SELECT SUM(ST_NPoints(ST_Intersection(majrivers.geom, railroads.geom))) FROM majrivers, railroads 
WHERE ST_Intersects(railroads.geom, majrivers.geom);


--7. Wydobądź węzły dla warstwy railroads. Ile jest takich węzłów?
SELECT SUM(ST_NPoints(geom)) AS LiczbaWęzłów FROM railroads;

SELECT (ST_DumpPoints(geom)).geom FROM railroads
UNION
SELECT railroads.geom FROM railroads;


--8. Wyszukaj  najlepsze  lokalizacje do budowy hotelu. Hotel powinien być oddalony 
--   od lotniska nie więcej niż 100 km i nie mniej niż 50km  od  linii  kolejowych. 
--   Powinien leżeć także w pobliżu sieci drogowej.

SELECT ST_Difference(ST_UNION(regions.geom), ST_UNION(ST_Buffer(railroads.geom, 164042))) INTO toryBufor FROM regions, railroads

SELECT ST_Intersection(szlaki.hotele, st_difference) FROM
(
	SELECT ST_Intersection(ST_Buffer(airports.geom, 328083), ST_Buffer(trails.geom, 3280)) AS hotele FROM airports, trails
	WHERE ST_Intersects(ST_Buffer(airports.geom, 328083), ST_Buffer(trails.geom, 3280))
) AS szlaki, toryBufor
UNION
SELECT ST_UNION(ST_Buffer(railroads.geom, 164042)) FROM railroads


SELECT ST_Intersection(lotniska.geom, ST_Buffer(trails.geom, 3280)) FROM
(
SELECT ST_Difference(ST_UNION(ST_Buffer(airports.geom, 328083)), ST_UNION(ST_Buffer(railroads.geom, 164042))) AS geom
FROM airports, railroads	
) AS lotniska, trails
UNION
SELECT ST_UNION(ST_Buffer(railroads.geom, 164042)) FROM railroads;

