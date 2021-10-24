CREATE DATABASE cwiczenie2;
CREATE EXTENSION postgis;

-- 4. Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) położonych 
--    w odległości mniejszej niż 1000 m od głównych rzek. Budynki spełniające to kryterium zapisz do osobnej 
--    tabeli tableB.

SELECT COUNT(popp.f_codedesc) 
FROM popp, majrivers 
WHERE popp.f_codedesc = 'Building' AND ST_Distance(popp.geom, majrivers.geom) < 1000;

SELECT popp.* INTO tableB 
FROM popp, majrivers 
WHERE popp.f_codedesc = 'Building' AND ST_Distance(popp.geom, majrivers.geom) < 1000;

SELECT geom FROM tableB
union
SELECT geom FROM majrivers;

--SELECT COUNT(popp.f_codedesc) 
--FROM popp INNER JOIN majrivers ON ST_DWithin(popp.geom, majrivers.geom, 1000) 
--WHERE popp.f_codedesc = 'Building';		

-- 5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich geometrię, 
--    a także atrybut elev, reprezentujący wysokość n.p.m.  
SELECT id, name, geom, elev INTO airportsNew FROM airports;

-- a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.  
SELECT wschod.name, ST_AsText(wschod.geom) AS Wschód, zachod.name, ST_AsText(zachod.geom) AS Zachód
FROM airportsNew wschod, airportsNew zachod
WHERE (ST_Y(wschod.geom) = (SELECT MAX(ST_Y(geom)) FROM airportsNew)) AND (ST_Y(zachod.geom) = (SELECT MIN(ST_Y(geom)) FROM airportsNew))

-- b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym 
--    drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB. Wysokość n.p.m. przyjmij dowolną.
INSERT INTO airportsNew VALUES(77, 'airportB', 
							   (SELECT ST_Centroid(ST_ShortestLine(wschod.geom, zachod.geom))
							   FROM airportsNew wschod, airportsNew zachod
							   WHERE (ST_Y(wschod.geom) = (SELECT MAX(ST_Y(geom)) 
														   FROM airportsNew)) 
							   AND (ST_Y(zachod.geom) = (SELECT MIN(ST_Y(geom)) 
														 FROM airportsNew))), 40.000);

SELECT * FROM airportsNew; 

-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej linii 
--    łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”
	SELECT ST_Area(ST_Buffer(ST_ShortestLine(lakes.geom, airports.geom), 1000)) FROM lakes, airports 
	WHERE lakes.names = 'Iliamna Lake' AND airports.name = 'AMBLER';	
					 
-- 7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących poszczególne typy 
--    drzew znajdujących się na obszarze tundry i bagien (swamps). 
SELECT vegdesc, SUM(ST_Area(trees.geom)) AS SumarycznePolePoligonów FROM trees, swamp, tundra
WHERE ST_Contains(tundra.geom, trees.geom) OR ST_Contains(swamp.geom, trees.geom)
GROUP BY vegdesc;
