component name="CBMongoDBBaseTest" extends="testbox.system.BaseSpec"{
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	property name="MongoClient" inject="MongoClient@cbmongodb";
	property name="Wirebox" inject="wirebox";
	property name="People" inject="People@CBMongoTestMocks";
	property name="States" inject="States@CBMongoTestMocks";
	property name="Counties" inject="Counties@CBMongoTestMocks";
		
	function beforeAll(){
		
		if(!structKeyExists(application,'wirebox') and !structKeyExists(application,'cbController')) throw(message="Wirebox not found in the application scope. It is required to run this test suite. Tests aborted.")
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
		  //drop all of our collections
          People.getDbInstance().drop();
          States.getDbInstance().drop();
          Counties.getDbInstance().drop(); 
		  MongoClient.close();
	}
}