select count(*) from salaries;
alter database  campusx rename to  DataScienceJob;

/* 1. You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, 
for the title 'managers’ Paying salaries Exceeding $90,000 USD*/

select * from salaries 
where remote_ratio = 100 and salary_in_usd > 90000 and job_title like '%manager%';

/* 2. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. 
you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.*/

select company_location, count(*) as counts from salaries 
where company_size = 'L' and experience_level = 'EN'
group by company_location
order by counts desc 
limit 5;

/* 3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/

set @total = (select count(*) as remote_emp from salaries where salary_in_usd > 100000);
set @cns = (select count(*) as remote_exd_salaries from salaries where remote_ratio =100 and salary_in_usd > 100000);
select @total;
select @cns;
set @percentage = (select round(((@cns)/(@total))*100,2) as perc) ;
select @percentage ;

/* 4. Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average
 salaries exceed the average salary for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities.*/
 
 select b.company_location, b.job_title, a.average, b.average_per_country from 
 (
 select job_title, round(avg(salary_in_usd),2) as average from salaries 
 where experience_level = "EN"
 group by  job_title
 )a
 inner join 
 (
 select company_location,job_title, round(avg(salary_in_usd),2) as average_per_country from salaries 
 where experience_level = "EN"
 group by company_location, job_title 
 )b 
 on a.job_title=b.job_title
 where average_per_country > average;
 
 /* 5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
 Your job is to Find out for each job title which. Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/
 select * from 
	(
		select *,
		dense_rank() over(partition by job_title order by average desc) num 
		from 
        (
		select company_location, job_title, avg(salary_in_usd) as average from salaries
		group by job_title, company_location
        ) t
	)k
 where num = 1;
 

 /* 6. AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations. 
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for
 3 years Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.*/
 
 with t as (
	select * from salaries where company_location in 
    (
		select company_location from 
        (
			select  company_location,avg(salary_in_usd) as average, count(distinct (work_year)) as cns from salaries 
			where work_year >=(year(current_date())-3)
			group by company_location
			having cns =3
		) a
    )   
 )
 select company_location,
 max(case when work_year=2022 then average end) as avg_2022,
 max(case when work_year=2023 then average end) as avg_2023,
 max(case when work_year=2024 then average end) as avg_2024
 from (select company_location, work_year, avg(salary_in_usd) as average from t group by company_location, work_year) q
 group by company_location having avg_2024>avg_2023 and avg_2023>avg_2022;
 
 /* 7. Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine the percentage of fully remote
 work for each experience level IN 2021 and compare it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases 
 IN remote work Adoption over the years. */
 with t1 as
 (
	select a.experience_level, a.total_2021,b.counts_2021,(counts_2021/total_2021)*100 as per_2021 from 
	(
		select experience_level, count(experience_level) As total_2021 from salaries where work_year = 2021 
		group by experience_level
    ) a
	inner join 
	(
		select experience_level, count(experience_level) As counts_2021 from salaries where work_year = 2021 and remote_ratio= 100
		group by experience_level
	) b
	on a.experience_level=b.experience_level
 ),
 
t2 as 
 (
	select c.experience_level, c.total_2024, d.counts_2024, (counts_2024/total_2024)*100 as per_2024 from 
	(
		select experience_level, count(experience_level) As total_2024 from salaries where work_year = 2024 
		group by experience_level
	) c
	inner join 
	(
		select experience_level, count(experience_level) As counts_2024 from salaries where work_year = 2024 and remote_ratio= 100
		group by experience_level
	) d
	on c.experience_level=d.experience_level
 )
select * from t1 inner join t2 on t1.experience_level=t2.experience_level;
 
 
 /* 8. AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. Your objective is to calculate
 the average salary increase percentage for each experience level and job title between the years 2023 and 2024, helping the company stay competitive
 IN the talent market.*/
 
 select a.experience_level,a.job_title,a.average_2023,b.average_2024,
 round((((average_2024-average_2023)/average_2023)*100),2)  AS changes_in_percentage 
 from 
 (
 select experience_level,job_title,work_year,round(avg(salary_in_usd),2) as average_2023 from salaries where work_year = 2023 
 group by experience_level, job_title
 ) a
 inner join
 (
 select experience_level,job_title,work_year, round(avg(salary_in_usd),2) as average_2024 from salaries where work_year = 2024 
 group by experience_level, job_title
 ) b
 on a.job_title=b.job_title and a.experience_level = b.experience_level
 where round((((average_2024-average_2023)/average_2023)*100),2) is not null;
 
 /* 9. You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement a security 
 measure where employees in different experience level (e.g. Entry Level, Senior level etc.) can only access details relevant to their respective 
 experience level, ensuring data confidentiality and minimizing the risk of unauthorized access.*/
 
 select * from salaries;
 create user 'Entry_level'@'%' identified by 'EN';
 create view EN_emp as
 (select * from salaries where experience_level = 'EN');
 
 grant select on campusx.EN_emp to 'Entry_level'@'%';
 
 show privileges;
 
 /* 10. You are working with a consultancy firm, your client comes to you with certain data and preferences such as (their year of experience ,
 their employment type, company location and company size )  and want to make an transaction into different domain in data industry 
 (like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering etc.)
 your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update their knowledge as 
 per the suggestion/.. The Suggestion should be based on average salary.*/
 
DELIMITER //
create procedure GetAverageSalary(in exp_lev varchar(2), IN emp_type varchar(3), IN comp_loc varchar(2), IN comp_size varchar(2))
begin
    select job_title, experience_level, company_location, company_size, employment_type, ROUND(avg(salary), 2) AS avg_salary 
    from salaries 
    where experience_level = exp_lev and company_location = comp_loc and company_size = comp_size and employment_type = emp_type 
    group by experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
end//


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
select * from salaries;
/*13.As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.*/

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
order by round(avg(salary_in
_usd),2) desc
limit 1;

select company_location, round(avg(salary_in_usd),2) as lowerst_avg_salary from salaries
where experience_level = 'SE' and work_year= 2023
group by company_location
order by round(avg(salary_in_usd),2) 
limit 1;

SELECT company_location AS highest_location, AVG(salary_in_usd) AS highest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY highest_avg_salary DESC
    LIMIT 1;
select * from salaries;    
/*15. You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. 
By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles.*/

 /*16. You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. Your task is to list the top three 
 Countries with the highest salary growth rate FROM 2020 to 2023, helping multinational Corporations identify  Emerging talent markets.*/

/* 17.Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for employees 
 they decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio for eligible employees,
 ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.*/


/* 18. In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
                   Entry Level-35%  of the salary.
                   Mid junior – 30% of the salary.
                   Immediate senior level- 22% of the salary.
                   Expert level- 20% of the salary.
                   Director – 15% of the salary.
you have to update the salaries accordingly and update it back in the original database. */

/*19. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/

/*20. You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type (full time, part time) in 
Different job roles, in the format where each row will be job title, each column will be type of employment type and  cell value  for that row and column will show 
the % value*/