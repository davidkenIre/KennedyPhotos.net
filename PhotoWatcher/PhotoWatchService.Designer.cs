using Microsoft.Win32;
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace PhotoWatcher
{
    partial class PhotoWatchService
    {
        // Must be int between 128 and 255
        public enum CustomEvents
        {
            RefreshAlbumEvent = 255
        }        

        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;
        Photos.Utility U = new Photos.Utility();


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
        /// <summary>
        /// Event occurs when the contents of a File or Directory are changed
        /// </summary>

        private void FSPhotoWatcher_Changed(object sender,
                        System.IO.FileSystemEventArgs e)
        {
            PerformRefresh();
        }

        /// <summary>
        /// Event occurs when the a File or Directory is created
        /// </summary>
        private void FSPhotoWatcher_Created(object sender,
                        System.IO.FileSystemEventArgs e)
        {
            PerformRefresh();
        }

        /// <summary>
        /// Event occurs when the a File or Directory is deleted
        /// </summary>
        private void FSPhotoWatcher_Deleted(object sender,
                        System.IO.FileSystemEventArgs e)
        {
            PerformRefresh();
        }
        /// <summary>
        /// Event occurs when the a File or Directory is renamed
        /// </summary>
        private void FSPhotoWatcher_Renamed(object sender,
                        System.IO.RenamedEventArgs e)
        {
            PerformRefresh();
        }

        /// <summary>
        /// This event should be raised by an external application to 
        /// allow on demand refreshing of the Albums
        /// </summary>
        /// <param name="command"></param>
        protected override void OnCustomCommand(int command)
        {
            base.OnCustomCommand(command);
            if (command == (int)CustomEvents.RefreshAlbumEvent)
            {
                PerformRefresh();
            }
        }

        /// <summary>
        /// Makes a call to the Photowatcher library, to perform a Library Refresh
        /// </summary>
        private void PerformRefresh()
        {
            Photos.Utility U = new Photos.Utility();
            
            U.RefreshAlbums((string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "BaseDirectory", ""));
            U.PerformCleanup();
        }
    }
}


