/**
*
* Mongo Client
*
* Maintains the Database Connection via the Native Driver
*
* @singleton
* @package cbmongodb.models.Mongo
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
*/
component name="MongoClient" accessors=true singleton{
	/**
	 * Init Properties
	 **/
	property name="db";
	property name="MongoConfig";
	property name="WCConfig";
	property name="WriteConcern";
	property name="ReadPreference";
	property name="collections";
	//injected properties
	/**
	 * Wirebox
	 **/
	property name="wirebox" inject="wirebox";
	/**
	* CBJavaloader
	**/
	property name="jLoader" inject="loader@cbjavaloader";
	/**
	 * Utility Class
	 **/
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	

	public function init(MongoConfig){
		this.setMongoConfig(ARGUMENTS.MongoConfig);
		if(isNull(getWirebox()) and structKeyExists(application,'wirebox')){
			application.wirebox.autowire(target=this,targetID="MongoClient@cbmongodb");
		} else {
			throw('Wirebox IOC Injection is required to user this service');
		}

		//The core mongo client connection
		VARIABLES.mongo = jLoader.create('com.mongodb.MongoClient');
		//VARIABLES.mongo = jLoader.create('com.mongodb.async.client.MongoClient');
		//WriteConcern Config
		VARIABLES.WriteConcern = jLoader.create("com.mongodb.WriteConcern");
		//Read Preference Configuration
		VARIABLES.ReadPreference = jLoader.create("com.mongodb.ReadPreference");

		VARIABLES.db = connect(VARIABLES.mongoConfig.getDbName());
		
		initCollections();
		return this;

	}

	/**
	* Our connection to the Mongo Server
	**/
	private function connect(required dbName=getMongoConfig().getDBName()){

		var MongoDb = VARIABLES.mongo;
		
		if(structKeyExists(MongoConfig,'auth') and len(MongoConfig.auth.username) and len(MongoConfig.auth.password)){
		
			var MongoCredentials = jLoader.create('java.util.ArrayList');
			var MongoServers = jLoader.create('java.util.ArrayList');
		
			 for (var mongoServer in MongoConfig.servers){
			 	MongoServers.add(mongoServer);
			 	MongoCredentials.add(createCredential(MongoConfig.auth.username,structKeyExists(MongoConfig.auth,'db')?javacast('string',MongoConfig.auth.db):javacast('string','admin'),MongoConfig.auth.password.toCharArray()));
			 }
		
			 MongoDb.init(MongoServers ,MongoCredentials, getMongoConfig().getMongoClientOptions() );
		
		} else {
			
			MongoDb.init( VARIABLES.mongoConfig.getServers(), getMongoConfig().getMongoClientOptions() );
		
		}

		return MongoDb.getDatabase(ARGUMENTS.dbName);

	}

	/**
	* Gets a CFMongoDB DBCollection object, which wraps the java DBCollection
	**/
	function getDBCollection( collectionName, dbName=getMongoConfig().getDBName() ){

		if(!structkeyexists(VARIABLES.collections, dbName)) VARIABLES.collections[dbName]={};

		if(!structKeyExists( VARIABLES.collections[dbName], collectionName ) ){

			//each collection receives their own connection
			VARIABLES.collections[ dbName ][ collectionName ] = Wirebox.getInstance("MongoCollection@cbmongodb").init(getDb().getCollection(collectionName));
			
		}

		return VARIABLES.collections[ dbName ][ collectionName ];
	}


	private function createCredential(required string username,required string password, required authDB='admin'){
		var MongoCredential = jLoader.create('com.mongodb.MongoCredential');
		var credential = MongoCredential.createCredential(javacast('string',username),javacast('string',ARGUMENTS.authDB),ARGUMENTS.password.toCharArray());
		return credential;
	}


	private function initCollections(){
		var dbName = getMongoConfig().getDBName();
		VARIABLES.collections = { '#dbName#' = {} };
	}


	/**
	*  Adds a user to the database
	*/
	function addUser( string username, string password) {
		getMongoDB( VARIABLES.mongoConfig ).addUser(ARGUMENTS.username, ARGUMENTS.password.toCharArray());
		return this;
	}

	/**
	* Drops the database currently specified in MongoConfig
	*/
	function dropDatabase() {
		VARIABLES.mongo.dropDatabase(VARIABLES.mongoConfig.getDBName());
		return this;
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
			VARIABLES.mongo.close();
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
		if(isSimpleValue(ARGUMENTS.mongoConfig)){
			mongoConfig = VARIABLES.mongoConfig;
		}
		return mongoConfig;
	}

	/**
	 * Get the underlying Java driver's Mongo object
	 */
	function getMongo(){
		return VARIABLES.mongo;
	}

	/**
	 * Get the underlying Java driver's DB object
	 */
	function getMongoDB( mongoConfig="" ){
		return getMongo().getDb(getMongoConfig().getDefaults().dbName);
	}


}