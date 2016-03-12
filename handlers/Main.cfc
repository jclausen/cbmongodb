/**
* My Event Handler Hint
*/
component{
	property name="People" inject="id:People@CBMongoTestMocks";

	// Index
	any function index1( event,rc, prc ){
		
		return "welcome to mongo module app";
	}
	
	public function index(event,rc,prc){	
		event.setView("main/index");
	}
	
	public function test(event,rc,prc){	
		writedump(People);
		abort;
		event.setView("main/index");
	}

	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}