/*******************************************************************************
 *	Unit Tests for cbmongodb.models.Mongo.MongoUtil
 *******************************************************************************/
component name="TestMongoUtil" extends="tests.specs.CBMongoDBBaseTest" {

	function run( testResults, testBox ){
		describe( "Tests Core Object Types", function(){
			it( "tests toMongoDocument()", function(){
				expect( getMetadata( MongoUtil.toMongoDocument( {} ) ).getCanonicalName() ).toBe( "java.lang.Class" );
			} );

			it( "tests toCF()", function(){
				expect( MongoUtil.toCF( MongoUtil.toMongoDocument( {} ) ) ).toBeStruct();
			} );

			it( "tests newObjectIDFromID()", function(){
				var testId = "53e787bd3773887239e56b17";
				expect( getMetadata( MongoUtil.newObjectIDFromID( testId ) ).getCanonicalName() ).toBe( "org.bson.types.ObjectId" );
			} );

			it( "tests newIDCriteriaObject", function(){
				var testId = "53e787bd3773887239e56b17";
				expect( getMetadata( MongoUtil.newIDCriteriaObject( testId ) ).getCanonicalName() ).toBe( "java.lang.Class" );
				expect( getMetadata( MongoUtil.newIDCriteriaObject( testId )[ "_id" ] ).getCanonicalName() ).toBe( "org.bson.types.ObjectId" );
			} );

			it( "tests dbObjectNew()", function(){
				var s = { "_id" : "53e787bd3773887239e56b17" };
				expect( getMetadata( MongoUtil.dbObjectNew( s ) ).getCanonicalName() ).toBe( "java.lang.Class" );
				expect( MongoUtil.dbObjectNew( s ) ).toHaveKey( "_id" );
			} );
		} );

		describe( "Tests DB Results", function(){
			it( "creates records for our tests", function(){
				MongoClient.getDBCollection( "MongoUtilTestCollection" ).drop();

				// we need to use the actual collection object to bypass our Collection facade
				variables.activeCollection = MongoClient
					.getDBCollection( "MongoUtilTestCollection" )
					.getDBCollection();
				for ( var i = 1; i <= 5; i = i + 1 ) {
					var doc = MongoUtil.toMongoDocument( { "one" : 1, "two" : 2, "three" : 3 } );
					variables.activeCollection.insertOne( doc );
				}
				expect( variables.activeCollection.count() ).toBe( 5 );
				describe( "Tests dbResult manipulation methods", function(){
					it( "tests the encapsulateDBResult() method", function(){
						var dbResult      = variables.activeCollection.find();
						var encapsulation = MongoUtil.encapsulateDBResult( dbResult );
						expect( encapsulation.asArray() ).toBeArray();
						// test our auto-stringification of the _id value
						expect( encapsulation.asArray()[ 1 ][ "_id" ] ).toBeString();
						expect( arrayLen( encapsulation.asArray() ) ).toBe( 5 );
						expect( getMetadata( encapsulation.asCursor() ).getCanonicalName() ).toBe( "com.mongodb.client.internal.MongoBatchCursorAdapter" );
						expect( encapsulation.asCursor().hasNext() ).toBeTrue();
						var next = encapsulation.asCursor().next();
						expect( next ).toHaveKey( "one" );
						expect( next ).toHaveKey( "two" );
						expect( next ).toHaveKey( "three" );

						expect( isJSON( encapsulation.asJSON() ) ).toBeTrue();
						expect( deserializeJSON( encapsulation.asJSON() ) ).toBeArray();
					} );
				} );
			} );
		} );
	}

}
