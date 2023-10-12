
-- Looking at Total Case VS Total Deaths
-- Shows likelihood of dying if you contract covid in your county

Select location, date, total_cases, total_deaths, CONVERT(float, total_deaths)/ NULLIF(CONVERT(float, total_cases), 0)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1, 2


-- Looking Total Cases VS Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, CONVERT(float, total_cases)/ NULLIF(CONVERT(float, population), 0)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null	
Order by 1, 2



-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(CONVERT(float, total_cases)) AS HighestInfectionCount, 
MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, population
Order By PercentPopulationInfected DESC



--Showing Countries With Highest Death Count Per Population

Select location, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, population
Order By TotalDeathCount DESC


-- Let's Break Things Down By Continent

Select location,  MAX(CONVERT(float, total_deaths)) AS TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is null 
Group By location
Order By TotalDeathCount DESC


-- Showing Continents With Highest Death Count

Select continent,  MAX(CONVERT(float, total_deaths)) AS TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By continent
Order By TotalDeathCount DESC


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(CONVERT(float, total_deaths)) as total_deaths, SUM(cast(total_deaths as float))/ SUM(NULLIF(CONVERT(float, new_cases), 0))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2


-- total population vs vaccination. USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
---Order by 2, 3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac	



-- Temp Table

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated	


-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
