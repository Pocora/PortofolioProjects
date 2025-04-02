select * 
from PortofolioProject1..CovidDeaths
where continent is not null
order by 3,4


--select * 
--from PortofolioProject1..CovidVaccinations$
--order by 3,4

-- Select data that I'm going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) *100  as DeathPercentage
from PortofolioProject1..CovidDeaths
order by 1,2

select * from portofolioProject1..CovidDeaths order by 3, 4
--select * from portofolioProject1..CovidVaccinations order by 3, 4


-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathProcentage
from PortofolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- It shows what % of procentage of population got Covid

select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopilationInfected
from PortofolioProject1..CovidDeaths
where location like '%romani%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as ProcentagePopulationInfected
from PortofolioProject1..CovidDeaths
--where location like '%romani%'
group by Location, population
order by ProcentagePopulationInfected desc

-- Showing Countries with Highest death Count per Population

select Location, MAX( cast (Total_deaths as int )) as TotalDeathCount
from PortofolioProject1..CovidDeaths
--where location like '%romani%'
where continent is not null
group by Location, population
order by TotalDeathCount desc


-- Let's break things down by continent



-- Showing continents whit the highest deaths count per population

select continent, MAX( cast (Total_deaths as int )) as TotalDeathCount
from PortofolioProject1..CovidDeaths
--where location like '%romani%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

select   sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_daths, SUM(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortofolioProject1..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Popilation vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int ,vac.new_vaccinations  )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int ,vac.new_vaccinations  )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)

select *, (RollingPeopleVaccinated / Population)*100 
from PopvsVac
Where location = 'Romania'

-- Temp table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int ,vac.new_vaccinations  )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
-- order by 2,3

select *, (RollingPeopleVaccinated / Population)*100 
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int ,vac.new_vaccinations  )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
Join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationVaccinated

