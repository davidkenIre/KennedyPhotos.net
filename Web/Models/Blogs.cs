using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Blogs.Models
{
   

    /// <summary>
    /// This class represents an Blog Post
    /// </summary>
    public class Blog
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Author { get; set; }
        public string DatePosted { get; set; }
        //private string blogtext;
        public string BlogText { get; set; }

    }

    
}

