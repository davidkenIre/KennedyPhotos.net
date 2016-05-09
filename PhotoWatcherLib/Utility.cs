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
        // Globals
        MySql.Data.MySqlClient.MySqlConnection MySQLConn;

        /// <summary>
        /// Class constructor
        /// </summary>
        public Utility()
        {
            MySQLConn = new MySql.Data.MySqlClient.MySqlConnection();
            MySQLConn.ConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "") + ";";
            MySQLConn.Open();
        }


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


        /// <summary>
        /// This subroutine will do a full scan of the album directory, add new files to the database, 
        /// sync the database with the filesystem and delete any thinbnails which are not active in the database
        /// </summary>
        /// <param name="sourcePath"></param>
        public void RefreshAlbums(string sourcePath)
        {
            dbDML("update photo set to_remove = 'Y';");
            dbDML("update album set to_remove = 'Y';");

            FullDirectoryScan(sourcePath);

            // Revove photos from database which are no longer available
            dbDML("update photo set active='N' where to_remove = 'Y';");
            dbDML("update album set active='N' where album_id in (select distinct album_id from photo where to_remove = 'Y');");

            // Remove thumbnails where the actual photo has just been removed
            string SQL = "select p.thumbnail_filename from photo p where to_remove = 'Y'";
            MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);
            MySqlDataReader dataReader = cmd.ExecuteReader();
            string ThumbnailDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "ThumbnailDirectory", "");
            if (dataReader.Read())
            {
                File.Delete(ThumbnailDirectory + dataReader["thumbnail_filename"].ToString());
            }
            dataReader.Close();            
        }

        /// <summary>
        /// This routine performs a complete scan of the root album directory
        /// and any subdirectories, checks to see if any photos it finds 
        /// already exists in the database, and if not, adds them.
        /// This routine uses recursive techniques
        /// </summary>
        /// <param name="sDir"></param>
        private void FullDirectoryScan(string sDir)
        {
            try
            {
                foreach (string f in Directory.GetFiles(   sDir, "."))
                {
                    //WriteLog(f);
                    // We encountered a photo, check its valid on the database, and that the thumbnail exists
                    if (!AlreadyExists(f)) { 
                        AddFile(f);
                    }
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

        /// <summary>
        /// Checks to see if the photo's metadata alredy exists in the database
        /// If it does, return true, else retuen false
        /// </summary>
        /// <returns></returns>
        private bool AlreadyExists(string FileName)
        {
            // Remove the Base directory from the filename
            string BaseDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "BaseDirectory", "");
            BaseDirectory = BaseDirectory.ToLower();

            FileName = FileName.ToLower();
            FileName = FileName.Replace(BaseDirectory, "");
            FileName = FileName.Replace("\\", "/");

            // Create Command
            string SQL = "select p.photo_id from album a, photo p ";
            SQL += " where a.album_id = p.album_id ";
            SQL += " and replace(lower(concat(a.location, p.filename)), '/albums/', '') = '" + FileName + "';";

            MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);
            // Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            // Read the the Album ID, if it cannot be create and read again
            // TODO: This section should be coded a little more elegantly!
            string PhotoID = "";
            if (dataReader.Read())
            {
                PhotoID = dataReader["Photo_ID"].ToString();
            }

            dataReader.Close();
            //conn.Close();

            if (PhotoID != "")
            {
                WriteLog("File Exists check: " + FileName + " exists in the database");
                // TODO: Implement the to_remove logic
                dbDML("update photo set to_remove='N' where photo_id = " + PhotoID);
                return true;
            } else {
                WriteLog("File Exists check: " + FileName + " does not exist in the database");
                return false;
            }
        }

        // Executes a DML statement
        public void dbDML(string SQL)
        {
            // Create Command
            MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);

            //Create a data reader and Execute the command
            cmd.ExecuteNonQuery();
            cmd.Dispose();
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

            // Create Command
            MySqlCommand cmd = new MySqlCommand("select Album_ID from album where upper(Album_Name) = '" + AlbumName.ToUpper() + "' and active = 'Y'", MySQLConn);
            // Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            // Read the the Album ID, if it cannot be create and read again
            // TODO: This section should be coded a little more elegantly!
            if (!dataReader.Read())
            {
                dataReader.Close();
                // Create Album
                MySqlCommand cmd2 = new MySqlCommand("insert into Album (album_name, location, created_date, created_by) values ('" + AlbumName + "', '/Albums/" + AlbumName + "/', now(), 'TEMPUSER')", MySQLConn);
                cmd2.ExecuteNonQuery();

                MySqlCommand cmd3 = new MySqlCommand("select Album_ID from album where upper(Album_Name) = '" + AlbumName.ToUpper() + "' and active = 'Y'", MySQLConn);
                MySqlDataReader dataReader3 = cmd.ExecuteReader();
                dataReader3.Read();
                Int32.TryParse(dataReader3["Album_ID"].ToString(), out AlbumID);
                dataReader3.Close();
            }
            else
            {
                
                Int32.TryParse(dataReader["Album_ID"].ToString(), out AlbumID);
                dataReader.Close();
            }

            //conn.Close();
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
                sw.Write(DateTime.Now.ToString("dd-MMM-yyyy HH:mm:ss", System.Globalization.CultureInfo.GetCultureInfo("en-US")) + ": ");
                sw.WriteLine(Message);                
            }
        }
    }
}
