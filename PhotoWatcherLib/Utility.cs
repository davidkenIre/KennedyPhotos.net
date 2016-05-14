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
using System.Security.Cryptography;

// TODO: CRC checks on picture files
// TODO: Get rid of to_remove, use the active flag only - we can use a user_active for user deletes later on

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

            // Dispose Objects
            imgOriginal.Dispose();
            ResizedImage.Dispose();
            ThumbnailBitmap.Dispose();
        }

        /// <summary>
        ///  Called when the PhotoWatcherService detects a phisical delete of a file
        /// </summary>
        /// <param name="FileName"></param>
        public void RemoveFile(string FileName)
        {
            try
            {
                WriteLog("Removing File: " + FileName);
                // Get an Album ID (It may be necessary to create a new Album)
                // The Album name should match the name of the directory containing the photos
                FileInfo fInfo = new FileInfo(FileName);
                int AlbumID = GetAlbum(fInfo.Directory.Name);

                // Connect to MySQL and mark file removed
                dbDML("update photo set active = 'N', update_date = now(), update_by = 'TEMPUSER' where album_id = " + AlbumID + " and filename = '" + Path.GetFileName(FileName).ToString() + "'");
                dbDML("update album set active='N' where album_id not in (select distinct album_id from photo where active = 'Y');");
                dbDML("update album set active='Y' where album_id in (select distinct album_id from photo where active = 'Y');");
            }
            catch (Exception e1)
            {
                WriteLog("Message: (" + e1.Message + ") Base Exception: (" + e1.GetBaseException().ToString() + ") Inner Exception: (" + e1.InnerException + ")");
            }
        }

        /// <summary>
        ///  Given a filename, this subroutine will examine the file,
        ///  generate a thumbnail add it to the database if appropiate,
        ///  This can be called from the PhotoWatcher service, or from the Full Directory Scan
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
                    WriteLog("Adding File: " + FileName);

                    // Create the thumbnail                    
                    string ThumbnailDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "ThumbnailDirectory", "");
                    Guid g = Guid.NewGuid();
                    CreateThumbnail(200, FileName, ThumbnailDirectory + g.ToString() + Path.GetExtension(FileName).ToString());

                    // Get the parent Directory Name - this is needed to link the picture to an Album name
                    FileInfo fInfo = new FileInfo(FileName);

                    // Get an Album ID (It may be necessary to create a new Album)
                    // The Album name should match the name of the directory containing the photos
                    int AlbumID = GetAlbum(fInfo.Directory.Name);

                    // Get the  MD5 Checksum
                    int MD5Checksum = CalculateChecksum(FileName);

                    // Insert a record in the database for the photo
                    // We should also issue a delete before the update, usually this will delete 0 rows,  
                    // but sometimes, in the case where a file has been updated, and a checksum has changed, the photo
                    // might already exist on the database.  A straight delete will remove and we can then insert again.
                    dbDML("delete from photo where album_id = " + AlbumID + " and filename= '" + Path.GetFileName(FileName).ToString() + "'");
                    dbDML("insert into photo (album_id, filename, thumbnail_filename, checksum, created_date, created_by) values (" + AlbumID + ", '" + Path.GetFileName(FileName).ToString() + "', '" + g.ToString() + Path.GetExtension(FileName).ToString() + "', '" + MD5Checksum + "', now(), 'TEMPUSER')");                    
                }
            }
            catch (Exception e1)
            {
                WriteLog("Message: (" + e1.Message + ") Base Exception: (" + e1.GetBaseException().ToString() + ") Inner Exception: (" + e1.InnerException + ")");
            }
        }

        /// <summary>
        /// This subroutine will do a full scan of the album directory, add new files to the database, 
        /// sync the database with the filesystem and delete any thinbnails which are not active in the database
        /// </summary>
        /// <param name="sourcePath"></param>
        public void RefreshAlbums(string sourcePath)
        {
            WriteLog("Performing an Album Refresh");
            dbDML("update photo set to_remove = 'Y';");
            dbDML("update album set to_remove = 'Y';");

            // Keep running directory scans until a full scan has completed without making any changes
            do
            {
                WriteLog("Checking for changes in the Album directory");
            } while (FullDirectoryScan(sourcePath, false) == true);

            // Revove photos from database which are no longer available
            dbDML("update photo set active='N' where to_remove = 'Y';");
            dbDML("update album set active='N' where album_id not in (select distinct album_id from photo where active = 'Y');");
            dbDML("update album set active='Y' where album_id in (select distinct album_id from photo where active = 'Y');");

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
            WriteLog("Finished Performing Album Refresh");
        }

        /// <summary>
        /// This routine performs a complete scan of the root album directory
        /// and any subdirectories, checks to see if any photos it finds 
        /// already exists in the database, and if not, adds them.
        /// This routine uses recursive techniques
        /// </summary>
        /// <param name="sDir"></param>
        /// <returns>
        /// false-No Change was made
        /// true-Changes were made
        /// </returns>
        private bool FullDirectoryScan(string DirToScan, bool ChangeMadeIn)
        {
            bool ChangeMade = false;
            try                
            {
                // Add new Photos to the database
                foreach (string FileName in Directory.GetFiles(DirToScan, "."))
                {
                    // We encountered a photo, check its valid on the database, and that the thumbnail exists
                    if (!AlreadyExists(FileName)) {
                        if (IsImage(FileName))
                        {
                            ChangeMade = true;
                            AddFile(FileName);
                        }
                    }
                }

                foreach (string d in Directory.GetDirectories(DirToScan))
                {
                    ChangeMade = this.FullDirectoryScan(d, ChangeMade) ;
                }

                // Use an OR operator to bubble up the ChangeMade flag in the recusion operation
                return ChangeMade || ChangeMadeIn;
            }
            
            catch (System.Exception e1)
            {                
                WriteLog("Message: (" + e1.Message + ") Base Exception: (" + e1.GetBaseException().ToString() + ") Inner Exception: (" + e1.InnerException + ")");
                throw new Exception("Error Performing Directory Scan");
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

            string FileNameURL = FileName.ToLower();
            FileNameURL = FileNameURL.Replace(BaseDirectory, "");
            FileNameURL = FileNameURL.Replace("\\", "/");

            // Create Command
            string SQL = "select p.photo_id, p.checksum from album a, photo p ";
            SQL += " where a.album_id = p.album_id ";
            SQL += " and replace(lower(concat(a.location, p.filename)), '/albums/', '') = '" + FileNameURL + "';";

            MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);
            // Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd.ExecuteReader();

            // Read the the Album ID, if it cannot be create and read again
            // TODO: This section should be coded a little more elegantly!
            string PhotoID = "";
            int Checksum = 0;
            if (dataReader.Read())
            {
                PhotoID = dataReader["Photo_ID"].ToString();
                Checksum = (Convert.ToInt32(dataReader["checksum"]));
            }
            dataReader.Close();

            // Metadata not on database
            if (PhotoID == "")
                return false;


            // Does File Checksum match whats on the database?
            if (Checksum != CalculateChecksum(FileName))
                return false;

            // All checks match
            // TODO: This update soes not belong in this function
            dbDML("update photo set to_remove='N' where photo_id = " + PhotoID);
            return true;
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
            MySqlCommand cmd1 = new MySqlCommand("select Album_ID from album where upper(Album_Name) = '" + AlbumName.ToUpper() + "' and active = 'Y'", MySQLConn);
            // Create a data reader and Execute the command
            MySqlDataReader dataReader = cmd1.ExecuteReader();

            // Read the the Album ID, if it cannot be create and read again
            if (!dataReader.Read())
            {
                dataReader.Close();
                // Create Album, then select back the newly created Album_id
                MySqlCommand cmd2 = new MySqlCommand("insert into Album (album_name, location, created_date, created_by) values ('" + AlbumName + "', '/Albums/" + AlbumName + "/', now(), 'TEMPUSER')", MySQLConn);
                cmd2.ExecuteNonQuery();

                dataReader = cmd1.ExecuteReader();  // Try the Album ID select again, should work this time!
                dataReader.Read();
                Int32.TryParse(dataReader["Album_ID"].ToString(), out AlbumID);
                dataReader.Close();
            }
            else
            {
                Int32.TryParse(dataReader["Album_ID"].ToString(), out AlbumID);
                dataReader.Close();
            }

            return AlbumID;
        }

        /// <summary>
        /// Copied the following routine from 
        /// http://stackoverflow.com/questions/670546/determine-if-file-is-an-image
        /// Should return true or false if the passed in filename is an image or not
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public static bool IsImage(string fileName)
        {
            string targetExtension = System.IO.Path.GetExtension(fileName);
            if (String.IsNullOrEmpty(targetExtension))
                return false;
            else
                targetExtension = "*" + targetExtension.ToLowerInvariant();

            List<string> recognisedImageExtensions = new List<string>();

            foreach (System.Drawing.Imaging.ImageCodecInfo imageCodec in System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders())
                recognisedImageExtensions.AddRange(imageCodec.FilenameExtension.ToLowerInvariant().Split(";".ToCharArray()));

            foreach (string extension in recognisedImageExtensions)
            {
                if (extension.Equals(targetExtension))
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Calculate the md5 checksum for a file
        /// Code was lifted from http://stackoverflow.com/questions/10520048/calculate-md5-checksum-for-a-file
        /// </summary>
        /// <param name="Filename"></param>
        /// <returns></returns>
        private int CalculateChecksum(string Filename) {
            using (var md5 = MD5.Create())
            {
                using (var stream = File.OpenRead(Filename))
                {
                    byte[] MD5ChecksumArray = md5.ComputeHash(stream);
                    string MD5Checksum = System.Text.Encoding.UTF8.GetString(MD5ChecksumArray, 0, MD5ChecksumArray.Length);
                    //  return MD5Checksum;


                    // if (BitConverter.IsLittleEndian)
                    //     Array.Reverse(MD5ChecksumArray);
                    return BitConverter.ToInt32(MD5ChecksumArray, 0);
                }
            }
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
