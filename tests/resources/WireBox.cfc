<cfcomponent output="false" extends="coldbox.system.ioc.config.Binder">
<cfscript>
	/**
	* Configure WireBox, that's it!
	*/
	function configure(){

		// WireBox Mappings
		map("Counties@CBMongoTestMocks").to("tests.mocks.CountiesMock");
		map("Files@CBMongoTestMocks").to("tests.mocks.FileEntityMock");
		map("People@CBMongoTestMocks").to("tests.mocks.ActiveEntityMock");
		map("States@CBMongoTestMocks").to("tests.mocks.StatesMock");
	}
</cfscript>
</cfcomponent>