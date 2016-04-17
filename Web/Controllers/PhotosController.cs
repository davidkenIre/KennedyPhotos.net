using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;

namespace Photos.Controllers
{
    public class PhotosController : Controller
    {
        PhotosDb _db = new PhotosDb();

        //
        // GET: /Photo/
        [HttpGet]
        public ActionResult Index()
        {
            List<Album> _AlbumListing = _db.GetAllAlbums();
            return View(_AlbumListing.ToList());
        }

        [HttpGet]
        public ActionResult ViewAlbum(int id)
        {
            //            return Content("Viewing Album: " + id);
            List<Photo> _PhotoListing = _db.GetAllPhotos();
            return View(_PhotoListing.ToList());

        }
    }
}
