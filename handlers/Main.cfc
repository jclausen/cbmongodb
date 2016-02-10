/**
* My Event Handler Hint
*/
component{

	// Index
	any function index1( event,rc, prc ){
		
		return "welcome to mongo module app";
	}
	
	public function index(event,rc,prc){
	
		//writeDump(getInstance( name="MongoConfig@cbmongodb"));
		//writeDump(getInstance( name="MongoUtil@cbmongodb"));
		
		//writeDump(getInstance( name="MongoIndexer@cbmongodb"));
		//writeDump(getInstance( name="MongoCollection@cbmongodb"));
		//writeDump(getInstance( name="GridFS@cbmongodb"));


		//writeDump(getInstance("People@CBMongoTestMocks")); 
		//writeDump(getInstance("People@CBMongoTestMocks").getDbInstance());
		//writeDump(getInstance("Counties@CBMongoTestMocks"));
		//writeDump(getInstance("States@CBMongoTestMocks"));
		//writeDump(getInstance("Files@CBMongoTestMocks"));
		//abort;


		//return;	
		event.noLayout();
		event.setView(view="../tests/runner");
	}
	
	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}