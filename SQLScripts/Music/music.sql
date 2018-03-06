drop table song;

create table song (
	song_id integer auto_increment,
    created_date date not null,
    created_by varchar(100) not null,
    updated_date date,
    updated_by varchar(100),
    album_name varchar(256),
    song_name varchar(500),
    play_count integer not null,
    primary key (song_id)
) 
CHARACTER SET utf8
COLLATE utf8_general_ci
    ;
    
    CREATE  INDEX album_name_ind ON song (album_name);
    
    CREATE  INDEX song_name_ind ON song (song_name);
    
    

select * from mymusic60.song;

select * from mymusic60.album;

insert into music.song (created_date, created_by, album_name, song_name, play_count) 
select now(), 'TEMPUSER', a.strAlbum, s.strTitle, 0
;


select count(*)
from mymusic60.song s, mymusic60.album a
where s.idAlbum = a.idAlbum
and concat(a.strAlbum, 'z|z', s.strTitle) not in 
	(select concat(a.strAlbum, 'z|z', s.strTitle)
    from music.song);



insert into music.song (album_name, song_name) values ('s', 'd');

select concat('a', 'f', 'm') from mymusic60.song;


insert into song (created_date, created_by, album_name, song_name, play_count) 
select now(), 'TEMPUSER';

select count(*) from music.song;


delete from music.song where album_name = 'Believe';

commit;
