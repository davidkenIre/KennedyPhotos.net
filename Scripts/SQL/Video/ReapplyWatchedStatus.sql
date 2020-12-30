

-- Create a backup table
create table photos.dkenfiles as select * from myvideos116.files;

-- Check for duplicates
select strFilename, count(*) from photos.dkenfiles a
where a.strFilename not in ('VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
and a.strFilename is not null
group by strFilename
order by 2 desc;

-- Drop the schema
drop schema myvideos116;

-- Reboot Kodi

-- For TV and Movies, go into files and set content to tv or movies

-- Allow to load content from internet

-- Reapply from backup
update myvideos116.files a 
set a.playCount = (select b.playCount from photos.dkenfiles b where a.strFilename = b.strFilename and b.strFilename is not null 
and b.strFilename not in ('', 'VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
and a.strFilename not in ('', 'VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
);

update myvideos116.files a 
set a.lastPlayed = (select b.lastPlayed from photos.dkenfiles b where a.strFilename = b.strFilename and b.strFilename is not null 
and b.strFilename not in ('', 'VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
and a.strFilename not in ('', 'VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
);

update myvideos116.files a 
set a.dateAdded = (select b.dateAdded from photos.dkenfiles b where a.strFilename = b.strFilename and b.strFilename is not null 
and b.strFilename not in ('', 'VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
and a.strFilename not in ('', 'VIDEO_TS.IFO', '7.1Ch DTS-HD MA - Speaker Mapping Test File.mkv', 'Renovation of Yard Day 3.MOV', 'Ellie Playing.MOV', 'Star.Trek.Beyond.2016.1080p.3D.BluRay.Half-OU.x264.DTS-JYK.mkv', 'master.m3u8|Referer=http%3A%2F%2Fvidlox.tv%2Fembed-wai9h0ae4ns3.html&User-Agent=Mozilla%2F5.0+%28Windows+NT+6.1%3B+WOW64%3B+Trident%2F7.0%3B+AS%3B+rv%3A11.0%29+like+Gecko')
);

-- Drop old temp table;
drop table photos.dkenfiles;

commit;


select * from photos.dkenfiles;