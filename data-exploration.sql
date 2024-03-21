

select location,date, total_cases ,new_cases ,total_deaths ,population 
from data_exploration.coviddeaths c ;



-- looking at total cases vs total deaths
-- shows likelihood of dying i f tou contract coivd in your country

select location,date, total_cases ,total_deaths , 
( 1.0*total_deaths /total_cases )*100 as deathpercentage
from data_exploration.coviddeaths c 
where location like 'India'
order by 1,2;




-- looking at total cases vs population
-- shows what percentage of population got covid

select location,date, total_cases ,population, 
( 1.0*total_cases /population )*100 as percentpopulationinfected
from data_exploration.coviddeaths c 
where location like 'India'
order by 3 desc;


-- looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount , 
max(( 1.0*total_cases /population )*100) as percentpopulationinfected
from data_exploration.coviddeaths c 
--where location like 'India'
group by location ,population
order by 1,2;



-- showing countries with highest death count

select location,
max(total_deaths) totaldeathcount
from data_exploration.coviddeaths c 
where continent like '%_%' and continent is not null
group by 1
order by totaldeathcount desc nulls last;



-- lets break things down by continent 
-- showing continents with highest death count

select location,
max(total_deaths) totaldeathcount
from data_exploration.coviddeaths c 
--where continent like '%_%' and continent is null
where trim(continent) = '' 
group by 1
order by totaldeathcount desc nulls last;



-- global numbers

select  sum(new_cases) as total_deaths,sum(new_deaths::int) as total_deaths,(sum(new_deaths::int)/sum(new_cases))*100 from data_exploration.coviddeaths c 
where trim(continent) <> ''
--group by "date" 
order by 1,2



-- looking at total population vs vaccination
-- in this when i import that its datatype is varchar and i want to sum this then i cast this as a int
--then i get error because of this column have some blank rows that why i use case to handle this when the blank <> ''  then sum else 0 
--and i put this into sum function


with cte as(
select cd.continent ,cd."location" ,cd."date",cd.population ,cv.new_vaccinations ,
sum(case when trim(cv.new_vaccinations) <> '' then cv.new_vaccinations::int 
else 0 end ) over(partition by cd."location" order by cd."location",cd."date") as RollingPeopleVaccinated
from data_exploration.covidvaccinations cv 
join data_exploration.coviddeaths cd on cd."location" = cv."location" 
and cd."date" = cv."date" 
where trim(cd.continent) <> ''
order by 2,3)
select continent,location,date,
		population , new_vaccinations,
		RollingPeopleVaccinated,
		(1.0*RollingPeopleVaccinated/population)*100 
from cte;


--another method to do this is 
--temp table

drop table if exists vaccine;
create temp table vaccine(
continent varchar(50),
location varchar(50),
date date,
population int8,
new_vaccinations varchar(50),
RollingPeopleVaccinated varchar(50)
);

insert into vaccine(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
select cd.continent ,cd."location" ,cd."date",cd.population ,cv.new_vaccinations ,
		sum(case when trim(cv.new_vaccinations) <> '' then cv.new_vaccinations::int 
			else 0 end ) over(partition by cd."location" order by cd."location",cd."date") as RollingPeopleVaccinated
	from data_exploration.covidvaccinations cv 
	join data_exploration.coviddeaths cd on cd."location" = cv."location" 
	and cd."date" = cv."date" 
	where trim(cd.continent) <> ''
	order by 2,3;

select *,(1.0*RollingPeopleVaccinated::int/population)*100 as VaccinatedPeoplePercentage
from vaccine;
