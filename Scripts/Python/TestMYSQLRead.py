#pip install mysql-connector



import datetime
import mysql.connector

cnx = mysql.connector.connect(user='root', password='',
                              host='lattuce-dc',
                              database='music')


cursor = cnx.cursor()

query = ("SELECT album_name,  song_name, path FROM song ")


cursor.execute(query)

for (album_name,  song_name, path) in cursor:
  print("{}, {}, {}".format(
   album_name,  song_name, path))

cursor.close()
cnx.close()