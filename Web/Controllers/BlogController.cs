﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;
using System.IO;
using Microsoft.AspNet.Identity;


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
        [Authorize]
        public ActionResult Index()
        {
            //var RoleController = new RoleController(); // DependencyResolver.Current.GetService<RoleController>();
            //List<Blog> _BlogListing = _db.GetBlogs(0, User.Identity.GetUserId(), RoleController.isAdminUser());
            List<Blog> _BlogListing = _db.GetBlogs(0, User.Identity.GetUserId(), false);
            return View(_BlogListing.ToList());            
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="BlogID">A Blog ID</param>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult View(int Id)
        {
            ViewBag.Id = Id;
            // If Id <> 0 then load existing blog data
            if (Id > 0)
            {
                // Load Blog entry from the database
                Blog _blog = _db.GetBlog(Id, User.Identity.GetUserId());
                return View(_blog);
            }
            else
            {
                return View(new Blog());
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="BlogID">A Blog ID</param>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult Edit(int Id)
        {
            ViewBag.Id = Id;
            // If Id <> 0 then load existing blog data
            if (Id > 0 )
            {
                // Load Blog entry from the database
                Blog _blog = _db.GetBlog(Id, User.Identity.GetUserId());
                return View(_blog);
            } else
            {
                return View(new Blog());
            }
        }

        /// <summary>
        /// Save a Blog Post
        /// </summary>
        /// <param name="Id"></param>
        /// <param name="title"></param>
        /// <param name="author"></param>
        /// <param name="dateposted"></param>
        /// <param name="blogtexthtml"></param>
        /// <returns></returns>
        [HttpPost]
        [Authorize]
        [ValidateInput(false)]
        public ActionResult Save(string Id, string title, String author, string blogtexthtml, string btnsubmit)
        {
            switch (btnsubmit)
            {
                case "Save":
                    Blog blog = new Blog();
                    blog.Id = Id;
                    blog.Title = title;
                    blog.Author = author;
                    blog.BlogText = blogtexthtml;
                    Id = _db.SaveBlogEntry(blog);
                    return RedirectToAction("View", "Blog", new { id = Id });
                case "Delete":
                    _db.DeleteBlogEntry(Id);
                    return RedirectToAction("Index", "Blog");
            }
            return RedirectToAction("Index", "Blog");
        }

    }
}
