Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select Data that we are going to be using.

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths in the United States
--Death_percentage shows likelihood of dying by Covid.

Select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as death_percentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population in the United States
--Shows what percentage of pupulation got Covid

Select location,date,total_cases,population,(total_cases/population) * 100 as Infection_rates
FROM PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rates compared to population

Select location,population,MAX (total_cases) as HighestInfectionCount,MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break it down by continent.

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Covid Vaccinations

Select* 
From PortfolioProject..CovidVaccinations

--Let's join out tables

Select*
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date 

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Peoplevaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
)

Select *, (Peoplevaccinated/population)
FROM PopvsVac

-- temp table
-- DROP TABLE if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select *, (peoplevaccinated/population)* 100 as PercentagePeopleVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null



