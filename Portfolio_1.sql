SELECT *
FROM Portfolio_Project..COVID_deaths$
Order By 3,4

SELECT *
FROM Portfolio_Project..COVID_Vaccinations$
Order By 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_Project..COVID_deaths$
Order By 1,2

--Looking at Total cases vs Total deaths 

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS percent_deaths
FROM Portfolio_Project..COVID_deaths$
WHERE location like '%Nigeria%'
Order By 1,2

--Looking at Total cases vs population

SELECT location,date,total_cases, population, (total_cases/population)*100 AS prevalence_rate
FROM Portfolio_Project..COVID_deaths$
WHERE location like '%Nigeria%'
Order By 1,2

--Breaking things down by location

SELECT location, MAX(cast(total_deaths AS int)) AS Total_death_count
FROM Portfolio_Project..COVID_deaths$
WHERE continent is null
Group By location
Order By Total_death_count desc

SELECT continent, MAX(cast(total_deaths AS int)) AS Total_death_count
FROM Portfolio_Project..COVID_deaths$
WHERE continent is not null
Group By continent
Order By Total_death_count desc

-- Looking at Total population vs Vaccination

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
From Portfolio_Project..COVID_deaths$ dea
JOIN Portfolio_Project..COVID_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

With Pop_vs_Vac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
AS
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
From Portfolio_Project..COVID_deaths$ dea
JOIN Portfolio_Project..COVID_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *
FROM Pop_vs_Vac


--TEMP TABLE

DROP TABLE If exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
rolling_people_vaccinated float
)

INSERT INTO #Percentpopulationvaccinated
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
From Portfolio_Project..COVID_deaths$ dea
JOIN Portfolio_Project..COVID_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *
FROM #Percentpopulationvaccinated


--Creating view for data visualization

CREATE VIEW 
Pop_vs_Vac AS
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
From Portfolio_Project..COVID_deaths$ dea
JOIN Portfolio_Project..COVID_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null