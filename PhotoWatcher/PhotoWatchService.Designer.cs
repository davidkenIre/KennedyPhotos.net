using Microsoft.Win32;
using System;
using System.IO;
using System.Text;

namespace PhotoWatcher
{
    partial class PhotoWatchService
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.FSPhotoWatcher = new System.IO.FileSystemWatcher();
            ((System.ComponentModel.ISupportInitialize)(this.FSPhotoWatcher)).BeginInit();
            // 
            // FSPhotoWatcher
            // 
            this.FSPhotoWatcher.EnableRaisingEvents = true;
            this.FSPhotoWatcher.IncludeSubdirectories = true;
            this.FSPhotoWatcher.NotifyFilter = ((System.IO.NotifyFilters)((((((((System.IO.NotifyFilters.FileName | System.IO.NotifyFilters.DirectoryName) 
            | System.IO.NotifyFilters.Attributes) 
            | System.IO.NotifyFilters.Size) 
            | System.IO.NotifyFilters.LastWrite) 
            | System.IO.NotifyFilters.LastAccess) 
            | System.IO.NotifyFilters.CreationTime) 
            | System.IO.NotifyFilters.Security)));

            this.FSPhotoWatcher.Changed += new System.IO.FileSystemEventHandler(this.FSPhotoWatcher_Changed);
            this.FSPhotoWatcher.Created += new System.IO.FileSystemEventHandler(this.FSPhotoWatcher_Created);
            this.FSPhotoWatcher.Deleted += new System.IO.FileSystemEventHandler(this.FSPhotoWatcher_Deleted);
            this.FSPhotoWatcher.Renamed += new System.IO.RenamedEventHandler(FSPhotoWatcher_Renamed);

            // 
            // PhotoWatchService
            // 
            this.ServiceName = "PhotoWatcher";
            ((System.ComponentModel.ISupportInitialize)(this.FSPhotoWatcher)).EndInit();

        }

        #endregion

        private System.IO.FileSystemWatcher FSPhotoWatcher;
        /* DEFINE WATCHER EVENTS... */
        /// <summary>
        /// Event occurs when the contents of a File or Directory are changed
        /// </summary>

        private void FSPhotoWatcher_Changed(object sender,
                        System.IO.FileSystemEventArgs e)
        {
            //code here for newly changed file or directory
        }
        /// <summary>
        /// Event occurs when the a File or Directory is created
        /// </summary>
        private void FSPhotoWatcher_Created(object sender,
                        System.IO.FileSystemEventArgs e)
        {
            Utility U = new Utility();
            try {
                // Create the thumbnail
                // Wait 5 seconds for the original file to actually land and avoid errors where file is still busy
                System.Threading.Thread.Sleep(5000);

                string ThumbnailDirectory = (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "ThumbnailDirectory", "");
                Guid g = Guid.NewGuid();
                U.CreateThumbnail(200, e.FullPath, ThumbnailDirectory + g.ToString() + Path.GetExtension(e.Name).ToString());

                // Get the parent Directory Name - this is needed to link the picture to an Album name
                FileInfo fInfo = new FileInfo(e.FullPath);
                String AlbumName = fInfo.Directory.Name;

                // Connect to MySQL and load all the photos
                U.dbDML("insert into photo (album_id, filename, thumbnail_filename) select distinct album_id, '" + Path.GetFileName(e.FullPath).ToString() + "', '" + g.ToString() + Path.GetExtension(e.Name).ToString() + "' from album where upper(album_name)='" + AlbumName.ToUpper() + "';");
            } 
            catch (Exception e1) {
                U.WriteLog("Message: " + e1.Message +  "\r\n" + "Base Exception: " + e1.GetBaseException().ToString() + "\r\n" + "Inner Exception: " + e1.InnerException);
            }
        }

        /// <summary>
        /// Event occurs when the a File or Directory is deleted
        /// </summary>
        private void FSPhotoWatcher_Deleted(object sender,
                        System.IO.FileSystemEventArgs e)
        {
            //code here for newly deleted file or directory
        }
        /// <summary>
        /// Event occurs when the a File or Directory is renamed
        /// </summary>
        private void FSPhotoWatcher_Renamed(object sender,
                        System.IO.RenamedEventArgs e)
        {
            //code here for newly renamed file or directory
        }
    }
}


