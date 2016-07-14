using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;

namespace WebApplication1.Controllers
{
    public class HomeController : Controller
    {

        PhotosDb _db = new PhotosDb();

        [HttpGet]
        [Authorize]
        public ActionResult Index()
        {
            List<Album> _AlbumListing = _db.GetAlbums(5);
            return View(_AlbumListing.ToList());
        }



        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}