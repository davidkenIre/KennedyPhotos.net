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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        [HttpGet]
        public ActionResult Edit()
        {
            //List<Photo> _PhotoListing = _db.GetAllPhotos(Id);
            //ViewBag.AlbumName = _PhotoListing[0].AlbumName;  // Get the Album Name from the first element in the listing
            //return View(_PhotoListing.ToList());
            return View();

        }

        [HttpPost]
        public ActionResult Save(string title, String author, string dateposted, string blogtext)
        {
            Blog blog = new Blog();
            blog.Title = title;
            blog.Author = author;
            blog.DatePosted = dateposted;
            blog.BlogText = blogtext;

            string Id = _db.SaveBlogEntry(blog);

            return RedirectToAction("Edit", "Blog", new { id = Id });
        }

    }
}
