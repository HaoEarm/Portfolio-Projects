
-- Data Sources (retrieved 2021)
-- CovidDeaths https://ourworldindata.org/covid-deaths
-- CovidVaccinations https://ourworldindata.org/covid-vaccinations

/* Data Exploration of Covid 19 (Deaths & Vaccinations)

Skills/Commands Used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types.
*/

-- Selecting Everything and checking import is successful
--SELECT * 
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProj.dbo.CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4;

-- Selecting Data that is going to be used
--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths 
-- Could show the likelihood of dying if you contract Covid in each country
--SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100  AS DeathPercentage
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NOT NULL
---- WHERE location LIKE 'Singapore' Looking at individual country 
--ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
--SELECT location,date,population,total_cases,(total_cases/population)*100 AS PositivePercentage
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE location LIKE 'Singapore'
--ORDER BY 1,2;

-- Looking at countries with highest Positive Rate vs Population
--SELECT location,population,MAX(total_cases) AS HighestPositiveCount, MAX((total_cases/population))*100 AS PositivePopulationPercentage
--FROM PortfolioProj.dbo.CovidDeaths
--GROUP BY location, population
--ORDER BY PositivePopulationPercentage DESC;

 -- Looking at Countries with Highest Death Count per Population
 -- Total Death column is nvarchar and not int
 -- Exclude International and continents 
--SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC;

-- Looking at Continents with highest death count per population
-- Excluding World Total, European Union which is in Europe, and International
--SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NULL
--AND location NOT IN ('World', 'European Union', 'International')
--GROUP BY location
--ORDER BY TotalDeathCount DESC;

-- Looking at Global Numbers, Global Death counts per population
-- new_deaths is nvarchar, new_cases is float
-- Unable to just SELECT total_cases and total_deaths, then GROUP BY date because we are looking at multiple columns, not just date
-- SUM(MAX(total_cases)) does not work as well due to 2 aggregate functions 
-- using SUM(new_cases) to represent total cases and the same for total_deaths
--SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS GlobalDeathPercentage
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2;

-- Looking at Total Global Death counts per population 
--SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS GlobalDeathPercentage
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2;


-- Looking at CovidVaccinations
--SELECT  * 
--FROM PortfolioProj.dbo.CovidVaccinations;

-- Joining 2 tables CovidDeath + CovidVaccinations
--SELECT *
--FROM PortfolioProj.dbo.CovidDeaths dea
--JOIN PortfolioProj.dbo.CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date;

-- Looking at total population vs vaccinations
-- new_vaccinations is nvarchar, 
-- Using PARTITION BY OVER to get total vaccinations with a rolling count
-- Using this query as CTE , ORDER BY is invalid in CTE
--WITH PopvsVac (Continent, Location, Date, Population,New_vaccinations,RollingVaccinationCount)
--AS
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--FROM PortfolioProj.dbo.CovidDeaths dea
--JOIN PortfolioProj.dbo.CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
---- ORDER BY 2,3
--)
---- Using CTE for calculating Vaccination vs Population
--SELECT *, (RollingVaccinationCount/Population)*100 as RollingVaccinationPercentage
--FROM PopvsVac;

-- Using Temp Table to calculate Vaccination vs Population (Same as CTE)
--DROP TABLE IF EXISTS #VaccinatedPopulationPercentage
--CREATE TABLE #VaccinatedPopulationPercentage
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingVaccinationCount numeric
--)

--INSERT INTO #VaccinatedPopulationPercentage
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--FROM PortfolioProj.dbo.CovidDeaths dea
--JOIN PortfolioProj.dbo.CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

--SELECT *, (RollingVaccinationCount/Population)*100 as RollingVaccinationPercentage
--FROM #VaccinatedPopulationPercentage;

-- Creating View to store data for visualizations 
-- Using Continents with highest death count per population
--CREATE VIEW HighestContinentDeathCounts AS
--SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProj.dbo.CovidDeaths
--WHERE continent IS NULL
--GROUP BY location

-- Querying on View
--SELECT * 
--FROM HighestContinentDeathCounts;