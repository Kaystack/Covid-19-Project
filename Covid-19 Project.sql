-- Covid 19 Data Exploration for Nigeria-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- Data selection for exploration in Nigeria
-- This selects Covid-19 data for Nigeria, including location, date, total cases, new cases, total deaths, and population,
-- and orders it by location and date.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM MyPortfolio..CovidDeaths
WHERE location = 'Nigeria' AND continent = 'Africa'
ORDER BY 1,2

-- Total Cases vs Total Deaths in Nigeria
-- This Shows likelihood of dying if you contract covid in Nigeria and shows the total cases vs total deaths in Nigeria
-- and calculates the death percentage by dividing the total deaths by the total cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE location = 'Nigeria' AND continent = 'Africa'
ORDER BY 1,2

-- Total Cases Over Population in Nigeria
-- Shows what percentage of population in Nigeria is infected with Covid by dividing the total cases by the population.
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE location = 'Nigeria' AND continent = 'Africa'
ORDER BY 1,2

-- Countries in Africa with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE continent = 'Africa'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries in Africa with Highest Death Count per Population
-- includes location and total death count, and orders it by total death count in descending order.
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM MyPortfolio..CovidDeaths
WHERE continent = 'Africa'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing African countries with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM MyPortfolio..CovidDeaths
WHERE continent = 'Africa'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS for Africa
-- This query shows the African continent's global numbers, including the total cases, 
-- total deaths, and death percentage, and filters it by the African continent.
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent = 'Africa'


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
-- creates a view to store the data for later visualizations, including the continent, location, 
-- date, population, new vaccinations, and rolling people vaccinated, and joins the CovidDeaths 
-- and CovidVaccinations tables on location and date and filters by the African continent.
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

