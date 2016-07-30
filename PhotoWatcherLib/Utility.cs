using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using Microsoft.Win32;
using MySql.Data;
using MySql.Data.MySqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.IO.Compression;
using ImageProcessor;
using ImageProcessor.Imaging.Formats;

// TODO: What happens when a thumbnail gets deleted - when does it get recreated?
// TODO: Database Created by and updated by
// TODO: str_to_date in SQL is not stable because the date format is dependant on the local
// TODO: Can get 3 empty divs at the end of a listing
// TODO: Download status in the View albums page
// TODO: Schedule Cleanup and refresh modules
// TODO: Importer does not work if there is a single ' in the directory Name
// TODO: Implement Security

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
            try
            {
                MySQLConn = new MySql.Data.MySqlClient.MySqlConnection();
                MySQLConn.ConnectionString = "Server=lattuce-dc;Database=photos;Uid=root;Pwd=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Password", "") + ";";
                MySQLConn.Open();
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not connect to the Database - " + e1.Message);
            }
        }

        /// <summary>
        /// Create a thumbnail.  Function uses package taken from http://imageprocessor.org/
        /// </summary>
        /// <param name="ThumbnailMax"></param>
        /// <param name="OriginalImagePath"></param>
        /// <param name="ThumbnailImagePath"></param>
        public void CreateThumbnail(int ThumbnailMax, string OriginalImagePath, string ThumbnailImagePath)
        {
            try { 

            byte[] photoBytes = File.ReadAllBytes(OriginalImagePath); // change imagePath with a valid image path
            int quality = 70;
            ISupportedImageFormat format = new PngFormat { Quality = 70 };

            // Finds height and width of original image, before calculating an appropiate thumbnail size
            Image imgOriginal = Image.FromFile(OriginalImagePath);
            float OriginalHeight = imgOriginal.Height;
            float OriginalWidth = imgOriginal.Width;
            int ThumbnailHeight = ThumbnailMax;
            int ThumbnailWidth = (int)((OriginalWidth / OriginalHeight) * (float)ThumbnailMax);
            var size = new Size(ThumbnailHeight, ThumbnailWidth);

            using (var inStream = new MemoryStream(photoBytes))
            {
                using (var outStream = new MemoryStream())
                {
                    // Initialize the ImageFactory using the overload to preserve EXIF metadata.
                    using (var imageFactory = new ImageFactory(preserveExifData: true))
                    {
                        // How should the image be resized?
                        //var resizeLayer = new ImageProcessor.Imaging.ResizeLayer(size, ImageProcessor.Imaging.ResizeMode.Max, ImageProcessor.Imaging.AnchorPosition.Center);

                        // Do your magic here
                        imageFactory.Load(inStream)
                            //.Resize(resizeLayer)
                            .Constrain(size)
                            .Format(format)
                            .Quality(quality)
                            .AutoRotate()
                            .Save(outStream);
                        //if (OriginalHeight > OriginalWidth)
                        //  imageFactory.Rotate(90);

                        //imageFactory
                    }
                    FileStream file = new FileStream(ThumbnailImagePath, FileMode.Create, System.IO.FileAccess.Write);
                    outStream.CopyTo(file);
                }
            }
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not create thumbnail - " + e1.Message);
            }
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
                dbDML("update photo set active='N', update_date = now(), update_by = 'TEMPUSER' where album_id = " + AlbumID + " and filename = '" + Path.GetFileName(FileName).ToString() + "'");
                dbDML("update album set active='N' where album_id not in (select distinct album_id from photo where active = 'Y');");
                dbDML("update album set active='Y' where album_id in (select distinct album_id from photo where active = 'Y');");
            }

            catch (Exception e1)
            {
                WriteLog("Error: Could not remove file - " + e1.Message);
            }

}

        /// <summary>
        /// Only allow certain character types in a string
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string RemoveSpecialCharacters(string str)
        {
            return Regex.Replace(str, @"[^a-zA-Z0-9:\-\\_. /]+", "", RegexOptions.Compiled);  
        }

        /// <summary>
        ///  Given a filename, this subroutine will examine the file,
        ///  generate a thumbnail add it to the database if appropiate,
        ///  This can be called from the PhotoWatcher service, or from the Full Directory Scan
        /// </summary>
        /// <param name="FileName"></param>

        [STAThread]
        public void AddFile(string FileName)
        {
            try
            {
                string DateTaken = "";
                string FStop = "";
                string Exposure = "";
                string ISO = "";
                string FocalLength = "";
                string Dimensions = "";
                string CameraMaker = "";
                string CameraModel = "";

                FileAttributes attr = File.GetAttributes(FileName);

                // Only execute if the object being created is not a directory
                if (!attr.HasFlag(FileAttributes.Directory))
                {
                    WriteLog("Adding File: " + FileName);

                    // Read the photos tags
                    TagLib.File tagFile = TagLib.File.Create(FileName);
                    var image = tagFile as TagLib.Image.File;

                    DateTaken = Convert.ToString(image.ImageTag.DateTime);
                    FStop = Convert.ToString(image.ImageTag.FNumber);
                    Exposure = Convert.ToString(image.ImageTag.ExposureTime);
                    ISO = Convert.ToString(image.ImageTag.ISOSpeedRatings);
                    FocalLength = Convert.ToString(image.ImageTag.FocalLength);
                    Dimensions = Convert.ToString(image.Properties.PhotoHeight) + "x" + Convert.ToString(image.Properties.PhotoWidth);
                    CameraMaker = image.ImageTag.Make;
                    CameraModel = image.ImageTag.Model;
                
                    // Create the thumbnail                    
                    string ThumbnailDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "ThumbnailDirectory", "");
                    int ThumbnailSize = (int)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "Thumbnailsize", "");
                    Guid g = Guid.NewGuid();
                    CreateThumbnail(ThumbnailSize, FileName, ThumbnailDirectory + g.ToString() + Path.GetExtension(FileName).ToString());

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
                    dbDML("insert into photo (album_id, filename, thumbnail_filename, date_taken, fStop, exposure, iso, focal_length, dimensions, Camera_maker, Camera_model, checksum, created_date, created_by) values (" + AlbumID + ", '" + Path.GetFileName(FileName).ToString() + "', '" + g.ToString() + Path.GetExtension(FileName).ToString() + "', str_to_date('" + DateTaken + "', '%d/%c/%Y %T:%i:%s'), '" + FStop + "', '" + Exposure + "', '" + ISO + "', '" + FocalLength + "', '" + Dimensions + "', '" + CameraMaker + "', '" + CameraModel + "','" + MD5Checksum + "', now(), 'TEMPUSER')");
                }
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not add file - " + e1.Message);
    }
}

        /// <summary>
        /// This subroutine will do a full scan of the album directory, add new files to the database, 
        /// sync the database with the filesystem and delete any thinbnails which are not active in the database
        /// </summary>
        /// <param name="sourcePath"></param>
        public void RefreshAlbums(string sourcePath)
        {
            try { 
            WriteLog("Performing an Album Refresh");
            dbDML("update photo set to_remove = 'Y';");

            // Keep running directory scans until a full scan has completed without making any changes
            do
            {
                WriteLog("Checking for changes in the Album directory");
            } while (FullDirectoryScan(sourcePath, false) == true);

            // Remove photos from database which are no longer available
            dbDML("update photo set active='N' where to_remove = 'Y';");
            dbDML("update album set active='N' where album_id not in (select distinct album_id from photo where active = 'Y');");
            dbDML("update album set active='Y' where album_id in (select distinct album_id from photo where active = 'Y');");

            // Remove Old Log Files
            string[] files = Directory.GetFiles(AppDomain.CurrentDomain.BaseDirectory + "\\Logs\\");
            foreach (string file in files)
            {
                FileInfo fi = new FileInfo(file);
                if (fi.LastAccessTime < DateTime.Now.AddMonths(-1))
                    fi.Delete();
            }

            WriteLog("Finished Performing Album Refresh");
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not refresh album - " + e1.Message);
            }
        }

        public void PerformCleanup()
        {
            // Remove thumbnails where the actual photo has just been removed
            CleanThumbnailDir();
            CleanDownloadDir();
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
                    if (!AlreadyExists(FileName))
                    {
                        if (IsImage(FileName))
                        {
                            ChangeMade = true;
                            AddFile(FileName);
                        }
                    }
                }

                foreach (string d in Directory.GetDirectories(DirToScan))
                {
                    ChangeMade = this.FullDirectoryScan(d, ChangeMade);
                }
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not perform directory scan - " + e1.Message);
            }

            // Use an OR operator to bubble up the ChangeMade flag in the recusion operation
            return ChangeMade || ChangeMadeIn;
        }

        /// <summary>
        /// Checks to see if the photo's metadata alredy exists in the database
        /// If it does, return true, else retuen false
        /// </summary>
        /// <returns></returns>
        private bool AlreadyExists(string FileName)
        {
            try { 
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
            MySqlDataReader dataReader = cmd.ExecuteReader();

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

            // At this point we can mark the database record to ensure the record is not made inactive 
            // at the end of the scans, this is probably a funny place to put this update - should really move it to somewhere 
            // more appropiate, but the nice thing about doing it here is that you have the PhotoID
            dbDML("update photo set to_remove='N' where photo_id = " + PhotoID);
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not perform check to see if metadata already exists - " + e1.Message);
            }
            return true;
        }

        // Executes a DML statement
        public void dbDML(string SQL)
        {
            try { 
                // Create Command
                MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);

                //Create a data reader and Execute the command
                cmd.ExecuteNonQuery();
                cmd.Dispose();
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not execute database command - " + e1.Message);
            }
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
            try
            {
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
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not get album ID - " + e1.Message);
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
        public bool IsImage(string fileName)
        {
            try { 
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
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not determine if file is an image - " + e1.Message);
            }
            return false;
        }

        /// <summary>
        /// Calculate the md5 checksum for a file
        /// Code was lifted from http://stackoverflow.com/questions/10520048/calculate-md5-checksum-for-a-file
        /// </summary>
        /// <param name="Filename"></param>
        /// <returns></returns>
        private int CalculateChecksum(string Filename)
        {
            try { 
                using (var md5 = MD5.Create())
                {
                    using (var stream = File.OpenRead(Filename))
                    {
                        byte[] MD5ChecksumArray = md5.ComputeHash(stream);
                        string MD5Checksum = System.Text.Encoding.UTF8.GetString(MD5ChecksumArray, 0, MD5ChecksumArray.Length);
                        return BitConverter.ToInt32(MD5ChecksumArray, 0);
                    }
                }
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not calculate checksum - " + e1.Message);
            }
            return 0;
        }

        /// <summary>
        /// Loop through each thumbnail in the filesystem, delete it if it does not
        /// exist on the database
        /// </summary>
        private void CleanThumbnailDir()
        {
            try { 
                string ThumbnailDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "ThumbnailDirectory", "");
                MySqlCommand cmd;
                MySqlDataReader dataReader;
                string SQL;

                // Add new Photos to the database
                foreach (string FileName in Directory.GetFiles(ThumbnailDirectory, "."))
                {
                    SQL = "select photo_id from photo p where lower(thumbnail_filename)='" + Path.GetFileName(FileName.ToLower()) + "'";
                    cmd = new MySqlCommand(SQL, MySQLConn);
                    dataReader = cmd.ExecuteReader();

                    if (!dataReader.Read())
                    {
                        // Delete
                        File.Delete(FileName);
                    }
                    dataReader.Close();
                }
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not clean thumbnail directory - " + e1.Message);
            }
        }

        /// <summary>
        /// Clean any Temp Files older than a day
        /// </summary>
        private void CleanDownloadDir()
        {
            try
            {
                string TempFolder = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "TempDirectory", "");
                var Dirs = new DirectoryInfo(TempFolder).GetDirectories();
                foreach (var Dir in Dirs)
                {
                    // Delete directory if it is greater one day old 
                    if (DateTime.UtcNow - Dir.CreationTimeUtc > TimeSpan.FromDays(1))
                    {
                        Directory.Delete(Dir.FullName, true);
                    }
                }
            }

            catch (Exception e1)
            {
                WriteLog("Error: Could not clean downloaded directory - " + e1.Message);
            }
        }

        /// <summary>
        /// Write a generic string to the Log file
        /// </summary>
        /// <param name="Message"></param>
        public void WriteLog(string Message)
        {
            try
            {
                using (StreamWriter sw = File.AppendText(AppDomain.CurrentDomain.BaseDirectory + "\\Logs\\PhotoWatcher_" + DateTime.Today.ToString("yyyyMMdd") + ".log"))
                {
                    sw.Write(DateTime.Now.ToString("dd-MMM-yyyy HH:mm:ss", System.Globalization.CultureInfo.GetCultureInfo("en-US")) + ": ");
                    sw.WriteLine(Message);
                }
            }
            catch 
            {
                // Cant write a log entry!!
            }
        }

        /// <summary>
        /// Zip a folder
        /// </summary>
        /// <param name="Id">The Album ID we are zipping</param>
        /// <returns>The physical location of the newly zipped archive</returns>
        public string ZipFolder(int Id)
        {
            string ZipDirectory = "";
            string ZipName = "";
            try { 
                // Get the album name from the id passed in
                MySqlCommand cmd;
                MySqlDataReader dataReader;
                string SQL = "select album_name from album a where album_id = " + Id;
                cmd = new MySqlCommand(SQL, MySQLConn);
                dataReader = cmd.ExecuteReader();
                dataReader.Read();
                string AlbumName = dataReader["album_name"].ToString();
                dataReader.Close();
                cmd.Dispose();

                // Build up the physical location of the album
                string Location = Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "BaseDirectory", "") + AlbumName + "\\";

                // Get the Zip Name
                Guid g = Guid.NewGuid();
                ZipDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "TempDirectory", "") + "\\" + g.ToString() + "\\";
                ZipName = AlbumName + ".zip";
            
                // Create the temporary directory
                Directory.CreateDirectory(ZipDirectory);

                // Add all active files into the new archive
                SQL = "select filename from photo p where album_id = " + Id + " and active='Y'";
                cmd = new MySqlCommand(SQL, MySQLConn);
                dataReader = cmd.ExecuteReader();

                using (ZipArchive archive = ZipFile.Open(ZipDirectory + ZipName, ZipArchiveMode.Update)) {
                    while (dataReader.Read())
                    {
                        string FileName = dataReader["filename"].ToString();
                        archive.CreateEntryFromFile(Location + FileName, FileName);
                    }
                }
            
                dataReader.Close();
                cmd.Dispose();
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not zip folder - " + e1.Message);
            }
            return ZipDirectory + ZipName;
        }
    }
}

