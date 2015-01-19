/**
* 
* <strong>CFMongoDB Module Configuration</strong>
* 
* <p>A modification of the cfmongodb library for use as a Coldbox Module</p>
* 
* @author Bill Shelton <bill@if.io>
* @author Marc Escher <marc.esher@gmail.com>
* @author Jon Clausen <jon_clausen@silowebworks.com>
* 
* @link https://github.com/jclausen/cfmongodb [coldbox/master]  
*/
component{

	// Module Properties
	this.title 				= "CFMongoDB";
	this.author 			= "Jon Clausen";
	this.webURL 			= "http://https://github.com/jclausen/cfmongodb";
	this.description 		= "ColdFusion SDK to interact with MongoDB NoSQL Server";
	this.version			= "1.1.0.00074";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "cbmongodb";
	// Model Namespace to use
	this.modelNamespace		= "cbmongodb";
	// CF Mapping to register
	this.cfmapping			= "cbmongodb";
	// Module Dependencies to be loaded in order
	this.dependencies 		= [];

	/**
	* Fired on Module Registration
	*/
	function configure(){
		// Map Config
		binder.map( "MongoDBConfig" )
			.to( "cfMongoDB.config.MongoDBConfig" );
	}

	/**
	* Fired when the module is activated.
	*/
	function onLoad(){
		var configStruct = controller.getConfigSettings();
		var javaloaderFactory = createObject('component','cfmongodb.core.JavaloaderFactory').init();
		// parse parent settings
		parseParentSettings();
		// Configure
		var MongoConfig = createObject('component','cbmongodb.config.MongoConfig').init(hosts=configStruct.MongoDB.hosts,dbName=configStruct.MongoDB.db, mongoFactory=javaloaderFactory);
		// Map our MongoDB Client using per-environment settings.
		binder.map( "MongoClient@cfMongoDB" )
			.to( "cfmongodb.core.MongoClient" )
			.initWith(MongoConfig=MongoConfig)
			.asSingleton();
	}

	/**
	* Fired when the module is unloaded
	*/
	function onUnload(){
		// safely destroy connection
		wirebox.getInstance( "MongoClient@cfMongoDB" ).close();
	}

	/**
	* Prepare settings and returns true if using i18n else false.
	*/
	private function parseParentSettings(){
		var oConfig 		= controller.getSetting( "ColdBoxConfig" );
		var configStruct 	= controller.getConfigSettings();
		var MongoDB 		= oConfig.getPropertyMixin( "MongoDB", "variables", structnew() );

		//defaults
		configStruct.MongoDB = {
			hosts		= [
							{
								serverName='127.0.0.1',
								serverPort='27017'
							}
						  ],
			db 	= "local",
			viewTimeout	= "1000"
		};

		//Check for IOC Framework
		structAppend( configStruct.MongoDB, MongoDB, true );
		
	}

}