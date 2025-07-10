/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// Module Properties
	this.title       = "cbmongodb";
	this.author      = "Jon Clausen<jclausen@ortussolutions.com>";
	this.webURL      = "https://forgebox.io/view/cbmongodb";
	this.description = "cbmongodb";
	this.version     = "@build.version@+@build.number@";

	// Model Namespace
	this.modelNamespace = "cbmongodb";

	// CF Mapping
	this.cfmapping = "cbmongodb";

	// Dependencies
	this.dependencies = [ "cbjavaloader" ];

	/**
	 * Configure Module
	 */
	function configure(){
		settings = {
			// The default hosts
			hosts         : [ { serverName : "127.0.0.1", serverPort : "27017" } ],
			// the default client options
			clientOptions : {
				// The connection timeout in ms (if omitted, the timeout is 30000ms)
				"connectTimeout" : 2000
			},
			// The default database
			db          : "test",
			// whether to permit viewing of the API documentation
			permitDocs  : true,
			// whether to permit unit tests to run
			permitTests : true,
			// whether to permit generic API access (future implementation)
			permitAPI   : true,
			// GridFS settings - this key is omitted by default
			GridFS      : {
				"imagestorage" : {
					// whether to store the cfimage metadata
					"metadata"     : true,
					// the max allowed width of images in the GridFS store
					"maxwidth"     : 1000,
					// the max allowed height of images in the GridFS store
					"maxheight"    : 1000,
					// The path within the site root with trailing slash to use for resizing images (required if maxheight or max width are specified)
					"tmpDirectory" : "/cbmongodb/tmp/"
				}
			}
		};
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){
		// ensure cbjavaloader is an activated module
		if (
			!Wirebox
				.getColdbox()
				.getModuleService()
				.isModuleActive( "cbjavaloader" )
		) {
			Wirebox
				.getColdbox()
				.getModuleService()
				.reload( "cbjavaloader" );
		}

		// load MongoDB jars
		wirebox.getInstance( "loader@cbjavaloader" ).appendPaths( expandPath( "/cbmongodb" ) & "/lib" );

		/**
		 * Main Configuration Object Singleton
		 **/
		binder
			.map( "MongoConfig@cbmongodb" )
			.to( "#this.cfmapping#.models.Mongo.Config" )
			.initWith( configStruct = variables.settings )
			.threadSafe()
			.asSingleton();

		/**
		 * Utility Classes
		 **/

		// models.Mongo.Util
		binder
			.map( "MongoUtil@cbmongodb" )
			.to( "#this.cfmapping#.models.Mongo.Util" )
			.asSingleton();

		// indexer
		binder
			.map( "MongoIndexer@cbmongodb" )
			.to( "#this.cfmapping#.models.Mongo.Indexer" )
			.asSingleton();

		/**
		 * Manual Instantiation Instances
		 **/

		// models.Mongo.Collection
		binder
			.map( "MongoCollection@cbmongodb" )
			.to( "#this.cfmapping#.models.Mongo.Collection" )
			.noInit();


		// models.Mongo.GridFS
		binder.map( "GridFS@cbmongodb" ).to( "#this.cfmapping#.models.Mongo.GridFS" );

		/**
		 * The Mongo Client Singleton
		 **/
		binder
			.map( "MongoClient@cbmongodb" )
			.to( "#this.cfmapping#.models.Mongo.Client" )
			.threadSafe()
			.asSingleton();
	}

	/**
	 * Fired when the module is unregistered and unloaded
	 */
	function onUnload(){
		if ( Wirebox.containsInstance( "MongoClient@cbmongodb" ) ) {
			Wirebox.getInstance( "MongoClient@cbmongodb" ).close();
		}
	}

}
