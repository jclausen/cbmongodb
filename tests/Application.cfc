<cfcomponent output="false">

	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = "cbmongodbTesting" & hash(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,0,0)>
	<cfset this.setClientCookies = true>

	<cfscript>
	COLDBOX_APP_ROOT_PATH = expandPath('/');
	this.mappings['/testbox'] = COLDBOX_APP_ROOT_PATH & 'testbox';
	</cfscript>

	<!--- Create testing mapping --->
	<cfset this.mappings[ "/cbmongodb" ] = expandPath('../')>
	<cfset this.mappings[ "/cfmongodb" ] = expandPath('../modules/cfmongodb')>
	<cfset this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() )>
	<!--- Map back to its root --->
	<cfset rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" )>
	<cfset this.mappings["/root"]   = rootPath>

</cfcomponent>