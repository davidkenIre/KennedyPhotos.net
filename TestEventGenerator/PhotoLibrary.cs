﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.ServiceProcess;
using System.Diagnostics;
using System.Threading;
using Microsoft.Win32;
using System.IO;
using System.Drawing.Drawing2D;


namespace TestEventGenerator
{
    public partial class PhotoLibrary : Form
    {
        public PhotoLibrary()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            ServiceController sc = new ServiceController("PhotoWatcher");
            sc.ExecuteCommand(255);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Photos.Utility U = new Photos.Utility();
            
            U.RefreshAlbums((string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "BaseDirectory", ""));
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Photos.Utility U = new Photos.Utility();
            U.PerformCleanup();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            Music.Utility U = new Music.Utility();
            U.SyncMusicFromKodi();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            ServiceController sc = new ServiceController("PhotoWatcher");
            sc.ExecuteCommand(254);
        }
    }
}
