Select *
From PortfolioProject..['CovidDeaths']
where continent is not null
order by 3,5

--Select *
--From PortfolioProject..['CovidVaccinations']
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths']
where Continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases , total_deaths, (cast(Total_deaths as int)/ cast(total_cases as int))*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
where location='Spain'
and continent is not null 
Order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (Total_cases/population)*100 as PercentInfectedPopulation
From PortfolioProject..['CovidDeaths']
--where location ='Spain'
Order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((Total_cases/population))*100 as PercentInfectedPopulation
From PortfolioProject..['CovidDeaths']
--where location ='Spain'
Group by Location, Population
Order by PercentInfectedPopulation desc


--Showing Countries with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
--where location ='Spain'
where continent is not null
Group by Location
Order by TotalDeathCount desc


--LET´S BREAK THINGS DOWN BY CONTINENT


-- Showing the Continents with Highest Death Count

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
--where location ='Spain'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
--where location='Spain'
where continent is not null 
and new_cases != 0
--Group by date
Order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select*
From PercentPopulationVaccinated