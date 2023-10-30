SELECT dth.location,dth.date,dth.new_cases,vac.new_vaccinations
FROM [COVID deaths 2020-21] dth
JOIN [COVID vaccinations 2020-21] vac 
	ON dth.location = vac.location
	AND dth.date = vac.date
ORDER BY location

-- look at total vaccinations by population

SELECT dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
FROM [COVID deaths 2020-21] dth
JOIN [COVID vaccinations 2020-21] vac 
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null
ORDER BY dth.date

--- Rolling count of vaccinations

SELECT dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
--,	sum(cast(vac.new_vaccinations as bigint)) OVER(PARTITION by dth.Location  ORDER by dth.Location, dth.date) as RollingPeopleVacs

FROM [COVID deaths 2020-21] dth
JOIN [COVID vaccinations 2020-21] vac 
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null and vac.new_vaccinations is not NULL
ORDER BY 2,3

--- use CTE

WITH PopVsVac (continent,location,date,population,New_Vaccinations,RollingPeopleVacs)
AS
(
SELECT dth.continent,dth.location,dth.date,cast(dth.population as bigint),vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as bigint)) OVER(PARTITION by dth.Location  ORDER by dth.Location, dth.date) as RollingPeopleVacs
FROM [COVID deaths 2020-21] dth
JOIN [COVID vaccinations 2020-21] vac 
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null and vac.new_vaccinations is not NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVacs/population) *100 as RollingVaxRate
FROM PopVsVac

--- Using Temp Table

DROP TABLE if exists #PercentPopulationVac
CREATE TABLE #PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVacs numeric
)

INSERT INTO #PercentPopulationVac
SELECT dth.continent,dth.location,dth.date,cast(dth.population as bigint),vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as bigint)) OVER(PARTITION by dth.Location  ORDER by dth.Location, dth.date) as RollingPeopleVacs
FROM [COVID deaths 2020-21] dth
JOIN [COVID vaccinations 2020-21] vac 
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null and vac.new_vaccinations is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVacs/population) *100 as RollingVaxRate
FROM #PercentPopulationVac

-- Creating View to store data for later visualizations

CREATE VIEW RollingVaxRate AS
WITH PopVsVac (continent,location,date,population,New_Vaccinations,RollingPeopleVacs)
AS
(
SELECT dth.continent,dth.location,dth.date,cast(dth.population as bigint),vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as bigint)) OVER(PARTITION by dth.Location  ORDER by dth.Location, dth.date) as RollingPeopleVacs
FROM [COVID deaths 2020-21] dth
JOIN [COVID vaccinations 2020-21] vac 
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null -- and vac.new_vaccinations is not NULL
)

SELECT *, (RollingPeopleVacs/population) *100 as RollingVaxRate
FROM PopVsVac

SELECT *
FROM RollingVaxRate
WHERE New_Vaccinations is not NULL