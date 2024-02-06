use portfolio_project;
select * from covid_deaths;
select * from covid_vaccinations;

select * from covid_deaths
order by 3,4;

select * from covid_vaccinations
order by 3,4;

select * from covid_deaths
where continent like "asia";

select * from covid_deaths
where location like "india";

select continent, count(continent) from covid_deaths
group by continent;

select location, count(location) from covid_deaths
group by location;

select continent, count(continent) as total_no_of_rows from covid_deaths
group by continent
order by total_no_of_rows desc
limit 1;

select location, count(location) as total_no_of_rows from covid_deaths
group by location
order by total_no_of_rows desc
limit 1;

select location, date, total_cases, new_cases, total_deaths, population from covid_deaths
order by 1,2;

#total cases and total deaths
select location, date, total_cases, total_deaths from covid_deaths
order by 1,2;

#death percentage in india
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage from covid_deaths
where location like "%india%"
order by 1,2;

#total cases and total population
select location, date, total_cases, population, (total_cases/population)*100 as case_percentage from covid_deaths
where location like "%india%"
order by 1,2;

#countries with highest infection rate compared to population
select location, population, max(total_cases) as total_infected, round((max(total_cases)/population)*100,2) as population_infected_percentage 
from covid_deaths
group by location, population
order by population_infected_percentage desc;

#countries with highest death rate compared to population
select location, population, max(total_deaths) as total_deaths, round((max(total_deaths)/population)*100,2) as population_death_percentage 
from covid_deaths
group by location, population
order by population_death_percentage desc;

#countries and total deaths
select location, max(total_deaths) as total_deaths from covid_deaths
where location is not null
group by location
order by max(total_deaths) desc;

#continents and total deaths
select continent, max(total_deaths) as total_deaths from covid_deaths
where continent is not null
group by continent
order by max(total_deaths) desc;

#continent with highest deaths rate
select continent, population, max(total_deaths) as total_deaths, round((max(total_deaths)/population)*100,2) as population_death_percentage 
from covid_deaths
group by continent, population
order by population_death_percentage;   

#global cases and deaths
select date , sum(total_cases) as total_cases, sum(total_deaths) as total_deaths, round(sum(total_deaths)/sum(total_cases)*100,2) as death_percentage 
from covid_deaths
where continent is not null
group by date
order by death_percentage;

#total population ands total vacccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(new_vaccinations) over (partition by d.continent order by d.continent) as total_vaccination
from covid_deaths as d 
join covid_vaccinations as v 
on d.continent = v.continent and
d.date = v.date
where d.continent is not null
order by d.continent;

select d.location, d.date, d.population, 
v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location) as total_vaccination
from covid_deaths as d 
join covid_vaccinations as v 
on d.location = v.location and
d.date = v.date
order by d.location;

with Population_vs_Vaccination (continent, location, date, population, new_vaccinations, total_vaccination)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(new_vaccinations) over (partition by d.location order by d.location) as total_vaccination
from covid_deaths as d 
join covid_vaccinations as v 
on d.location = v.location and
d.date = v.date
where d.continent is not null
)
select *, round((total_vaccination/population)*100,2) as vaccinated_percentage from Population_vs_Vaccination;

drop table if exists Population_Vaccinated_percentage;
create table Population_Vaccinated_percentage
(
Continent varchar(255),
Location varchar(255),
Date varchar(255),
Population numeric,
New_vaccinations varchar(255),
Total_vaccinated numeric
);
Insert into Population_Vaccinated_percentage
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.date) as total_vaccination
from covid_deaths as d 
join covid_vaccinations as v 
on d.location = v.location and
d.date = v.date;
select *, round((Total_vaccinated/population)*100,2) as vaccinated_percentage from Population_Vaccinated_percentage;

#view for global cases and deaths
Create view Population_Vaccinated_per as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(new_vaccinations) over (partition by d.continent order by d.continent) as total_vaccination
from covid_deaths as d 
join covid_vaccinations as v 
on d.continent = v.continent and
d.date = v.date
where d.continent is not null
order by d.continent;
select * from Population_Vaccinated_per;