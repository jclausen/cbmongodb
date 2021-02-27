component{

	function MongoDBPreSave( event, interceptData ){

		var keyMap = interceptData.entity.get_map();

		if( interceptData.document.keyExists( "id" ) && !interceptData.keyExists( "_id" ) ){
			interceptData.document[ "_id" ] = interceptData.document[ "id" ];
			interceptData.document.delete( "id" );
		}

		interceptData.entity.denormalizeFields(
			keyMap.keyArray().filter( function( key ){
				return keyMap[ key ].keyExists( "normalize" ) && !keyMap[ key ].keyExists( "on" );
			} ),
			interceptData.document
		);

	}

	function MongoDBPostSave( event, interceptData ){
		var keyMap = interceptData.entity.get_map();

		keyMap.keyArray().filter( function( key ){
			return keyMap[ key ].keyExists( "normalize" )
					&& !keyMap[ key ].keyExists( "on" )
					&& keyMap[ key ].keyExists( "lazy" )
					&& !KeyMap[ key ].lazy
		} ).each( function( key ){ interceptData.entity.eagerLoadCollection( key );} );
	}

}