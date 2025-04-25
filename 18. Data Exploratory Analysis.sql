-- Exploratory Data Analysis

select *
from layoffs_staging2;
-- What was the highest amount for each category in one layoff
select MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs_staging2;
-- Which companies completely folded ordered by who laid off the most when it happened
select *
from layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- Same, but now looking at order of who got the most money
select *
from layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Which company laid off the most people
select company, SUM(total_laid_off)
from layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- The earliest and latest layoffs
select MIN(`date`), MAX(`date`)
from layoffs_staging2;
-- What industry got hit the most during this time
select industry, SUM(total_laid_off)
from layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- Which country laid off the most
select country, SUM(total_laid_off)
from layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- Which days had the most layoffs, order by 2, order by 1 shows it from most recent to oldest
select `date`, SUM(total_laid_off)
from layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;
-- Same but now, just by year and not actual day
select YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- Shows layoffs by which stage the company was at during the layoff
select stage, SUM(total_laid_off)
from layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;
-- Percentage doesn't really show us anything because we don't know the total number at these companies
-- Rolling total, this doesn't show the year, but if you're interested to see if certain months have more layoffs in general
select SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
from layoffs_staging2
GROUP BY `MONTH`;
-- Now we get to see it by specific month
select SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
from layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
select SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
from layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
-- Let's see how many layoffs per year for each company
select company, SUM(total_laid_off)
from layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;
-- Now, let's rank who laid off the most per year
select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;
-- Let's just see the top 5 based on ranking
WITH Company_Year (company, years, total_laid_off) AS
(
select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;







