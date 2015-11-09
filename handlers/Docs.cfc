component extends="coldbox.system.EventHandler"{

	public function index(event,rc,prc){
		setNextEvent(url='/modules/cbmongodb/apidocs/index.html');
	}

	public function update(event,rc,prc){
		event.noLayout();
		event.setView("../apidocs/generator");
	}
}