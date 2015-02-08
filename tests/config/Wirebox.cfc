component extends="coldbox.system.ioc.config.Binder"{

	/**
	* Configure WireBox for integration tests
	*/
	function configure(){

		// The WireBox configuration structure DSL
		wireBox = {
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			// By default it registeres itself on application scope
			scopeRegistration = {
				enabled = true,
				scope   = "application", // server, cluster, session, application
				key		= "wireBox"
			},

			// DSL Namespace registrations
			customDSL = {
				// namespace = "mapping name"
			},

			// Custom Storage Scopes
			customScopes = {
				// annotationName = "mapping name"
			},

			// Package scan locations
			scanLocations = ['modules.cbmongodb','models'],

			// Stop Recursions
			stopRecursions = [],

			// Parent Injector to assign to the configured injector, this must be an object reference
			parentInjector = "",

			// Register all event listeners here, they are created in the specified order
			listeners = [
				// { class="", name="", properties={} }
			]
		};


			//defaults
			var configStruct.MongoDB = {
				hosts		= [
								{
									serverName='127.0.0.1',
									serverPort='27017'
								}
							  ],
				db 	= "unit_tests",
				viewTimeout	= "1000"
			};
			var MongoConfig = createObject('component','cbmongodb.config.MongoConfig').init(hosts=configStruct.MongoDB.hosts,dbName=configStruct.MongoDB.db);
			//mappings
			//configuration
			map("MongoConfig@cbmongodb").toValue(MongoConfig)
			.asSingleton();
			//core java client
			map("JClient@cbmongodb").toValue(
				createObject('java','com.mongodb.MongoClient').init(MongoConfig.getMongoClientOptions())
			).asSingleton();
			//client wrapper
			map("MongoUtil@cbmongodb")
				.to("cbmongodb.Mongo.Util")
				.initWith().asSingleton();

			map( "MongoClient@cfMongoDB" )
			.to( "cbmongodb.Mongo.Client" )
			.initWith(MongoConfig).asSingleton();


			map("Person")
			.to("cbmongodb.tests.mocks.ActiveEntityMock");
			map("State")
			.to("cbmongodb.tests.mocks.StatesMock");
			map("County")
			.to("cbmongodb.tests.mocks.CountiesMock");
	}

}