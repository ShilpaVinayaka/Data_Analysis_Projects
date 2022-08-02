SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4;

---Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$ 
WHERE continent is not NULL
ORDER by 1,2;

---Looking at Total Cases vs Total Deaths
--- Shows the likelihood of dying if you contract covid in your ocuntry
SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%ndia%' and continent is not NULL
ORDER by 1,2;

--- Looking at Total Cases vs Population
---  Shows what percentage of population got Covid
SELECT location, date, population, total_cases, 
(total_cases/population)*100 as PercentPopulation
FROM PortfolioProject..CovidDeaths$
WHERE location like '%ndia%' and continent is not NULL
ORDER by 1,2;

--- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionRate, 
MAX((total_cases/population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
GROUP BY location, population
ORDER by InfectionRate DESC;

-- LET's BREAK THINGS DOWN BY CONTINENT

--- Showing continent with Highest Death COunt per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL 
GROUP BY location
ORDER by TotalDeathCount DESC;

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL 
GROUP BY continent
ORDER by TotalDeathCount DESC;

---correct deathcount
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is NULL 
GROUP BY location
ORDER by TotalDeathCount DESC;

--- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_newCases, 
SUM(cast(new_deaths as int)) as total_newDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
GROUP BY date
ORDER by 1,2;

SELECT SUM(new_cases) as total_newCases, 
SUM(cast(new_deaths as int)) as total_newDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
ORDER by 1,2; 

-------------------------------------------------
SELECT *
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
ON dea.location = vac.location and dea.date = vac.date;

--- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidVaccinations$ vac
	JOIN PortfolioProject..CovidDeaths$ dea
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER by 2,3; 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) 
 OVER (Partition by dea.Location Order By dea.location, dea.date) 
 as RollingPeopleVaccine
FROM PortfolioProject..CovidDeaths$ dea 
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER by 2,3; 

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations,
RollingPeopleVaccine)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) 
 OVER (Partition by dea.Location Order By dea.location, dea.date) 
 as RollongPeopleVaccine
FROM PortfolioProject..CovidDeaths$ dea 
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location  
	and dea.date = vac.date
WHERE dea.continent is not NULL
 
)
Select * , (RollingPeopleVaccine/population)*100
FROM PopvsVac

--- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinates;

CREATE TABLE #PercentPopulationVaccinates
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccine numeric
)

INSERT INTO #PercentPopulationVaccinates
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) 
 OVER (Partition by dea.Location Order By dea.location, dea.date) 
 as RollongPeopleVaccine
FROM PortfolioProject..CovidDeaths$ dea 
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location  
	and dea.date = vac.date
--WHERE dea.continent is not NULL;

Select * , (RollingPeopleVaccine/population)*100
FROM #PercentPopulationVaccinates

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinates AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) 
 OVER (Partition by dea.Location Order By dea.location, dea.date) 
 as RollongPeopleVaccine
FROM PortfolioProject..CovidDeaths$ dea 
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location  
	and dea.date = vac.date
WHERE dea.continent is not NULL

Select *
FROM PercentPopulationVaccinates
