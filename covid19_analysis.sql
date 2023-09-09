-- Covid 19 Data exploration
 -- Selecting data with concrete location

SELECT *
FROM public.covid_deaths
WHERE location = 'Russia'
LIMIT 100;

-- total cases vs total deaths: death percentage in Russia

SELECT location, date, total_cases,
	total_deaths,
	(cast(total_deaths AS numeric) / total_cases) * 100 AS death_percentage
FROM public.covid_deaths
WHERE location = 'Russia'
ORDER BY date DESC
LIMIT 100;

-- percentage of population infected with covid in specific date range

SELECT location, date, population,
	total_cases,
	(cast(total_cases AS numeric) / population) * 100 AS infected_percent
FROM public.covid_deaths
WHERE location = 'Russia'
	AND '2022-01-01' <= date
	AND date <= '2022-06-01'
ORDER BY date DESC
LIMIT 100;

SELECT location,
	population,
	max(total_cases) AS infection_count,
	max(cast(total_cases AS numeric) / population) * 100 AS infected_percent
FROM public.covid_deaths
GROUP BY location,
	population
ORDER BY infected_percent DESC NULLS LAST
LIMIT 200;

-- contintents with the highest death count

SELECT continent,
	max(cast(total_deaths AS integer)) AS total_death_count
FROM public.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- contintents with the highest mortality risk of covid 19

SELECT continent,
	(cast(max(total_deaths) AS numeric) / max(total_cases)) * 100 AS death_percent
FROM public.covid_deaths
WHERE continent IS NOT NULL
	AND total_cases IS NOT NULL
	AND total_deaths IS NOT NULL
GROUP BY continent
ORDER BY death_percent DESC;

-- Population vs Vaccinations
-- Shows number of population that has recieved at least one covid vaccine in Russia

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS rolling_people_vaccinated																																											
FROM public.covid_deaths dea
JOIN public.covid_vaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location = 'Russia'
ORDER BY dea.date DESC;

