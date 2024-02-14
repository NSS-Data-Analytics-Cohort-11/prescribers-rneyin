SELECT *
FROM prescriber

-- For this exericse, you'll be working with a database derived from the [Medicare Part D Prescriber Public Use File](https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0). More information about the data is contained in the Methodology PDF file. See also the## Prescribers Database
--  included entity-relationship diagram.

-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, COUNT(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1;
-- Answer: npi-1356305197	highest total number of claims - 379

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT p.npi, pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.nppes_provider_last_org_name, pr.specialty_description,p.total_claims 

FROM prescriber AS pr
INNER JOIN
(SELECT p.npi,COUNT(p.total_claim_count) AS total_claims
FROM prescription AS p
GROUP BY p.npi)
USING(npi)

ORDER BY total_claims DESC

LIMIT 1;



-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, COUNT(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN
GROUP BY specialty_description
ORDER BY total_claims DESC




--     b. Which specialty had the most total number of claims for opioids?

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost? 
SELECT d.generic_name, p.total_drug_cost
FROM prescription AS p
INNER JOIN drug AS d
USING(drug_name)
ORDER BY p.total_drug_cost DESC
LIMIT 1;
--Answer: "PIRFENIDONE"

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


SELECT d.generic_name, ROUND(p.total_drug_cost/p.total_day_supply,2) AS cost_per_day
FROM prescription AS p
INNER JOIN drug AS d
USING(drug_name)
ORDER BY cost_per_day DESC
LIMIT 1;
--Answer: "IMMUN GLOB G(IGG)/GLY/IGA OV50"



-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ JOIN DRUG NAME TABLE TO GET GENERIC NAME
SELECT drug_name, drug_type,

CASE WHEN opiod_drug_flag = 'Y' THEN 'opiod'
WHEN antibiotic_drug_flag = 'Y' THEN 'atibotic'
ELSE 'neither' END AS drug_type


--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname ILIKE '%TN%'

--Answer: 58

SELECT *
FROM cbsa

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--JOIN WITH POPULATION TABLE
SELECT cbsa, COUNT(*) as 
FROM cbsa
GROUP BY cbsa
ORDER BY 

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count. DONE
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC



--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid. MERGE PRESCRIPTION TABLE WITH DRUG TABLE

SELECT drug_name, opiod_tag
FROM prescription
CASE WHEN opioid_drug_flag = 'Y' THEN 'opiod'
ELSE 'N' ENS AS opioid_tag


--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row. MERGE WITH PRESCRIBER TABLE

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.