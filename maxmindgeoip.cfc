<cfcomponent displayname="MaxMindGeoIP Helper" output="false">
	
	<cffunction name="init">
        <cfset this.version = "1.1,1.1.1,1.1.2">
		<cfif structKeyExists(server,"MMLookupService")>
			<cflock timeout="5" scope="server">
				<cfset structDelete(server,"MMLookupService")/>
			</cflock>
		</cfif>
        <cfreturn this>
    </cffunction>
	
	<cffunction name="getMMDatabaseInfo" returntype="any">
		<cflock timeout="5" scope="server">
			<cfscript>
				jDBInfo = $getLookupService().getDatabaseInfo();
			
				dbInfo = structNew();
				if(!isNull(jDBInfo)){
					dbInfo.COUNTRY_EDITION = jDBInfo.COUNTRY_EDITION;
					dbInfo.REGION_EDITION_REV0 = jDBInfo.REGION_EDITION_REV0;
					dbInfo.REGION_EDITION_REV1 = jDBInfo.REGION_EDITION_REV1;
					dbInfo.CITY_EDITION_REV0 = jDBInfo.CITY_EDITION_REV0;
					dbInfo.CITY_EDITION_REV1 = jDBInfo.CITY_EDITION_REV1;
					dbInfo.ORG_EDITION = jDBInfo.ORG_EDITION;
					dbInfo.ISP_EDITION = jDBInfo.ISP_EDITION;
					dbInfo.PROXY_EDITION = jDBInfo.PROXY_EDITION;
					dbInfo.ASNUM_EDITION = jDBInfo.ASNUM_EDITION;
					dbInfo.NETSPEED_EDITION = jDBInfo.NETSPEED_EDITION;
					dbInfo.COUNTRY_EDITION_V6 = jDBInfo.COUNTRY_EDITION_V6;
				}
			</cfscript>
		</cflock>
		
		<cfreturn dbInfo/>
	</cffunction>
	
	<cffunction name="getIDByIP" returntype="any">
		<cfargument name="ip" type="string" default="#cgi.REMOTE_ADDR#"/>
		
		<cflock timeout="5" scope="server">
			<cfset ret = $getLookupService().getID(arguments.ip)/>
		</cflock>
		
		<cfreturn ret/>
	</cffunction>
	
	<cffunction name="getCountryByIP" returntype="any">
		<cfargument name="ip" type="string" default="#cgi.REMOTE_ADDR#"/>
		
		<cflock timeout="5" scope="server">
			<cfscript>
				jCountry = $getLookupService().getCountry(arguments.ip);
			
				country = structNew();
				if(!isNull(jCountry)){
					country["name"] = jCountry.getName();
					country["code"] = jCountry.getCode();
				}
			</cfscript>
		</cflock>
		
		<cfreturn country/>
	</cffunction>
	
	<cffunction name="getRegionByIP" returntype="any">
		<cfargument name="ip" type="string" default="#cgi.REMOTE_ADDR#"/>
		
		<cflock timeout="5" scope="server">
			<cfscript>
				jRegion = $getLookupService().getRegion(arguments.ip);
			
				region = structNew();
				if(!isNull(jRegion)){
					region["countryCode"] = jRegion.countryCode;
					region["countryName"] = jRegion.countryName;
					region["region"] = jRegion.region;
				}
			</cfscript>
		</cflock>
		
		<cfreturn region/>
	</cffunction>
	
	<cffunction name="getOrgByIP" returntype="any">
		<cfargument name="ip" type="string" default="#cgi.REMOTE_ADDR#"/>
		
		<cflock timeout="5" scope="server">
			<cfset ret = $getLookupService().getOrg(arguments.ip)/>
		</cflock>
		
		<cfreturn ret/>
	</cffunction>
	
	<cffunction name="getLocationByIP" returntype="any">
		<cfargument name="ip" type="string" default="#cgi.REMOTE_ADDR#"/>
		
		<cflock timeout="5" scope="server">
			<cfscript>
				jLocation = $getLookupService().getLocation(arguments.ip);
			
				location = structNew();
				if(!isNull(jLocation)){
					location["countryCode"] = jLocation.countryCode;
					location["countryName"] = jLocation.countryName;
					location["region"] = jLocation.region;
					location["city"] = jLocation.city;
					location["postalCode"] = jLocation.postalCode;
					location["latitude"] = jLocation.latitude;
					location["longitude"] = jLocation.longitude;
					location["dma_code"] = jLocation.dma_code;
					location["area_code"] = jLocation.area_code;
					location["metro_code"] = jLocation.metro_code;
				}
			</cfscript>
		</cflock>
		
		<cfreturn location/>
	</cffunction>
	
	<cffunction name="getIPDistance" returntype="any">
		<cfargument name="toIP" type="string" required="true"/>
		<cfargument name="fromIP" type="string" default="#cgi.REMOTE_ADDR#"/>
		
		<cflock timeout="5" scope="server">
			<cfscript>
				jLocationT = $getLookupService().getLocation(arguments.toIP);
				jLocationF = $getLookupService().getLocation(arguments.fromIP);
			
				ret = jLocationF.distance(jLocationT);
			</cfscript>
		</cflock>
		
		<cfreturn ret/>
	</cffunction>

	<cffunction name="reinitializeMM" returntype="void">
		<cfscript>$getLookupService(true);</cfscript>
	</cffunction>
	
	<cffunction name="$getLookupService" returntype="any">
		<cfargument name="reinitialize" type="boolean" default="false"/>
		
		<cfif !isDefined("server.MMLookupService") OR arguments.reinitialize>
			<cflock timeout="20" scope="server">
				<!--- We need to create the wurfl manager --->
				<cfscript>
				
					datFile = "";
					cacheType = 0;
				
					try{
						cacheType = get('geoDBCacheType');
					}
					catch(any e){}
				
					try{
						if(FileExists(get('geoDBLocation'))){
							datFile = get('geoDBLocation');
						}
						else if(FileExists(get('geoDBLocationFallBack'))){
							datFile = get('geoDBLocationFallBack');
						}
						else{
							throw();
						}
					}
					catch(any e){
						throw(message="GeoLocation DB could not be found");
					}

					server.MMLookupService = createObject("java","com.maxmind.geoip.LookupService").init(datFile,JavaCast("int", cacheType));
				</cfscript>
			</cflock>
		</cfif>
		
		<cfreturn server.MMLookupService/>
		
	</cffunction>
	
</cfcomponent>