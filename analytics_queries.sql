-- =============================================
-- Analytical Queries for Coffee Quality Database
-- =============================================

------------------------------------------------
-- Q1: Avg sensory attributes by species + method
------------------------------------------------

SELECT s.SPECIES_NAME AS SPECIES,
       pm.PROCESSING_METHOD_NAME AS PROCESSING_METHOD,
       ROUND(AVG(cq.AROMA), 3)      AS AVG_AROMA,
       ROUND(AVG(cq.FLAVOR), 3)     AS AVG_FLAVOR,
       ROUND(AVG(cq.AFTERTASTE), 3) AS AVG_AFTERTASTE,
       ROUND(AVG(cq.ACIDITY), 3)    AS AVG_ACIDITY,
       ROUND(AVG(cq.BODY), 3)       AS AVG_BODY,
       ROUND(AVG(cq.BALANCE), 3)    AS AVG_BALANCE,
       ROUND(AVG(
            cq.AROMA + cq.FLAVOR + cq.AFTERTASTE +
            cq.ACIDITY + cq.BODY + cq.BALANCE
       ), 3) AS AVG_COMPOSITE_SCORE
FROM COFFEE_QUALITY cq
JOIN VARIETY v ON cq.VARIETY_ID = v.VARIETY_ID
JOIN SPECIES s ON v.SPECIES_ID = s.SPECIES_ID
JOIN PROCESSING_METHOD pm ON cq.PROCESSING_METHOD_ID = pm.PROCESSING_METHOD_ID
GROUP BY s.SPECIES_NAME, pm.PROCESSING_METHOD_NAME
ORDER BY AVG_COMPOSITE_SCORE DESC;

------------------------------------------------
-- Q2: Countries above-average moisture AND defects
------------------------------------------------

SELECT c.COUNTRY_NAME AS COUNTRY,
       ROUND(AVG(cq.MOISTURE), 3)            AS AVG_MOISTURE,
       ROUND(AVG(cq.CATEGORY_ONE_DEFECTS), 3) AS AVG_CAT1,
       ROUND(AVG(cq.CATEGORY_TWO_DEFECTS), 3) AS AVG_CAT2,
       ROUND(AVG(cq.CATEGORY_ONE_DEFECTS + cq.CATEGORY_TWO_DEFECTS), 3)
           AS AVG_TOTAL_DEFECTS
FROM COFFEE_QUALITY cq
JOIN COUNTRY c ON cq.COUNTRY_ID = c.COUNTRY_ID
GROUP BY c.COUNTRY_NAME
HAVING AVG(cq.MOISTURE) >
       (SELECT AVG(MOISTURE) FROM COFFEE_QUALITY)
   AND AVG(cq.CATEGORY_ONE_DEFECTS + cq.CATEGORY_TWO_DEFECTS) >
       (SELECT AVG(CATEGORY_ONE_DEFECTS + CATEGORY_TWO_DEFECTS)
        FROM COFFEE_QUALITY)
ORDER BY AVG_TOTAL_DEFECTS DESC;

------------------------------------------------
-- Q3: Avg composite score for varieties w/ >= 30 records
------------------------------------------------

SELECT v.VARIETY_NAME AS VARIETY,
       COUNT(*) AS NUM_RECORDS,
       ROUND(AVG(
           cq.AROMA + cq.FLAVOR + cq.AFTERTASTE +
           cq.ACIDITY + cq.BODY + cq.BALANCE
       ), 3) AS AVG_COMPOSITE_SCORE
FROM COFFEE_QUALITY cq
LEFT JOIN VARIETY v ON cq.VARIETY_ID = v.VARIETY_ID
GROUP BY v.VARIETY_NAME
HAVING COUNT(*) >= 30
ORDER BY AVG_COMPOSITE_SCORE DESC;

------------------------------------------------
-- Q4: Avg sensory score + avg defects per harvest year
------------------------------------------------

SELECT cq.HARVEST_YEAR,
       ROUND(AVG(
           cq.AROMA + cq.FLAVOR + cq.AFTERTASTE +
           cq.ACIDITY + cq.BODY + cq.BALANCE
       ), 3) AS AVG_COMPOSITE_SCORE,
       ROUND(AVG(
           cq.CATEGORY_ONE_DEFECTS + cq.CATEGORY_TWO_DEFECTS
       ), 3) AS AVG_TOTAL_DEFECTS
FROM COFFEE_QUALITY cq
GROUP BY cq.HARVEST_YEAR
ORDER BY cq.HARVEST_YEAR;

------------------------------------------------
-- Q5: Country + variety combos w/ >= 20 records and above-average score
------------------------------------------------

SELECT c.COUNTRY_NAME AS COUNTRY,
       v.VARIETY_NAME AS VARIETY,
       COUNT(*) AS NUM_RECORDS,
       ROUND(AVG(
           cq.AROMA + cq.FLAVOR + cq.AFTERTASTE +
           cq.ACIDITY + cq.BODY + cq.BALANCE
       ), 3) AS AVG_COMPOSITE_SCORE
FROM COFFEE_QUALITY cq
LEFT JOIN COUNTRY c ON cq.COUNTRY_ID = c.COUNTRY_ID
LEFT JOIN VARIETY v ON cq.VARIETY_ID = v.VARIETY_ID
GROUP BY c.COUNTRY_NAME, v.VARIETY_NAME
HAVING COUNT(*) >= 20
   AND AVG(
       cq.AROMA + cq.FLAVOR + cq.AFTERTASTE +
       cq.ACIDITY + cq.BODY + cq.BALANCE
   ) > (
       SELECT AVG(
           AROMA + FLAVOR + AFTERTASTE +
           ACIDITY + BODY + BALANCE
       ) FROM COFFEE_QUALITY
   )
ORDER BY AVG_COMPOSITE_SCORE DESC;
