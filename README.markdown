MaxMindGeoIP - CFWheels
========================

[maxmind]: http://www.maxmind.com/ "MaxMind"
[jardownload]: http://sourceforge.net/projects/wurfl/ "Download jars"

[MaxMind][maxmind] provides both free and paid databases that let you look up location information of a user based on their IP address. This plugin is a wrapper for the Java API they provide for interacting with their database. They freely provide a database which will let you identify the country for the IP address: [http://www.maxmind.com/app/geolitecountry](http://www.maxmind.com/app/geolitecountry) and a database which goes down to the city level: [http://www.maxmind.com/app/geolitecity](http://www.maxmind.com/app/geolitecity).

Installation
------------
Before using the plugin, you need to add the MaxMind jar file into your class path (e.g. the `lib/` folder in tomcat). Because of the way that they distribute it, you'll need to build this from source. They provide instructions in the download for compiling. This can be found here: [http://www.maxmind.com/app/java](http://www.maxmind.com/app/java)  You will need to restart your CF server to load it. Make sure you download one of the database files - depending on your needs. You can only use one database at a time.

Since the API needs to know where your database file is, you'll need to set this in you settings. Go to `settings.cfm` in the `config` folder and add this entry:

	set(geoDBCacheType="0");
	set(geoDBLocation="/Path/To/GeoLiteCity.dat");
	
The CacheType setting refers to how the database file is cached. I recommend leaving it as `0` which keeps the entire index in memory. Optionally you can also set a fallback location for loading the database if the first cannot be loaded (e.g. in case you're reading over the network).

	set(geoDBLocationFallBack="/Path/To/Fallback/GeoLiteCity.dat");
	
You should be ready to start using the wrapper functions. Please note that the MaxMind index is rather large, so the java object is stored in the server scope for fast access, and would be used across all sites using it on your server. It may be slow on first usage depending on your setup.

Usage
----------

The MaxMind plugin exposes all of the methods that the java API provides. These are injected globally, so you should be able to access them everywhere. It's important to realize that some of these functions only work if you provide the right database. Otherwise, you may get errors.

### `getMMDatabaseInfo()`

Returns the database info for the currently loaded database.
	
### `getIDByIP([ip])`

Get the ID that maxmind uses for the IP address. Optionally pass in an IP. Defaults to `cgi.REMOTE_ADDR`.

### `getCountryByIP([ip])`

Get the country information for an IP. Optionally pass in an IP. Defaults to `cgi.REMOTE_ADDR`. This should be used when using the CountryLite database.

### `getRegionByIP([ip])`

Get the region information by IP address. Optionally pass in an IP. Defaults to `cgi.REMOTE_ADDR`.

### `getOrgByIP([ip])`

Get organization information by IP. Optionally pass in an IP. Defaults to `cgi.REMOTE_ADDR`.

### `getLocationByIP([ip])`

Get the location information for an IP. Optionally pass in an IP. Defaults to `cgi.REMOTE_ADDR`. This should be used when using the CityLite database.

### `getIPDistance(toIP,[fromIP])`

Calculates the physical difference between IPs. Optionally pass in a from IP. Defaults to `cgi.REMOTE_ADDR`.

### `reinitializeMM()`

Re-initialize the MaxMind database.

Building From Source
--------------------

	rake build

History
------------

Version 0.1 - Initial Release

Version 0.1.1 - Fixed issue with variables not being wrapped in ##

Version 0.2 - Index now reloads on application reload