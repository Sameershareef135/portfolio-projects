-- DATA CLEANING PROJECT --

SET SQL_SAFE_UPDATES = 0;


USE WORLD_LAYOFFS;

select * from layoffs;

-- 1. REMOVE DUPLICATES IF ANY --
-- 2. STANDARDIZE THE DATA --
-- 3. LOOK AND TRY TO FILL/POPULATE NULL AND BLANK VALUES --
-- 4. REMOVE ANY COLUMNSn or rows --

create table layoffs_staging
like layoffs;

select * from layoffs_staging;

insert into layoffs_staging
select * from layoffs;


# IDENTIFYING DUPLICATES
with duplicate_cte as( 
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, 
stage, country, funds_raised_millions ) as row_num
 from layoffs_staging
)
select * 
from duplicate_cte
where row_num > 1;

select *
from layoffs_staging
where company = 'casper';

with duplicate_cte as( 
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, 
stage, country, funds_raised_millions ) as row_num
 from layoffs_staging
)
delete
from duplicate_cte
where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, 
stage, country, funds_raised_millions ) as row_num
 from layoffs_staging;

delete
from layoffs_staging2
where row_num > 1;

select * 
from layoffs_staging2;
where row_num > 1;



-- STANDARDIZING DATA --

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2 
SET company = trim(company);


select distinct industry
from layoffs_staging2
order by industry;

select *
from layoffs_staging2
where industry like '%crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like '%crypto%';

select distinct country
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'United States'
where country like '%United States%';
# this above line is wrong, i should be trying

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;


SELECT *
FROM world_layoffs.layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.layoffs_staging2;


# REMOVING NULL  AND BLANK VALUES

select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off;

select distinct industry
from layoffs_staging2;

select * 
from layoffs_staging2
where industry is null
or industry = ''; # FOR BLANK SPACES NO NEED ADD A SPACE BETWEEN QOUTES ' '," " LIKE THIS, USE THEM WITHOUT QUOTES '',""

update layoffs_staging2
set industry = null
where industry = '';

# TRYING TO POPULATE AIRBNB

select *
from layoffs_staging2
where company = 'airbnb';

select *
from layoffs_staging2
where company like 'bally%';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

# removing unnecessary rows and columns

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


select * 
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num
