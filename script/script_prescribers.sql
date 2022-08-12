-- Q1a.
SELECT p1.npi, p2.total_claim_count
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
WHERE p2.total_claim_count IS NOT NULL
ORDER BY p2.total_claim_count DESC;
-- Answer: Highest claim count is 4,538 .

-- Q1b.
SELECT 
    p1.nppes_provider_last_org_name as last_name,
    p1.nppes_provider_first_name as first_name,
    p1.specialty_description as specialty,
    p2.total_claim_count
FROM prescriber as p1
LEFT JOIN prescription as p2 USING(npi)
WHERE p2.total_claim_count IS NOT NULL
ORDER BY p2.total_claim_count DESC;
-- Answer: David Coffey, specialty being family practice .

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