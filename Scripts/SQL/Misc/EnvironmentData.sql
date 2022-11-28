drop table  misc.environment_data;

CREATE TABLE misc.environment_data (
     environment_data_id MEDIUMINT NOT NULL AUTO_INCREMENT,
     point_date datetime NOT NULL,
     location varchar(100) NOT NULL,
     point_data_type varchar(100) NOT NULL,
     point_data decimal(7,4) NOT NULL,
     PRIMARY KEY (environment_data_id)
);

select * from misc.environment_data where location = 'Noel Bedroom'
order by environment_data_id desc;