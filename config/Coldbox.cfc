<cfcomponent output="false" hint="cbmongodb module Configuration">
<cfscript>
	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "cbmongodb-module",

			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,

			//Implicit Events
			defaultEvent			= "main.index",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "main.onAppInit",
			applicationEndHandler	= "",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",

			//Extension Points
			ApplicationHelper 			= "",
			coldboxExtensionsLocation 	= "",
			modulesExternalLocation		= [],
			pluginsExternalLocation 	= "",
			viewsExternalLocation		= "",
			layoutsExternalLocation 	= "",
			handlersExternalLocation  	= "",
			requestContextDecorator 	= "",

			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate		= "/coldbox/system/includes/BugReport.cfm",

			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= false,
			proxyReturnCollection 	= false
		};

		// custom settings
		settings = {
		};

		//Mongo DB settings
		MongoDB = {
		    //an array of servers to connect to
			hosts= [
				{
					serverName='127.0.0.1',
					serverPort='27017'
				}
			],
		    //The default database to connect to
		    db  = "test",
		    //whether to permit viewing of the API documentation
		    permitDocs = true,
		    //whether to permit unit tests to run
		    permitTests = true,
		    //whether to permit API access to the Generic API (future implementation)
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
					"tmpDirectory":"/tests/assets/tmp/"
				}
			}
		};
		
		// Activate WireBox
		wirebox = { enabled = true, singletonReload=false };

		// Module Directives
		modules = {
			//Turn to false in production, on for dev
			autoReload = false
		};

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				files={class="coldbox.system.logging.appenders.RollingFileAppender",
					properties = {
						filename = coldbox.appName, filePath="/logs"
					}
				}
			},
			// Root Logger
			root = { levelmax="ERROR", appenders="*" },
			// Implicit Level Categories
			info = [ "coldbox.system" ]
		};

		//Register interceptors as an array, we need order
		interceptors = [
			//SES
			{class="coldbox.system.interceptors.SES",
			 properties={}
			}
		];

	}
</cfscript>
</cfcomponent>
