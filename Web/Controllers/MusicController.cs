using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;
using System.IO;
using Microsoft.AspNet.Identity;

namespace Photos.Controllers
{
    public class MusicController : Controller
    {
        PhotosDb _db = new PhotosDb();

        /// <summary>
        /// Get a Playlist Listing
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult Playlist()
        {
            List<Playlist> _PlaylistListing = _db.GetPlaylists(0, User.Identity.GetUserId());
            return View(_PlaylistListing.ToList());
        }

        /// <summary>
        /// Get a Song Listing
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult Index()
        {
            List<Song> _SongListing = _db.GetSongs();
            return View(_SongListing.ToList());
        }

        [HttpGet]
        [Authorize]
        public ActionResult _PartialMusic()
        {
            List<Blog> _BlogListing = _db.GetBlogs(5, User.Identity.GetUserId());
            return PartialView(_BlogListing.ToList());
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
                Playlist _playlist = _db.GetPlaylist(Id, User.Identity.GetUserId());
                return View(_playlist);
            }
            else
            {
                return View(new Playlist());
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
                Playlist _playlist = _db.GetPlaylist(Id, User.Identity.GetUserId());
                return View(_playlist);
            } else
            {
                return View(new Playlist());
            }
        }

        /// <summary>
        /// Save a Playlist
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
        public ActionResult Save(string Id, string playlistname, string btnsubmit)
        {
            switch (btnsubmit)
            {
                case "Save":
                    Playlist playlist = new Playlist();
                    playlist.Id = Id;
                    playlist.PlaylistName = playlistname;
      
                    Id = _db.SavePlaylistEntry(playlist);
                    return RedirectToAction("View", "Music", new { id = Id });
                case "Delete":
                    _db.DeletePlaylistEntry(Id);
                    return RedirectToAction("Index", "Music");
            }
            return RedirectToAction("Index", "Music");
        }

    }
}
