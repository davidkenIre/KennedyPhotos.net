# Docs
# https://qbittorrent-api.readthedocs.io/en/latest/

# TODO

# Dependancies
# pip install qbittorrent-api

# Imports
import qbittorrentapi

# instantiate a Client using the appropriate WebUI configuration
# qbt_client = qbittorrentapi.Client(host='localhost:8080', username='admin', password='adminadmin')
qbt_client = qbittorrentapi.Client(host='localhost:8085')

# the Client will automatically acquire/maintain a logged in state in line with any request.
# therefore, this is not necessary; however, you many want to test the provided login credentials.
try:
    qbt_client.auth_log_in()
except qbittorrentapi.LoginFailed as e:
    print(e)

# display qBittorrent info
print('qBittorrent: {qbt_client.app.version}')
print('qBittorrent Web API: {qbt_client.app.web_api_version}')
for k,v in qbt_client.app.build_info.items(): print(f'{k}: {v}')

# retrieve and show all torrents
for torrent in qbt_client.torrents_info():
    print('{torrent.hash[-6:]}: {torrent.name} ({torrent.state})')
    # Remove Complete Files
    if torrent.state_enum.is_complete:
        print('Removing {torrent.hash[-6:]}: {torrent.name} ({torrent.state})')
        torrent.delete(delete_files='None')

# Resume all torrents
qbt_client.torrents.resume.all()

