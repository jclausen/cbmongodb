/*******************************************************************************
*	Integration Test for /cfmongodb/models/ActiveEntity.cfc
*******************************************************************************/
component name="TestModelActiveEntity" extends="testbox.system.BaseSpec"{
	property name="people";

	function beforeAll(){
		//custom methods
		application.wirebox = new coldbox.system.ioc.Injector('cbmongodb.tests.config.Wirebox');
		variables.people= application.wirebox.getInstance("Person");
	}

	function afterAll(){
          variables.people.getDB().dropDatabase();
          variables.people.getDB().close();
          structDelete( application, "wirebox" );
          structDelete( variables, "people" );
	}

	function run(testResults, testBox){

		describe( "MongoDB Active Entity", function(){

			beforeEach(function( currentSpec ){

			});

			it( "+checks our mock", function(){
				expect(variables.people).toBeComponent();
				expect(variables.people.get_default_document()).toBeStruct();
				expect(variables.people.getTest_document()).toBeStruct();
			});

			it('+checks connectivity', function(){
				expect(variables.people.getDBInstance()).toBeComponent();
			});

			it('+checks basic CRUD', function(){
				var model=variables.people;
				var person=variables.people.getTest_document();
				expect(model.populate(person)).toBeComponent();
				var document_id=model.create();
				expect(document_id).toBeString();
				//test entity load
				expect(model.reset().load(document_id).loaded()).toBeTrue();
				expect(model.whereNotI().count()).toBe(0);
				//test our single record queries
				expect(model.reset().where('address.city','Timbuktu').find(false)).toBeNull();
				expect(model.reset().where('address.city','Timbuktu').find()).toBeComponent();
				expect(model.reset().where('address.city','Timbuktu').find().loaded()).toBeFalse();
				expect(model.reset().where('address.city',model.getTest_document().address.city).find(false)).toBeStruct();
				expect(model.reset().where('address.city',model.getTest_document().address.city).find()).toBeComponent();
				expect(model.reset().where('address.city',model.getTest_document().address.city).count()).toBe(1);
				expect(model.reset().where('address.city',model.getTest_document().address.city).exists()).toBeTrue();
				//test our updates
				var ae=model.reset().where('address.city',model.getTest_document().address.city).find();
				expect(ae.loaded()).toBeTrue();
				ae.set('address.city','Chicago').set('address.state','IL').set('address.postalcode','60622').update();
				expect(ae.get_document()['address']['city']).toBe("Chicago");
				expect(model.reset().where('address.city','Chicago').find().loaded()).toBeTrue();
				//check that we updated the first record
				expect(model.reset().where('first_name',model.getTest_document().first_name).where('last_name',model.getTest_document().last_name).count()).toBe(1);
				//test our multi record queries
				//insert a duplicate record
				model.reset().populate(model.getTest_document());
				model.set('first_name','Second').set('last_name','Record').create();
				expect(model.loaded()).toBeTrue();
				//test multiple records
				expect(model.reset().findAll()).toBeArray();
				expect(arrayLen(model.reset().get(document_id).whereNotI().findAll())).toBe(1);
				//cursor tests
				//TODO: write a custom expectation for the cursor object
				var cursor=model.reset().findAll(true);
				expect(isArray(cursor)).toBeFalse();
				expect(cursor.hasNext()).toBeTrue();
				while(cursor.hasNext()){
					var nr=cursor.next();
					var doc_id=nr['_id'];
					expect(nr).toBeStruct();
					expect(nr).toHaveKey('first_name');
					expect(nr).toHaveKey('address');
					//now delete our records
					expect(model.reset().get(doc_id).delete()).toBeTrue();
					expect(model.reset().get(doc_id).loaded()).toBeFalse();
					//expect(model.delete()).toThrow();
				}

			});
		});
	}

}