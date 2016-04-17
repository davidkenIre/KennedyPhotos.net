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
        public List<Photo> GetAllAlbums()
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
            MySqlCommand cmd = new MySqlCommand("select * from album", conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            //Read the data and store them in the list
            List<Album> _photos = new List<Album>();
            while (dataReader.Read())
            {
                Photo item = new Album()
                {
                    Id = dataReader["album_id"].ToString(),
                    FileName = dataReader["filename"].ToString(),
                    Location = dataReader["location"].ToString(),
                    AlbumName = dataReader["albumname"].ToString()
                };
                _photos.Add(item);
            }

            //close Data Reader
            dataReader.Close();
            conn.Close();

            return _photos;

        }




        public List<Photo> GetAllPhotos()
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
            MySqlCommand cmd = new MySqlCommand("select * from photo", conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            //Read the data and store them in the list
            List<Photo> _photos = new List<Photo>();
            while (dataReader.Read())
            {
                Photo item = new Photo()
                {
                    Id = dataReader["photo_id"].ToString(),
                    FileName = dataReader["filename"].ToString(),
                    Location = dataReader["location"].ToString(),
                    AlbumName = dataReader["albumname"].ToString()
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