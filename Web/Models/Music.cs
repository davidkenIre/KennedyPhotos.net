using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Music.Models
{

    /// <summary>
    /// This class represents a Album
    /// </summary>
    public class Album
    {
        public string Id { get; set; }
        public string AlbumName { get; set; }
    }


    /// <summary>
    /// This class represents a Song
    /// </summary>
    public class Song
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Album { get; set; }
        public string Location { get; set; }
        public string PlaylistSongID { get; set; }
    }

    public class AlbumSong
    {
        public List<Song> Song { set; get; }
        public List<Album> Album { set; get; }
    }

    /// <summary>
    /// This class represents a Playlist
    /// </summary>
    public class Playlist
    {
        public string Id { get; set; }
        public string PlaylistName { get; set; }
        public string Owner { get; set; }
        public string DateModified { get; set; }
        public List<Song> Song { set; get; }
    }
}

