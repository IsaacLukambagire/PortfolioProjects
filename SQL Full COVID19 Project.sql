Select*
From PortfolioProject1..CovidDeaths$
Where continent is not null
Order by 3,4

--Select*
--From PortfolioProject1..CovidVacinations$
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths$
Where continent is not null
Order by 1,2

--Total Cases vs Total Deaths in Uganda - The likelihood of dying when contracted with COVID
Select Location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2),total_deaths) / CONVERT(DECIMAL(18,2), total_cases))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths$
Where Location like '%Uganda%'
Order by 1,2

--Total Cases vs Population in Uganda - The percentage of population that contracted COVID
Select Location, date, total_cases, population, ((cast(total_cases as int) / population) )*100 as PercentofPopulationInfected
From PortfolioProject1..CovidDeaths$
Where Location like '%Uganda%'
Order by 1,2


-- Countries with highest infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Countries with the highest death Count per population
Select Location, MAX(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where Continent is not null
Group by location, population
Order by TotalDeathCount desc

-- Breaking things down by continent
Select Continent, Max (cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where Continent is not null
Group by continent
Order by TotalDeathCount desc

-- Showing the continents with the highest death count per population
Select Continent, Max (cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where Continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths$
where continent is not null
order by 1,2

-- Total population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--uSing CTE 

with PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLES

Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating views to store data for visualisations 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVacinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Create View TotalDeathCount as
Select Continent, Max (cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where Continent is not null
Group by continent
