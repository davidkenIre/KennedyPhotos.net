
create table misc.tvdb_link (
created_date date,
created_by varchar(100) ,
name varchar(255),
pattern varchar(255),
path varchar(255),
seriesid varchar(255)
);

insert into tvdb_link (
curdate(), 
'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', 
'',
'',
'',
'');


insert into misc.tvdb_link values (
curdate(), 
'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', 
'Yellowstone',
'yellowstone',
'd:\\Media\\Video\\TV\\Yellowstone',
'341164');

insert into misc.tvdb_link values (
curdate(), 
'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', 
'The Walking Dead',
'the.walking.dead',
'd:\\Media\\Video\\TV\\The Walking Dead',
'153021');

Name,Pattern,Path,SeriesID
Wheeler Dealers,*Wheeler.Dealers*,d:\Media\Video\TV\Wheeler Dealers,81320;

select name, pattern, path, seriesid from misc.tvdb_link where pattern like '%the.expanse%';


select * from misc.tvdb_link;

select name, pattern, path, seriesid from misc.tvdb_link where instr('the.expanse.s05e04.720p.web.h264-glhf.mkv', pattern) > 0;

delete from misc.tvdb_link where seriesid = 81320;