/*******************************************************************************
*	Integration Test for /cfmongodb/models/ActiveEntity.cfc
*******************************************************************************/
component name="TestMongoUtil" extends="testbox.system.BaseSpec"{
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	property name="MongoClient" inject="MongoClient@cbmongodb";
	property name="Wirebox" inject="wirebox";

	function beforeAll(){
		//custom methods
		application.wirebox = new coldbox.system.ioc.Injector('cbmongodb.tests.config.Wirebox');
		application.wirebox.autowire(this);
		expect(isNull(MongoUtil)).toBeFalse("Autowiring Failed!");

	}

	function afterAll(){
          structDelete( application, "wirebox" );
	}

	function run(testResults, testBox){

		describe( "Test Client Immutability", function(){
			it("tests Collection Immutability",function(){
				var person = Wirebox.getInstance("Person");
				expect(person.getCollectionObject().getCollectionName()).toBe("people");
				var state = Wirebox.getInstance("State");
				
				expect(state.getCollectionObject().getCollectionName()).toBe("states");
				//person.findAll();
				expect(person.getCollectionObject().getCollectionName()).toBe("people");
				
				var county = Wirebox.getInstance("County");
				expect(county.getCollectionObject().getCollectionName()).toBe("counties");
				//state.findAll();
				expect(state.getCollectionObject().getCollectionName()).toBe("states");
				//person.findAll();
				expect(person.getCollectionObject().getCollectionName()).toBe("people");
			});
			
			
		});

	}

}
				