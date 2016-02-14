component name="FileEntityMock" extends="cbmongodb.models.FileEntity" collection="files" database="cbmongo_unit_tests" accessors=true{
	property name="person" schema="true" normalize="People@CBMongoTestMocks" on="person.id" keys="first_name,last_name,address";
	property name="person.id" schema="true" required=true;
		
}