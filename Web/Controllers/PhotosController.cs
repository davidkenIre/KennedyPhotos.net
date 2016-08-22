using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;
using System.IO;
using System.Security.Principal;
using Microsoft.AspNet.Identity;

namespace Photos.Controllers
{
    public class PhotosController : Controller
    {
        PhotosDb _db = new PhotosDb();

        /// <summary>
        /// Get an Album Listing
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult Index()
        {
            List<Album> _AlbumListing = _db.GetAlbums(0, User.Identity.GetUserId());
            return View(_AlbumListing.ToList());
        }

        [HttpGet]
        [Authorize]
        public ActionResult _PartialAlbum()
        {
            List<Album> _AlbumListing = _db.GetAlbums(5, User.Identity.GetUserId());
            return PartialView(_AlbumListing.ToList());
        }

        /// <summary>
        /// Get a Photo Listing
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult ViewAlbum(int Id)
        {
            List<Photo> _PhotoListing = _db.GetAllPhotos(Id, User.Identity.GetUserId());
            ViewBag.AlbumName = _PhotoListing[0].AlbumName;  // Get the Album Name from the first element in the listing
            return View(_PhotoListing.ToList());
        }

        /// <summary>
        /// Get a Single Album
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult GetAlbum(int Id)
        {
            Album _Album = _db.GetAlbum(Id, User.Identity.GetUserId());
            return View(_Album);
        }

        /// <summary>
        /// Zip up an album and present it for download
        /// </summary>
        /// <param name="Id">Album ID</param>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult DownloadAlbum(int Id)
        {
            PhotoWatcherLib.Utility Utility = new PhotoWatcherLib.Utility();
            string file = Utility.ZipFolder(Id);

            string contentType = "application/zip";
            return File(file, contentType, Path.GetFileName(file));
        }
    }
}
