-- (Checking that the data was successfully imported)

SELECT *
FROM 
	PortfolioProject.dbo.covid_deaths
ORDER BY 
	3,4


SELECT *
FROM 
	PortfolioProject.dbo.covid_vaccinations
ORDER BY 
	3,4

-- (Select the data that we are going to be using)

SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	PortfolioProject.dbo.covid_deaths
ORDER BY 
	1,2

-- Looking at Total Cases vs. Total Deaths in Spain
-- Likelihood of dying of COVID in your country

SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths / total_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject.dbo.covid_deaths
WHERE 
	Location = 'Spain'
ORDER BY 
	1,2

-- Looking at Total Cases vs. Population in Spain

SELECT 
	Location, 
	date, 
	population, 
	total_cases, 
	(total_cases / population)*100 AS PercentPopulationInfected
FROM 
	PortfolioProject.dbo.covid_deaths
WHERE 
	Location = 'Spain'
ORDER BY
	1,2



-- Looking at COUNTRIES with highest Infection Rate compared to Population

SELECT 
	Location, 
	Population,
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases / Population)) * 100 AS PercentPopulationInfected
FROM 
	PortfolioProject.dbo.covid_deaths
GROUP BY 
	Location, 
	Population
ORDER BY 
	4 DESC

-- Looking at COUNTRIES with highest Death Count compared to Population

SELECT 
	Location, 
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
	PortfolioProject.dbo.covid_deaths
WHERE 
	continent is not null -- Delete cells where the continent is in the Location column
GROUP BY 
	Location
ORDER BY 
	2 DESC


-- Looking at the CONTINENTS with highest Death Count

SELECT 
	Location, 
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
	PortfolioProject.dbo.covid_deaths
WHERE 
	continent IS NULL AND 
	Location NOT LIKE '%income%' -- Delete cells where the continent is in the Location column
GROUP BY 
	Location
ORDER BY 
	2 DESC


-- TOTAL CASES VS TOTAL DEATHS per day

SELECT 
	date, 
	SUM(new_cases) AS Total_Cases, 
	SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject.dbo.covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	date
ORDER BY 
	1,2

-- TOTAL CASES AND DEATHS (GLOBAL)

SELECT  
	SUM(new_cases) AS Total_Cases, 
	SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject.dbo.covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	1,2


-- LOOKING TOTAL POPULATION VS VACCINATIONS (USE TEMPORARY TABLE)

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..covid_deaths AS dea
JOIN 
	PortfolioProject..covid_vaccinations AS vac
	ON 
		dea.Location = vac.location AND 
		dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

-- Creating View to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS 
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..covid_deaths AS dea
JOIN 
	PortfolioProject..covid_vaccinations AS vac
	ON 
		dea.Location = vac.location AND 
		dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM
	PercentagePopulationVaccinated