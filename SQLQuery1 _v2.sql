
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Canada'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in Canada

select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location = 'Canada'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as HighestCovidPercentage
from PortfolioProject..CovidDeaths
--where location = 'Canada'
Group by location, population
order by HighestCovidPercentage desc

-- Showing the countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Canada'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing the Continent with Highest Death Count per Population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Canada'
where continent is not null
Group by continent
order by TotalDeathCount desc 

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinatons vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location and
	dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
--order by 1,2,3)
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinatons vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location and
	dea.date = vac.date
	--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

Create view PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinatons vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null


select *
from PercentPopulationVaccinated1