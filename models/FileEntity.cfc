/**
*
* File Entity (e.g. GridFS) for CBMongoDB
*
* File Entity object for MongoDB GridFS File Storage
*
* @package cbmongodb.models
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
*/

component name="CFMongoFileEntity" extends="cbmongodb.models.ActiveEntity" accessors=true {
	property name="bucketName" default="fs";
	//Our file path for temporary file operations
	property name="filePath";
	//Mongo Config
	property name="MongoConfig" inject="MongoConfig@cbmongodb";
	//Our GridFS Object (uninstantiated)
	property name="GridFS" inject="GridFS@cbmongodb";
	//Placeholder for the instantiated GridFS Instance
	property name="GridFSInstance";

	//The GridFS FileID Property
	property name="fileId" schema=true required=true;


	public function init(){
		super.init(argumentCollection=ARGUMENTS);
		
		//Instantiate our Partner GridFS
		var md = getMetadata(this);
		if(structKeyExists(md,'bucket')) setBucketName(md.bucket);

		if(structKeyExists(md,'database')){
			var dbName = md.database;
		} else {
			var dbName = MongoConfig.getDbName();
		}

		setGridFSInstance(GridFS.init(dbName,getBucketName()));

		return this;

	}

	/**
	* Set our file from a path
	* @param string filePath 		The system path to the file
	* @param boolean deleteFile 	Whether to delete the file after it has been loaded to GridFS
	**/
	public function loadFile(required string filePath,deleteFile=false){
		
		if(!fileExists(filePath) && fileExists(expandPath(ARGUMENTS.filePath))) ARGUMENTS.filePath = expandPath(ARGUMENTS.filePath);

		if(!fileExists(ARGUMENTS.filePath)) throw ("File #ARGUMENTS.filePath# could not be found in the local file system.");

		if(this.loaded()){
			if(len(getFileId())) GridFSInstance.removeById(getFileId());
		}

		this.setFileId(GridFSInstance.createFile(argumentCollection=arguments));

		return this;

	}

	/**
	* Overload to delete method to ensure GFS files are deleted as well
	**/
	boolean function delete(truncate=false){
		if(this.loaded()){
			GridFSInstance.removeById(getFileId());
		}
		return super.delete(argumentCollection=arguments);
	 }

	/**
	* Alias for loadFile()
	**/
	public function setFile(required string filePath,deleteFile=false){
		return this.loadFile(argumentCollection=arguments);
	}

	/**
	* Gets the core MongoDB GridFS file object - http://api.mongodb.org/java/current/com/mongodb/gridfs/GridFSFile.html
	**/
	public function getFileObject(){
		return GridFSInstance.findById(getFileId());
	}

	/**
	* Returns the Java file output stream for the GridFS file object
	**/
	public function getFileOutputStream(){
		var gfsFile = getFile();
		if(isNull(gfsFile)) throw("The GridFS file with the id #this.getFileId()# could not be found in the bucket #getBucketName()#");

		return gfsFile.getOutputStream();
	}
}
