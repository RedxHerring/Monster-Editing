from internetarchive import get_item
import configparser
import os
# Having pip installed internetarchive, we use ia configure to create a file connecting our account with its access and secret keys
config = configparser.ConfigParser()
# Make sure to run python as the user where the config file is stored
config_fullname = fr'{os.path.expanduser("~")}/.config/internetarchive/ia.ini'
print(f'Opening {config_fullname}')
config.readfp(open(config_fullname))

my_access_key = config.get('s3', 'access')
my_secret_key = config.get('s3', 'secret')
item = get_item('details/monster-upscale-devel')
md = {'collection': 'community_movies', 'title': 'Development Page for Monster Upscale', 'mediatype': 'movies'}
r = item.upload(files=['Output/Monster_-_Chapter_01_-_Herr_Dr._Tenma.mkv'], metadata=md, access_key=my_access_key, secret_key=my_secret_key)
print(r[0].status_code)
