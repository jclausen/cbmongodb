component name="MongoClient" accessors=true singleton{
	property name="MongoConfig";
	property name="collections";
	//injected properties
	/**
	 * Wirebox
	 **/
	property name="wirebox" inject="wirebox";
	/**
	 * Utility Class
	 **/
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	/**
	 * Java Mongo Client
	 **/
	property name="mongo" inject="JClient@cbmongodb";

	public function init(MongoConfig="#createObject('MongoConfig')#"){
		this.setMongoConfig(arguments.MongoConfig);
		initCollections();
		return this;

	}


	private function initCollections(){
		var dbName = getMongoConfig().getDBName();
		variables.collections = { dbName = {} };
	}

	/**
	* Authenticates connection/db with given name and password

		Typical usage:
		mongoConfig.init(...);
		mongo = new Mongo( mongoConfig );
		mongo.authenticate( username, password );

		If authentication fails, an error will be thrown
	*
	*/
	void function authenticate( string username, string password ){
		var result = {authenticated = false, error={}};
		result.authenticated = getMongoDB( variables.mongoConfig ).authenticateCommand( arguments.username, arguments.password.toCharArray() );
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
			variables.collections[ dbName ][ collectionName ] = createObject("component", "DBCollection" ).init( collectionName, this, dbName );
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