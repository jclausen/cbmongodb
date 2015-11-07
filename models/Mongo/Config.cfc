/**
*
* Mongo Config
*
* The configuration object passed to MongoDB
*
* @singleton
* @package cbmongodb.models.Mongo
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
*/
component accessors="true" output="false" hint="Main configuration for MongoDB Connections"{
	/**
	* CBJavaloader
	**/
	property name="jLoader" inject="jl@cbjavaloader";
	variables.conf = {};


	 /**
	 * Constructor
	 * @hosts Defaults to [{serverName='localhost',serverPort='27017'}]
	 */
	 public function init(configStruct){
	 	if(isNull(jLoader)){
	 		application.wirebox.autowire(this);
	 	}
	 	var hosts = structKeyExists(configStruct,'hosts')?configStruct.hosts: [{serverName='localhost',serverPort='27017'}]
	 	var dbName= configStruct.db 
	 	var MongoClientOptions=structKeyExists(configStruct,'clientOptions')?configStruct.clientOptions:{};


	 	establishHostInfo();
	 	
	 	var auth = {
	 		username:structKeyExists(hosts[1],'username')?hosts[1].username:"",
	 		password:structKeyExists(hosts[1],'password')?hosts[1].password:""
	 	}
	 	if(structKeyExists(hosts[1],'authenticationDB')) auth['db']=hosts[1].authenticationDB;

		variables.conf = { dbname = dbName, servers = createObject("java",'java.util.ArrayList').init(), auth=auth};

		var item = "";
	 	for(item in hosts){
	 		addServer( item.serverName, item.serverPort );
	 	}
		//turn the struct of MongoClientOptions into a proper object
		buildMongoClientOptions( mongoClientOptions );

		//main entry point for environment-aware configuration; subclasses should do their work in here
		environment = configureEnvironment();

	 	return this;
	 }

	 public function addServer(serverName, serverPort){
	 	var sa = createObject("java","com.mongodb.ServerAddress").init( serverName, serverPort );
	 	variables.conf.servers.add( sa );
		return this;
	 }

	 public function removeAllServers(){
	 	variables.conf.servers.clear();
	 	return this;
	 }

     public function establishHostInfo(){
		// environment decisions can often be made from this information
		var inetAddress = createObject( "java", "java.net.InetAddress");
		variables.hostAddress = inetAddress.getLocalHost().getHostAddress();
		variables.hostName = inetAddress.getLocalHost().getHostName();
		return this;
	}

	function buildMongoClientOptions( struct mongoClientOptions ){
		var builder = createObject("java","com.mongodb.MongoClientOptions$Builder");

		for( var key in mongoClientOptions ){
			var arg = mongoClientOptions[key];
			evaluate("builder.#key#( arg )");
		}

		variables.conf.MongoClientOptions = builder.build();
		return variables.conf.MongoClientOptions;
	}

	 /**
	 * Main extension point: do whatever it takes to decide environment;
	 * set environment-specific defaults by overriding the environment-specific
	 * structure keyed on the environment name you decide
	 */
	 public string function configureEnvironment(){
	 	//overriding classes could do all manner of interesting things here... read config from properties file, etc.
	 	return "local";
	 }

	 public string function getDBName(){ return getDefaults().dbName; }

	 public Array function getServers(){return getDefaults().servers; }

	 public function getMongoClientOptions(){
	 	if( not structKeyExists(getDefaults(), "mongoClientOptions") ){
	 		buildMongoClientOptions({});
	 	}
	 	return getDefaults().mongoClientOptions;
	 }

	 public struct function getDefaults(){ return conf; }


}
