from pprint import pprint
import requests
from time import gmtime, strftime, localtime
print(strftime("%Y-%m-%d %H:%M:%S", localtime()))
r = requests.get('http://api.openweathermap.org/data/2.5/weather?q=London&appid=f3aee7c3b6bfb084ec625bc705b28192')
jsonres = r.json()
pprint(jsonres)