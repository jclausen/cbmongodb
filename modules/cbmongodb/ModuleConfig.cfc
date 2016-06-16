/**
*
* <strong>CFMongoDB Module Configuration</strong>
*
* <p>An Active Entity Module for MongoDB</p>
*
* @author Jon Clausen <jon_clausen@silowebworks.com>
*
* @link https://github.com/jclausen/cbmongodb
*/
component {
	
	// Module Properties
	this.title 				= "CBMongoDB";
	this.author 			= "Jon Clausen";
	this.webURL 			= "https://github.com/jclausen/cbmongodb";
	this.description 		= "Coldbox SDK and Virtual Entity Service for MongoDB";
	// Our version changes with the driver version used, only the patch is updated without a full driver updated
	this.version			= "3.2.0.4";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= false;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = false;
	// Module Entry Point
	this.entryPoint			= "cbmongodb";
	// Model Namespace to use
	this.modelNamespace		= "cbmongodb";
	// Auto Map Models Directory
	this.autoMapModels		= false;
	// CF Mapping to register
	this.cfmapping			= "cbmongodb";
	// Module Dependencies to be loaded in order
	this.dependencies 		= ['cbjavaloader'];
	
	MongoDBConfig = "";
	
	function configure(){

		// Java Loader Settings
		settings = {

		};

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [
		];

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		//Retrieve our module settings
		parseParentSettings();
		
		//ensure cbjavaloader is an activated module
		if(!Wirebox.getColdbox().getModuleService().isModuleActive('cbjavaloader')){
			Wirebox.getColdbox().getModuleService().reload('cbjavaloader');	
		}
		
		// load MongoDB jars
		wirebox.getInstance("loader@cbjavaloader").appendPaths(expandPath("/cbmongodb") & "/lib");
		
		/**
		* Main Configuration Object Singleton
		**/
		binder.map("MongoConfig@cbmongodb")
			.to('#moduleMapping#.models.Mongo.Config')
			.initWith(configStruct=variables.MongoDBConfig)
			.threadSafe()
			.asSingleton();

		/**	
		* Utility Classes
		**/

		//models.Mongo.Util
		binder.map("MongoUtil@cbmongodb")
			.to("#moduleMapping#.models.Mongo.Util")
			.asSingleton();

		//indexer
		binder.map("MongoIndexer@cbmongodb")
			.to("#moduleMapping#.models.Mongo.Indexer")
			.asSingleton();

		/**
		* Manual Instantiation Instances
		**/

		//models.Mongo.Collection
		binder.map("MongoCollection@cbmongodb")
			.to('#moduleMapping#.models.Mongo.Collection')
			.noInit();


		//models.Mongo.GridFS
		binder.map("GridFS@cbmongodb")
			.to('#moduleMapping#.models.Mongo.GridFS');

		/**
		* The Mongo Client Singleton
		**/
		binder.map( "MongoClient@cbmongodb" )
			.to( "#moduleMapping#.models.Mongo.Client" )
			.threadSafe()
			.asSingleton();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
		if(Wirebox.containsInstance("MongoClient@cbmongodb")){
			Wirebox.getInstance("MongoClient@cbmongodb").close();		
		}
	}

	/**
	* Prepare settings for MongoDB Connections.
	*/
	private function parseParentSettings(){
		var oConfig 			= controller.getSetting( "ColdBoxConfig" );
		var configStruct 		= controller.getConfigSettings();
		var MongoDBSettings		= oConfig.getPropertyMixin( "MongoDB", "variables", {} );

		
		//check if a config has been misplaced within the custom settings structure
		if(structIsEmpty(MongoDbSettings) and structKeyExists(configStruct,"MongoDB")){
			MongoDBSettings = duplicate(configStruct.MongoDB);
		}		
			
		//default config struct
		configStruct.MongoDB = {
			//The default hosts
			hosts		= [
							{
								serverName:'127.0.0.1',
								serverPort:'27017'
							}
							
						  ],
			//the default client options
			clientOptions = {
				//The connection timeout in ms (if omitted, the timeout is 30000ms)
				"connectTimeout":2000
			},
			//The default database
			db 	= "test",
			//whether to permit viewing of the API documentation
			permitDocs = true,
			//whether to permit unit tests to run
			permitTests = true,
			//whether to permit generic API access (future implementation)
			permitAPI = true,
			//GridFS settings - this key is omitted by default
			GridFS = {
				"imagestorage":{
					//whether to store the cfimage metadata
					"metadata":true,
					//the max allowed width of images in the GridFS store
					"maxwidth":1000,
					//the max allowed height of images in the GridFS store
					"maxheight":1000,
					//The path within the site root with trailing slash to use for resizing images (required if maxheight or max width are specified)
					"tmpDirectory":"/cbmongodb/tmp/"
				}
			}
		};

		// Incorporate settings
		structAppend( configStruct.MongoDB, MongoDBSettings, true );

		variables.MongoDBConfig = configStruct.MongoDB;

	}

}
