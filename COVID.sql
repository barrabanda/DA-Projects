-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases,total_deaths, population
  FROM CovidDeaths
  ORDER BY 1,2

-- Looking at Total Cases vs Total Death
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
  FROM CovidDeaths
  WHERE continent IS NOT NULL
 -- WHERE location like 'Russia'
  ORDER BY 1,2

-- Loking at total cases vs Population
-- Shows what pecentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases / population)*100 as PercentPopulationInfected
  FROM CovidDeaths
 -- WHERE location like '%Zea%'
  ORDER BY 1,2

-- Looking at countries with highest rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases / population)*100 as PercentPopulationInfected
  FROM CovidDeaths
 -- WHERE location like '%Zea%'
  GROUP BY Location, population
  ORDER BY PercentPopulationInfected desc

-- Showing the countries with  highest death count per population
SELECT Location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
  FROM CovidDeaths
  WHERE continent IS NOT NULL
 -- WHERE location like '%Zea%'
  GROUP BY Location
  ORDER BY TotalDeathCount desc

-- Showing the continents with  highest death count per population
SELECT continent, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
  FROM CovidDeaths
  WHERE continent IS NOT NULL
 -- WHERE location like '%Zea%'
  GROUP BY continent
  ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, 
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPersantage
  FROM CovidDeaths
  WHERE continent IS NOT NULL
 -- WHERE location like 'Russia'
  GROUP BY date
  ORDER BY 1,2

-- Looking at Total Population vs Vaccination

WITH PopsvsVac  (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopsvsVac

--TEMP

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
