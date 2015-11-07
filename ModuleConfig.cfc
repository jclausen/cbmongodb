/**
*
* <strong>CFMongoDB Module Configuration</strong>
*
* <p>An Active Entity Module for MongoDB</p>
*
* @author Jon Clausen <jon_clausen@silowebworks.com>
*
* @link https://github.com/jclausen/cfmongodb [coldbox/master]
*/
component{

	// Module Properties
	this.title 				= "CBMongoDB";
	this.author 			= "Jon Clausen";
	this.webURL 			= "http://https://github.com/jclausen/cbmongodb";
	this.description 		= "Coldbox SDK and Virtual Entity Service for MongoDB";
	this.version			= "0.1";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= false;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = false;
	// Module Entry Point
	this.entryPoint			= "cbmongodb";
	// Model Namespace to use
	this.modelNamespace		= "cbmongodb";
	// CF Mapping to register
	this.cfmapping			= "cbmongodb";
	// Module Dependencies to be loaded in order
	this.dependencies 		= ['cbjavaloader'];

	/**
	* Fired on Module Registration
	*/
	function configure(){
		//mappings
		binder.map( "jl@cbjavaloader" )
			.to( "cbjavaloader.models.javaloader.JavaLoader" )
			.initArg( name="loadPaths",value=[expandPath('../lib')]);
		/**	
		* Utility Classes
		**/
		//utility class
		binder.map("MongoUtil@cbmongodb")
			.to("cbmongodb.models.Mongo.Util")
			.initWith().asSingleton();

		//collection wrapper
		binder.map("MongoCollection@cbmongodb")
			.to('cbmongodb.models.Mongo.Collection');

		/**
		* Singletons
		**/
		//configuration object
		binder.map("MongoConfig@cbmongodb")
			.to('cbmongodb.models.Mongo.Config')
			.initWith(configStruct.MongoDB)
			.asSingleton();

		//core client
		binder.map( "MongoClient@cbmongodb" )
		.to( "cbmongodb.models.Mongo.Client" )
		.initArg(name="MongoConfig",ref="MongoConfig@cbmongodb")
		.asSingleton();

	}

	/**
	* Fired when the module is activated.
	*/
	function onLoad(){}

	/**
	* Fired when the module is unloaded
	*/
	function onUnload(){}

}