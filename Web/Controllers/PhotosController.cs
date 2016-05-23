using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;
using System.IO;


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
            List<Photo> _PhotoListing = _db.GetAllPhotos(Id);
            return View(_PhotoListing.ToList());

        }

        /// <summary>
        /// Zip up an album and present it for download
        /// </summary>
        /// <param name="Id">Album ID</param>
        /// <returns></returns>
        [HttpGet]
        public ActionResult DownloadAlbum(int Id)
        {
            PhotoWatcherLib.Utility Utility = new PhotoWatcherLib.Utility();
            string file = Utility.ZipFolder(Id);

            string contentType = "application/zip";
            return File(file, contentType, Path.GetFileName(file));
        }
    }
}
