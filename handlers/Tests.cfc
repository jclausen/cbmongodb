component extends="coldbox.system.EventHandler"{

	public function preHandler(event,action,eventArguments){
		var MongoSettings = getSetting("MongoDB");
		if(structKeyExists(MongoSettings,'permitTests') && !MongoSettings.permitTests) {
			header statusCode=405 statusText="Not Allowed";
			writeOutput("Module Testing is Currently Disabled.");
			flush;
			abort;
		}
	}

	public function index(event,rc,prc){
		
		event.noLayout();
		event.setView("../tests/runner");
	}
}