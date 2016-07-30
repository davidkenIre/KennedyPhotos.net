using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;
using Microsoft.AspNet.Identity;

namespace WebApplication1.Controllers
{
    public class HomeController : Controller
    {

        PhotosDb _db = new PhotosDb();

        [HttpGet]
        [Authorize]
        public ActionResult Index()
        {
            List<Album> _AlbumListing = _db.GetAlbums(5, User.Identity.GetUserId());
            return View(_AlbumListing.ToList());
        }



        [Authorize]
        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        [Authorize]
        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}