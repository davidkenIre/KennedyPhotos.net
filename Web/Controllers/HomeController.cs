using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;

namespace Photos.Controllers
{
    public class HomeController : Controller
    {
        PhotosDb _db = new PhotosDb();
        //
        // GET: /Home/

        //public ActionResult Index()
        //{
        //    return View();
        //}

        //
        // GET: /Photo/
        [HttpGet]
        public ActionResult Index()
        {
            List<Album> _AlbumListing = _db.GetAlbums(5);
            return View(_AlbumListing.ToList());
        }
    }
}
