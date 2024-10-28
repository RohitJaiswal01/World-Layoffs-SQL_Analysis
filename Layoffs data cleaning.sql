
-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


SELECT * 
FROM layoffs;


-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT layoffs_staging 
SELECT * FROM layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

-- checking all the duplicate values
SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
-- let's just look at oda to confirm
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;
-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate


-- let's do the partition by on all columns to see duplicate values
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
    
-- let's look all the values that are duplicate by making a CTE
WITH Duplicate_CTE AS (SELECT *FROM 
(SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging) duplicates
WHERE row_num > 1)
    
select * from layoffs_staging    -- select the values that are in Duplicate_CTE
 where (company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions)
 in (select company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions from Duplicate_CTE)
 order by company;
-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially


-- one solution to remove duplicates , which I think is a good one. Is to create a table and add row numbers in. Then delete where row numbers are over 2,
-- so let's do it!!

CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
`row_num` INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

-- now that we have this we can delete rows were row_num is greater than 2
DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;


-- 2. Standardize Data
-- Industry distinct values 
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- 3 different crypto values
select industry 
from layoffs_staging2
where industry like 'Crypto%';

-- update industry crypto values 
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';


-- --------------------------------------------------
-- we also need to look at 

SELECT *
FROM world_layoffs.layoffs_staging2;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- now if we run this again it is fixed
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;


-- Let's also fix the date columns:
SELECT *
FROM world_layoffs.layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. Look at Null Values
-- total_laid_off and percentage_laid_off both null values data
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL 
or percentage_laid_off is null;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
or percentage_laid_off IS NULL;


-- Delete some null values rows that are in industry, date and stage columns  
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE (industry IS NULL OR industry = '')
or (stage IS NULL or stage = ' ') 
or (date is null) ;

-- Deleting null values in industry, date and stage columns  
delete
FROM world_layoffs.layoffs_staging2
WHERE (industry IS NULL OR industry = '')
or (stage IS NULL or stage = ' ') 
or (date is null) ;

-- removing null values in funds_raised_millions column
delete 
from layoffs_staging2
where funds_raised_millions is null;

-- 4. remove any columns and rows we need to
-- removing row_num column as it is not useful anymore
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- dataset for EDA
SELECT * 
FROM world_layoffs.layoffs_staging2;