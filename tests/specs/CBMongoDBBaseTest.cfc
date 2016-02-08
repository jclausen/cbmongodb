component name="CBMongoDBBaseTest" extends="coldbox.system.testing.BaseTestCase" appMapping="/root"{
	
	property name="MongoUtil" inject="id:MongoUtil@cbmongodb";
	property name="MongoClient" inject="id:MongoClient@cbmongodb";
	property name="Wirebox" inject="wirebox";
	
	property name="People" inject="id:People@CBMongoTestMocks";
	property name="States" inject="id:States@CBMongoTestMocks";
	property name="Counties" inject="id:Counties@CBMongoTestMocks";
	property name="FileEntity" inject="id:Files@CBMongoTestMocks";
	
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		//MongoClient = application.wirebox.getInstance("MongoClient@cbmongodb");
		//MongoUtil =  application.wirebox.getInstance("MongoUtil@cbmongodb");

		//new coldbox.system.ioc.Injector(binder="tests.resources.WireBox");
		
		if(!structKeyExists(application,'wirebox') and !structKeyExists(application,'cbController')){
			writeDump(application); 
			throw(message="Wirebox not found in the application scope. It is required to run this test suite. Tests aborted.");
		}	
		
		//custom methods
		if(structKeyExists(application,'cbController')){
			application.cbController.getWirebox().autowire(this);
		} else {
			application.wirebox.autowire(this);	
		}

		expect(isNull(Wirebox)).toBeFalse("Autowiring Failed");
		expect(isNull(MongoUtil)).toBeFalse("Autowiring Failed!");
	}

	function afterAll(){
		super.afterAll();

		//drop all of our collections
		application.wirebox.getInstance("People@CBMongoTestMocks").getDbInstance().drop();
		application.wirebox.getInstance("States@CBMongoTestMocks").getDbInstance().drop();
		application.wirebox.getInstance("Counties@CBMongoTestMocks").getDbInstance().drop();
	}
}