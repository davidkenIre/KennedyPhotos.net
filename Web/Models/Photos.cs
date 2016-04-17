using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Photos.Models
{
    /// <summary>
    /// This class represents a single photo
    /// </summary>
    public class Photo
    {
        public string Id { get; set; }
        public string FileName { get; set; }
        public string Location { get; set; }
        public string AlbumName { get; set; }
   }
}
 
