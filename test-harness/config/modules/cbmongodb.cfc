component {
	function configure(){
		return {
		    //an array of servers to connect to
			hosts= [
				{
					serverName='127.0.0.1',
					serverPort='27017'
				}
			],
		    //The default database to connect to
		    db  = "test",
		    //whether to permit viewing of the API documentation
		    permitDocs = true,
		    //whether to permit unit tests to run
		    permitTests = true,
		    //whether to permit API access to the Generic API (future implementation)
		    permitAPI = true,
		    //GridFS settings - this key is omitted by default
			GridFS = {
				"imagestorage":{
					//whether to store the cfimage metadata
					"metadata":true,
					//the max allowed width of images in the GridFS store
					"maxwidth":1000,
					//the max allowed height of images in the GridFS store
					"maxheight":1000,
					//The path within the site root with trailing slash to use for resizing images (required if maxheight or max width are specified)
					"tmpDirectory":"/tests/assets/tmp/"
				}
			}
		};
	}
}