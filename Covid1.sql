select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2;

-- Total Cases Vs total Deaths of India
-- shows % of death if you got covid positive in India 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like 'India'
order by 3;

-- Total Cases Vs Population
-- shows what % of population died in Covid in India 
select location, date, population, total_cases, round((total_cases/population)*100,2) as PercentagePopulation
from PortfolioProject..CovidDeaths
Where location like 'India'
order by 1,2;

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max(round(total_cases/population,4)*100) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location, population 
order by PercentagePopulationInfected desc;

-- countries with highest death count per population
-- total death->varchar->cast
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
-- ->grouping by continent-> when continent is null
where continent is not null
group by location 
order by TotalDeathCount desc;


-- EXPLOING DATA BY CONTINENT

-- Continent with hughest death count per population 

select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
-- ->grouping by continent-> when continent is null
where continent is null
group by location 
order by TotalDeathCount desc;


-- Global Numbers (total no. of cases,no. of deaths, death%)
-- total global number of infection
select  sum(new_cases) as NoOfCases, sum(cast(new_deaths as int)) as NoOfDeaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2;

-- Global Numbers (total cases per day)
-- new_cases:float, new_death:varchar->cast
select date, sum(new_cases) as NoOfCases, sum(cast(new_deaths as int)) as NoOfDeaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group By date
order by 1,2;



-- Vaccinations data
select * 
from PortfolioProject..CovidVaccinations


-- Total population vs vaccination
select d.continent, d.location, d.date, d.population,v.new_vaccinations ,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.Date) as RollingPopulationVaccinated
--(RollingPopulationVaccinated/population)*100
-- sum(cast(v.new_vaccinations as int))
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2,3;


-- use CTE
with PopVsVac (continent, location,date, population,New_Vaccinations,RollingPopulationVaccinated)
as
(
select d.continent, d.location, d.date, d.population ,v.new_vaccinations ,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.Date) as RollingPopulationVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
--order by 2,3
)

select * , round((RollingPopulationVaccinated/population)*100,2)as PercentPopulationVaccinated
from PopVsVac;



-- TEMP TABLE
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)

insert into #percentPopulationVaccinated
select d.continent, d.location, d.date, d.population ,v.new_vaccinations ,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.Date) as RollingPopulationVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
--order by 2,3

select * , round((RollingPopulationVaccinated/population)*100,2)as PercentPopulationVaccinated
from #percentPopulationVaccinated;



-- Create View to store data for later visualisation

create view percentPopulationVaccinated as
select d.continent, d.location, d.date, d.population ,v.new_vaccinations ,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.Date) as RollingPopulationVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null;

select * from
percentPopulationVaccinated;