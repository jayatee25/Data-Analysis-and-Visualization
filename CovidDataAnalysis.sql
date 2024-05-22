Select location, date, total_deaths, total_cases, new_cases, population
From Project..['Covid Deaths$']
Where continent is not null
order by 1,2

--percentage
--shows likelihood of dying if you contract covid in your country
Select location, date, total_deaths, total_cases, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From Project..['Covid Deaths$']
Where location like '%india%'
order by 1,2

--looking at total cases vs population

Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as CovidPercentage
From Project..['Covid Deaths$']
Where location like '%india%'
order by 1,2

--highest infection rate
Select location, MAX(total_cases) as HighestInfCount, population, (cast(MAX(total_cases) as float)/cast(population as float))*100 as maxinfected
From Project..['Covid Deaths$']
Group by Location, Population
order by maxinfected 

--Continent wise breakdown
Select location, MAX(total_cases) as HighestInfCount, population, (cast(MAX(total_cases) as float)/cast(population as float))*100 as maxinfected
From Project..['Covid Deaths$']
Where continent is not null
Group by Location, Population
order by maxinfected 


--highest death rate
Select location, MAX(total_deaths) as Maxtotaldeaths, population, (cast(MAX(total_deaths) as float)/cast(population as float))*100 as maxdead
From Project..['Covid Deaths$']
Where continent is not null
Group by Location, Population
order by maxdead desc

-- continent wise 
Select location, MAX(total_deaths) as totaldeathcount
From Project..['Covid Deaths$']
Where continent is null
Group by location
order by totaldeathcount desc

-- countries with the highest death count
Select Location, MAX(total_deaths) as totaldeathcount
From Project..['Covid Deaths$']
Where continent is not null
Group by Location
order by totaldeathcount desc

-- showing the continents with the highest death count
Select continent, MAX(total_deaths) as totaldeathcount
From Project..['Covid Deaths$']
Where continent is not null
Group by continent
order by totaldeathcount desc

-- global numbers
Select date, SUM(new_cases) as newcases, SUM(new_deaths) as newdeaths, (SUM(new_deaths)/SUM(new_cases))*100 as newdeathpercentage
From Project..['Covid Deaths$']
Where continent is not null AND new_cases > 0
Group by date 
order by 1,2

Select SUM(new_cases) as newcases, SUM(new_deaths) as newdeaths, (SUM(new_deaths)/SUM(new_cases))*100 as newdeathpercentage
From Project..['Covid Deaths$']
Where continent is not null AND new_cases > 0
--Group by date 
order by 1,2

--total population vs vaccination

Select *
From Project..['Covid Deaths$'] dea
Join Project..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Project..['Covid Deaths$'] dea
Join Project..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingPplvaccinated
From Project..['Covid Deaths$'] dea
Join Project..['covid vaccinations$'] vac
	On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- use cte
-- In order to store and use Rollingpplvaccinated, we create a CTE or a TempTable

With PopsvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPplvaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingPplvaccinated
From Project..['Covid Deaths$'] dea
Join Project..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3
)
Select *, (RollingPplvaccinated/Population)*100 as percentagerpv
From PopsvsVac

--TEMP TABLE

DROP table if exists #PercentPopVaccinanted
Create Table #PercentPopVaccinanted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVaccinated numeric
)

Insert into #PercentPopVaccinanted
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingPplvaccinated
From Project..['Covid Deaths$'] dea
Join Project..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3

Select *, (RollingPplvaccinated/Population)*100 as percentintemptable
From #PercentPopVaccinanted

--Creating view to store data for later visualization

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.Date) as RollingPplvaccinated
From Project..['Covid Deaths$'] dea
Join Project..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3

Select *
From PercentPopVaccinated