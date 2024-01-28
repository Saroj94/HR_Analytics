use hr;
select*from hr;
	   ###################################		-- DATA CLEANING--      ##########################################
                                            
-- CHANGE THE FORMAT OF VALUES PRESENT IN A DATE COLUMN AND ALSO CONVERT STR/TEXT FORMAT DATE TO DATE FORMAT
UPDATE hr
SET birthdate= CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
                WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
                ELSE NULL
                END;

-- CHANGE THE DATATYPE OF THE DATE COLUMN                
ALTER TABLE hr
MODIFY COLUMN birthdate date;


-- CHANGE THE FORMAT OF THE VALUES PRESENT IN THE HIRE_DATE COLUMN AND ALSO CONVERT STR/TEXT FORMAT TO DATE FORMAT
UPDATE hr
SET hire_date= CASE
		WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
                ELSE NULL
                END;
                
-- CHANGE THE DATA TYPE OF THE COLUMN.
ALTER TABLE hr
MODIFY COLUMN hire_date date;

ALTER TABLE hr
ADD COLUMN Age int;

ALTER TABLE hr
ADD COLUMN term_date text;

-- CHANGE TEXT DATE FORMAT TO DATE FORMAT OF termdate COLUMN
UPDATE HR
SET term_date = date(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

-- SETTING UP VALUES NULL WHERE IF termdate COLUMN HAS EMPTY SPACE 
UPDATE hr
SET termdate= NULL
WHERE termdate = '';

UPDATE hr
SET Age= timestampdiff(Year,birthdate, curdate());
-----------------------------------------------------------------------------------------------------------
################################## -- DATA ANALYSIS -- #########################################
-- 1. Max and Min age 
SELECT MAX(Age), MIN(Age) 
FROM hr;

-- 2. what is the gender breakdown of the employees
SELECT gender, COUNT(*) AS gender_dist
FROM hr
GROUP BY gender;

-- 3. what is the race breakdown in the company
SELECT race, COUNT(*) AS Count_race, COUNT(*)/(SELECT COUNT(*) FROM hr) AS Race_Percentage
FROM hr
WHERE term_date IS NULL
GROUP BY race;

-- 4. what is the age distribution in the company
SELECT      
	   CASE
			WHEN Age>=18 AND Age<=24 THEN '18-24'
			WHEN Age>=25 AND Age<=34 THEN '25-34'
			WHEN Age>=35 AND Age<=44 THEN '35-44'
			WHEN Age>=45 AND Age<=54 THEN '45-54'
			WHEN Age>=55 AND Age<=64 THEN '55-64'
			ELSE '64 and above'
		END AS age_group,
	COUNT(*) AS count_age, COUNT(*)/(SELECT COUNT(*) FROM hr) AS Age_dist_percentage
FROM hr
WHERE  termdate IS NULL
GROUP BY age_group
ORDER BY age_group DESC;

-- 5.how many Employee work in HQ & remote
SELECT location, COUNT(*) AS work_dist
FROM  hr
WHERE termdate IS NULL
GROUP BY location;

-- 6.What is the average lenght of employement who have been terminated
SELECT ROUND(AVG((datediff(termdate,hire_date))/365),0) AS avg_empntLength
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate();

-- Alternative query
select round(avg(year(termdate)-year(hire_date)),0)
from hr
where termdate is not null and termdate<=curdate();

-- 7. How does the gender vary based on the job titles and dept.alter
SELECT department,jobtitle,gender, COUNT(*) AS gender_count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department,jobtitle,gender;

-- 8.What is the job title distribution in a company
SELECT jobtitle, COUNT(*) AS job_dist
FROM hr
WHERE termdate IS NOT NULL
GROUP BY jobtitle;


-- 9. Which department has the highest termination rate?
SELECT department, 
       count( CASE WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1 END) AS termination_count,
       (COUNT(CASE WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1 END)/COUNT(*))*100 AS term_rate
FROM hr
GROUP BY department
ORDER BY term_rate DESC;

-- 10. what is the employee distribution accross the state location
SELECT location_state,COUNT(*)
FROM hr
WHERE termdate IS NULL
GROUP BY location_state;


-- 11. How has the company employee count has changed over time based on hires and termination date

-- memory wise more costly
SELECT year,
		hires,
        terminations,
        (hires-terminations) AS net_employee_change,
        (terminations/hires)*100 AS  emp_change_percent
FROM (
		SELECT YEAR (hire_date) AS year,
					COUNT(*) AS hires,
					SUM(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
					END) AS terminations
					FROM hr
                    GROUP BY YEAR(hire_date)) AS subquery
GROUP BY year
ORDER BY year asc;
        
	
-- memory wise less expensive
WITH emp_change AS ( SELECT 
			YEAR(hire_date) AS year, 
			COUNT(*) hire_no,
			SUM(CASE
				WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
                                END) AS termination_no
				FROM hr
                    		GROUP BY year
                    		ORDER BY year)
                    
SELECT year,hire_no,termination_no, 
			(hire_no-termination_no) AS Net_emp_change,
			round((termination_no/hire_no)*100,1) AS 'Emp_change%'
FROM emp_change;

-- 12. what is the tenure distribution in each department
SELECT department, ROUND(AVG(timestampdiff(YEAR, hire_date,termdate)),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate()
GROUP BY department;

-- Alternative Query
SELECT department, ROUND(AVG(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate()
GROUP BY department;
