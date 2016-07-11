using System;
using System.Collections.Generic;
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
        /// Get a single album from the database
        /// </summary>
        /// <returns></returns>
        public Album GetAlbum(int Id)
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
            string SQL = "select * from album where album_id = " + Id + " and active = 'Y'";

            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            dataReader.Read();
            Album _album = new Album()
            {
                Id = dataReader["album_id"].ToString(),
                Location = dataReader["location"].ToString(),
                AlbumName = dataReader["album_name"].ToString(),
                AlbumDate = dataReader["album_date"].ToString(),
                Description = dataReader["description"].ToString()
            };                

            //close Data Reader
            dataReader.Close();
            conn.Close();

            return _album;
        }

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
            MySqlCommand cmd = new MySqlCommand("select a.*, p.* from photo p, album a where a.album_id = p.album_id and a.album_id = " + AlbumId + " and a.active = 'Y' and p.active = 'Y' order by p.date_taken, p.filename", conn);
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

        /// <summary>
        /// Retrive a list of all albums from the database
        /// </summary>
        /// <param name="Limit">No. of Blog Entries to return</param>
        /// <returns></returns>
        public List<Blog> GetBlogs(int Limit)
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
            string SQL = "select * from blog where active = 'Y' order by created_date desc";
            if (Limit != 0)
            {
                SQL += " Limit " + Limit;
            }

            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            //Read the data and store them in the list
            List<Blog> _blogs = new List<Blog>();
            while (dataReader.Read())
            {
                Blog item = new Blog()
                {
                    Id = dataReader["blog_id"].ToString(),
                    Title = dataReader["Title"].ToString(),
                    Author = dataReader["Author"].ToString(),
                    DatePosted = dataReader["dte_posted"].ToString(),
                    BlogText = dataReader["Blog_Text"].ToString(),                    
                };
                _blogs.Add(item);
            }

            //close Data Reader
            dataReader.Close();
            conn.Close();

            return _blogs;
        }


        /// <summary>
        /// Retrive a single blog entry from the database
        /// </summary>
        /// <param name="BlogId">the blog Id to load</param>
        /// <returns></returns>
        public Blog GetBlog(int BlogId)
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
            string SQL = "select * from blog where blog_id = " + BlogId;
            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            //Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            //Read the data and store them in the list            
            Blog _blog = new Blog();
            if (dataReader.Read()) 
            {
                _blog.Id = dataReader["blog_id"].ToString();
                _blog.Title = dataReader["Title"].ToString();
                _blog.Author = dataReader["Author"].ToString();
                _blog.DatePosted = dataReader["dte_posted"].ToString();
                _blog.BlogText = dataReader["Blog_Text"].ToString();
            }

            //close Data Reader
            dataReader.Close();
            conn.Close();

            return _blog;
        }

        /// <summary>
        /// Insert or Update a blog entry
        /// </summary>
        /// <param name="blog">The Blog model</param>
        /// <returns></returns>
        public string SaveBlogEntry(Blog blog)
        {
            MySql.Data.MySqlClient.MySqlConnection conn;
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "");
            string myConnectionString;
            string Id = "";
            string SQL;
            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";default command timeout=0";
            conn.ConnectionString = myConnectionString;
            conn.Open();

            
            if (blog.Id == "0") {
                // Insert
                SQL = "insert into blog(created_date, created_by, title, author, dte_posted, blog_text) values(now(), 'TEMPUSER', '" + blog.Title + "', '" + blog.Author + "', now(), '" + blog.BlogText + "');";
                MySqlCommand cmd = new MySqlCommand(SQL, conn);
                cmd.ExecuteNonQuery();

                // Get the ID
                SQL = "select LAST_INSERT_ID() AS MYID from blog;";
                cmd = new MySqlCommand(SQL, conn);
                MySqlDataReader dataReader = cmd.ExecuteReader();
                dataReader.Read();
                Id = dataReader["MYID"].ToString();
            }
            else
            {
                SQL = "update blog set title = '" + blog.Title + "', author = '" + blog.Author + "', dte_posted = now(), blog_text = '" + blog.BlogText + "', updated_by = 'TEMPUSER', updated_date = now() where blog_id = " + blog.Id;
                MySqlCommand cmd = new MySqlCommand(SQL, conn);
                cmd.ExecuteNonQuery();
                Id = blog.Id;
            }

            conn.Close();
            return Id;
        }
    }
}