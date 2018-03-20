-- New Music
insert into music.song (created_date, created_by, album_name, song_name, path, filename, play_count, kodi_idSong, active) 
select curdate(), user(), a.strAlbum, s.strTitle, p.strPath, s.strFileName, 0, s.idSong, 'Y'
from mymusic60.song s, mymusic60.album a, mymusic60.path p
where s.idAlbum = a.idAlbum
and s.idPath = p.idPath
and s.idSong not in 
	(select ts.kodi_idSong
    from music.song ts);
    
-- Deleted Music    
update music.song s set active = 'N', updated_date = curdate(), updated_by = user()
where s.kodi_idSong not in 
	( select
    s.idSong
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

