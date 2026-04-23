USE project_bfl;

 -- # VISUAL CHECK
SELECT * FROM birth_person LIMIT 50;
SELECT * FROM demo_p_countryf LIMIT 50;
SELECT * FROM demography LIMIT 50;

  -- # EXTRACTING TARGETED COUNTRIES from BABIES Born per year per countrie
  
DROP TABLE IF EXISTS birth_number_target;  
CREATE TABLE birth_number_target AS
SELECT year, Germany, Greece, Hungary, Netherlands, Spain, Romania
FROM birth_number_by_countryf;
SELECT * FROM birth_number_target LIMIT 10;

 -- # EXTRACTING TARGETED COUNTRIES from DEMOGRAPHY
 
DROP TABLE IF EXISTS demography_target;
CREATE TABLE demography_target AS
SELECT year, Germany, Greece, Hungary, Netherlands, Spain, Romania
FROM demo_p_countryf;
SELECT * FROM demography_target LIMIT 50;
-- # EXTRACTING TARGETED COUNTRIES from Quality Of life index

DROP TABLE IF EXISTS quality_of_life_index_target;
CREATE TABLE quality_of_life_index_target AS
SELECT year, Germany, Greece, Hungary, Netherlands, Spain, Romania
FROM quality_of_life_indexf;
SELECT * FROM quality_of_life_index_target LIMIT 10;

-- # Creating Birth index Coefficient and year ID

DROP TABLE IF EXISTS birth_coef;
CREATE TABLE birth_coef AS
SELECT
  birth_number_target. Year,
  birth_number_target. Germany      / NULLIF(demography_target. Germany , 0)      AS  Germany ,
  birth_number_target. Greece        / NULLIF(demography_target. Greece , 0)       AS  Greece ,
  birth_number_target. Hungary       / NULLIF(demography_target. Hungary , 0)      AS  Hungary ,
  birth_number_target. Netherlands   / NULLIF(demography_target. Netherlands , 0)  AS  Netherlands ,
  birth_number_target. Spain         / NULLIF(demography_target. Spain , 0)        AS  Spain ,
  birth_number_target. Romania       / NULLIF(demography_target. Romania , 0)      AS  Romania ,
  NULL AS year_id
FROM birth_number_target birth_number_target
JOIN demography_target demography_target ON birth_number_target. Year  = demography_target. Year ;

SET SQL_SAFE_UPDATES = 0;
UPDATE birth_coef
SET year_id = CASE Year
  WHEN 2009 THEN 9
  WHEN 2010 THEN 10
  WHEN 2011 THEN 11
  WHEN 2012 THEN 12
  WHEN 2013 THEN 13
  WHEN 2014 THEN 14
  WHEN 2015 THEN 15
  WHEN 2016 THEN 16
  WHEN 2017 THEN 17
  WHEN 2018 THEN 18
  WHEN 2019 THEN 19
  WHEN 2020 THEN 20
  WHEN 2021 THEN 21
  WHEN 2022 THEN 22
  WHEN 2023 THEN 23
  WHEN 2024 THEN 24
  WHEN 2025 THEN 25
  ELSE year_id
END
WHERE Year BETWEEN 2009 AND 2025;
SET SQL_SAFE_UPDATES = 1;
SELECT * FROM birth_coef LIMIT 30;

-- # Lets make table only for Germany

DROP TABLE IF EXISTS germany_full;
CREATE TABLE germany_full AS
SELECT
  t1.Germany AS germany_population,
  t2.Germany AS QOL_index,
  t3.Germany AS Birth_index,
  t3.year_id
FROM demography_target t1
JOIN quality_of_life_indexf t2 ON t2.Year = t1.Year
JOIN birth_coef t3 ON t3.Year = t1.Year;

SELECT * FROM germany_full LIMIT 30;

DELETE FROM germany_full
WHERE year_id IN (15,16,17);

SELECT * FROM germany_full LIMIT 30;

-- # Lets make table only for Netherlands

DROP TABLE IF EXISTS netherlands_full;
CREATE TABLE netherlands_full AS
SELECT
  t1.Netherlands AS Netherlands_population,
  t2.Netherlands AS QOL_index,
  t3.Netherlands AS Birth_index,
  t3.year_id
FROM demography_target t1
JOIN quality_of_life_indexf t2 ON t2.Year = t1.Year
JOIN birth_coef t3 ON t3.Year = t1.Year
WHERE t3.year_id IN (18,19,20,21,22,23,24);

-- # Lets see some tendencies like biggest birth coeff in targeted countries

-- # Highest bith rate per year and per country

SELECT year, country, value
FROM (
  SELECT year, 'Germany' AS country, Germany AS value FROM birth_coef
  UNION ALL
  SELECT year, 'Greece', Greece FROM birth_coef
  UNION ALL
  SELECT year, 'Hungary', Hungary FROM birth_coef
  UNION ALL
  SELECT year, 'Netherlands', Netherlands FROM birth_coef
  UNION ALL
  SELECT year, 'Spain', Spain FROM birth_coef
  UNION ALL
  SELECT year, 'Romania', Romania FROM birth_coef
) t
ORDER BY value DESC
LIMIT 1;

-- # get biggest mean value to understand which country is "keeping level"

SELECT country, AVG(value) AS avg_value
FROM (
  SELECT Germany AS value, year, 'Germany'  AS country FROM birth_coef
  UNION ALL
  SELECT Greece, year, 'Greece'  FROM birth_coef
  UNION ALL
  SELECT Hungary, year, 'Hungary'  FROM birth_coef
  UNION ALL
  SELECT Netherlands, year, 'Netherlands'  FROM birth_coef
  UNION ALL
  SELECT Spain, year, 'Spain'  FROM birth_coef
  UNION ALL
  SELECT Romania, year, 'Romania'  FROM birth_coef
) t
GROUP BY country
ORDER BY avg_value DESC
LIMIT 1; 

-- # get the "most" fertile year

SELECT year,
       (COALESCE(Germany,0)+COALESCE(Greece,0)+COALESCE(Hungary,0)+COALESCE(Netherlands,0)+COALESCE(Spain,0)+COALESCE(Romania,0))
       /
       ((Germany IS NOT NULL) + (Greece IS NOT NULL) + (Hungary IS NOT NULL) + (Netherlands IS NOT NULL) + (Spain IS NOT NULL) + (Romania IS NOT NULL))
       AS avg_value
FROM birth_coef
WHERE year >= 2015
ORDER BY avg_value DESC
LIMIT 1;

-- # get the "least" fertile year

SELECT year,
       (COALESCE(Germany,0)+COALESCE(Greece,0)+COALESCE(Hungary,0)+COALESCE(Netherlands,0)+COALESCE(Spain,0)+COALESCE(Romania,0))
       /
       ((Germany IS NOT NULL) + (Greece IS NOT NULL) + (Hungary IS NOT NULL) + (Netherlands IS NOT NULL) + (Spain IS NOT NULL) + (Romania IS NOT NULL))
       AS avg_value
FROM birth_coef
WHERE year <> 2025
ORDER BY avg_value ASC
LIMIT 1;

-- # get avg QOL fot the "most" fertile year

SELECT AVG(value) AS avg_QOL
FROM (
  SELECT Germany AS value FROM quality_of_life_index_target WHERE year = 2009
  UNION ALL
  SELECT Greece        FROM quality_of_life_index_target WHERE year = 2009
  UNION ALL
  SELECT Hungary       FROM quality_of_life_index_target WHERE year = 2009
  UNION ALL
  SELECT Netherlands   FROM quality_of_life_index_target WHERE year = 2009
  UNION ALL
  SELECT Spain         FROM quality_of_life_index_target WHERE year = 2009
  UNION ALL
  SELECT Romania       FROM quality_of_life_index_target WHERE year = 2009
) t
WHERE value IS NOT NULL;
------ # HMM seems like we dont have info for year 2009

SELECT AVG(value) AS avg_QOL
FROM (
  SELECT Germany AS value FROM quality_of_life_index_target WHERE year = 2016
  UNION ALL
  SELECT Greece        FROM quality_of_life_index_target WHERE year = 2016
  UNION ALL
  SELECT Hungary       FROM quality_of_life_index_target WHERE year = 2016
  UNION ALL
  SELECT Netherlands   FROM quality_of_life_index_target WHERE year = 2016
  UNION ALL
  SELECT Spain         FROM quality_of_life_index_target WHERE year = 2016
  UNION ALL
  SELECT Romania       FROM quality_of_life_index_target WHERE year = 2016
) t
WHERE value IS NOT NULL;

-- # get avg QOL fot the "least" fertile year

SELECT AVG(value) AS avg_QOL
FROM (
  SELECT Germany AS value FROM quality_of_life_index_target WHERE year = 2024
  UNION ALL
  SELECT Greece        FROM quality_of_life_index_target WHERE year = 2024
  UNION ALL
  SELECT Hungary       FROM quality_of_life_index_target WHERE year = 2024
  UNION ALL
  SELECT Netherlands   FROM quality_of_life_index_target WHERE year = 2024
  UNION ALL
  SELECT Spain         FROM quality_of_life_index_target WHERE year = 2024
  UNION ALL
  SELECT Romania       FROM quality_of_life_index_target WHERE year = 2024
) t
WHERE value IS NOT NULL;

-- # get visual check for idea that the higher the QOL, The higher the birth rate


SELECT
  b.country,
  b.value AS birth_rate,
  ROUND(
    CASE b.country
      WHEN 'Germany' THEN q.Germany
      WHEN 'Greece' THEN q.Greece
      WHEN 'Hungary' THEN q.Hungary
      WHEN 'Netherlands' THEN q.Netherlands
      WHEN 'Spain' THEN q.Spain
      WHEN 'Romania' THEN q.Romania
    END
  , 2) AS QOL
FROM (
  SELECT 'Germany'      AS country, Germany      AS value, year FROM birth_coef
  UNION ALL
  SELECT 'Greece',      Greece,      year FROM birth_coef
  UNION ALL
  SELECT 'Hungary',     Hungary,     year FROM birth_coef
  UNION ALL
  SELECT 'Netherlands', Netherlands, year FROM birth_coef
  UNION ALL
  SELECT 'Spain',       Spain,       year FROM birth_coef
  UNION ALL
  SELECT 'Romania',     Romania,     year FROM birth_coef
) b
JOIN quality_of_life_index_target q
  ON q.year = b.year
WHERE b.year = 2016
  AND b.value IS NOT NULL
ORDER BY b.value DESC;

-- # get visual check for idea that the higher the QOL, The higher the birth rate

SELECT
  b.country,
  b.value AS birth_rate,
  ROUND(
    CASE b.country
      WHEN 'Germany' THEN q.Germany
      WHEN 'Greece' THEN q.Greece
      WHEN 'Hungary' THEN q.Hungary
      WHEN 'Netherlands' THEN q.Netherlands
      WHEN 'Spain' THEN q.Spain
      WHEN 'Romania' THEN q.Romania
    END
  , 2) AS QOL
FROM (
  SELECT 'Germany'      AS country, Germany      AS value, year FROM birth_coef
  UNION ALL
  SELECT 'Greece',      Greece,      year FROM birth_coef
  UNION ALL
  SELECT 'Hungary',     Hungary,     year FROM birth_coef
  UNION ALL
  SELECT 'Netherlands', Netherlands, year FROM birth_coef
  UNION ALL
  SELECT 'Spain',       Spain,       year FROM birth_coef
  UNION ALL
  SELECT 'Romania',     Romania,     year FROM birth_coef
) b
JOIN quality_of_life_index_target q
  ON q.year = b.year
WHERE b.year = 2024
  AND b.value IS NOT NULL
ORDER BY b.value DESC;

-- # checking max birth rate for germany

SELECT year_id, MAX(Birth_index) AS max_birth
FROM germany_full
GROUP BY year_id
ORDER BY max_birth DESC
LIMIT 1;


-- # comparing it with target countries set

WITH bf AS (
  SELECT 'Germany'      AS country, Germany      AS value, year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Greece',      Greece,      year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Hungary',     Hungary,     year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Netherlands', Netherlands, year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Spain',       Spain,       year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Romania',     Romania,     year AS year_id FROM birth_coef
)
SELECT bf.country,
       CAST(bf.value AS DECIMAL(10,4)) AS birth_rate,
       bf.year_id,
       RANK() OVER (ORDER BY CAST(bf.value AS DECIMAL(10,4)) DESC) AS rank_by_birth_rate
FROM bf
WHERE bf.value IS NOT NULL
  AND CAST(bf.value AS DECIMAL(10,4)) > (SELECT MAX(Birth_index) FROM germany_full)
ORDER BY rank_by_birth_rate, bf.year_id, bf.country;

  -- # checking CTE'S

WITH bb AS (
  SELECT 'Germany'      AS country, Germany      AS value, year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Greece',      Greece,      year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Hungary',     Hungary,     year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Netherlands', Netherlands, year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Spain',       Spain,       year AS year_id FROM birth_coef
  UNION ALL
  SELECT 'Romania',     Romania,     year AS year_id FROM birth_coef
  )
SELECT * FROM bb
ORDER BY year_id, country;

 -- # checking CTE'S
 
with g_max1 AS (
  SELECT MAX(Birth_index) AS max_birth
  FROM germany_full
)
SELECT * FROM g_max1;
