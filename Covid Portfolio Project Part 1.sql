use PortfolioProject 

select * from CovidDeaths 

drop table 

Drop table CovidDeaths 
select * from CovidVaccinations 


select * 
from PortfolioProject..CovidDeaths 
--where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidDeaths 
order by 3,4

select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
order by 1, 2

--Looking at total cases vs total deaths 
--shows likelihood of dying if you contract covid in your country 

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths 
where Location = 'United States'
order by 1, 2


---Lookig at the total cases vs populatuon 
--shows what percentage of population got covid 

select Location, Date, total_cases, Population, (total_cases/Population)*100 as PopulationPercentage 
from PortfolioProject..CovidDeaths 
where Location  = 'India'
order by 1, 2

--which country has the highest infection rates compared to the population 
--looking at countries with the highest infection rate compared to the population

select Location,  Population, max(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 as InfectedPopulationPercentage 
from PortfolioProject..CovidDeaths
group by Location, Population 
order by InfectedPopulationPercentage desc


--How many people actually died 
--showing the countries with the highest death count per population 

select Location,   max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by Location 
order by TotalDeathCount desc




--showing the continent with the highest death counts 

select continent, MAX(cast(total_deaths as int)) as [Total Death Count]
from PortfolioProject..CovidDeaths
where continent is not null
group by continent 
order by [Total Death Count] desc 


--MyInnovation-- 
alter proc sptotaldeathcountsequencebycountry as begin 
with cte as 
(select location, continent,  MAX(cast(total_deaths as int)) as [Total Death Count],
DENSE_RANK() over (order by  MAX(cast(total_deaths as int)) desc) as dr 
from PortfolioProject..CovidDeaths
where continent is not null 
group by location, continent) 
select top 1  [Total Death Count],   location, continent 
from cte 
where dr = 5
end 


---GLOBAL NUMBERS 

--1
select date,  sum(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage  
from PortfolioProject..CovidDeaths 
--where Location  = 'India'
where continent is not null 
group by date 
order by 1, 2
 
--2 
select   sum(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage  
from PortfolioProject..CovidDeaths 
--where Location  = 'India'
where continent is not null 
--group by date 
order by 1, 2

select * from PortfolioProject..CovidVaccinations

use PortfolioProject

select * from PortfolioProject..CovidVaccination
select * from PortfolioProject..CovidDeaths 


---Looking at total population vs vaccinations --Running Total 

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) as RollingPeopleVaccinated 
--(sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) / CD.population)*100
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccination CV 
on CD.location = CV.location and CD.date = CV.date 
where CD.continent is not null  and CD.location = 'India'
order by 2,3

--using CTE
 
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
 select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) as RollingPeopleVaccinated 
--(sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) / CD.population)*100
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccination CV 
on CD.location = CV.location and CD.date = CV.date 
where CD.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated / population)*100
from PopVsVac

--or using temptable 

drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date  datetime ,
Population numeric,
new_vaccinations numeric, RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
 select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) as RollingPeopleVaccinated 
--(sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) / CD.population)*100
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccination CV 
on CD.location = CV.location and CD.date = CV.date 
--where CD.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated
  
 ---creating view to store data fopr later visualisation 
 
create view vwPercentPopulationVaccinated as 
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) as RollingPeopleVaccinated 
--(sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) / CD.population)*100
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccination CV 
on CD.location = CV.location and CD.date = CV.date 
where CD.continent is not null
--order by 2,3

select * from vwPercentPopulationVaccinated

create view vwPercentPopulationVaccinated1 as 
with PopVsVac 
as 
(
 select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) as RollingPeopleVaccinated 
--(sum(cast(CV.new_vaccinations as numeric)) over (partition by CD.location order by CD.location , CD.date ) / CD.population)*100
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccination CV 
on CD.location = CV.location and CD.date = CV.date 
where CD.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated / population)*100 as PercentPopVac
from PopVsVac

select * from vwPercentPopulationVaccinated1



