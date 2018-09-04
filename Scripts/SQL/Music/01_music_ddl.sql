drop table playlist_song;

drop table playlist;

drop table song;

drop table album;

create table album (
	album_id integer auto_increment,
    created_date date not null,
    created_by_id varchar(128) not null,
    updated_date date,
    updated_by_id varchar(128),
	album_name varchar(256) not null,
    active varchar(1) not null,
    primary key (album_id)
); 

create table song (
	song_id integer auto_increment,
    created_date date not null,
    created_by_id varchar(128) not null,
    updated_date date,
    updated_by_id varchar(128),
    album_id integer not null,
    song_name varchar(500) not null,
    path varchar(500) not null,
    filename varchar(500) not null,
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
    owner_idalbum varchar(128) not null,
    playlist_name varchar(500) not null,
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
    playlist_id integer not null,
    song_id integer not null,
    active varchar(1) not null
    primary key (playlist_song_id)
);

CREATE UNIQUE index kodi_idsong_playlist_ind on playlist_song(song_id, playlist_id); 

create table setting (
	setting_id integer auto_increment,
    created_date date not null,
    created_by_id varchar(128) not null,
    updated_date date,
    updated_by_id varchar(128),
    setting varchar(128) NOT NULL,
    value varchar(128),    
    primary key (setting_id)
);

CREATE UNIQUE index setting_ind on setting(setting_id); 