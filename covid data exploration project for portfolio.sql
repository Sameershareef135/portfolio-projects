select * from CovidDeaths
where continent is not null
order by 3,4 

--select * from CovidVaccinations
--order by 3,4

-- select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- looking at total case vs total deaths
-- shows likelihood of dying if you get covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at total case vs population
-- shows percentage of population got covid
select location, date, population, total_cases , (total_cases/population)*100 as covid_effected_range
from CovidDeaths
--where location like '%states%'
order by 1,2

-- looking at countries with higher infection rate compared to population
select location, population, max(total_cases) as highest_infection_count , max((total_cases/population)*100) as percent_population_infected 
from CovidDeaths
--where location like '%states%'
group by location,population
order by percent_population_infected desc


-- LET'S BREAK THINGS BY CONTINENT 

-- countries with highest deaths per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
where continent is null
group by location
order by totaldeathcount desc


-- GLOBAL NUMBERs

-- added "and new_cases > 0" because i am getting division error for null values
-- the query worked for the youtube tutorial without adding the above line
select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int)/new_cases) as deathpercentage
from CovidDeaths
where continent is not null and new_cases > 0
group by date
order by 1,2

select  sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int)/new_cases) as deathpercentage
from CovidDeaths
where continent is not null and new_cases > 0
--group by date
order by 1,2


-- LOOKING AT TOTAL POPULATIONS VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPplVaccinated
-- (rollingpplvaccinated/population)*100 doesnt work cuz the column was just created
from CovidDeaths  dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


-- TEMP TABLE

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric)


INSERT INTO #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentagePopulationVaccinated


-- creating view to store data for later visualisations

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select * from PercentagePopulationVaccinated
