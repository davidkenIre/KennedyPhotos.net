using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Photos.Models
{
    /// <summary>
    /// This class represents an Album
    /// </summary>
    public class Album
    {
        public string Id { get; set; }
        public string Location { get; set; }
        public string AlbumName { get; set; }
        public string AlbumDate { get; set; }
        public string Description { get; set; }
    }


    /// <summary>
    /// This class represents a single Photo
    /// </summary>
    public class Photo
    {
        public string Id { get; set; }
        public string Album_Id { get; set; }
        public string Filename { get; set; }
        public string Location { get; set; }
        public string AlbumName { get; set; }
        public string ThumbnailFilename { get; set; }
    }
}
 
