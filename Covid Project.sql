SELECT *
FROM CovidData cd 
WHERE continent IS NOT NULL 
ORDER BY 3,4

-- Select the data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData cd 
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Look at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidData cd 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Look at total cases vs population
SELECT location, date, total_cases, population , (total_cases/population)*100 AS percent_population_infected
FROM CovidData cd 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Look at contries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS percent_population_infected
FROM CovidData cd 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
GROUP BY location, population 
ORDER BY 4 DESC 

-- Show contries with highest death count per population
SELECT location, MAX(total_deaths) AS total_death_count
FROM CovidData cd 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY 2 DESC 

-- Break things down by continent
-- Show continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS total_death_count
FROM CovidData cd 
-- WHERE location LIKE'%states%'
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY 2 DESC 

-- Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM CovidData cd 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
-- ORDER BY 1

-- Look at population vs vaccinations
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated
FROM CovidData cd 
WHERE continent IS NOT NULL 
ORDER BY 2,3

-- CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated
FROM CovidData cd 
WHERE continent IS NOT NULL 
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac
-- WHERE location LIKE 'United States'
ORDER BY 2,3

-- Temp table
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated (
continent VARCHAR(50),
location VARCHAR(50),
date VARCHAR(50),
population REAL,
new_vaccinations REAL,
rolling_people_vaccinated REAL
);
INSERT INTO percent_population_vaccinated
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated
FROM CovidData cd 
WHERE continent IS NOT NULL;
SELECT *, (rolling_people_vaccinated/population)*100
FROM percent_population_vaccinated
-- WHERE location LIKE 'United States'
ORDER BY 2,3

-- Create view to store data for later visualizations
CREATE VIEW percent_population_vaccinated1 AS
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated
FROM CovidData cd 
WHERE continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM percent_population_vaccinated1