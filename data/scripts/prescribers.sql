SELECT *
FROM prescription



-- For this exericse, you'll be working with a database derived from the [Medicare Part D Prescriber Public Use File](https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0). More information about the data is contained in the Methodology PDF file. See also the## Prescribers Database
--  included entity-relationship diagram.

-- 1.
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, COUNT(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1;

-- Answer: npi-1356305197 highest total number of claims - 379


--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.nppes_provider_last_org_name, pr.specialty_description,sub.total_claims
FROM prescriber AS pr
INNER JOIN

(SELECT npi,COUNT(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi) As sub
USING(npi)

ORDER BY total_claims DESC
LIMIT 1;

--Answer: "MICHAEL" "COX" "COX" "Internal Medicine" 379


-- 2.
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT pr.specialty_description, SUM(p.total_claim_count) AS total_claims
FROM prescriber AS pr
INNER JOIN prescription AS p
USING (npi)
GROUP BY pr.specialty_description
ORDER BY total_claims DESC

--Answer:"Family Practice"

-- SELECT pr.specialty_description, sub.total_claims
-- FROM prescriber AS pr
-- INNER JOIN

-- (SELECT npi, SUM(total_claim_count) AS total_claims
--   FROM prescription
-- GROUP BY npi)AS sub

-- USING (npi)
-- GROUP BY pr.specialty_description, sub.total_claims
-- ORDER BY sub.total_claims DESC

-- (SELECT npi, SUM(total_claim_count) AS total_claims
--   FROM prescription
-- GROUP BY npi)AS sub

--     b. Which specialty had the most total number of claims for opioids?

SELECT pr.specialty_description, SUM(p.total_claim_count) AS total_claims, dr.drug_count
FROM prescriber AS pr
INNER JOIN prescription AS p
USING (npi)
INNER JOIN

(SELECT d.drug_name, COUNT(d.drug_name) AS drug_count
FROM drug AS d
WHERE d.opioid_drug_flag = 'Y'
GROUP BY d.drug_name) AS dr
ON p.drug_name =dr.drug_name

GROUP BY pr.specialty_description,dr.drug_count
ORDER BY total_claims DESC

--Answer: "Nurse Practitioner"

-- SELECT pr.specialty_description, sub.total_claims, dr.drug_count
-- FROM prescriber AS pr
-- INNER JOIN

-- (SELECT npi, drug_name, SUM(total_claim_count) AS total_claims
--   FROM prescription
-- GROUP BY npi, drug_name)AS sub

-- USING (npi)
-- INNER JOIN
-- (SELECT d.drug_name, COUNT(d.drug_name) AS drug_count
-- FROM drug AS d
-- WHERE d.opioid_drug_flag = 'Y'
-- GROUP BY d.drug_name) AS dr
-- ON sub.drug_name =dr.drug_name

-- ORDER BY sub.total_claims DESC


--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT pr.specialty_description, SUM(p.total_claim_count) AS total_claims, dr.drug_count
FROM prescriber AS pr
LEFT JOIN prescription AS p
USING (npi)
LEFT JOIN

(SELECT d.drug_name, COUNT(d.drug_name) AS drug_count
FROM drug AS d
WHERE d.opioid_drug_flag = 'Y'
GROUP BY d.drug_name) AS dr
ON p.drug_name =dr.drug_name

WHERE p.total_claim_count IS NULL
GROUP BY pr.specialty_description,dr.drug_count
ORDER BY total_claims DESC

--Answer: Yes


--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

SELECT pr.specialty_description,
ROUND(AVG(CASE WHEN d.opioid_drug_flag = 'Y' THEN 1
		 WHEN d.opioid_drug_flag = 'N' THEN 0 END),2) AS percentage_of_claims
FROM prescription AS p
LEFT JOIN prescriber AS pr	 
USING (npi)	 
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
GROUP BY pr.specialty_description



-- SELECT pr.specialty_description, ROUND(p.total_claim_count * 100/(SELECT SUM(p.total_claim_count)),0) AS percentage_of_claims
-- FROM prescription AS p
-- LEFT JOIN prescriber AS pr
-- USING (npi)
-- LEFT JOIN drug AS d
-- ON p.drug_name = d.drug_name
-- WHERE d.opioid_drug_flag = 'Y'
-- GROUP BY pr.specialty_description, p.total_claim_count


-- 3.
--     a. Which drug (generic_name) had the highest total drug cost? SUM the total cost of each drug
SELECT d.generic_name, SUM(p.total_drug_cost) AS sum_total_cost
FROM prescription AS p
INNER JOIN drug AS d
USING(drug_name)
GROUP BY d.generic_name
ORDER BY sum_total_cost DESC
LIMIT 1;

--Answer: "INSULIN GLARGINE,HUM.REC.ANLOG"


--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


SELECT d.generic_name, ROUND(p.total_drug_cost/p.total_day_supply,2) AS cost_per_day
FROM prescription AS p
INNER JOIN drug AS d
USING(drug_name)
ORDER BY cost_per_day DESC
LIMIT 1;

--Answer: "IMMUN GLOB G(IGG)/GLY/IGA OV50"



-- 4.
--     a.DONE For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ JOIN DRUG NAME TABLE TO GET GENERIC NAME
SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug
ORDER BY drug_type DESC


--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT sub.drug_type, SUM(p.total_drug_cost) AS money
FROM prescription AS p
INNER JOIN

(SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug) AS sub
USING (drug_name)

--ORDER BY drug_type DESC
--ON p.drug_name = d.drug_name
GROUP BY sub.drug_type
ORDER BY money DESC

--Answer: More was spent on opioids



--p.drug_name = d.drug_name

-- SELECT d.drug_name,SUM(p.total_drug_cost) AS sum_total_cost
-- CASE WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
-- WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- ELSE 'neither' END AS drug_type
-- FROM d.drug
-- INNER JOIN
-- prescription AS p
-- USING (drug_name)
-- GROUP BY d.drug_name
-- ORDER BY drug_type DESC



-- 5. Fips county column
--     a. DONE How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname ILIKE '%TN%'

--Answer: 58

SELECT *
FROM cbsa

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--JOIN WITH POPULATION TABLE
SELECT c.cbsa, c.cbsaname, SUM(p.population) AS total_population
FROM cbsa AS c
INNER JOIN
population AS p
USING(fipscounty)
GROUP BY c.cbsa, c.cbsaname
ORDER BY total_population --DESC

--Answer: largest population - "34980" "Nashville-Davidson--Murfreesboro--Franklin, TN" 1830410
--smallest population - "34100" "Morristown, TN" 116352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- SELECT c.cbsa, c.cbsaname, SUM(p.population) AS total_population
-- FROM cbsa AS c
-- INNER JOIN
-- population AS p
-- USING(fipscounty)
-- WHERE C.cbsaname IS NULL
-- GROUP BY c.cbsa, c.cbsaname
-- ORDER BY total_population --DESC


-- select * from cbsa
-- select * from population
-- select * from fips_county
-- left join population

SELECT f.county,COALESCE(SUM(p.population),0) AS total_population
FROM fips_county AS f
LEFT JOIN population AS p
USING(fipscounty)
LEFT JOIN cbsa AS c
ON p.fipscounty= c.fipscounty
WHERE c.cbsa IS NULL
GROUP BY f.county
ORDER BY total_population DESC

--Answer:"SEVIER" population - 95523




-- 6.
--     a.DONE Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, SUM(total_claim_count) AS sum_of_claims
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY sum_of_claims DESC



--     b. DONE For each instance that you found in part a, add a column that indicates whether the drug is an opioid. MERGE PRESCRIPTION TABLE WITH DRUG TABLE
SELECT p.drug_name, SUM(p.total_claim_count) AS sum_of_claims, sub.opioid_tag
FROM prescription AS p
INNER JOIN


(SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
ELSE 'N' END AS opioid_tag
FROM drug
ORDER BY opioid_tag DESC) AS sub

USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY p.drug_name, sub.opioid_tag
ORDER BY sum_of_claims DESC

--     c. DONE Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row. MERGE WITH PRESCRIBER TABLE

SELECT pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, p.drug_name, SUM(p.total_claim_count) AS sum_of_claims, sub.opioid_tag
FROM prescription AS p
INNER JOIN


(SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
ELSE 'N' END AS opioid_tag
FROM drug
ORDER BY opioid_tag DESC) AS sub
USING (drug_name)

INNER JOIN prescriber AS pr
ON p.npi = pr.npi

WHERE total_claim_count >= 3000
GROUP BY p.drug_name, sub.opioid_tag,pr.nppes_provider_first_name, pr.nppes_provider_last_org_name
ORDER BY sum_of_claims DESC





-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. DONE First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT pr.npi, d.drug_name
FROM prescriber AS pr
--CROSS JOIN prescription AS p
CROSS JOIN drug AS d
--ON p.drug_name = d.drug_name
WHERE pr.specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'



SELECT * FROM DRUG
FROM prescriber
--GIVES 35
-- SELECT pr.npi, d.drug_name
-- FROM prescriber AS pr
-- INNER JOIN prescription AS p
-- USING(npi)
-- INNER JOIN drug AS d
-- ON p.drug_name = d.drug_name
-- WHERE pr.specialty_description = 'Pain Management'
-- AND pr.nppes_provider_city = 'NASHVILLE'
-- AND d.opioid_drug_flag = 'Y'



-- SELECT pr.npi
-- FROM prescriber AS pr
-- LEFT JOIN prescription AS p
-- USING(npi)
-- WHERE p.total_claim_count IS NULL
-- -- WHERE nppes_provider_city ilike 'NASHVILLE'


--     b. DONE Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
--figure out how to get null values  (TRY USING A CROSS JOIN)

SELECT pr.npi, d.drug_name
FROM prescriber AS pr
--CROSS JOIN prescription AS p
CROSS JOIN drug AS d
--ON p.drug_name = d.drug_name
WHERE pr.specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'




-----BELOW WRONG
SELECT pr.npi, d.drug_name,coalesce(SUM(p.total_claim_count),0) AS claims
FROM prescriber AS pr
CROSS JOIN prescription AS p
USING(npi)
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name

-- left join (
-- SELECT drug_name, SUM(p.total_claim_count) AS claims
-- FROM
-- prescription AS p
-- GROUP BY drug_name) as sub
-- ON d.drug_name = sub.drug_name

WHERE pr.specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'
--OR p.total_claim_count IS NULL

GROUP BY pr.npi, d.drug_name
ORDER BY claims


-- 1ST SOLUTION
--SELECT pr.npi, d.drug_name, p.total_claim_count
-- FROM prescriber AS pr
-- LEFT JOIN prescription AS p
-- USING(npi)
-- LEFT JOIN drug AS d
-- ON p.drug_name = d.drug_name
-- WHERE pr.specialty_description = 'Pain Management'
-- AND pr.nppes_provider_city = 'NASHVILLE'
-- AND d.opioid_drug_flag = 'Y'
-- OR p.total_claim_count IS NULL
-- ORDER BY total_claim_count

--sol 2 beginning
-- SELECT pr.npi, d.drug_name,coalesce(SUM(p.total_claim_count),0) AS claims
-- FROM prescriber AS pr
-- LEFT JOIN prescription AS p
-- USING(npi)
-- LEFT JOIN drug AS d
-- ON p.drug_name = d.drug_name

-- -- left join (
-- -- SELECT drug_name, SUM(p.total_claim_count) AS claims
-- -- FROM
-- -- prescription AS p
-- -- GROUP BY drug_name) as sub
-- -- ON d.drug_name = sub.drug_name

-- WHERE pr.specialty_description = 'Pain Management'
-- AND pr.nppes_provider_city = 'NASHVILLE'
-- AND d.opioid_drug_flag = 'Y'
-- --OR p.total_claim_count IS NULL

-- GROUP BY pr.npi, d.drug_name
-- ORDER BY claims



--     c. DONE Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT pr.npi, d.drug_name, COALESCE(p.total_claim_count,0) AS total_claim_count
FROM prescriber AS pr
LEFT JOIN prescription AS p
USING(npi)
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
WHERE pr.specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'
OR p.total_claim_count IS NULL
ORDER BY total_claim_count