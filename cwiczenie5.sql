CREATE DATABASE cwiczenie5;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

--C:\Program Files\PostgreSQL\13\bin

ALTER SCHEMA schema_name RENAME TO pelka;

SELECT * FROM rasters.dem
SELECT * FROM public.raster_columns;


--TWORZENIE RASTRÓW Z ISTNIEJĄCYCH RASTRÓW I INTERAKCJA Z WEKTORAMI:

-- PRZYKŁAD 1 - ST_Intersects:

-- Przecięcie rastra z wektorem.
CREATE TABLE pelka.intersects AS 
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

SELECT * FROM pelka.intersects;

-- 1. dodanie serial primary key:
ALTER TABLE pelka.intersects
ADD COLUMN rid SERIAL PRIMARY KEY;

-- 2. utworzenie indeksu przestrzennego:
CREATE INDEX idx_intersects_rast_gist ON pelka.intersects
USING gist (ST_ConvexHull(rast));

--3. dodanie raster constraints: 
-- schema::name table_name::name raster_column::name 
SELECT AddRasterConstraints('pelka'::name, 'intersects'::name,'rast'::name); 

-- PRZYKŁAD 2 - ST_Clip:
 
--Obcinanie rastra na podstawie wektora. 
CREATE TABLE pelka.clip AS 
SELECT ST_Clip(a.rast, b.geom, true), b.municipality 
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO'; 

SELECT * FROM pelka.clip;

-- PRZYKŁAD 3 - ST_Union

-- Połączenie wielu kafelków w jeden raster.
CREATE TABLE pelka.union AS 
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

SELECT * FROM pelka.union;

--TWORZENIE RASTRÓW Z WEKTORÓW (RASTROWANIE):

-- PRZYKŁAD 1 - ST_AsRaster

CREATE TABLE pelka.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem 
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

SELECT * FROM pelka.porto_parishes;
--SELECT geom FROM vectors.porto_parishes where municipality ilike 'porto';

--PRZYKŁAD 2 - ST_Union

DROP TABLE pelka.porto_parishes; --> drop table porto_parishes first
CREATE TABLE pelka.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem 
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

SELECT * FROM pelka.porto_parishes;

-- PRZYKŁAD 3 - ST_Tile

DROP TABLE pelka.porto_parishes; --> drop table porto_parishes first
CREATE TABLE pelka.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem 
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

SELECT * FROM pelka.porto_parishes;

--KONWERTOWANIE RASTRÓW NA WEKTORY (WEKTORYZOWANIE):

-- PRZYKŁAD 1 - ST_Intersection

CREATE TABLE pelka.intersection AS 
SELECT 
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b 
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

SELECT * FROM pelka.intersection;

--PRZYKŁAD 2 - ST_DumpAsPolygons

CREATE TABLE pelka.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b 
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

SELECT * FROM pelka.dumppolygons;

-- ANALIZA RASTRÓW:

-- PRZYKŁAD 1 - ST_Band

CREATE TABLE pelka.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

SELECT * FROM pelka.landsat_nir;

-- Przykład 2 - ST_Clip

CREATE TABLE pelka.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

SELECT * FROM pelka.paranhos_dem;

-- PRZYKŁAD 3 - ST_Slope

CREATE TABLE pelka.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM pelka.paranhos_dem AS a;

SELECT * FROM pelka.paranhos_slope;

-- PRZYKŁAD 4 - ST_Reclass

CREATE TABLE pelka.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', 
'32BF',0)
FROM pelka.paranhos_slope AS a;

SELECT * FROM pelka.paranhos_slope_reclass;

-- PRZYKŁAD 5 - ST_SummaryStats

SELECT st_summarystats(a.rast) AS stats
FROM pelka.paranhos_dem AS a;

-- PRZYKŁAD 6 - ST_SummaryStats oraz Union

SELECT st_summarystats(ST_Union(a.rast))
FROM pelka.paranhos_dem AS a;

-- PRZYKŁAD 7 - ST_SummaryStats z lepszą kontrolą złożonego typu danych

WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM pelka.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

-- PRZYKŁAD 8 - ST_SummaryStats w połączeniu z GROUP BY

WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, 
b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

-- PRZYKŁAD 9 - ST_Value

SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;


-- TOPOGRAPHIC POSITION INDEX (TPI):

-- PRZYKŁAD 10 - ST_TPI

CREATE TABLE pelka.tpi30 AS
SELECT ST_TPI(a.rast,1) AS rast
FROM rasters.dem a; --36 secs 682 msec

SELECT * FROM pelka.tpi30;

--Tworzenie indeksu przestrzennego:
CREATE INDEX idx_tpi30_rast_gist ON pelka.tpi30
USING gist (ST_ConvexHull(rast)); --56 msec

--Dodanie constraintów:
SELECT AddRasterConstraints('pelka'::name, 'tpi30'::name,'rast'::name); --223 msec

--PROBLEM DO SAMODZIELNEGO ROZWIĄZANIA:
CREATE TABLE pelka.tpi30_intersects AS
SELECT ST_TPI(a.rast,1) AS rast
FROM rasters.dem a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'; --1 sec 474 msec

SELECT * FROM pelka.tpi30_intersects;

--Tworzenie indeksu przestrzennego:
CREATE INDEX idx_tpi30_rast_gist_intersects ON pelka.tpi30_intersects
USING gist (ST_ConvexHull(rast)); --45 msec

--Dodanie constraintów:
SELECT AddRasterConstraints('pelka'::name, 'tpi30_intersects'::name,'rast'::name); --88msec

--ALGEBRA MAP:

-- PRZYKŁAD 1 - Wyrażenie Algebry Map

CREATE TABLE pelka.porto_ndvi AS 
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] + 
[rast1.val])::float','32BF'
) AS rast
FROM r;

SELECT * FROM pelka.porto_ndvi;

--Utworzenie indeksu przestrzennego na wcześniej stworzonej tabeli:
CREATE INDEX idx_porto_ndvi_rast_gist ON pelka.porto_ndvi
USING gist (ST_ConvexHull(rast));

--Dodanie constraintów:
SELECT AddRasterConstraints('pelka'::name, 'porto_ndvi'::name,'rast'::name);

-- PRZYKŁAD 2 – Funkcja zwrotna

CREATE OR REPLACE FUNCTION pelka.ndvi(
value double precision [] [] [], 
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value 
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

--Wywołanie funkcji zwrotnej:

CREATE TABLE pelka.porto_ndvi2 AS 
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'pelka.ndvi(double precision[], 
integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;

SELECT * FROM pelka.porto_ndvi2;

--Dodanie indeksu przestrzennego:
CREATE INDEX idx_porto_ndvi2_rast_gist ON pelka.porto_ndvi2
USING gist (ST_ConvexHull(rast));

--Dodanie constraintów:
SELECT AddRasterConstraints('pelka'::name, 'porto_ndvi2'::name,'rast'::name);

-- EKSPORT DANYCH:

-- PRZYKŁAD 0

CREATE TABLE pelka.porto_ndvi_export_qgis AS 
SELECT ST_Union(rast)
FROM pelka.porto_ndvi;

-- PRZYKŁAD 1 - ST_AsTiff

SELECT ST_AsTiff(ST_Union(rast))
FROM pelka.porto_ndvi;

-- PRZYKŁAD 2 - ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM pelka.porto_ndvi;

-- Lista formatów obsługiwanych przez bibliotekę gdal
SELECT ST_GDALDrivers();

-- PRZYKŁAD 3 - Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM pelka.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'C:\Users\48692\Desktop\bazy_lab6\rasters\myraster.tiff') --> Save the file in a place 
--where the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.

-- Geoserver

CREATE TABLE public.mosaic (
    name character varying(254) COLLATE pg_catalog."default" NOT NULL,
    tiletable character varying(254) COLLATE pg_catalog."default" NOT NULL,
    minx double precision,
    miny double precision,
    maxx double precision,
    maxy double precision,
    resx double precision,
    resy double precision,
    CONSTRAINT mosaic_pkey PRIMARY KEY (name, tiletable)
);

insert into mosaic (name,tiletable) values ('mosaicpgraster','rasters.dem');

select * from mosaic


