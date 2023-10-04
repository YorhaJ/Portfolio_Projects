Select *
From PortfolioProject..[covid deaths]
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..[covid vaccinations]
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[covid deaths]
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 as DeathPercentage
From PortfolioProject..[covid deaths]
order by 1,2

-- Total Cases vs Population

Select location, date, total_cases, population, (CONVERT(float, total_cases) / CONVERT(float, population)) * 100 as InfectionPercentage
From PortfolioProject..[covid deaths]
--Where location like 'portugal'
order by 1,2

-- Countries with Highest infection Rate compared to Population

Select location, MAX(cast(total_cases as bigint)) as HighestInfectionCount, population, (MAX(cast(total_cases as bigint))/population) * 100 as PercentPopulationInfected
From PortfolioProject..[covid deaths]
--Where location like 'portugal'
Group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death count per Population

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..[covid deaths]
--Where location like 'portugal'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Death breakdown by Continent 

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..[covid deaths]
--Where location like 'portugal'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..[covid deaths]
where continent is not null and new_cases > 0
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..[covid deaths]
where continent is not null and new_cases > 0
--Group by date
order by 1,2


-- Total Pop vs Vaxx


Select  dea.continent, dea.location, dea.date, dea.location, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From PortfolioProject..[covid deaths] dea
Join PortfolioProject..[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- CTE

With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(Convert(bigint,vac.new_vaccinations_smoothed)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..[covid deaths] dea
Join PortfolioProject..[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From PopvsVax;


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(Convert(bigint,vac.new_vaccinations_smoothed)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..[covid deaths] dea
Join PortfolioProject..[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated;

-- View for later visualizations 

DROP VIEW PercentPopulationVaccinated;
USE PortfolioProject 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(Convert(bigint,vac.new_vaccinations_smoothed)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..[covid deaths] dea
Join PortfolioProject..[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

