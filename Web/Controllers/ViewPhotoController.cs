using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Photos.Models;

namespace Photos.Controllers
{
    public class ViewPhotoController : Controller
    {
        PhotosDb _db = new PhotosDb();

        //
        // GET: /Photo/
        [HttpGet]
        public ActionResult Index()
        {
            List<Photo> _g = _db.GetAllPhotos();
            var model = _g.ToList();
            return View(model);
        }

        [HttpGet]
        public ActionResult ViewPhoto(int id)
        {
            return Content("Viewing Photo: " + id);
        }
    }
}
