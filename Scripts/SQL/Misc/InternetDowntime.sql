SELECT * FROM misc.internet_uptime;

DROP TABLE misc.internet_uptime;


drop table misc.internet_downtime;

CREATE TABLE misc.internet_downtime (
     internet_downtime_id MEDIUMINT NOT NULL AUTO_INCREMENT,
     start_date datetime NOT NULL,
     end_date datetime,
     PRIMARY KEY (internet_downtime_id)
);

SELECT * FROM misc.internet_downtime;



insert into misc.internet_downtime (start_date, end_date) values (now(), now());


	select case when end_date is null then "Down" else "Up" end as status from misc.internet_downtime a
	where a.internet_downtime_id = (select max(internet_downtime_id) from misc.internet_downtime b);
    
    
    
    update misc.internet_downtime set end_date = null;
    
    
    drop view misc.internet_downtime_v;
    
    create or replace view misc.internet_downtime_v as
    select d.*, TIMEDIFF(ifnull(end_date,now()), start_date) as duration from misc.internet_downtime d;
    
    select * from misc.internet_downtime_v;
    
    
    select ifnull(end_date,now()) from misc.internet_downtime;
    
SELECT * FROM misc.internet_downtime_v order by internet_downtime_id desc;    