using System;
using System.Collections.Generic;
//using System.Data.Entity;
using System.Linq;
using System.Web;
using MySql.Data;
using MySql.Data.MySqlClient;
using Microsoft.Win32;

namespace Photos.Models
{
    public class PhotosDb 
    {
        /// <summary>
        /// Retrive a list of all albums from the database
        /// </summary>
        /// <returns></returns>
        public List<Album> GetAlbums(int Limit)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            //Create Command
            string SQL = "select * from album where active = 'Y' order by created_date desc";
            if (Limit != 0) {
                SQL += " Limit " + Limit;
            }

            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            //Read the data and store them in the list
            List<Album> _albums = new List<Album>();
            while (dataReader.Read())
            {
                Album item = new Album()
                {
                    Id = dataReader["album_id"].ToString(),
                    Location = dataReader["location"].ToString(),
                    AlbumName = dataReader["album_name"].ToString(),
                    AlbumDate = dataReader["album_date"].ToString(),
                    Description = dataReader["description"].ToString()
                };
                _albums.Add(item);
            }

            //close Data Reader
            dataReader.Close();
            conn.Close();

            return _albums;
        }

        /// <summary>
        /// Retrive a list of all photos from the database, 
        /// along with a list of associated albums
        /// </summary>
        /// <returns></returns>
        public List<Photo> GetAllPhotos(int AlbumId)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password +";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            //Create Command
            MySqlCommand cmd = new MySqlCommand("select a.*, p.* from photo p, album a where a.album_id = p.album_id and a.album_id = " + AlbumId + " and a.active = 'Y' and p.active = 'Y'", conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            //Read the data and store them in the list
            List<Photo> _photos = new List<Photo>();
            while (dataReader.Read())
            {
                Photo item = new Photo()
                {
                    Id = dataReader["photo_id"].ToString(),
                    Album_Id = dataReader["album_id"].ToString(),
                    Filename = dataReader["filename"].ToString(),
                    Location = dataReader["location"].ToString(),
                    AlbumName = dataReader["album_name"].ToString(),
                    ThumbnailFilename = dataReader["thumbnail_filename"].ToString(),
                    DateTaken = dataReader["date_taken"].ToString(),
                    FStop = dataReader["fStop"].ToString(),
                    Exposure = dataReader["exposure"].ToString(),
                    ISO = dataReader["iso"].ToString(),
                    FocalLength = dataReader["focal_length"].ToString(),
                    Dimensions = dataReader["dimensions"].ToString(),
                    CameraMaker = dataReader["Camera_maker"].ToString(),
                    CameraModel = dataReader["Camera_model"].ToString()
                };
                _photos.Add(item);
            }

            //close Data Reader
            dataReader.Close();
            conn.Close();

            return _photos;
        }
    }
}