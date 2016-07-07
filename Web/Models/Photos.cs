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
        public string DateTaken { get; set; }
        public string FStop { get; set; }
        public string Exposure { get; set; }
        public string ISO { get; set; }
        public string FocalLength { get; set; }
        public string Dimensions { get; set; }
        public string CameraMaker { get; set; }
        public string CameraModel { get; set; }
    }

    /// <summary>
    /// This class represents an Blog Post
    /// </summary>
    public class Blog
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Author { get; set; }
        public string DatePosted { get; set; }
        private string blogtext;
        public string BlogText {
            get { return blogtext; }
            set
            {
                // Format the URL's for display in a Browser
                // 1. Replace all "[[" with <img class="img-responsive" src="
                // 2. Replace all "]]" with " alt="">
                //< img class="img-responsive" src="/BlogImages/Blog00001.jpg" alt="">

                blogtext = value.Replace("[[", "<img class=\"img-responsive\" src=\"");
                blogtext = blogtext.Replace("]]", "\" alt = \"\">");
            }
        }
    }
}
 
