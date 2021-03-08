component extends="cbmongodb.models.ActiveEntity" collection="cfmigrations" {

	property name="name"         schema validate="string";
	property
		name="migrationRan"
		schema
		validate="time";

	Migration function init(){
		super.init();
		return this;
	}

}
