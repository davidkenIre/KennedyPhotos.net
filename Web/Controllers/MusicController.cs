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

        ////////////////////// Songs
        
        /// <summary>
        /// Get a Song Listing
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult SongList()
        {
            List<Song> _SongListing = _db.GetSongs();
            return View(_SongListing.ToList());
        }


        ////////////////////// Playlists

        /// <summary>
        /// Get a Playlist Listing
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult PlaylistList()
        {
            List<Playlist> _PlaylistListing = _db.GetPlaylists(0, User.Identity.GetUserId());
            return View(_PlaylistListing.ToList());
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="Id">A Playlist ID</param>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult PlaylistView(int Id)
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
        /// <param name="Id">A Playlist ID</param>
        /// <returns></returns>
        [HttpGet]
        [Authorize]
        public ActionResult PlaylistEdit(int Id)
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
        /// <param name="playlistname"></param>
        /// <param name="btnsubmit"></param>
        /// <returns></returns>
        [HttpPost]
        [Authorize]
        [ValidateInput(false)]
        public ActionResult PlaylistSave(string Id, string playlistname, string btnsubmit)
        {
            switch (btnsubmit)
            {
                case "Save":
                    Playlist playlist = new Playlist();
                    playlist.Id = Id;
                    playlist.PlaylistName = playlistname;
      
                    Id = _db.SavePlaylistEntry(playlist);
                    return RedirectToAction("PlaylistView", "Music", new { id = Id });
                case "Delete":
                    _db.DeletePlaylistEntry(Id);
                    return RedirectToAction("PlaylistList", "Music");
            }
            return RedirectToAction("PlaylistList", "Music");
        }
    }
}
