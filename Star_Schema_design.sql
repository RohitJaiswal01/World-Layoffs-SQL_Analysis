-- STAR Schema Design OLAP
-- Step 1: Create a new database
CREATE DATABASE world_layoffs_star_schema;

-- Step 2: Switch to the newly created database
USE world_layoffs_star_schema;

-- Step 3: Create Dimension & Fact table Tables 
CREATE TABLE Company (
    Company_ID INT AUTO_INCREMENT PRIMARY KEY,  -- Unique company ID
    Company_Name VARCHAR(255) NOT NULL          -- Company Name
);

CREATE TABLE Location (
    Location_ID INT AUTO_INCREMENT PRIMARY KEY,  -- Unique location ID
    Location_Name VARCHAR(255) NOT NULL          -- Location (e.g., City, State)
);

CREATE TABLE Industry (
    Industry_ID INT AUTO_INCREMENT PRIMARY KEY,  -- Unique industry ID
    Industry_Name VARCHAR(255) NOT NULL          -- Industry name (e.g., Healthcare, Marketing, etc.)
);

CREATE TABLE Stage (
    Stage_ID INT AUTO_INCREMENT PRIMARY KEY,     -- Unique stage ID
    Stage_Value VARCHAR(255) NOT NULL UNIQUE,    -- Stage name or value (e.g., Series A, Series B)
    Description TEXT,                            -- Description of the stage
    Funding_Source VARCHAR(100)                  -- Funding source for the stage (e.g., Venture Capital, Private Equity)
);

CREATE TABLE Country (
    Country_ID INT AUTO_INCREMENT PRIMARY KEY,   -- Unique country ID
    Country_Name VARCHAR(255) NOT NULL,           -- Country name
    Continent VARCHAR(255)                        -- Continent (e.g., Europe, Asia, North America)
);

CREATE TABLE Fact_Layoffs (
    Layoff_ID INT AUTO_INCREMENT PRIMARY KEY,    -- Unique identifier for each record
    Company_ID INT,                              -- Foreign key to Company Dimension
    Location_ID INT,                             -- Foreign key to Location Dimension
    Industry_ID INT,                             -- Foreign key to Industry Dimension
    Stage_ID INT,                                -- Foreign key to Stage Dimension
    Country_ID INT,                              -- Foreign key to Country Dimension
    Total_Laid_Off INT,                          -- Total number of employees laid off
    Percentage_Laid_Off FLOAT,                   -- Percentage of workforce laid off
    Layoff_Date DATE,                            -- Date of the layoff
    Funds_Raised_Millions INT,                   -- Funds raised (in millions)
    GDP_Billions DECIMAL(15, 2),                 -- GDP value (in billions)
    Population_Million INT,                      -- Population of the country
    Literacy_Rate FLOAT,                         -- Literacy rate of the country
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID),
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID),
    FOREIGN KEY (Industry_ID) REFERENCES Industry(Industry_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID),
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID)
);

-- Step: 4 Insert Values in Schema Tables
USE world_layoffs_star_schema;

INSERT INTO Country (Country_Name, Continent)
SELECT Country_Name, Continent
FROM world_layoffs.Country_sql_data;

INSERT INTO Stage (Stage_Value, Description, Funding_Source)
SELECT stage_value, description, funding_source
FROM world_layoffs.Stage_sql_data;

INSERT INTO Company (Company_Name)
SELECT DISTINCT company
FROM world_layoffs.layoffs_staging2;

INSERT INTO Location (Location_Name)
SELECT DISTINCT location
FROM world_layoffs.layoffs_staging2;

INSERT INTO Industry (Industry_Name)
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2;


INSERT INTO Fact_Layoffs (
    Company_ID, Location_ID, Industry_ID, Stage_ID, Country_ID,
    Total_Laid_Off, Percentage_Laid_Off, Layoff_Date, Funds_Raised_Millions, 
    GDP_Billions, Population_Million, Literacy_Rate
)
SELECT 
    c.Company_ID,
    l.Location_ID,
    i.Industry_ID,
    s.Stage_ID,
    cty.Country_ID,
    ls.total_laid_off,
    ls.percentage_laid_off,
    ls.date AS Layoff_Date,
    ls.funds_raised_millions,
    wcql.GDP_Billions,
    wcql.Population_Million,
    wcql.Literacy_Rate
FROM world_layoffs.layoffs_staging2 ls
JOIN world_layoffs_star_schema.Company c ON ls.company = c.Company_Name
JOIN world_layoffs_star_schema.Location l ON ls.location = l.Location_Name
JOIN world_layoffs_star_schema.Industry i ON ls.industry = i.Industry_Name
JOIN world_layoffs_star_schema.Stage s ON ls.stage = s.Stage_Value
JOIN world_layoffs_star_schema.Country cty ON ls.country = cty.Country_Name

-- join with stage_sql_data & country_sql_data table
JOIN world_layoffs.stage_sql_data wsql ON wsql.stage_value = ls.stage
JOIN world_layoffs.country_sql_data wcql ON  wcql.Country_Name = ls.country;

COMMIT;

-- let's see the data output
select * from fact_layoffs;