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



insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1319, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1318, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (8010, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (8027, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (7999, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (8013, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (7995, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (7990, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (5290, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4771, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2529, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2235, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (671, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (540, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17899, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17877, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17886, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17889, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17876, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1106, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1085, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1102, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (18622, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (18623, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2365, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (778, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1949, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (9947, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (7847, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (7848, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2971, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4800, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (928, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (875, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (878, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1530, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2138, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (20153, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (3445, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (3452, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (20132, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (3455, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (3468, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (3472, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4030, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (20258, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4824, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2630, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (12449, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (728, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (738, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2642, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2060, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1897, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4340, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (3247, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4659, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2598, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14305, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14368, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14358, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14347, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14440, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14616, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14728, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (14863, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15016, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15018, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15144, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15162, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15419, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15457, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15511, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15699, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15754, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15766, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15819, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15834, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15851, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15855, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15859, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (15910, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16415, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (16647, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (20276, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1286, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1281, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1288, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17264, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4121, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (19688, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (20261, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (107, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (133, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (145, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17594, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17580, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17620, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17673, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17660, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4982, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4981, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17908, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17935, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17973, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17990, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17968, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (17976, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (18024, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4405, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4411, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4409, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4408, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1667, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2404, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4676, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1646, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1649, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2735, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2729, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (5009, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (5011, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (452, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1974, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1977, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1973, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1982, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (1972, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4563, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (4561, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2748, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2322, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2333, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (2324, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');
insert into music.playlist_song (song_id, created_date, created_by_id, playlist_id, active) values (220, curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', (select playlist_id from playlist where playlist_name = 'General'), 'Y');



select * from music.playlist;


update music.playlist set owner_id = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3';

select playlist_id, playlist_name, DATE_FORMAT(GREATEST(p.CREATED_DATE, ifnull(p.UPDATED_DATE, p.CREATED_DATE)), '%d-%M-%Y') as dte_posted, u.username 
from music.playlist p, photos.aspnetusers u where p.active='Y' and u.id = p.owner_id order by playlist_name