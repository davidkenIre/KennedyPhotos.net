using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using System.Drawing.Drawing2D;
using Microsoft.Win32;
using MySql.Data;
using MySql.Data.MySqlClient;
using System.IO;

namespace PhotoWatcherLib
{
    public class Utility
    {
        /// <summary>
        /// Create a thumbnail.  Code taken from http://www.beansoftware.com/ASP.NET-FAQ/Create-Thumbnail-Image.aspx
        /// </summary>
        /// <param name="ThumbnailMax"></param>
        /// <param name="OriginalImagePath"></param>
        /// <param name="ThumbnailImagePath"></param>
        public void CreateThumbnail(int ThumbnailMax, string OriginalImagePath, string ThumbnailImagePath)
        {
            // Loads original image from file
            Image imgOriginal = Image.FromFile(OriginalImagePath);
            // Finds height and width of original image
            float OriginalHeight = imgOriginal.Height;
            float OriginalWidth = imgOriginal.Width;
            // Finds height and width of resized image
            int ThumbnailWidth;
            int ThumbnailHeight;
            if (OriginalHeight > OriginalWidth)
            {
                ThumbnailHeight = ThumbnailMax;
                ThumbnailWidth = (int)((OriginalWidth / OriginalHeight) * (float)ThumbnailMax);
            }
            else
            {
                ThumbnailWidth = ThumbnailMax;
                ThumbnailHeight = (int)((OriginalHeight / OriginalWidth) * (float)ThumbnailMax);
            }
            // Create new bitmap that will be used for thumbnail
            Bitmap ThumbnailBitmap = new Bitmap(ThumbnailWidth, ThumbnailHeight);
            Graphics ResizedImage = Graphics.FromImage(ThumbnailBitmap);
            // Resized image will have best possible quality
            ResizedImage.InterpolationMode = InterpolationMode.HighQualityBicubic;
            ResizedImage.CompositingQuality = CompositingQuality.HighQuality;
            ResizedImage.SmoothingMode = SmoothingMode.HighQuality;
            // Draw resized image
            ResizedImage.DrawImage(imgOriginal, 0, 0, ThumbnailWidth, ThumbnailHeight);
            // Save thumbnail to file
            ThumbnailBitmap.Save(ThumbnailImagePath);
        }


        /// <summary>
        ///  
        /// </summary>
        /// <param name="FileName"></param>
        public void RemoveFile(string FileName)
        {
            try
            {
                // Get the Album the file belongs to
                // Get the parent Directory Name - this is needed to link the picture to an Album name
                FileInfo fInfo = new FileInfo(FileName);

                // Get an Album ID (It may be necessary to create a new Album)
                // The Album name should match the name of the directory containing the photos
                int AlbumID = GetAlbum(fInfo.Directory.Name);

                // Connect to MySQL and mark file removed
                dbDML("update photo set active = 'N', update_date = now(), update_by = 'TEMPUSER' where album_id = " + AlbumID + " and filename = '" + Path.GetFileName(FileName).ToString() + "'");

                // TODO: The cleanup utility should delete thumbnails which no longer exist in the database
            }
            catch (Exception e1)
            {
                WriteLog("Message: " + e1.Message + "\r\n" + "Base Exception: " + e1.GetBaseException().ToString() + "\r\n" + "Inner Exception: " + e1.InnerException);
            }
        }

        /// <summary>
        ///  Given a filename, this subroutine will examine the file,
        ///  generate a thumbnail add it to the database if appropiate
        /// </summary>
        /// <param name="FileName"></param>
        public void AddFile(string FileName)
        {
            try
            {
                FileAttributes attr = File.GetAttributes(FileName);
                // Only execute if the object being created is not a directory
                if (!attr.HasFlag(FileAttributes.Directory))
                {
                    // Create the thumbnail
                    // Wait 5 seconds for the original file to actually land and avoid errors where file is still busy
                    // TODO: Probably a better way to do this rather than waiting 5 seconds
                    System.Threading.Thread.Sleep(5000);
                    string ThumbnailDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "ThumbnailDirectory", "");
                    Guid g = Guid.NewGuid();
                    CreateThumbnail(200, FileName, ThumbnailDirectory + g.ToString() + Path.GetExtension(FileName).ToString());

                    // Get the parent Directory Name - this is needed to link the picture to an Album name
                    FileInfo fInfo = new FileInfo(FileName);

                    // Get an Album ID (It may be necessary to create a new Album)
                    // The Album name should match the name of the directory containing the photos
                    int AlbumID = GetAlbum(fInfo.Directory.Name);

                    // Connect to MySQL and load all the photos
                    dbDML("insert into photo (album_id, filename, thumbnail_filename, created_date, created_by) values (" + AlbumID + ", '" + Path.GetFileName(FileName).ToString() + "', '" + g.ToString() + Path.GetExtension(FileName).ToString() + "', now(), 'TEMPUSER')");
                }
            }
            catch (Exception e1)
            {
                WriteLog("Message: " + e1.Message + "\r\n" + "Base Exception: " + e1.GetBaseException().ToString() + "\r\n" + "Inner Exception: " + e1.InnerException);
            }
        }


        public void RefreshAlbums(string sourcePath)
        {
            dbDML("delete from photo;");
            dbDML("delete from album;");

            DirSearch(sourcePath);
        }

        private void DirSearch(string sDir)
        {
            try
            {
                foreach (string f in Directory.GetFiles(   sDir, "."))
                {
                    WriteLog(f);
                    // We encountered a photo, check its valid on the database, and that the thumbnail exists
                    AddFile(f);
                }

                foreach (string d in Directory.GetDirectories(sDir))
                {
                    this.DirSearch(d);
                }
            }
            catch (System.Exception excpt)
            {
                WriteLog(excpt.Message);
            }
        }
    





        // Executes a DML statement
        public void dbDML(string SQL)
        {
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            // Create Command
            MySqlCommand cmd = new MySqlCommand(SQL, conn);

            //Create a data reader and Execute the command
            cmd.ExecuteNonQuery();
            conn.Close();
        }

        /// <summary>
        /// Get an Album ID from the database.  If the album 
        /// does not exist, create a new record and return that ID
        /// </summary>
        /// <param name="AlbumName"></param>
        /// <returns></returns>
        public int GetAlbum(string AlbumName)
        {
            int AlbumID = 0;
            MySql.Data.MySqlClient.MySqlConnection conn;
            string myConnectionString;

            // Get the connection password
            string password = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "");

            myConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + password + ";";
            conn = new MySql.Data.MySqlClient.MySqlConnection();
            conn.ConnectionString = myConnectionString;
            conn.Open();

            // Create Command
            MySqlCommand cmd = new MySqlCommand("select Album_ID from album where upper(Album_Name) = '" + AlbumName.ToUpper() + "' and active = 'Y'", conn);
            // Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            // Read the the Album ID, if it cannot be create and read again
            // TODO: This section should be coded a little more elegantly!
            if (!dataReader.Read())
            {
                dataReader.Close();
                // Create Album
                MySqlCommand cmd2 = new MySqlCommand("insert into Album (album_name, location, created_date, created_by) values ('" + AlbumName + "', '/Albums/" + AlbumName + "/', now(), 'TEMPUSER')", conn);
                cmd2.ExecuteNonQuery();

                MySqlCommand cmd3 = new MySqlCommand("select Album_ID from album where upper(Album_Name) = '" + AlbumName.ToUpper() + "' and active = 'Y'", conn);
                MySqlDataReader dataReader3 = cmd.ExecuteReader();
                dataReader3.Read();
                Int32.TryParse(dataReader3["Album_ID"].ToString(), out AlbumID);
                dataReader3.Close();
            }
            else
            {
                Int32.TryParse(dataReader["Album_ID"].ToString(), out AlbumID);
            }

            conn.Close();
            return AlbumID;
        }


        /// <summary>
        /// Write a generic string to the Log file
        /// </summary>
        /// <param name="Message"></param>
        public void WriteLog(string Message)
        {
            using (StreamWriter sw = File.AppendText(AppDomain.CurrentDomain.BaseDirectory + "\\PhotoWatcher.log"))
            {
                sw.WriteLine(DateTime.Now.ToString("dd-Mmm-yyyy HH:mm:ss", System.Globalization.CultureInfo.GetCultureInfo("en-US")));
                sw.WriteLine(Message);
                sw.WriteLine("---------------------------------------------------------------------------");
            }
        }
    }
}
