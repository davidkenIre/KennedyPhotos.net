-- New Music
insert into music.song (created_date, created_by, album_name, song_name, path, filename, play_count, active) 
select curdate(), user(), a.strAlbum, s.strTitle, p.strPath, s.strFileName, 0, 'Y'
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

-- Create Playlist
insert into music.playlist (created_date, created_by, playlist_name, active)
values
(curdate(), user(), 'DKEN Playlist', 'Y'); 

-- Reset Playlist
delete from music.playlist_song;
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16891, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16873, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16885, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16886, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16909, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16942, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16967, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by, playlist_id, active) values (16970, curdate(), user(), (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
