-- Sample data to setup the photos schema

delete from photo;

delete from album;

insert into album (album_name, location, album_date, description) values ('Aran Islands 2014', '/Albums/Aran Islands 2014/', sysdate(), 'Sample Description');
insert into album (album_name, location) values ('Croatia 2014', '/Albums/Croatia 2014/');
insert into album (album_name, location) values ('Cuba 2013', '/Albums/Cuba 2013/');
insert into album (album_name, location) values ('Edinburgh 2014', '/Albums/Edinburgh 2014/');
insert into album (album_name, location) values ('France 2007', '/Albums/France 2007/');

insert into album (album_name, location) values ('Test 2016', '/Albums/Test 2016/');


insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, 'IMG_4040.JPG', 'e6795fa1-131c-45e0-b52d-3e0bf5d639a3.png' from album where album_name='Aran Islands 2014';

insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, 'IMG_4041.JPG', 'e6795fa1-131c-45e0-b52d-3e0bf5d639a3.png' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, 'IMG_4042.JPG', 'e6795fa1-131c-45e0-b52d-3e0bf5d639a3.png' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, 'IMG_4043.JPG', 'e6795fa1-131c-45e0-b52d-3e0bf5d639a3.png' from album where album_name='Aran Islands 2014';
insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, 'IMG_4045.JPG', 'e6795fa1-131c-45e0-b52d-3e0bf5d639a3.png' from album where album_name='Aran Islands 2014';

insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, 'fff', 'e6795fa1-131c-45e0-b52d-3e0bf5d639a3.png' from album where album_name='Aran Islands 2014';

commit;

select * from album;

select * from photo;

            select p.photo_id from album a, photo p 
             where a.album_id = p.album_id 
             and replace(lower(concat(a.location, p.filename)), '/albums/', '') = '.ds_store';

select * from album order by created_date limit 4;