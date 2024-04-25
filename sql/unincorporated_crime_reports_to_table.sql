-- -- create a table called called 'crime_reports' from the PG county crime reports dataset
-- -- add geom column based on location columns

ALTER TABLE crime_reports ADD COLUMN geom geometry(Point, 4326);
UPDATE crime_reports SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

-- now grab only those points that touch any of our 12 municipaliteis of interest. 
-- Create a new table of all crime in 12 municipaliteis called 'crime_reports_along_annapolis'

create table crime_reports_along_annapolis as (
with crime_reports_along_annapolis as (select cr.*
	from crime_reports as cr
	join along_annapolis_rd as aar
	on st_intersects(cr.geom, aar.geom))
	
select craa.*, Extract('Year' from craa.date) as Year,  aar.namelsad
	from crime_reports_along_annapolis as craa
	join along_annapolis_rd as aar
	on st_intersects(craa.geom, aar.geom));

-- now idenfiy all unique types of crime and group by them for each municipality per year

select DISTINCT clearance_code_inc_type
	from crime_reports_along_annapolis;

create table crime_per_year as (with grouped as (select namelsad as jurisdiction, year, clearance_code_inc_type, count(clearance_code_inc_type) as count
	from crime_reports_along_annapolis
	group by jurisdiction, year, clearance_code_inc_type
	order by year)
	



select jurisdiction, year, 
  max(case when clearance_code_inc_type = 'VANDALISM' then count else null end) as vandalism, 
  max(case when clearance_code_inc_type = 'AUTO, STOLEN' then count else null end) as stolen_auto, 
  max(case when clearance_code_inc_type = 'AUTO, STOLEN & RECOVERED' then count else null end) as stolen_recovered_auto,
  max(case when clearance_code_inc_type = 'THEFT' then count else null end) as theft, 
  max(case when clearance_code_inc_type = 'ROBBERY, VEHICLE' then count else null end) as robbery_vehicle,
  max(case when clearance_code_inc_type = 'HOMICIDE' then count else null end) as homicide,
  max(case when clearance_code_inc_type = 'ASSAULT, WEAPON' then count else null end) as assault_weapon,
  max(case when clearance_code_inc_type = 'ROBBERY, OTHER' then count else null end) as robbery_other,
  max(case when clearance_code_inc_type = 'ROBBERY, RESIDENTIAL' then count else null end) as robbery_residential,
  max(case when clearance_code_inc_type = 'ASSAULT' then count else null end) as assualt,
  max(case when clearance_code_inc_type = 'B & E, RESIDENTIAL (VACANT)' then count else null end) as b_e_residential_vacant,
  max(case when clearance_code_inc_type = 'ASSAULT, SHOOTING' then count else null end) as assault_shooting,
  max(case when clearance_code_inc_type = 'ACCIDENT WITH IMPOUND' then count else null end) as accident_with_impound,
  max(case when clearance_code_inc_type = 'B & E, SCHOOL' then count else null end) as b_e_school,
  max(case when clearance_code_inc_type = 'B & E, COMMERCIAL' then count else null end) as b_e_commercial,
  max(case when clearance_code_inc_type = 'B & E, VACANT' then count else null end) as b_e_vacant,
  max(case when clearance_code_inc_type = 'SEX OFFENSE' then count else null end) as sex_offense,
  max(case when clearance_code_inc_type = 'ROBBERY, COMMERCIAL' then count else null end) as robbery_commercial,
  max(case when clearance_code_inc_type = 'B & E, RESIDENTIAL' then count else null end) as b_e_residential,
  max(case when clearance_code_inc_type = 'ACCIDENT' then count else null end) as accident,
  max(case when clearance_code_inc_type = 'THEFT FROM AUTO' then count else null end) as theft_from_auto,
  max(case when clearance_code_inc_type = 'B & E, OTHER' then count else null end) as b_e_other
from grouped
group by jurisdiction, year
order by jurisdiction, year)

-- From here, the addition of population data for each jurisdiction per year, 
-- combining columns to have matching names to the state of Maryland table, 
-- and the adding the unincorporated label was done by hand in excel. 

