SELECT * FROM satyam2.`insurance_data - insurance_data`;
-- Problem 1: What are the top 5 patients who claimed the highest insurance amounts?
RENAME TABLE `insurance_data - insurance_data` to insurance;

SELECT*, DENSE_RANK() over(order by claim desc) from insurance limit 5;

-- Problem 2: What is the average insurance claimed by patients based on the number of children they have?
SELECT children, avg_claim,row_num from(SELECT *,
AVG(claim) over(PARTITION BY children) as avg_claim,
ROW_NUMBER() over(PARTITION BY children) as row_num
from insurance) t
WHERE t.row_num =1;

-- Problem 3: What is the highest and lowest claimed amount by patients in each region?
SELECT region,min_claim,max_claim from(SELECT*, 
min(claim) over(PARTITION BY region) as min_claim,
max(claim) over(PARTITION BY region) as max_claim,
ROW_NUMBER() over(PARTITION BY region) as row_num
from insurance) t
WHERE t.row_num=1;

-- Problem 5: What is the difference between the claimed amount of each
--            patient and the first claimed amount of that patient?
SELECT *,
round(claim-FIRST_VALUE(claim) over(),2) as diff
from insurance;

-- Problem 6: For each patient, calculate the difference between their claimed 
-- amount and the average claimed amount of patients with the same number of children.
 SELECT*,
 claim-avg(claim) over (PARTITION BY children)
 from insurance;
 
-- Problem 7: Show the patient with the highest BMI in each region and their respective rank.
select * from(SELECT*,
RANK() over(PARTITION BY region order by bmi desc) as grp_rank,
rank() over(ORDER BY bmi desc)  as overall_rank
from insurance) t
WHERE t.grp_rank=1 ;

-- Problem 8: Calculate the difference between the claimed amount of each 
-- patient and the claimed amount of the patient who has the highest BMI in their region.

select *,
claim- FIRST_VALUE(claim) over (PARTITION BY region order by bmi desc)
from insurance;



-- Problem 9: For each patient, calculate the difference in claim amount 
-- between the patient and the patient with the highest claim amount among 
-- patients with the same bmi and smoker status, within the same region. 
-- Return the result in descending order difference.
SELECT*,
(max(claim) over (PARTITION BY region,smoker)-claim) as claim_diff
from insurance
order by claim_diff desc;



-- Problem 10: For each patient, find the maximum BMI value among their next three records (ordered by age).

SELECT*,
max(bmi) over(ORDER BY age  ROWS BETWEEN 1 FOLLOWING and 3 FOLLOWING)
from insurance;

-- Problem 11: For each patient, find the rolling average of the last 2 claims.
SELECT*, 
avg(claim) over(rows BETWEEN 2 PRECEDING and 1 PRECEDING)
from insurance	;


-- Problem 12: Find the first claimed insurance value for male and 
-- female patients, within each region order the data by patient age in ascending order, 
-- and only include patients who are non-diabetic and have a bmi value between 25 and 30

with filtered_data as(
	SELECT * from insurance
    where diabetic='No' and bmi BETWEEN 25 and 30
)
SELECT * from(SELECT*,
FIRST_VALUE(claim) over(PARTITION BY region,gender ORDER BY age),
ROW_NUMBER() over(PARTITION BY region, gender ORDER BY age) as row_num
from filtered_data) t
where t.row_num=1;




