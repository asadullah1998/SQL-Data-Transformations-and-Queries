
select * from PortfolioProject..Covid_Deaths
order by 3,4; 

--select * from ..Covid_Vaccinations
--order by 3,4;



--ordering our data set by location and then date
select Location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths
order by 1,2;


--Total cases vs Total deaths
--This shows the likelihood of death incase you contract covid in Pakistan
select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..Covid_Deaths
where location = 'Pakistan'
order by 1,2;

--Total cases vs Total Population
--Shows what percentage of the population got covid
select Location,date, total_cases, population, (total_cases/population)*100 as Percentage_of_population_infected
from PortfolioProject..Covid_Deaths
where location = 'Pakistan'
order by 1,2;


 --looking at countries with highest infection rates compared to population
 select Location, population, max(total_cases) as highest_infection_count,
 max((total_cases/population))*100 as percentage_population_infected
from PortfolioProject..Covid_Deaths
--where location = 'Pakistan'
group by Location,Population
order by percentage_population_infected desc;


--showing cuntries with highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
where continent is not null --because  continents asia,africa.. are also included in this list
group by location
order by TotalDeathCount desc;



--breakup by continent
select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..Covid_Deaths
where continent is not null
Group by continent
order by total_death_count desc; 


--Global Numbers
select date,sum(new_cases) as total_cases_worldwide, sum(cast(new_deaths as int)) as total_deaths_worldwide, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..Covid_Deaths
where continent is not null
group by date
order by 1,2;


--Total global numbers
select sum(new_cases) as total_cases_worldwide, sum(cast(new_deaths as int)) as total_deaths_worldwide, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..Covid_Deaths
where continent is not null
order by 1,2;


--------------------------------------------------------------------------------------------------------------
--Taking a look at total population vs vaccinations
 --totals new_vaccinations of a country(location)
select  d.continent,d.location, d.population, d.date, v.new_vaccinations,
	
	sum(convert(int,v.new_vaccinations)) 
	OVER (partition by d.location) as Rolling_people_Vaccinated        --totals new_vaccinations of a country(location)

from PortfolioProject..Covid_Deaths d join PortfolioProject..Covid_Vaccinations v
	on d.location = v.location 
		and d.date = v.date

where d.continent is not null
order by 2,3







--totals new_vaccinations of a country(location) by each date
select  d.continent,d.location, d.population, d.date, v.new_vaccinations,
	
	sum(convert(int,v.new_vaccinations)) 
	OVER (partition by d.location order by d.location,d.date) as Rolling_people_Vaccinated
									--totals new_vaccinations of a country(location) by each date

from PortfolioProject..Covid_Deaths d join PortfolioProject..Covid_Vaccinations v
	on d.location = v.location 
		and d.date = v.date

where d.continent is not null
order by 2,3


--now we want to find out percentage total people vaccinated within a population
select  d.continent,d.location, d.population, d.date, v.new_vaccinations,
	
	sum(convert(int,v.new_vaccinations)) 
	OVER (partition by d.location order by d.location,d.date) as Rolling_people_Vaccinated
    --,(Rolling_people_Vaccinated/population)*100
	--we cant do the above beacause alias can't be used for a new calculation
	--so we need to do something else 

									--totals new_vaccinations of a country(location) by each date

from PortfolioProject..Covid_Deaths d join PortfolioProject..Covid_Vaccinations v
	on d.location = v.location 
		and d.date = v.date

where d.continent is not null
order by 2,3



-------------------------------------------------------------------------------------------------------------
--common table expression
--Specifies a temporary named result set, known as a common table expression (CTE).

With PopvsVac (continent,location,population,date,new_vaccinations,Rolling_people_vaccinated)
as
(
select  d.continent,d.location, d.population, d.date, v.new_vaccinations,
	
	sum(convert(int,v.new_vaccinations)) 
	OVER (partition by d.location order by d.location,d.date) as Rolling_people_Vaccinated
 
from PortfolioProject..Covid_Deaths d join PortfolioProject..Covid_Vaccinations v
	on d.location = v.location 
		and d.date = v.date

where d.continent is not null --and d.location = 'Pakistan'
--order by 2,3  --orderby clause cant be in there
)
Select * ,(Rolling_people_Vaccinated/population)*100 as Percentage_people_vaccinated from PopvsVac





----------------------------------------------------------------------------------------------------------




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths d
Join PortfolioProject..Covid_Vaccinations v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--------------------------------------------------------------------------------------------------
Create View View_PercentPopulationVaccinated as
		Select d.continent, d.location, d.date, d.population, v.new_vaccinations
		, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Rolling_People_Vaccinated
		--, (RollingPeopleVaccinated/population)*100
		From PortfolioProject..Covid_Deaths d
		Join PortfolioProject..Covid_Vaccinations v
			On d.location = v.location
			and d.date = v.date
		where d.continent is not null 
		--order by 2,3
		

select * from View_PercentPopulationVaccinated ;
