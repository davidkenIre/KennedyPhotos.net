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
        public Album GetAlbum(int Id, string UserID)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            //Create Command
            string SQL = "";
            SQL = "select * from ( " +
                  "select a.album_id, album_name, description, location, DATE_FORMAT(a.album_date, '%d-%b-%Y') as album_date from album a, albumaccess aa " +
                  "where a.album_id = " + Id + " " +
                  "and a.active = 'Y' " +
                  "and aa.album_id = a.album_id " +
                  "and aa.userid = '" + UserID + "' " +
                  "union " +
                  "select a.album_id, album_name, description, location, DATE_FORMAT(a.album_date, '%d-%b-%Y') as album_date from album a, aspnetroles ar2, aspnetuserroles aur2 " +
                  "where aur2.userid = '" + UserID + "' " +
                  "and a.album_id = " + Id + " " +
                  "and aur2.RoleId = ar2.Id " +
                  "and ar2.Name = 'Admin' " +
                  "and a.active = 'Y') as a";

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
        public List<Album> GetAlbums(int Limit, string UserID)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            // Create Command
            string SQL = "";
            SQL = "select * from (select a.created_date, a.album_name, a.description, a.location, " +
            "    a.album_id, DATE_FORMAT(a.album_date, '%d-%b-%Y') as album_date " +
            "from album a, albumaccess aa " +
            "where a.active = 'Y' " +
            "and a.album_id = aa.album_id " +
            "and aa.userid = '" + UserID + "' " +
            "union " +
            "select a.created_date, a.album_name, a.description, a.location, " +
            "    a.album_id, DATE_FORMAT(a.album_date, '%d-%b-%Y') as album_date " +
            "from album a, aspnetroles ar2, aspnetuserroles aur2 " +
            "where aur2.userid = '" + UserID + "' " +
            "and aur2.RoleId = ar2.Id " +
            "and ar2.Name = 'Admin' " +
            "and a.active = 'Y') as a " +
            "order by a.created_date desc";

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
        public List<Photo> GetAllPhotos(int AlbumId, string UserID)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password +";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            // Create Command
            string Sql = @"select * from (
            select a.album_id, a.album_name, DATE_FORMAT(a.album_date, '%d-%b-%Y') as album_date,
            a.description, a.location, p.photo_id, p.filename, p.thumbnail_filename,
            DATE_FORMAT(p.date_taken, '%d-%b-%Y') as date_taken, p.fStop, p.exposure,
            p.iso, p.focal_length, p.dimensions, p.Camera_maker, p.Camera_model, p.checksum
            from photo p, album a, albumaccess aa
            where a.album_id = p.album_id
            and a.album_id = " + AlbumId + @" 
            and a.active = 'Y'
            and p.active = 'Y'
            and aa.userid = '" + UserID + @"'  
            and a.album_id = aa.album_id
            union
            select a.album_id, a.album_name, DATE_FORMAT(a.album_date, '%d-%b-%Y') as album_date,
            a.description, a.location, p.photo_id, p.filename, p.thumbnail_filename,
            DATE_FORMAT(p.date_taken, '%d-%b-%Y') as date_taken, p.fStop, p.exposure,
            p.iso, p.focal_length, p.dimensions, p.Camera_maker, p.Camera_model, p.checksum
            from photo p, album a, aspnetroles ar2, aspnetuserroles aur2
            where a.album_id = p.album_id
            and a.album_id = " + AlbumId + @" 
            and a.active = 'Y'
            and p.active = 'Y'
            and aur2.userid = '" + UserID + @"'  
            and aur2.RoleId = ar2.Id
            and ar2.Name = 'Admin') as a
            order by date_taken, filename";

            MySqlCommand cmd = new MySqlCommand(Sql, conn);
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
        /// Update Album Details (Date and Description)
        /// </summary>
        /// <param name="album">The Album model</param>
        /// <returns></returns>
        public void SaveAlbum(Album album)
        {
            MySql.Data.MySqlClient.MySqlConnection conn;
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");
            string myConnectionString;            
            string SQL;
            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";default command timeout=0";
            conn.ConnectionString = myConnectionString;
            conn.Open();

            SQL = "update album set description = '" + album.Description + "', album_date = STR_TO_DATE('" + album.AlbumDate + "','%Y-%c-%d') , updated_date = now(), updated_by = 'TEMPUSER' where album_id = " + album.Id;
            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            cmd.ExecuteNonQuery();

            conn.Close();
        }

        /// <summary>
        /// Retrive a list of all albums from the database
        /// </summary>
        /// <param name="Limit">No. of Blog Entries to return</param>
        /// <returns></returns>
        public List<Blog> GetBlogs(int Limit, string UserID)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            // Create the SQL command - This is a union statement because if the user is an Administrator
            //                          we do not want to restrict the blogs returned
            string SQL = "";
            SQL = "select * from ( " +
            "select b1.* from blog b1, blogaccess ba1 " +
            "where b1.blog_id = ba1.blog_id " +
            "and ba1.userid = '" + UserID + "' " +
            "and b1.active = 'Y' " +
            "union " +
            "select b2.* from blog b2, aspnetroles ar2, aspnetuserroles aur2 " +
            "where " +
            "aur2.userid = '" + UserID + "' " +
            "and aur2.RoleId = ar2.Id " +
            "and ar2.Name = 'Admin' " +
            "and b2.active = 'Y') As blogscombined " +
            "order by blogscombined.created_date desc";

            // Sometimes we only want to return a certain amount of blogs
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
        public Blog GetBlog(int BlogId, string UserID)
        {
            // Connect to MySQL and load all the photos
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            // Create Command
            string SQL = @"select b.blog_id, Title, Author, Blog_Text, 
                DATE_FORMAT(GREATEST(b.CREATED_DATE, ifnull(b.UPDATED_DATE, b.CREATED_DATE)), '%d-%M-%Y') as dte_posted
            from blog b, blogaccess ba
            where b.blog_id =  " + BlogId + @" 
            and b.blog_id = ba.blog_id
            and ba.userid = '" + UserID + @"'  
            union
            select b.blog_id, Title, Author, Blog_Text, 
                DATE_FORMAT(GREATEST(b.CREATED_DATE, ifnull(b.UPDATED_DATE, b.CREATED_DATE)), '%d-%M-%Y') as dte_posted
            from blog b, aspnetroles ar2, aspnetuserroles aur2
            where b.blog_id =  " + BlogId + @" 
            and aur2.userid = '" + UserID + @"'  
            and aur2.RoleId = ar2.Id
            and ar2.Name = 'Admin'";

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
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");
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

        /// <summary>
        /// Delete a blog entry
        /// </summary>
        /// <param name="Id">The Blog Id</param>
        /// <returns></returns>
        public void DeleteBlogEntry(string Id)
        {
            MySql.Data.MySqlClient.MySqlConnection conn;
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "");
            string myConnectionString;
            string SQL;
            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";default command timeout=0";
            conn.ConnectionString = myConnectionString;
            conn.Open();

            SQL = "update blog set active = 'N', updated_by = 'TEMPUSER', updated_date = now() where blog_id = " + Id;
            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            cmd.ExecuteNonQuery();

            conn.Close();
        }
    }
}