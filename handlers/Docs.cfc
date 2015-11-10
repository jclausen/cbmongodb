component extends="coldbox.system.EventHandler"{

	public function preHandler(event,action,eventArguments){
		var MongoSettings = getSetting("MongoDB");
		if(structKeyExists(MongoSettings,'permitDocs') && !MongoSettings.permitDocs) {
			header statusCode=405 statusText="Not Allowed";
			writeOutput("API Doc Viewing and Generation is Currently Disabled.");
			flush;
			abort;
		}
	}

	public function index(event,rc,prc){
		setNextEvent(url='/modules/cbmongodb/apidocs/index.html');
	}

	public function update(event,rc,prc){
		event.noLayout();
		event.setView("../apidocs/generator");
	}
}