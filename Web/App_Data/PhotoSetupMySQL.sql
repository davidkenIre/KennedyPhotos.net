drop table photo;

create table photo (
photo_id int not null primary key  AUTO_INCREMENT,
filename varchar(1000) not null,
location varchar(1000) not null,
albumname varchar(1000) not null
);

delete from photo;
insert into photo (filename, location, albumname) values ('IMG_4039.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4040.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4041.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4042.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4043.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4044.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4045.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4046.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4047.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4048.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
insert into photo (filename, location, albumname) values ('IMG_4049.JPG', '/Albums/Aran Islands 2014/', 'Aran Islands 2014');
commit;

select * from photo;



