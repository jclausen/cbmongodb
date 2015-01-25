/*******************************************************************************
*	Integration Test for /cfmongodb/models/GEOEntity.cfc
*******************************************************************************/
component name="TestModelGEOEntity" extends="testbox.system.BaseSpec" accessors=true{
	property name="people";
	property name="states";

	function beforeAll(){
		//custom methods
		application.wirebox = new coldbox.system.ioc.Injector('cbmongodb.tests.config.Wirebox');
		variables.wirebox=application.wirebox;
		variables.people= application.wirebox.getInstance("Person");
		variables.states= application.wirebox.getInstance("State");
	}

	function afterAll(){
          variables.people.getDB().dropDatabase();
          variables.people.getDB().close();
          structDelete( application, "wirebox" );
          structDelete( variables, "people" );
          structDelete( variables, "states" );
	}


	function run(testResults, testBox){
		describe( "MongoDB Active Entity", function(){
			beforeEach(function( currentSpec ){

			});

			it('+checks geospatial query functions',function(){
				var person=variables.people;
				expect(person.populate(person.getTest_document())).toBeComponent();
				var document_id=person.create();
				expect(document_id).toBeString();
				var state=variables.states;
				expect(state.populate(state.getTest_document())).toBeComponent();
				var state_id=state.create();
				expect(state_id).toBeString();
				expect(arrayLen(state.load(state_id).within('geometry','Person.address.location').findAll())).toBe(1);
				//load our counties
				var counties = application.wirebox.getInstance("County");
				for(var county in counties.getTest_Documents()){
					counties.reset().populate(county).create();
				}
				writeDump(state.reset().load(state_id).within('geometry','County.geometry').findAll());
				abort;

				expect(arrayLen(state.reset().load(state_id).within('geometry','County.geometry').findAll())).toBe(3);


			});
		});
	}

}