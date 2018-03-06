drop table song;

create table song (
	song_id integer auto_increment,
    created_date date not null,
    created_by varchar(100) not null,
    updated_date date,
    updated_by varchar(100),
    album_name varchar(256),
    song_name varchar(500),
    path varchar(500),
    filename varchar(500),
    play_count integer not null,
    primary key (song_id)
) 
CHARACTER SET utf8
COLLATE utf8_general_ci
    ;
    
    CREATE  INDEX album_name_ind ON song (album_name);
    
    CREATE  INDEX song_name_ind ON song (song_name);
    
    CREATE  INDEX path_ind ON song (path);
    
    CREATE  INDEX filename_ind ON song (filename);
    

select * from music.song;

select * from mymusic60.song;

select * from mymusic60.album;

-- New Music
insert into music.song (created_date, created_by, album_name, song_name, path, filename, play_count) 
select now(), 'TEMPUSER', a.strAlbum, s.strTitle, p.strPath, s.strFileName, 0
from mymusic60.song s, mymusic60.album a, mymusic60.path p
where s.idAlbum = a.idAlbum
and s.idPath = p.idPath
and concat(p.strPath, 'z|z', s.strFileName) not in 
	(select concat(ts.path, 'z|z', ts.filename)
    from music.song ts);
    
-- Deleted Music    

delete from music.song
where concat(Path, 'z|z', FileName) not in 
	( select
    concat(p.strPath, 'z|z', s.strFileName)
    from mymusic60.song s, mymusic60.album a, mymusic60.path p
where s.idAlbum = a.idAlbum
and s.idPath = p.idPath);

-- 20405
select count(*)
from mymusic60.song s, mymusic60.album a
where s.idAlbum = a.idAlbum
union all
select count(*)
from music.song;

insert into music.song (album_name, song_name) values ('s', 'd');

select concat('a', 'f', 'm') from mymusic60.song;


insert into song (created_date, created_by, album_name, song_name, play_count) 
select now(), 'TEMPUSER';

select count(*) from music.song;


delete from music.song where album_name = 'Believe';

commit;
