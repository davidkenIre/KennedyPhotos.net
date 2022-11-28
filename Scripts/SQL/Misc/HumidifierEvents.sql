-- drop table misc.humidifier_events;

CREATE TABLE misc.humidifier_events (
     humidifier_events_id MEDIUMINT NOT NULL AUTO_INCREMENT,
     start_date datetime NOT NULL,
     end_date datetime,
     PRIMARY KEY (humidifier_events_id)
);

SELECT * FROM misc.humidifier_events;
    
    
-- drop view misc.humidifier_events_v;

create or replace view misc.humidifier_events_v as
select d.*, TIMEDIFF(ifnull(end_date,now()), start_date) as duration from misc.humidifier_events d;

create or replace view misc.average_humidity_v as
select hn.day 'Day', hl.average_humidity 'Limerick', hn.average_humidity 'Noel Bedroom', hs.average_humidity 'Study' ,
hn.average_humidity - hs.average_humidity 'Noel Bedroom Study Diff'
from misc.average_humidity_noelbedroom_v hn, average_humidity_study_v hs, average_humidity_limerick_v hl
where hl.day = hn.day
and hl.day = hs.day
order by day desc;

select * from misc.average_humidity_v;

create or replace view misc.average_humidity_noelbedroom_v as
SELECT DATE(point_date)  'day',
AVG(point_data)  'average_humidity'
FROM misc.environment_data
where location = 'Noel Bedroom'
and point_data_type = 'Humidity'
GROUP BY DATE(point_date)
order by 2 desc;

create or replace view misc.average_humidity_limerick_v as
SELECT DATE(point_date)  'day',
AVG(point_data)  'average_humidity'
FROM misc.environment_data
where location in ('Limerick', 'Ardnacrusha')
and point_data_type = 'Humidity'
GROUP BY DATE(point_date)
order by 2 desc;

select * from  misc.average_humidity_limerick_v;

select * from misc.environment_data;

create or replace view misc.average_humidity_study_v as
SELECT DATE(point_date)  'day',
AVG(point_data)  'average_humidity'
FROM misc.environment_data
where location = 'Study'
and point_data_type = 'Humidity'
GROUP BY DATE(point_date)
order by 2 desc;





select * from misc.humidifier_events_v;

    
SELECT * FROM misc.humidifier_events_v order by humidifier_events_id desc;    

insert into misc.humidifier_events (start_date, end_date) values (now()-20000, NULL);

update misc.humidifier_events set end_date= null;