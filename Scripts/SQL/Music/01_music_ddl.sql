drop table playlist_song;

drop table playlist;

drop table song;

create table song (
	song_id integer auto_increment,
    created_date date not null,
    created_by_id varchar(128) not null,
    updated_date date,
    updated_by_id varchar(128),
    album_name varchar(256),
    song_name varchar(500),
    path varchar(500),
    filename varchar(500),
    play_count integer not null,
    kodi_idSong integer not null,
    active varchar(1) not null,
    primary key (song_id)
)
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE UNIQUE index kodi_idsong_ind on song(kodi_idSong); 

create table playlist (
	playlist_id integer auto_increment,
    created_date date not null,
    created_by_id varchar(128) not null,
    updated_date date,
    updated_by_id varchar(128),
    owner_id varchar(128) not null,
    playlist_name varchar(500),
    active varchar(1) not null,
    primary key (playlist_id)
); 

CREATE UNIQUE index playlist_name_ind on playlist(playlist_name); 

create table playlist_song (
	playlist_song_id integer auto_increment,
    created_date date not null,
    created_by_id varchar(128) not null,
    updated_date date,
    updated_by_id varchar(128),
    playlist_id integer,
    song_id integer,
    active varchar(1) not null,
    primary key (playlist_song_id)
);
