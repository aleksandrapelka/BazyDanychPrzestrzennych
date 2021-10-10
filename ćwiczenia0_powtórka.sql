-- 1. Utwórz now¹ bazê danych nazywaj¹c j¹ firma.
CREATE DATABASE firma_powtórka;

--2. Dodaj schemat o nazwie ksiegowosc.
USE firma_powtórka;
CREATE SCHEMA ksiegowosc;

--3. Dodaj cztery tabele: 
CREATE TABLE ksiegowosc.pracownicy (ID_pracownika INT PRIMARY KEY, imie VARCHAR(40) NOT NULL, nazwisko VARCHAR(40) NOT NULL, adres VARCHAR(50) NOT NULL, telefon VARCHAR(11));
CREATE TABLE ksiegowosc.godziny (ID_godziny INT PRIMARY KEY, _data DATE NOT NULL, liczba_godzin INT NOT NULL, ID_pracownika INT NOT NULL);
CREATE TABLE ksiegowosc.pensja (ID_pensji VARCHAR(2) PRIMARY KEY, stanowisko VARCHAR(20), kwota MONEY NOT NULL);
CREATE TABLE ksiegowosc.premia (ID_premii VARCHAR(3) PRIMARY KEY, rodzaj VARCHAR(20), kwota MONEY);
CREATE TABLE ksiegowosc.wynagrodzenie(ID_wynagrodzenia VARCHAR(4) PRIMARY KEY, _data DATE NOT NULL, ID_pracownika INT NOT NULL, ID_godziny INT NOT NULL, ID_pensji VARCHAR(2) NOT NULL, ID_premii VARCHAR(3) NOT NULL);

ALTER TABLE ksiegowosc.godziny ADD FOREIGN KEY (ID_pracownika) REFERENCES ksiegowosc.pracownicy(ID_pracownika);
ALTER TABLE ksiegowosc.wynagrodzenie ADD FOREIGN KEY (ID_pracownika) REFERENCES ksiegowosc.pracownicy(ID_pracownika);
ALTER TABLE ksiegowosc.wynagrodzenie ADD FOREIGN KEY (ID_godziny) REFERENCES ksiegowosc.godziny(ID_godziny);
ALTER TABLE ksiegowosc.wynagrodzenie ADD FOREIGN KEY (ID_pensji) REFERENCES ksiegowosc.pensja(ID_pensji);
ALTER TABLE ksiegowosc.wynagrodzenie ADD FOREIGN KEY (ID_premii) REFERENCES ksiegowosc.premia(ID_premii);

-- Dodanie komentarzy do tabel:
EXEC sp_addextendedproperty 'Pracownicy', 'Tabela przedstawiajaca informacje o pracownikach', 'SCHEMA', 'ksiegowosc', 'TABLE', 'pracownicy' ;
EXEC sp_addextendedproperty 'Godziny', 'Tabela przedstawiajaca informacje o przepracowanej liczbie godzin przez pracowników', 'SCHEMA', 'ksiegowosc', 'TABLE', 'godziny' ;
EXEC sp_addextendedproperty 'Pensja', 'Tabela przedstawiajaca informacje o pensji i stanowisku pracowników', 'SCHEMA', 'ksiegowosc', 'TABLE', 'pensja' ;
EXEC sp_addextendedproperty 'Premia', 'Tabela przedstawiajaca informacje o rodzaju ewentualnej premii pracowników i jej wysokoœci', 'SCHEMA', 'ksiegowosc', 'TABLE', 'premia' ;
EXEC sp_addextendedproperty 'Wynagrodzenie', 'Tabela ³¹cz¹ca pozosta³e tabele', 'SCHEMA', 'ksiegowosc', 'TABLE', 'wynagrodzenie' ;
SELECT * FROM sys.extended_properties;

--4. Wype³nij ka¿d¹ tabelê 10. rekordami.
INSERT INTO ksiegowosc.pracownicy VALUES (1, 'Mateusz', 'Nowak', 'ul. Œl¹ska 10, 42-200 Czêstochowa', '683-237-114');
INSERT INTO ksiegowosc.pracownicy VALUES (2, 'Janina', 'Kowalska', 'ul. Katedralna 56, 42-200 Czêstochowa', '571-882-725');
INSERT INTO ksiegowosc.pracownicy VALUES (3, 'Daniel', 'Gawron', 'ul. Focha 13, 42-200 Czêstochowa', '583-782-444');
INSERT INTO ksiegowosc.pracownicy VALUES (4, 'Jêdrzej', 'Matyja', 'ul. Sportowa 203, 42-200 Czêstochowa', '639-662-909');
INSERT INTO ksiegowosc.pracownicy VALUES (5, 'Karolina', 'Zêbik', 'ul. Zielona 84, 42-200 Czêstochowa', '662-971-835');
INSERT INTO ksiegowosc.pracownicy VALUES (6, 'Lucyna', 'Morawiec', 'ul. Czêstochowska 26, 42-200 Czêstochowa', '592-595-862');
INSERT INTO ksiegowosc.pracownicy VALUES (7, 'Genowefa', 'ŒledŸ', 'ul. Sosnowa 48, 42-200 Czêstochowa', '672-792-440');
INSERT INTO ksiegowosc.pracownicy VALUES (8, 'Mi³osz', 'Polak', 'ul. Mi³a 15, 42-200 Czêstochowa', '791-222-972');
INSERT INTO ksiegowosc.pracownicy VALUES (9, 'Bart³omiej', 'Leszcz', 'ul. Szczupaka 59, 42-200 Czêstochowa', '690-808-257');
INSERT INTO ksiegowosc.pracownicy VALUES (10, 'Irena', 'Skiba', 'ul. Wolnoœci 201, 42-200 Czêstochowa', '655-917-636');

INSERT INTO ksiegowosc.godziny VALUES (11, '2021-03-15', 160, 1);
INSERT INTO ksiegowosc.godziny VALUES (22, '2021-03-15', 140, 2);
INSERT INTO ksiegowosc.godziny VALUES (33, '2021-03-15', 175, 3);
INSERT INTO ksiegowosc.godziny VALUES (44, '2021-03-15', 160, 4);
INSERT INTO ksiegowosc.godziny VALUES (55, '2021-03-15', 160, 5);
INSERT INTO ksiegowosc.godziny VALUES (66, '2021-03-15', 185, 6);
INSERT INTO ksiegowosc.godziny VALUES (77, '2021-03-15', 150, 7);
INSERT INTO ksiegowosc.godziny VALUES (88, '2021-03-10', 160, 8);
INSERT INTO ksiegowosc.godziny VALUES (99, '2021-03-10', 140, 9);
INSERT INTO ksiegowosc.godziny VALUES (101, '2021-03-10', 180, 10);

INSERT INTO ksiegowosc.premia VALUES ('P1a', 'regulaminowa', 100.00);
INSERT INTO ksiegowosc.premia VALUES ('P1b', NULL, NULL);
INSERT INTO ksiegowosc.premia VALUES ('P1c', 'uznaniowa', 500.00);
INSERT INTO ksiegowosc.premia VALUES ('P2a', 'regulaminowa', 100.00);
INSERT INTO ksiegowosc.premia VALUES ('P2b', 'regulaminowa', 100.00);
INSERT INTO ksiegowosc.premia VALUES ('P2c', 'uznaniowa', 500.00);
INSERT INTO ksiegowosc.premia VALUES ('P3a', NULL, NULL);
INSERT INTO ksiegowosc.premia VALUES ('P3b', 'regulaminowa', 100.00);
INSERT INTO ksiegowosc.premia VALUES ('P3c', NULL, NULL);
INSERT INTO ksiegowosc.premia VALUES ('P3d', 'uznaniowa', 1000.00);

INSERT INTO ksiegowosc.pensja VALUES ('1a', 'marketing manager', 4000.00);
INSERT INTO ksiegowosc.pensja VALUES ('1b', 'administrator IT', 5200.00);
INSERT INTO ksiegowosc.pensja VALUES ('1c', 'asystent', 3300.00);
INSERT INTO ksiegowosc.pensja VALUES ('2a', 'kierownik projektu', 4000.00);
INSERT INTO ksiegowosc.pensja VALUES ('2b', 'architekt systemu', 5200.00);
INSERT INTO ksiegowosc.pensja VALUES ('2c', 'asystent', 3300.00);
INSERT INTO ksiegowosc.pensja VALUES ('3a', 'analityk', 4000.00);
INSERT INTO ksiegowosc.pensja VALUES ('3b', 'administrator IT', 5200.00);
INSERT INTO ksiegowosc.pensja VALUES ('3c', 'asystent', 3300.00);
INSERT INTO ksiegowosc.pensja VALUES ('3d', 'prezes zarz¹du', 7000.00);

INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP1a', '2021-04-01', 1, 11, '1a', 'P1a');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP1b', '2021-04-01', 2, 22, '1b', 'P1b');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP1c', '2021-04-01', 3, 33, '1c', 'P1c');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP2a', '2021-04-01', 4, 44, '2a', 'P2a');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP2b', '2021-04-01', 5, 55, '2b', 'P2b');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP2c', '2021-04-01', 6, 66, '2c', 'P2c');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP3a', '2021-04-01', 7, 77, '3a', 'P3a');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP3b', '2021-04-01', 8, 88, '3b', 'P3b');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP3c', '2021-04-01', 9, 99, '3c', 'P3c');
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP3d', '2021-04-01', 10, 101, '3d', 'P3d');

-- 5. WYKONANIE NASTÊPUJ¥CYCH ZAPYTAÑ:

--a) Wyœwietl tylko id pracownika oraz jego nazwisko.
SELECT ID_pracownika, nazwisko FROM ksiegowosc.pracownicy;

--b) Wyœwietl id pracowników, których p³aca jest wiêksza ni¿ 1000.
SELECT pracownicy.ID_pracownika, pensja.kwota 
FROM ksiegowosc.pracownicy INNER JOIN (ksiegowosc.pensja INNER JOIN ksiegowosc.wynagrodzenie 
ON pensja.ID_pensji = wynagrodzenie.ID_pensji) ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika 
WHERE pensja.kwota > 1000.00;

--c) Wyœwietl id pracowników nieposiadaj¹cych premii, których p³aca jest wiêksza ni¿ 2000. 
SELECT pracownicy.ID_pracownika, pensja.kwota, premia.kwota
FROM ksiegowosc.pracownicy INNER JOIN ksiegowosc.pensja INNER JOIN ksiegowosc.premia INNER JOIN ksiegowosc.wynagrodzenie 
ON premia.ID_premii = wynagrodzenie.ID_premii ON pensja.ID_pensji = wynagrodzenie.ID_pensji ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
WHERE (premia.kwota IS NULL) AND (pensja.kwota > 2000.00);

--d) Wyœwietl pracowników, których pierwsza litera imienia zaczyna siê na literê ‘J’. 
SELECT ID_pracownika, imie, nazwisko FROM ksiegowosc.pracownicy WHERE imie LIKE 'J%';

--e) Wyœwietl pracowników, których nazwisko zawiera literê ‘n’ oraz imiê koñczy siê na literê ‘a’.
INSERT INTO ksiegowosc.pracownicy VALUES (11, 'Daria', 'Anakonda', 'ul. Wolnoœci 3, 42-200 Czêstochowa', '641-957-630');
INSERT INTO ksiegowosc.godziny VALUES (111, '2021-03-15', 180, 11);
INSERT INTO ksiegowosc.premia VALUES ('P3e', NULL, NULL);
INSERT INTO ksiegowosc.pensja VALUES ('3e', 'sprz¹taczka', 2500.00);
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('WP3e', '2021-04-01', 11, 111, '3e', 'P3e');

SELECT ID_pracownika, imie, nazwisko FROM ksiegowosc.pracownicy WHERE (nazwisko LIKE '%n%') AND (imie LIKE '%a');

--f) Wyœwietl imiê i nazwisko pracowników oraz liczbê ich nadgodzin, przyjmuj¹c, i¿ standardowy czas pracy to 160 h miesiêcznie. 
SELECT pracownicy.imie, pracownicy.nazwisko, liczba_godzin-160 AS Nadgodziny 
FROM ksiegowosc.pracownicy INNER JOIN ksiegowosc.godziny INNER JOIN ksiegowosc.wynagrodzenie 
ON godziny.ID_godziny = wynagrodzenie.ID_godziny ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
WHERE liczba_godzin > 160;

--g) Wyœwietl imiê i nazwisko pracowników, których pensja zawiera siê w przedziale 1500 – 3000 PLN.
SELECT pracownicy.imie, pracownicy.nazwisko, pensja.kwota 
FROM ksiegowosc.pracownicy INNER JOIN ksiegowosc.pensja INNER JOIN ksiegowosc.wynagrodzenie 
ON pensja.ID_pensji = wynagrodzenie.ID_pensji ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
WHERE pensja.kwota BETWEEN 1500 AND 3000; --pensja.kwota >=1500 AND pensja.kwota <=3000

--h) Wyœwietl imiê i nazwisko pracowników, którzy pracowali w nadgodzinach i nie otrzymali premii.
SELECT pracownicy.imie, pracownicy.nazwisko, godziny.liczba_godzin, premia.kwota 
FROM ksiegowosc.pracownicy INNER JOIN ksiegowosc.godziny INNER JOIN ksiegowosc.premia INNER JOIN ksiegowosc.wynagrodzenie 
ON premia.ID_premii = wynagrodzenie.ID_premii ON godziny.ID_godziny = wynagrodzenie.ID_godziny ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
WHERE (premia.kwota IS NULL) AND (godziny.liczba_godzin > 160);

--i) Uszereguj pracowników wed³ug pensji.
SELECT pracownicy.*, pensja.kwota FROM ksiegowosc.pracownicy INNER JOIN ksiegowosc.pensja INNER JOIN ksiegowosc.wynagrodzenie 
ON pensja.ID_pensji = wynagrodzenie.ID_pensji ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika 
ORDER BY pensja.kwota;

--j) Uszereguj pracowników wed³ug pensji i premii malej¹co.
SELECT pracownicy.*, pensja.kwota AS pensja, premia.kwota AS premia
FROM ksiegowosc.pracownicy INNER JOIN ksiegowosc.pensja INNER JOIN ksiegowosc.premia INNER JOIN ksiegowosc.wynagrodzenie 
ON premia.ID_premii = wynagrodzenie.ID_premii ON pensja.ID_pensji = wynagrodzenie.ID_pensji ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
ORDER BY pensja.kwota DESC, premia.kwota DESC;

--k) Zlicz i pogrupuj pracowników wed³ug pola ‘stanowisko’.
SELECT COUNT(pensja.stanowisko), pensja.stanowisko
FROM ksiegowosc.pensja
GROUP BY pensja.stanowisko;

--l) Policz œredni¹, minimaln¹ i maksymaln¹ p³acê dla stanowiska ‘kierownik’ (je¿eli takiego nie masz, to przyjmij dowolne inne).
SELECT AVG(pensja.kwota) AS Œrednia, MIN(pensja.kwota) AS Minimalna, MAX(pensja.kwota) AS Maksymalna, pensja.stanowisko 
FROM ksiegowosc.pensja GROUP BY stanowisko HAVING pensja.stanowisko LIKE 'asystent' OR pensja.stanowisko LIKE 'administrator IT';

--m) Policz sumê wszystkich wynagrodzeñ.
SELECT SUM(pensja.kwota) AS SumaPensji, SUM(premia.kwota)  AS SumaPremii, SUM(pensja.kwota+premia.kwota) AS SumaWynagrodzeñ
FROM ksiegowosc.pensja INNER JOIN ksiegowosc.premia INNER JOIN ksiegowosc.wynagrodzenie 
ON premia.ID_premii = wynagrodzenie.ID_premii ON pensja.ID_pensji = wynagrodzenie.ID_pensji;

--n)  Policz sumê wynagrodzeñ w ramach danego stanowiska.
SELECT SUM(pensja.kwota) AS SumaPensji, SUM(premia.kwota)  AS SumaPremii, SUM(pensja.kwota) + SUM(premia.kwota) AS SumaWynagrodzeñ, pensja.stanowisko
FROM ksiegowosc.pensja INNER JOIN ksiegowosc.premia INNER JOIN ksiegowosc.wynagrodzenie 
ON premia.ID_premii = wynagrodzenie.ID_premii ON pensja.ID_pensji = wynagrodzenie.ID_pensji
GROUP BY pensja.stanowisko;

--o) Wyznacz liczbê premii przyznanych dla pracowników danego stanowiska.
SELECT COUNT(premia.kwota) AS LiczbaPremii, pensja.stanowisko
FROM ksiegowosc.pensja INNER JOIN ksiegowosc.premia INNER JOIN ksiegowosc.wynagrodzenie 
ON premia.ID_premii = wynagrodzenie.ID_premii ON pensja.ID_pensji = wynagrodzenie.ID_pensji
GROUP BY pensja.stanowisko;

--p)  Usuñ wszystkich pracowników maj¹cych pensjê mniejsz¹ ni¿ 1200 z³.
SELECT * FROM ksiegowosc.pensja;

SELECT pracownicy.ID_pracownika, pracownicy.imie, pracownicy.nazwisko, pensja.kwota
FROM ksiegowosc.pracownicy INNER JOIN ( ksiegowosc.pensja INNER JOIN ksiegowosc.wynagrodzenie ON pensja.ID_pensji = wynagrodzenie.ID_pensji) ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
WHERE pensja.kwota <= 3300

ALTER TABLE ksiegowosc.godziny
NOCHECK CONSTRAINT FK__wynagrodz__ID_pr__2D27B809;
GO
ALTER TABLE ksiegowosc.wynagrodzenie
NOCHECK CONSTRAINT FK__wynagrodz__ID_pr__2D27B809;
GO

DELETE pracownicy FROM ksiegowosc.pracownicy WHERE ID_pracownika IN(3, 6, 9, 11)
