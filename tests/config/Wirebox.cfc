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
			var javaloaderFactory = createObject('component','cfmongodb.core.JavaloaderFactory').init();
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
			var MongoConfig = createObject('component','cbmongodb.config.MongoConfig').init(hosts=configStruct.MongoDB.hosts,dbName=configStruct.MongoDB.db, mongoFactory=javaloaderFactory);
		
			//mappings
			map( "MongoClient@cfMongoDB" )
			.to( "cfmongodb.core.MongoClient" )
			.initWith(MongoConfig);
			
			map("ActiveEntityMock@MongoDB")
			.to("cbmongodb.tests.mocks.ActiveEntityMock");
	}	

}