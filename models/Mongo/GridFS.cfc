/**
*
* Mongo GridFS
*
* Processes Mongo GridFS Transactions
*
* @singleton
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
		setDBInstance(MongoClient.connect(ARGUMENTs.db));
		setBucketName(ARGUMENTS.bucket);
		setGridInstance(jLoader.create("com.mongodb.gridfs.GridFS").init(VARIABLES.dbInstance,VARIABLES.bucketName));
	}


	/**
	* Creates and stores a GridFS file
	* 
	* @param string fileName 	The filename for retreival operations
	* @param binary fileData 	The binary representation of the file data
	**/
	function createFile(required string fileName, required binary fileData){
		if(isNull(GridInstance)) throw("GridFS not initialized.");
	
		var inputStream = jLoader.create("java.io.InputStream").read(ARGUMENTs.fileData);
		return GridInstance.createFile(inputStream,ARGUMENTS.fileName);


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

}
