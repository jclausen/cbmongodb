component extends="coldbox.system.EventHandler"{

	public function index(event,rc,prc){
		event.noLayout();
		event.setView("../tests/runner");
	}
}