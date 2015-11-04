component name="MongoClient" accessors=true singleton{
	/**
	 * Init Properties
	 **/
	property name="db";
	property name="dbCollection";
	property name="MongoConfig";
	property name="collections";
	//injected properties
	/**
	 * Wirebox
	 **/
	property name="wirebox" inject="wirebox";
	/**
	* CBJavaloader
	**/
	property name="jLoader" inject="jl@cbjavaloader";
	/**
	 * Utility Class
	 **/
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	

	public function init(MongoConfig){
		this.setMongoConfig(arguments.MongoConfig);
		if(isNull(getWirebox()) and structKeyExists(application,'wirebox')){
			application.wirebox.autowire(target=this,targetID="MongoClient@cbmongodb");
		} else {
			throw('Wirebox IOC Injection is required to user this service');
		}

		
		variables.mongo = createObject('java','com.mongodb.MongoClient');

		if(structKeyExists(MongoConfig,'auth') and len(MongoConfig.auth.username) and len(MongoConfig.auth.password)){
			var MongoCredentials = createObject('java','java.util.ArrayList');
			var MongoServers = createObject('java','java.util.ArrayList');
			 for (var mongoServer in MongoConfig.servers){
			 	MongoServers.add(mongoServer);
			 	MongoCredentials.add(createCredential(MongoConfig.auth.username,structKeyExists(MongoConfig.auth,'db')?javacast('string',MongoConfig.auth.db):javacast('string','admin'),MongoConfig.auth.password.toCharArray()));
			 }
			 variables.mongo.init(MongoServers ,MongoCredentials, getMongoConfig().getMongoClientOptions() );
		} else {
			variables.mongo.init( variables.mongoConfig.getServers(), getMongoConfig().getMongoClientOptions() );
		}
		variables.db = variables.mongo.getDatabase(variables.mongoConfig.getDbName());
		
		initCollections();
		return this;

	}

	private function createCredential(required string username,required string password, required authDB='admin'){
		var MongoCredential = jLoader.create('com.mongodb.MongoCredential');
		var credential = MongoCredential.createCredential(javacast('string',username),javacast('string',arguments.authDB),arguments.password.toCharArray());
		return credential;
	}


	private function initCollections(){
		var dbName = getMongoConfig().getDBName();
		variables.collections = { '#dbName#' = {} };
	}


	/**
	*  Adds a user to the database
	*/
	function addUser( string username, string password) {
		getMongoDB( variables.mongoConfig ).addUser(arguments.username, arguments.password.toCharArray());
		return this;
	}

	/**
	* Drops the database currently specified in MongoConfig
	*/
	function dropDatabase() {
		variables.mongo.dropDatabase(variables.mongoConfig.getDBName());
		return this;
	}

	/**
	* Gets a CFMongoDB DBCollection object, which wraps the java DBCollection
	*/
	function getDBCollection( collectionName, dbName=getMongoConfig().getDBName() ){
		if( not structkeyexists(variables.collections, dbName) or not structKeyExists( variables.collections[dbName], collectionName ) ){
			variables.collections[ dbName ][ collectionName ] = this.getDB().getCollection(collectionName);
		}
		
		return variables.collections[ dbName ][ collectionName ];
	}


	/**
	* Closes the underlying mongodb object. Once closed, you cannot perform additional mongo operations and you'll need to init a new mongo.
	  Best practice is to close mongo in your Application.cfc's onApplicationStop() method. Something like:
	  getBeanFactory().getBean("mongo").close();
	  or
	  application.mongo.close()

	  depending on how you're initializing and making mongo available to your app

	  NOTE: If you do not close your mongo object, you WILL leak connections!
	*/
	function close(){
		try{
			variables.mongo.close();
		}catch(any e){
			//the error that this throws *appears* to be harmless.
			writeLog("Error closing Mongo: " & e.message);
		}
		return this;
	}

	/**
	* Returns the last error for the current connection.
	*/
	function getLastError()
	{
		return getMongoDB().getLastError();
	}


	/**
	* Decide whether to use the MongoConfig in the variables scope, the one being passed around as arguments, or create a new one
	*/
	function getMongoConfig(mongoConfig=""){
		if(isSimpleValue(arguments.mongoConfig)){
			mongoConfig = variables.mongoConfig;
		}
		return mongoConfig;
	}

	/**
	 * Get the underlying Java driver's Mongo object
	 */
	function getMongo(){
		return variables.mongo;
	}

	/**
	 * Get the underlying Java driver's DB object
	 */
	function getMongoDB( mongoConfig="" ){
		return getMongo().getDb(getMongoConfig().getDefaults().dbName);
	}


}