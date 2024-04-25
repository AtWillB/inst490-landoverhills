-- 1. Upload a dataset of all roads in Maryland to a PostgreSQL schema and call it "roads_md"
-- 2. Upload a dataset of all municipalities in Maryland to a PostgreSQL schema and call it 'md_municipalites'

-- 3. create a table that contains just the road segemtns of the Annapolis Rd that goes through Landover Hills called 'annapolis_rd'
 create table annapolis_rd as (SELECT roads_md.id,
    roads_md.linearid,
    roads_md.fullname,
    roads_md.rttyp,
    roads_md.mtfcc,
    roads_md.geom
   FROM roads_md
  WHERE roads_md.fullname::text = 'Annapolis Rd'::text AND (roads_md.id = ANY (ARRAY[5059, 1099, 3894, 1662, 1663, 5045, 5050])));
  

-- Create a table of all municiaplities that intersect with the line segments in 'annapolis_rd' called 'along_annapolis_rd'
 create table along_annapolis_rd as (SELECT mun.id,
    mun.statefp,
    mun.placefp,
    mun.placens,
    mun.geoid,
    mun.name,
    mun.namelsad,
    mun.geom
   FROM md_municipality mun
     JOIN annapolis_rd_view ann ON st_intersects(ann.geom, mun.geom));
	 

