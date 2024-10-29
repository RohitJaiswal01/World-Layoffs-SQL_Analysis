# SQL-World_Layoffs_Analysis
## Project Overview
The SQL World Layoffs Analysis project is a comprehensive examination of global layoff trends to provide insights into job market dynamics and industry impacts. Using SQL, this project analyzes various aspects of the layoffs dataset, including regional and industry-specific layoffs, affected company stages, and peak periods of workforce reductions. This analysis is intended to assist job seekers, placement agencies, and companies with data-backed insights for strategic workforce planning and decision-making.

## Project Objectives
Analyze global layoff data to identify trends and patterns over time.

Examine layoffs by region, industry, and company stage.

Identify high-impact periods and peak trends in layoffs.

Provide actionable insights to support job market understanding and strategic planning.

## Data Cleaning and Transformation
Data cleaning and transformation were conducted in a separate staging table to ensure data integrity and consistency before performing the analysis. Key transformations included:

Duplicate Removal: Identified and removed duplicate entries to avoid data redundancy.

Standardizing Entries: Standardized country and industry fields for uniformity in analysis.

Date Formatting: Reformatted date fields to a consistent structure, facilitating time-series analysis.

Handling Null Values: Managed missing data in key columns by either removing or imputing values where necessary.

Data Validation: Ensured that all transformations were accurately applied and consistent with project requirements.


## Exploratory Data Analysis (EDA)
After data cleaning, EDA was conducted to extract meaningful insights, including:

Layoff Distribution Analysis: Analyzed layoffs by location, industry, and company stage to identify high-impact regions and sectors.

Trend Analysis: Identified peak periods of layoffs by analyzing trends over time, including month-by-month and year-over-year comparisons.

Company-Level Insights: Ranked companies by total layoffs, highlighting companies most impacted by workforce reductions.

High-Impact Layoff Periods: Conducted a rolling monthly analysis to pinpoint periods with the highest layoff activity.

Yearly Ranking: Analyzed and ranked layoffs yearly to observe long-term trends and identify periods of high layoffs for strategic insights.


## Tools and Technologies
Database Management System: MySQL
SQL Queries: For data cleaning, transformation, and analysis


