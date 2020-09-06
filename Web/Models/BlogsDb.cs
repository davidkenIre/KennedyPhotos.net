using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MySql.Data;
using MySql.Data.MySqlClient;
using Microsoft.Win32;

namespace Blogs.Models
{
    public class BlogDb 
    {
       

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
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLPassword", "");

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
            "select b2.* from blog b2, user.aspnetroles ar2, user.aspnetuserroles aur2 " +
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
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLPassword", "");

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
            from blog b, user.aspnetroles ar2, user.aspnetuserroles aur2
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
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLPassword", "");
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
                SQL = "update blog set title = '" + blog.Title + "', author = '" + blog.Author + "', dte_posted = current_date(), blog_text = '" + blog.BlogText + "', updated_by = 'TEMPUSER', updated_date = current_date() where blog_id = " + blog.Id;
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
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLPassword", "");
            string myConnectionString;
            string SQL;
            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";default command timeout=0";
            conn.ConnectionString = myConnectionString;
            conn.Open();

            SQL = "update blog set active = 'N', updated_by = 'TEMPUSER', updated_date = current_date() where blog_id = " + Id;
            MySqlCommand cmd = new MySqlCommand(SQL, conn);
            cmd.ExecuteNonQuery();

            conn.Close();
        }



        
    }
}