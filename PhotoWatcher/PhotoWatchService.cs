using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;


namespace PhotoWatcher
{
    public partial class PhotoWatchService : ServiceBase
    {
        public PhotoWatchService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            FSPhotoWatcher.Path = ConfigurationManager.AppSettings["WatchPath"];
        }

        protected override void OnStop()
        {
        }
    }
}
