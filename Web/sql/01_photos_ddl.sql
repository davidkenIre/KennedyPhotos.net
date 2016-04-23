-- Setup the Photos database

drop table photo;

drop table album;

create table album (
	album_id           	int not null primary key auto_increment,
    created_date		date not null, 
    created_by			varchar(100) not null,
    updated_date		date,
    updated_by			varchar(100),
	album_name			varchar(500) not null,
    album_date			date,
    description			varchar(32000),
	location  			varchar(1000) not null,
    active              varchar(1) default 'Y'
);

create table photo (
	photo_id 			int not null primary key auto_increment,
    created_date		date not null, 
    created_by			varchar(100) not null,
    updated_date		date,
    updated_by			varchar(100),    
    album_id			int not null references album(album_id),
	filename 			varchar(1000) not null,
    thumbnail_filename  varchar(1000) not null,
    active              varchar(1) default 'Y'
);


select count(*) from photo where active = 'Y';