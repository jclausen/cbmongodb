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

			it('+checks geospatial query functions',function(){

				var person=variables.people;
				expect(person.populate(person.getTestDocument())).toBeComponent();
				var document_id=person.create();
				expect(document_id).toBeString();
				var state=variables.states;

				expect(state.populate(state.getTestDocument())).toBeComponent();
				var state_id=state.create();

				expect(state_id).toBeString();
				
				expect(arrayLen(state.load(state_id).within('geometry','Person.address.location').findAll())).toBe(1);
								
				//load our counties
				var counties = application.wirebox.getInstance("County");
				for(var county in counties.getTestDocuments()){
					var county_id=counties.reset().populate(county).create();
					expect(county_id).toBeString();
				}

				expect(arrayLen(counties.reset().findAll())).toBe(4);

				var reload = state.get(state_id);
				
				expect(reload.loaded()).toBeTrue("State could not be reloaded");

				expect(arrayLen(reload.reset().within('geometry','County.geometry').findAll())).toBe(4);

				var kent=counties.reset().where('name','Kent').find();

				expect(kent).toBeComponent();

				//writeDump(kent.near('geometry','this.geometry').findAll());
				//abort;
				//expect(kent.whereNotI().near('geometry','this.geometry').findAll());


			});
		});
	}

}