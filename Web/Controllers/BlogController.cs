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
        /// <param name="BlogID">A Blog ID</param>
        /// <returns></returns>
        [HttpGet]
        public ActionResult Edit(int Id)
        {
            ViewBag.Id = Id;
            // If Id <> 0 then load existing blog data
            if (Id > 0 )
            {
                // Load Blog entry from the database
                Blog _blog = _db.GetBlog(Id);
                return View(_blog);
            } else
            {
                return View(new Blog());
            }

            
        }


        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Save(string Id, string title, String author, string dateposted, string blogtexthtml)
        {
            Blog blog = new Blog();
            blog.Id = Id;
            blog.Title = title;
            blog.Author = author;
            blog.DatePosted = dateposted;
            blog.BlogText = blogtexthtml;

            Id = _db.SaveBlogEntry(blog);

            return RedirectToAction("Edit", "Blog", new { id = Id });
        }

    }
}
