/**
*
* Mongo GridFS
*
* Processes Mongo GridFS Transactions
*
* @package cbmongodb.models.Mongo
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
*/
component name="GridFS" accessors=true {
	/**
	* The Mongo Client Instance
	**/
	property name="MongoClient" inject="MongoClient@cbmongodb";
	/**
	* Mongo Utils
	**/
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	/**
	* CBJavaloader
	**/
	property name="jLoader" inject="loader@cbjavaloader";
	/**
	* Application Settings
	**/
	property name="AppSettings" inject="wirebox:properties";
	/**
	* Core GridFS connection properties
	**/
	property name="dbInstance";
	property name="bucketName";
	property name="GridInstance";


	/**
	* Initialize The GridFS Instance
	* 
	* @param string db 		The name of the database to use
	* @param string bucket 	The name of the bucket to use
	**/
	function init(required string db,required string bucket='fs'){	
		//Our implementation depends on the older DB construction
		setDBInstance(MongoClient.getMongo().getDb(ARGUMENTs.db));
		setBucketName(ARGUMENTS.bucket);
		setGridInstance(jLoader.create("com.mongodb.gridfs.GridFS").init(VARIABLES.dbInstance,VARIABLES.bucketName));
		return this;
	}


	/**
	* Creates and stores a GridFS file
	* 
	* @param binary filePath 	The path of the file which will be stored in the db
	* @param string [fileName] 	The filename for retrieval operations
	* @return string 			Returns the string representation of the file ID
	**/
	public string function createFile(required string filePath,string fileName,required boolean deleteFile=false){
		if(isNull(GridInstance)) throw("GridFS not initialized.");
		var inputStream = jLoader.create("java.io.FileInputStream").init(filePath);
		//create a file name from our path if not specified
		if(isNull(ARGUMENTS.fileName)) ARGUMENTS.fileName = listLast(filePath,'/');
		//default file data storage
		var fileData = {
			"name":ARGUMENTS.fileName,
			"extension":listLast(ARGUMENTS.filePath,'.'),
			"mimetype":fileGetMimeType(ARGUMENTs.filePath)
		};

		//image storage processing - skipped if GridFS settings are not enabled
		if(structKeyExists(AppSettings.MongoDB,'GridFS') && isReadableImage(filePath)){
			var GridFSConfig = AppSettings.MongoDB.GridFS;
			var img = imageRead(filePath);

			if(structKeyExists(GridFSConfig,'imagestorage')){
				var maxheight = img.height;
				var maxwidth = img.width;
				if(structKeyExists(GridFSConfig.imagestorage,'maxwidth') && maxwidth > GridFSConfig.imagestorage.maxwidth) maxwidth = GridFSConfig.imagestorage.maxwidth;
				if(structKeyExists(GridFSConfig.imagestorage,'maxheight') && maxheight > GridFSConfig.imagestorage.maxheight) maxheight = GridFSConfig.imagestorage.maxheight;
				
				if(maxheight != img.height || maxwidth != img.width){
					//throw an error if we are resizing without a tmp directory
					if(!structKeyExists(GridFSConfig.imagestorage,'tmpDirectory')) throw("GridFS maximum image sizes are specified but no temporary directory has been provided for processing.  Please ensure a tmpDirectory key exists in your GridFS imagestorage configuration.");
					//ensure our directory exists
					if(!directoryExists(expandPath(GridFSConfig.imagestorage.tmpDirectory))) directoryCreate(expandPath(GridFSConfig.imagestorage.tmpDirectory));
					var tmpPath = expandPath(GridFSConfig.imagestorage.tmpDirectory) & listLast(filePath,'/');
					imageResize(img,maxwidth,maxheight);
					//create a temporary file
					imageWrite(img,tmpPath,true);
					//reload our input stream from the tmp file
					inputStream = jLoader.create("java.io.FileInputStream").init(tmpPath);
				}

				if(structKeyExists(GridFSConfig.imagestorage,'metadata') && GridFSConfig.imagestorage.metadata){
					img = imageRead(isDefined('tmpPath')?tmpPath:ARGUMENTS.filePath);
					fileData['image']=structCopy(img);
				}
			}
		}

		var created = GridInstance.createFile(inputStream,ARGUMENTS.fileName);

		created.setContentType(fileData.mimetype);

		created.put('fileInfo', MongoUtil.toMongo(fileData));

		created.save();

		//clean up our files before returning
		if(isDefined('tmpPath') && fileExists(tmpPath)) fileDelete(tmpPath);

		if(ARGUMENTS.deleteFile) fileDelete(ARGUMENTS.filePath);

		return created.getId().toString();


	}

	/**
	* Retreives a GridFS file by ObjectId
	* 
	* @param any id 	The Mongo ObjectID or _id string representation
	**/
	function findById(required any id){
		if(isSimpleValue(ARGUMENTS.id)){
			ARGUMENTS.id = MongoUtil.newObjectIdFromId(ARGUMENTS.id);
		}

		return GridInstance.findOne(ARGUMENTS.id);
	}

	/**
	* Finds a file by search criteria
	* 
	* @param struct criteria 	The CFML struct representation of the Mongo criteria query
	**/
	function find(required struct criteria){
		if(isNull(GridInstance)) throw("GridFS not initialized.");

		return GridInstance.find(MongoUtil.toMongo(ARGUMENTS.criteria));

	}	

	/**
	* Finds an returns a single document with search criteria
	* 
	* @param struct criteria 	The CFML struct representation of the Mongo criteria query
	**/
	function findOne(required struct criteria){
		if(isNull(GridInstance)) throw("GridFS not initialized.");

		return GridInstance.findOne(MongoUtil.toMongo(ARGUMENTS.criteria));

	}

	/**
	* Returns the iterative cursor of the files contained in the GridFS Bucket
	* 
	* @param struct criteria 	The CFML struct representation of the Mongo criteria query
	**/
	function getFileList(required struct criteria={}){
		if(isNull(GridInstance)) throw("GridFS not initialized.");

		return GridInstance.getFileList(MongoUtil.toMongo(ARGUMENTS.criteria));

	}

	/**
	* Removes a GridFS file by id
	* 
	* @param any id 	The Mongo ObjectID or _id string representation
	**/
	function removeById(required any id){
		var criteria = MongoUtil.newIdCriteriaObject(ARGUMENTS.id);
		return GridInstance.remove(MongoUtil.toMongo(criteria));
	}

	/**
	* Removes a GridFS file by criteria
	* 
	* @param struct criteria 	The CFML struct representation of the Mongo criteria query
	**/
	function remove(required struct criteria){
		return GridInstance.remove(MongoUtil.toMongo(ARGUMENTS.criteria));
	}

	private function isReadableImage(filePath){
		var readableImageFormats = listToArray(lcase(getReadableImageFormats()));
		return arrayFind(readableImageFormats,lcase(listLast(filePath,'.')));
	}

}
