drop table playlist_song;

drop table playlist;

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
    active varchar(1) not null,
    primary key (song_id),
    fulltext (album_name),
    fulltext (song_name),
    fulltext (path),
    fulltext (filename)
)
CHARACTER SET utf8
COLLATE utf8_general_ci
ENGINE=MyISAM;

create table playlist (
	playlist_id integer auto_increment,
    created_date date not null,
    created_by varchar(100) not null,
    updated_date date,
    updated_by varchar(100),
    playlist_name varchar(500),
    active varchar(1) not null,
    primary key (playlist_id)
); 

create table playlist_song (
	playlist_song_id integer auto_increment,
    created_date date not null,
    created_by varchar(100) not null,
    updated_date date,
    updated_by varchar(100),
    playlist_id integer,
    song_id integer,
    active varchar(1) not null,
    primary key (playlist_song_id)
);
