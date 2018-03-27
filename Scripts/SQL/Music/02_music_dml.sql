-- New Music
insert into music.song (created_date, created_by_id, album_name, song_name, path, filename, play_count, kodi_idSong, active) 
select curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', a.strAlbum, s.strTitle, p.strPath, s.strFileName, 0, s.idSong, 'Y'
from mymusic60.song s, mymusic60.album a, mymusic60.path p
where s.idAlbum = a.idAlbum
and s.idPath = p.idPath
and s.idSong not in 
	(select ts.kodi_idSong
    from music.song ts);
    
-- Deleted Music    
update music.song s set active = 'N', updated_date = curdate(), updated_by_id = 1
where s.kodi_idSong not in 
	( select
    s.idSong
    from mymusic60.song s, mymusic60.album a, mymusic60.path p
where s.idAlbum = a.idAlbum
and s.idPath = p.idPath);

-- Create Playlist
insert into music.playlist (created_date, created_by_id, playlist_name, owner_id, active)
values
(curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', 'DKEN Playlist', 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', 'Y'); 

-- Reset Playlist
delete from music.playlist_song;
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16891, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16873, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16885, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16886, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16909, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16942, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16967, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16970, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'DKEN Playlist'), 'Y');


select * from music.playlist;

select playlist_id, playlist_name, DATE_FORMAT(GREATEST(p.CREATED_DATE, ifnull(p.UPDATED_DATE, p.CREATED_DATE)), '%d-%M-%Y') as dte_posted, u.username 
from music.playlist p, photos.aspnetusers u where p.active='Y' and u.id = p.owner_id order by playlist_name