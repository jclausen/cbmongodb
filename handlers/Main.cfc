/**
* My Event Handler Hint
*/
component{

	// Index
	any function index1( event,rc, prc ){
		
		return "welcome to mongo module app";
	}
	
	public function index(event,rc,prc){	
		event.setView("main/index");
	}
	
	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}