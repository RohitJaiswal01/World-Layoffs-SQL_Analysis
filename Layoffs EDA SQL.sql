-- EDA

-- MAX laid offs employees count
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;


-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs_staging2
WHERE  percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time


-- if we order by funds_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch



-- Companies with the biggest Layoffs
SELECT company, total_laid_off
FROM layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;
-- now that's a lot of layoffs


-- by location
SELECT location, SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY location
ORDER BY laid_offs DESC
LIMIT 10;

-- this it total in the past years in the dataset by country
SELECT country, SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY country
ORDER BY laid_offs DESC;

-- total layoffs in the past total years
SELECT YEAR(date) as Years, SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY Years ASC;


-- total layoffs industry wise
SELECT industry, SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY industry
ORDER BY laid_offs DESC;

-- total layoffs Company stage wise
SELECT stage, SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- total layoffs per month
SELECT SUBSTRING(date,1,7) as months, SUM(total_laid_off) AS laid_offs
FROM layoffs_staging2
GROUP BY SUBSTRING(date,1,7)
ORDER BY months ASC;

-- Rolling Total of Layoffs Per Month
-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as months, SUM(total_laid_off) AS laid_offs
FROM layoffs_staging2
GROUP BY SUBSTRING(date,1,7)
ORDER BY months ASC
)
SELECT months,laid_offs, SUM(laid_offs) OVER (ORDER BY months ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY months ASC;


-- layoffs per year by company

select company, year(date) as dates, sum(total_laid_off) as laid_offs
from layoffs_staging2
group by company, dates
order by laid_offs desc;


-- top 5 highest layoffs per year by company
WITH layoffs_year as(
select company, year(date) as dates, sum(total_laid_off) as laid_offs
from layoffs_staging2
group by company, dates),

ranked_layoffs_peryear as(select *, dense_rank() over(partition by dates order by laid_offs desc) as ranking
 from layoffs_year
 order by dates)
 
select * from ranked_layoffs_peryear
where ranking <= 5;
 
 
 select date from layoffs_staging2;