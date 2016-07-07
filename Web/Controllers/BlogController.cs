using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;
using System.IO;


namespace Photos.Controllers
{
    public class BlogController : Controller
    {
        PhotosDb _db = new PhotosDb();

        /// <summary>
        /// Get an Blog Listing
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public ActionResult Index()
        {
            List<Blog> _BlogListing = _db.GetBlogs(0);
            return View(_BlogListing.ToList());
        }
        
    }
}
