<cfcomponent output="false" hint="My App Configuration">
<cfscript>
	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Development Shell",

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
			ApplicationHelper 				= "",
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
		    permitAPI = true
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
						filename = coldbox.appName, filePath="/#appMapping#/logs"
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
