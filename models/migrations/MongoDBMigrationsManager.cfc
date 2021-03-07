component accessors="true" {

	property name="wirebox" inject="wirebox";
	property name="migrationsCollection" default="cfmigrations";
	property name="documentService";
	property name="Migration" provider="Migration@cbmongodb";


	boolean function isReady() {
		return true;
	}

	function install( runAll = false ) {}

	public void function uninstall() {
		getMigration().getDbInstance().drop();
	}

	public void function reset() {
		getMigration().getDb().drop();
	}

	array function findProcessed() {

		getMigration()
			.sort( "migrationRan", "desc" )
			.findAll()
			.map( function( entry ){
				return entry[ "name" ]
			} );
	}


	boolean function isMigrationRan( componentName ) {
		var processed = findProcessed();
		return processed.contains( componentName );
	}


	private void function logMigration( direction, componentName ) {
		switch( direction ){
			case "down":{
				getMigration().getCollection().findOneAndDelete( { "name" : arguments.componentName } );
				break;
			}
			default:{
				getMigration().create(
					{
						"name" : arguments.componentName,
						"migrationRan" : now()
					}
				);
			}
		}
	}


	public void function runMigration(
		direction,
		migrationStruct,
		postProcessHook,
		preProcessHook
	) {

		var migrationRan = isMigrationRan( migrationStruct.componentName );

		if ( migrationRan && direction == "up" ) {
			throw( "Cannot run a migration that has already been ran." );
		}

		if ( !migrationRan && direction == "down" ) {
			throw( "Cannot rollback a migration if it hasn't been ran yet." );
		}

		var migration = wirebox.getInstance( migrationStruct.componentPath );

		preProcessHook( migrationStruct );

		invoke(
			migration,
			direction
		);
		logMigration( direction, migrationStruct.componentName );

		postProcessHook( migrationStruct );
	}

}
