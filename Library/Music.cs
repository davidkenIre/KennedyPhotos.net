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

namespace Music
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
                MySQLConn.ConnectionString = "Server=lattuce-dc;Database=music;Uid=root;Pwd=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "Password", "") + ";";
                MySQLConn.Open();
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not connect to the Database - " + e1.Message);
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
                using (StreamWriter sw = File.AppendText(AppDomain.CurrentDomain.BaseDirectory + "\\Logs\\Music_" + DateTime.Today.ToString("yyyyMMdd") + ".log"))
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
        /// Executes a DML statement
        /// </summary>
        /// <param name="SQL"></param>
        public void dbDML(string SQL)
        {
            try
            {
                // Create Command
                MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);

                //Create a data reader and Execute the command
                cmd.CommandTimeout = 0;
                cmd.ExecuteNonQuery();
                cmd.Dispose();
            }
            catch (Exception e1)
            {
                WriteLog("Error: Could not execute database command - " + e1.Message);
            }
        }


        /// <summary>
        /// Add and remove music from Master tables depending on the files in Kodi
        /// </summary>
        public void SyncMusicFromKodi() {
            try  {
                Console.WriteLine("Starting music sync from Kodi");
                WriteLog("Starting music sync from Kodi");

                // Add new music from Kodi to the Master table
                dbDML("insert into music.song " +
                      "(created_date, created_by, album_name, song_name, path, filename, play_count) " +
                      "select now(), 'TEMPUSER', a.strAlbum, s.strTitle, p.strPath, s.strFileName, 0 " +
                      "from mymusic60.song s, mymusic60.album a, mymusic60.path p " +
                      "where s.idAlbum = a.idAlbum " +
                      "and s.idPath = p.idPath " +
                      "and concat(p.strPath, 'z|z', s.strFileName) not in " +
                      "(select concat(ts.path, 'z|z', ts.filename) from music.song ts)");

                // Delete from master table where music does not exist in Lodi
                dbDML("delete from music.song " +
                      "where concat(Path, 'z|z', FileName) not in " +
                      "(select " +
                      "concat(p.strPath, 'z|z', s.strFileName) " +
                      "from mymusic60.song s, mymusic60.album a, mymusic60.path p " +
                      "where s.idAlbum = a.idAlbum " +
                      "and s.idPath = p.idPath)");

                Console.WriteLine("Finished music sync from Kodi");
                WriteLog("Finished music sync from Kodi");
            } catch (Exception e1) {
                Console.WriteLine("Error syncing music from Kodi to Master table: " + e1.Message);
                WriteLog("Error syncing music from Kodi to Master table: " + e1.Message);   
            }
        }
    }
}

