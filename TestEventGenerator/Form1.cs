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
    public partial class Form1 : Form
    {
        public Form1()
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
            PhotoWatcherLib.Utility U = new PhotoWatcherLib.Utility();
            U.WriteLog("Intercepted call to refresh Albums");
            U.RefreshAlbums((string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\LattuceWebsite", "BaseDirectory", ""));
        }
    }
}
