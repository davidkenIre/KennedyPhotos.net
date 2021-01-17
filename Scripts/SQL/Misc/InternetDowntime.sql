drop table misc.internet_downtime;

CREATE TABLE misc.internet_downtime (
     internet_downtime_id MEDIUMINT NOT NULL AUTO_INCREMENT,
     start_date datetime NOT NULL,
     end_date datetime,
     PRIMARY KEY (internet_downtime_id)
);

SELECT * FROM misc.internet_downtime;
    
    
drop view misc.internet_downtime_v;

create or replace view misc.internet_downtime_v as
select d.*, TIMEDIFF(ifnull(end_date,now()), start_date) as duration from misc.internet_downtime d;

select * from misc.internet_downtime_v;

    
SELECT * FROM misc.internet_downtime_v order by internet_downtime_id desc;    