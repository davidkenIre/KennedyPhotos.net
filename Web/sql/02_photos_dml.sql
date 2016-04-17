-- Sample data to setup the photos schema

delete from photo;
delete from album;

insert into album (album_name, location) values ('Aran Islands 2014', '/Albums/Aran Islands 2014/');
insert into album (album_name, location) values ('Croatia 2014', '/Albums/Croatia 2014/');
insert into album (album_name, location) values ('Cuba 2013', '/Albums/Cuba 2013/');
insert into album (album_name, location) values ('Edinburgh 2014', '/Albums/Edinburgh 2014/');
insert into album (album_name, location) values ('France 2007', '/Albums/France 2007/');

insert into photo (album_id, filename) select distinct album_id, 'IMG_4040.JPG' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename) select distinct album_id, 'IMG_4041.JPG' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename) select distinct album_id, 'IMG_4042.JPG' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename) select distinct album_id, 'IMG_4043.JPG' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename) select distinct album_id, 'IMG_4045.JPG' from album where album_name='Aran Islands 2014';


commit;

select * from photo;

select * from album;