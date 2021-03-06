﻿using System;
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
                MySQLConn.ConnectionString = "Server=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLServer", "") + ";Database=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "LattuceMusicSchema", "") + ";Uid=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLUsername", "") + ";Pwd=" + (string)Registry.GetValue("HKEY_LOCAL_MACHINE\\Software\\Lattuce", "MySQLPassword", "") + ";";
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
        private void WriteLog(string Message)
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
        private void dbDML(string SQL)
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
                // Add new Albums from Kodi to the Master table
                dbDML("insert into music.album (created_date, created_by_id, album_name, active)  " +
                      "select distinct curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', a.strAlbum, 'Y' " +
                      "from mymusic72.album a " +
                      "where a.strAlbum not in " +
                      "(select ta.album_name from music.album ta)");

                // Delete from master table where albums does not exist in kodi
                dbDML("update music.album a set active = 'N', date_updated = curdate(), updated_by_id ='feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' " +
                      "where a.album_name not in (select ta.album_name from mymusic72.album ta)");

                // Add new songs from Kodi to the Master table
                dbDML("insert into music.song (created_date, created_by_id, album_id, song_name, path, filename, play_count, kodi_idSong, active)  " +
                      "select curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', ma.album_id, s.strTitle, p.strPath, s.strFileName, 0, s.idSong, 'Y' " +
                      "from mymusic72.song s, mymusic72.album a, mymusic72.path p, music.album ma " +
                      "where s.idAlbum = a.idAlbum " +
                      "and s.idPath = p.idPath " +
                      "and a.strAlbum = ma.album_name " +
                      "and s.idSong not in " +
                      "(select ts.kodi_idSong from music.song ts)");

                // Delete from master table where music does not exist in kodi
                dbDML("update music.song set active = 'N', date_updated = curdate(), updated_by_id = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' " +
                      "where s.kodi_idSong not in " +
                      "(select s.idSong " +
                      "from mymusic72.song s, mymusic72.album a, mymusic72.path p " +
                      "where s.idAlbum = a.idAlbum " +
                      "and s.idPath = p.idPath)");

                Console.WriteLine("Finished music sync from Kodi");
                WriteLog("Finished music sync from Kodi");
            } catch (Exception e1) {
                Console.WriteLine("Error syncing music from Kodi to Master table: " + e1.Message);
                WriteLog("Error syncing music from Kodi to Master table: " + e1.Message);   
            }
        }

        public void ExtractAlbumArt()
        {
            try
            {
                string SQL = @"select song_id, album_id, Path from music.song";

                MySqlCommand cmd = new MySqlCommand(SQL, MySQLConn);

                //Create a data reader and Execute the command
                cmd.CommandTimeout = 0;
                cmd.ExecuteNonQuery();
                cmd.Dispose();

                //Create a data reader and Execute the command
                MySqlDataReader dataReader = cmd.ExecuteReader();

                //Read the data and store them in the list            
                if (dataReader.Read())
                {
                    // Get Path to the music File
                    string MusicPath = dataReader["path"].ToString();
                    MusicPath = MusicPath.Replace("smb://", "d:\\");
                    MusicPath = MusicPath.Replace("/", "\\");

                    string AlbumArtPath = "d:\\Media\\Music\\Master\\AlbumArt\\" + dataReader["album_id"].ToString() + "\\.bmp";

                    Console.WriteLine(AlbumArtPath);
                    if (!File.Exists(AlbumArtPath))
                    {

                        TagLib.File file = TagLib.File.Create(MusicPath); //FilePath is the audio file location
                        TagLib.IPicture pic = file.Tag.Pictures[0];  //pic contains data for image.
                        MemoryStream stream = new MemoryStream(pic.Data.Data);  // create an in memory stream

                        //write to file
                        FileStream file1 = new FileStream(AlbumArtPath, FileMode.Create, FileAccess.Write);
                        stream.WriteTo(file1);
                        file1.Close();
                        stream.Close();


                        //Console.WriteLine("Creating");
                        //File.Create(Path);
                        //TextWriter tw = new StreamWriter(Path);
                        //tw.WriteLine("The very first line!");
                        //tw.Close();
                        //tw.Dispose();
                    }
                }

                //close Data Reader
                dataReader.Close();
            }
            catch (Exception e1)
            {
                Console.WriteLine("Error: Could not execute database command - " + e1.Message);
            }
        }
    }
}

