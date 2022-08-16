-- Q1a.
SELECT p1.npi, SUM(p2.total_claim_count) as total
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
WHERE p2.total_claim_count IS NOT NULL
GROUP BY p1.npi
ORDER BY total DESC;
-- Answer: Highest claim count is 99,707 .

-- Q1b.
SELECT 
    p1.nppes_provider_last_org_name as last_name,
    p1.nppes_provider_first_name as first_name,
    p1.specialty_description as specialty,
    SUM(p2.total_claim_count) as total
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
WHERE p2.total_claim_count IS NOT NULL
GROUP BY last_name, first_name, specialty
ORDER BY total DESC;
-- Answer: Bruce Pendley, specialty being family practice .

-- Q2a.
SELECT DISTINCT p1.specialty_description AS specailty, SUM(p2.total_claim_count) AS total
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
WHERE p2.total_claim_count IS NOT NULL
GROUP BY specailty
ORDER BY total DESC;
-- Answer: Family Practice, 9,752,347 .

-- Q2b.
SELECT DISTINCT p1.specialty_description AS specailty, SUM(p2.total_claim_count) AS total
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
LEFT JOIN drug as d1 USING(drug_name)
WHERE p2.total_claim_count IS NOT NULL AND d1.opioid_drug_flag = 'Y'
GROUP BY specailty
ORDER BY total DESC;
-- Answer: Nurse Practitioner, 900,845 .

-- Q2c.
SELECT DISTINCT p1.specialty_description AS specailty
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
WHERE p1.specialty_description NOT IN 
    (SELECT DISTINCT p1.specialty_description AS specailty
    FROM prescriber as p1
    LEFT JOIN prescription as p2 USING(npi)
    WHERE p2.total_claim_count IS NOT NULL
    GROUP BY specailty)
GROUP BY specailty;
-- Answer: Yes, 15 specialties . 

-- Q2d.


-- Answer: ?

-- Q3a.
SELECT DISTINCT d1.generic_name as name, SUM(p2.total_drug_cost) as total_cost
FROM drug as d1
LEFT JOIN prescription as p2 USING(drug_name)
WHERE p2.total_drug_cost IS NOT NULL
GROUP BY name
ORDER BY total_cost DESC;
-- Answer: "INSULIN GLARGINE,HUM.REC.ANLOG", 104,264,066 .

-- Q3b.
SELECT DISTINCT d1.generic_name as name, ROUND(SUM(p2.total_drug_cost)/SUM(p2.total_day_supply), 2) as cost_per_day
FROM drug as d1
LEFT JOIN prescription as p2 USING(drug_name)
WHERE p2.total_drug_cost IS NOT NULL
GROUP BY name
ORDER BY cost_per_day DESC;
-- Answer: "C1 ESTERASE INHIBITOR", 3,495.22 .

-- Q4a.
SELECT drug_name, 
CASE 
    WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
    ELSE 'Neither' 
END AS drug_type
FROM drug
ORDER BY drug_name ASC;
-- Answer: It works .

-- Q4b.
SELECT
CASE 
    WHEN d1.opioid_drug_flag = 'Y' THEN 'Opioid'
    WHEN d1.antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
    ELSE 'Neither' 
END AS drug_type, MONEY(SUM(p2.total_drug_cost)) AS total_cost
FROM drug as d1
LEFT JOIN prescription as p2 USING(drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;
-- Answer: Opioids - $105,080,626.37 > Antibiotics - $38,435,121.26 .

-- Q5a.
SELECT DISTINCT cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%';
-- Answer: 10 CBSAs in TN .

-- Q5b.
SELECT cbsaname, SUM(population) as total_pop
FROM cbsa as c1
LEFT JOIN population as p3 USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY total_pop DESC;
-- Answer: MAX - Nashville-Davidson--Murfreesboro--Franklin, 1,830,410. MIN - Morristown, 116,352 .

-- Q5c.
SELECT f1.county, p3.population
FROM population as p3
LEFT JOIN fips_county as f1 USING(fipscounty)
WHERE p3.fipscounty NOT IN 
    (SELECT p3.fipscounty
    FROM cbsa as c1
    LEFT JOIN population as p3 USING(fipscounty)
    WHERE p3.fipscounty IS NOT NULL)
ORDER BY p3.population DESC;
-- Answer: Sevier, 95,523 .

-- Q6a.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;
-- Answer: It works .

-- Q6b.
SELECT p2.drug_name, p2.total_claim_count, 
CASE
    WHEN d1.opioid_drug_flag = 'Y' THEN 'Y'
    ELSE 'N' 
END AS is_opioid
FROM prescription as p2
LEFT JOIN drug as d1 USING(drug_name)
WHERE p2.total_claim_count >= 3000
ORDER BY p2.total_claim_count DESC;
-- Answer: 2 opioids and 7 others .

-- Q6c.
SELECT p1.nppes_provider_last_org_name as last_name, p1.nppes_provider_first_name as first_name, p2.drug_name, p2.total_claim_count, 
CASE
    WHEN d1.opioid_drug_flag = 'Y' THEN 'Y'
    ELSE 'N' 
END AS is_opioid
FROM prescription as p2
LEFT JOIN drug as d1 USING(drug_name)
LEFT JOIN prescriber as p1 USING(npi)
WHERE p2.total_claim_count >= 3000
ORDER BY p2.total_claim_count DESC;
-- Answer: It works .

-- Q7a.
SELECT d1.drug_name, p1.npi
FROM prescriber AS p1
CROSS JOIN drug AS d1
WHERE specialty_description ILIKE '%Pain Management%' AND
nppes_provider_city ILIKE '%NASHVILLE%' AND
d1.opioid_drug_flag = 'Y'
ORDER BY d1.drug_name ASC;
-- Answer: It works .

-- Q7b.
SELECT d1.drug_name, p1.npi, p2.total_claim_count
FROM prescriber AS p1
CROSS JOIN drug AS d1
LEFT JOIN prescription as p2 ON p2.npi = p1.npi
AND d1.drug_name = p2.drug_name
WHERE specialty_description ILIKE '%Pain Management%' AND
nppes_provider_city ILIKE '%NASHVILLE%' AND
d1.opioid_drug_flag = 'Y'
GROUP BY d1.drug_name, p1.npi, p2.total_claim_count
ORDER BY p2.total_claim_count ASC;
-- Answer: It works . 

-- Q7c.
SELECT d1.drug_name, p1.npi, COALESCE(p2.total_claim_count,0)
FROM prescriber AS p1
CROSS JOIN drug AS d1
LEFT JOIN prescription as p2 ON p2.npi = p1.npi
AND d1.drug_name = p2.drug_name
WHERE specialty_description ILIKE '%Pain Management%' AND
nppes_provider_city ILIKE '%NASHVILLE%' AND
d1.opioid_drug_flag = 'Y'
GROUP BY d1.drug_name, p1.npi, p2.total_claim_count
ORDER BY p2.total_claim_count ASC;
-- Answer: It works .