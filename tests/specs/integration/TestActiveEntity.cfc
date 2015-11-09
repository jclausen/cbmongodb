/*******************************************************************************
*	Integration Test for /cfmongodb/models/ActiveEntity.cfc
*******************************************************************************/
component name="TestModelActiveEntity" extends="cbmongodb.tests.specs.CBMongoDBBaseTest"{
	
	function beforeAll(){
		//custom methods
		super.beforeAll();
	}

	function afterAll(){
          super.afterAll();
	}

	function run(testResults, testBox){

		describe( "MongoDB Active Entity", function(){

			beforeEach(function( currentSpec ){

			});

			it( "+checks our mocks", function(){
				expect(variables.people).toBeComponent();
				expect(variables.people.get_default_document()).toBeStruct();
				expect(variables.people.getTestDocument()).toBeStruct();
				
				//var scope our references for the remaining tests
				var model=variables.people;
				var person=variables.people.getTestDocument();

				describe("Verifies CRUD Functionality",function(){
					it('Tests entity insert operations', function(){
						expect(model.populate(person)).toBeComponent();
						var document_id=model.create();
						expect(document_id).toBeString();
						//test entity load
						expect(model.reset().load(document_id).loaded()).toBeTrue();
						expect(model.whereNotI().count()).toBe(0);
					});

					it("Tests entity retrieval operations",function(){
						//test our single record queries
						expect(model.reset().where('address.city','Timbuktu').find(false)).toBeNull();
						expect(model.reset().where('address.city','Timbuktu').find()).toBeComponent();
						expect(model.reset().where('address.city','Timbuktu').find().loaded()).toBeFalse();
						expect(model.reset().where('address.city',model.getTestDocument().address.city).find(false)).toBeStruct();
						expect(model.reset().where('address.city',model.getTestDocument().address.city).find()).toBeComponent();
						expect(model.reset().where('address.city',model.getTestDocument().address.city).count()).toBe(1);
						expect(model.reset().where('address.city',model.getTestDocument().address.city).exists()).toBeTrue();
					})

					it("Tests entity update operations",function(){
						//test our updates
						var ae=model.reset().where('address.city',model.getTestDocument().address.city).find();
						expect(ae.loaded()).toBeTrue();
						var document_id = ae.get_id();
						ae.set('address.city','Chicago').set('address.state','IL').set('address.postalcode','60622').update();
						expect(ae.get_document()['address']['city']).toBe("Chicago");
						expect(model.reset().where('address.city','Chicago').find().loaded()).toBeTrue();
						//check that we updated the first record
						expect(model.reset().where('first_name',person.first_name).where('last_name',person.last_name).count()).toBe(1);
						//test our multi record queries
						//insert a duplicate record
						model.reset().populate(model.getTestDocument());
						model.set('first_name','Second').set('last_name','Record').create();
						expect(model.loaded()).toBeTrue();
						//test multiple records
						var all_docs=model.reset().findAll();
						expect(all_docs).toBeArray();
						expect(arrayLen(all_docs)).toBe(2);
						//test our limit()
						expect(arrayLen(model.reset().limit(1).findAll())).toBe(1);
						expect(arrayLen(model.reset().get(document_id).whereNotI().findAll())).toBe(1);
					});

					it("Tests cursor operations and entity deletion",function(){
						//cursor tests
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
						}
					})
				});
					
			});

		});
	}

}