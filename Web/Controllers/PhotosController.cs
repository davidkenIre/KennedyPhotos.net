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
            List<Album> _AlbumListing = _db.GetAlbums(0);
            return View(_AlbumListing.ToList());
        }

        [HttpGet]
        public ActionResult ViewAlbum(int Id)
        {
            //            return Content("Viewing Album: " + id);
            List<Photo> _PhotoListing = _db.GetAllPhotos(Id);
            return View(_PhotoListing.ToList());

        }
    }
}
