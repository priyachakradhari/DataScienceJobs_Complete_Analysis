/*11.As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. Your Task is to know how many people were
 employed IN different types of companies AS per their size IN 2021.*/
 
 select  company_size,count(company_size) as count_of_employed, work_year from salaries
 where work_year=2021
 group by company_size;
 
 /*12.Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top 3 job titles that 
command the highest average salary Among part-time Positions IN the year 2023.*/

select job_title, avg(salary_in_usd) as avg_salary from salaries 
where employment_type = 'PT'and work_year = 2023
group by job_title
order by avg(salary_in_usd) desc
limit 3;

 /*13.As a database analyst you haSve been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.*/

select company_location, job_title, salary_in_usd, work_year from salaries 
where experience_level='MI' and work_year = 2023 and salary_in_usd > 
(
select round(avg(salary_in_usd),2) as avg_salary from salaries
where experience_level = 'MI' and work_year = 2023
)
group by company_location,job_title, salary_in_usd;

/*14.As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for 
senior-level (SE) employees in 2023.*/   
select company_location, round(avg(salary_in_usd),2) as highest_avg_salary from salaries
where experience_level = 'SE' and work_year= 2023
group by company_location
order by round(avg(salary_in_usd),2) desc
limit 1;

select company_location, round(avg(salary_in_usd),2) as lowerst_avg_salary from salaries
where experience_level = 'SE' and work_year= 2023
group by company_location
order by round(avg(salary_in_usd),2) 
limit 1;    
    
    
/*15. You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. 
By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles.*/
with t as 
(
select a.job_title, avg_2023, avg_2024 from
(select job_title, avg(salary_in_usd) as avg_2023  from salaries
where work_year = 2023
group by job_title) a
inner join
(select job_title, avg(salary_in_usd) as avg_2024  from salaries
where work_year = 2024
group by job_title) b)

select *, round((((avg_2024-avg_2023)/avg_2023)*100),2) as growth_rate_percentage from t;

 /*16. You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. Your task is to list the top three 
 Countries with the highest salary growth rate FROM 2020 to 2023, helping multinational Corporations identify  Emerging talent markets.*/
with t as 
(
	select company_location,work_year, avg(salary_in_usd) as average 
	from salaries
	where experience_level = 'EN' and work_year in (2021,2023)
	group by company_location,work_year
)
select *, round(((avg_2023-avg_2021)/avg_2021)*100,2) as growth_perc 
from 
	(
	select company_location,
	max(case when work_year =2021 then average end) as avg_2021,
	max(case when work_year =2023 then average end) as avg_2023
	from t
	group by company_location
    ) a
where round(((avg_2023-avg_2021)/avg_2021)*100,2) is not null
order by round(((avg_2023-avg_2021)/avg_2021)*100,2) desc limit 3 ;
 
/* 17.Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for employees 
 they decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio for eligible employees,
 ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.*/

-- creating temporary table so that changes are not made in actual table as actual table is being used in other cases also.
create table temp_table as select * from salaries;
 
 -- by default mysql runs on safe update mode , this mode  is a safeguard against updating
 -- or deleting large portion of  a table.
 -- We will turn off safe update mode using set_sql_safe_updates

SET SQL_SAFE_UPDATES = 0;

update temp_table 
set remote_ratio = 100
where (experience_level = 'US' or experience_level = 'AU') and salary_in_usd > 90000;

select * from temp_table where (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;

/* 18. In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
                   Entry Level-35%  of the salary.
                   Mid junior – 30% of the salary.
                   Immediate senior level- 22% of the salary.
                   Expert level- 20% of the salary.
                   Director – 15% of the salary.
you have to update the salaries accordingly and update it back in the original database. */

update temp_table
set salary_in_usd =
case 
when experience_level ='EN' then salary_in_usd *1.35  
when experience_level ='MI' then salary_in_usd *1.30  
when experience_level ='SE' then salary_in_usd *1.22  
when experience_level ='EX' then salary_in_usd *1.20 
when experience_level ='DX' then salary_in_usd *1.15 
else salary_in_usd
end
where work_year = 2024;

/*19. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/

with avg_salary_per_year as 
(
select job_title, work_year, avg(salary_in_usd) as avg_salary from salaries 
group by work_year, job_title
)

select job_title, work_year, avg_salary, rank_by_salary from 
(
select job_title, work_year, avg_salary,
rank() over(partition by job_title order by avg_salary desc) as rank_by_salary
from avg_salary_per_year
) as ranked_salary 
where rank_by_salary =1;


/*20. You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type (full time, part time) in 
Different job roles, in the format where each row will be job title, each column will be type of employment type and  cell value  for that row and column will show 
the % value*/    

select 
    job_title,
    round((SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS PT_percentage, -- Calculate percentage of part-time employment
    round((SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FT_percentage, -- Calculate percentage of full-time employment
    round((SUM(CASE WHEN employment_type = 'CT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS CT_percentage, -- Calculate percentage of contract employment
    round((SUM(CASE WHEN employment_type = 'FL' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FL_percentage -- Calculate percentage of freelance employment
from 
    salaries
group by 
    job_title; -- Group the result by job title
   
