--select *
--from PortfolioProjects..CovidDeaths
--order by 3,4

--select *
--from PortfolioProjects..CovidVaccinations
--order by 3,4

--The data that I will use

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProjects..CovidDeaths
--Order By 1,2

--Comparing Total Cases vs Total Deaths
--Chances of death if infected by COVID-19

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeaths
From PortfolioProjects..CovidDeaths
Where Location like '%zim%'
Order By 1,2

--Comparing Total Cases vs Population
--Percentage of population infected by COVID-19

Select Location, date, total_cases, population, (total_cases/population)*100 AS PercentageCases
From PortfolioProjects..CovidDeaths
Where Location like '%zim%'
Order By 1,2

--Countries with highest infection rate

Select Location, population, MAX(total_cases) AS HghestInfectionCount, MAX(total_cases/population)*100 AS InfectedPopulationPercentage
From PortfolioProjects..CovidDeaths
--Where Location like '%zim%'
Group By Location, Population
Order By InfectedPopulationPercentage desc

--Countries with highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%zim%'
Where continent is not null
Group By Location
Order By TotalDeathCount desc

--Breaking things down by continent

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%zim%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc


--Continents with highest Death Count per population

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%zim%'
Where continent is null
Group By continent
Order By TotalDeathCount desc

--Global numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 AS PercentageDeaths
From PortfolioProjects..CovidDeaths
--Where Location like '%zim%'
Where continent is not null
Group By date
Order By 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 AS PercentageDeaths
From PortfolioProjects..CovidDeaths
--Where Location like '%zim%'
Where continent is not null
--Group By date
Order By 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

--Use CTE

With Popvsvac (Continent, Location,Date, Poulation, new_vacciations, RollingPeopleVaccinated)
AS
(Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)

Select *
from Popvsvac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
new_vacciations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS RPV_P
from #PercentPopulationVaccinated

--Creating a view

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


SELECT *
FROM PercentPopulationVaccinated






