/**
*
* Mongo Collection
*
* The collection interface used for client operations by CBMongodb. Handles the translation of CFML objects for the DBCollection instance.
* 
*
* @constructor init(java:com.mongodb.MongoCollectionImpl)
* @package cbmongodb.models.Mongo
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
*/
component name="MongoCollection" accessors=true {
	property name="DBCollection";
	property name="MongoUtil" inject="MongoUtil@cbmongodb";

	/**
	* Constructor - Must be manually instantiated with the Mongo Collection Object
	* 
	* @param java:com.mongodb.MongoCollectionImpl dbCollection 	The MongoDB Collection Object
	**/
	public function init(required dbCollection){
		
		setDBCollection(arguments.dbCollection);

		return this;

	}

	/**
	* Counts the number of records, by restriction or in total
	* 
	* @param struct [criteria]	A criteria struct which restricts the counted document
	**/
	public function count(criteria={}){

		return getDBCollection().count(getMongoUtil().toMongo(arguments.criteria));

	}

	/**
	* Facade for the drivers find method. Encapuslates the result with a number of utility methods
	* 
	* @param struct [criteria]	The search criteria for the query
	* @param struct [options] 	The options for the search (accepts: offset,limit,skip)
	**/
	public function find(required criteria={},required struct options={}){

		var results = getDBCollection().find(getMongoUtil().toMongo(arguments.criteria));
		
		if(structKeyExists(options,'offset')) results.skip(options.offset);
		if(structKeyExists(options,'sort')) results.sort(getMongoUtil().toMongoDocument(options.sort));
		if(structKeyExists(options,'limit') and options.limit > 0) results.limit(options.limit);
			
		return getMongoUtil().encapsulateDBResult(results);

	}

	/**
	* Finds a single document by its _id
	* 
	* @param mixed id 				The id of the document to be retrieved - may be either a BSON object or string
	* @return mixed result|null 	Returns the result if found or returns null if the document was not found
	**/
	public function findById(required id){
		var qObj = getMongoUtil().newIDCriteriaObject(arguments.id);

		var results=this.getDBCollection().find(qObj).limit(1).iterator();
		
		if(!isNull(results.hasNext()) and results.hasNext()){
	
			return results.next();
	
		} else {
	
			return javacast('null',0)
	
		}
	}

	/**
	* Drops the collection
	**/
	public function drop(){

		return getDBCollection().drop();

	}

	/**
	* Creates a standard index
	* 
	* @param struct operation 		The index operation, containing the keys to be indexed (e.g. {"lastname":-1,"firstname":1})
	* @param struct options 		The indexing options such as the index name, sparse settings, etc.
	**/
	public function createIndex(required operation, required options={}){
		var idxOptions = getMongoUtil().createIndexOptions(options);
		
		try{
		
			this.getDBCollection().createIndex(toMongo(operation),idxOptions);
		
		} catch(any e){
			
			throw("Index on #options['name']# could not be created.  The error returned was: <strong>#e.message#</strong>");
		
		}					


	}

	/**
	* Creates a geospatial index
	* 
	* @param string field 			The field to index
	* @param struct options 		The indexing options such as the index name, sparse settings, etc.
	* @param string	geoType 		The GEOJSON spatial type to apply for the index.  Defaults to '2dsphere'.
	**/
	public function createGeoIndex(required string field,required options={},required string geoType='2dsphere'){

		var idxOptions = getMongoUtil().createIndexOptions(options);
		var doc = { "#arguments.field#" = arguments.geoType };

		try{

			this.getDBCollection().createIndex(toMongo(doc),idxOptions);

		} catch(any e){

			throw("Geo Index on #options['name']# could not be created.  The error returned was: <strong>#e.message#</strong>");
		
		}

	}

	/**
	* Returns an array of object maps for all of the indexes in the collection
	**/
	public function listIndexes(){
		var indexList = getDBCollection().listIndexes().iterator();
		var indexes=[];
		while(indexList.hasNext()){
			arrayAppend(indexes,indexList.next());
		}
		return indexes;
	}


	/**
	* Generic Save Function - Uses findOneAndReplace()
	* 
	* @param struct document 		The document to be saved
	* @param boolean upsert			Whether the document should be added if it cannot be found
	**/
	public function save(required document,required upsert=false){

		var utils = getMongoUtil();

		if(arguments.upsert and !structKeyExists(document,'_id')){
			
			var doc = insertOne(arguments.document);

		} else {

			var criteria = utils.newIDCriteriaObject(arguments.document['_id']);
			
			var doc=findOneAndReplace(criteria,arguments.document);	
		}

		return doc;

	}

	/**
	* Finds one document and deletes it
	* 
	* @param struct criteria 		The criteria for the deletion (e.g. {"_id":"123456789012456bx"})
	* @param struct [options] 		Any options which should be applied to the deletion
	**/
	public function findOneAndDelete(required struct criteria,options){

		if(isNull(options)){
			return getDBCollection().findOneAndDelete(getMongoUtil().toMongo(arguments.criteria))
		} else {
			return getDBCollection().findOneAndDelete(
				getMongoUtil().toMongo(arguments.criteria),
				getMongoUtil().toMongo(options)
			);
		}
	}

	/**
	* Facade for the driver's aggregate() method
	* <br><br><strong>NOTE:</strong> Not implemented as CF native at the present time. Operations will need to be performed using the java arguments: <a href="http://api.mongodb.org/java/current/com/mongodb/DBCollection.html">http://api.mongodb.org/java/current/com/mongodb/DBCollection.html</a>
	**/
	public function aggregate(){
		return getDbCollection().aggregate(argumentCollection=arguments);
	}

	/**
	* Facade for the driver's distinct() method
	* <br><br><strong>NOTE:</strong> Not implemented as CF native at the present time. Operations will need to be performed using the java arguments: <a href="http://api.mongodb.org/java/current/com/mongodb/DBCollection.html">http://api.mongodb.org/java/current/com/mongodb/DBCollection.html</a>
	**/
	public function distinct(){
		return getDbCollection().distinct(argumentCollection=arguments);
	}

	/**
	* Facade for the driver's mapReduce() method
	* <br><br><strong>NOTE:</strong> Not implemented as CF native at the present time. Operations will need to be performed using the java arguments: <a href="http://api.mongodb.org/java/current/com/mongodb/DBCollection.html">http://api.mongodb.org/java/current/com/mongodb/DBCollection.html</a>
	**/
	public function mapReduce(){
		return getDbCollection().mapReduce(argumentCollection=arguments);
	}

	/**
	* Facade for the driver's bulkWrite() method
	* <br><br><strong>NOTE:</strong> Not implemented as CF native at the present time. Operations will need to be performed using the java arguments: <a href="http://api.mongodb.org/java/current/com/mongodb/DBCollection.html">http://api.mongodb.org/java/current/com/mongodb/DBCollection.html</a>
	**/
	public function bulkWrite(){
		return getDbCollection().mapReduce(argumentCollection=arguments);
	}

	/**
	* Facade for the driver's insertMany() method
	* <br><br><strong>NOTE:</strong> Not implemented as CF native at the present time. Operations will need to be performed using the java arguments: <a href="http://api.mongodb.org/java/current/com/mongodb/DBCollection.html">http://api.mongodb.org/java/current/com/mongodb/DBCollection.html</a>
	**/
	public function insertMany(){
		return getDbCollection().insertMany(argumentCollection=arguments);
	}

	/**
	* Utility method which emulates the remove() method available in the v2 Mongo java drivers
	* 
	* @param struct criteria 		The criteria for the document deletion
	* @param boolean multiple 		Whether to delete multiple records. Defaults to true
	**/
	public function remove(required criteria,multiple=true){

		if(arguments.multiple){
			var removed = deleteMany(arguments.criteria).getN();
		} else {
			var removed = deleteOne(arguments.criteria).getN();
		}

		return removed;
	}

	/**
	* Deletes a single document by criteria
	* 
	* @param struct criteria 		The critera for deletion (e.g. {"_id":"123456789012456bx"})
	**/
	public function deleteOne(required criteria){

		return getDBCollection().deleteOne(getMongoUtil().toMongo(arguments.criteria));

	}

	/**
	* Deletes many documents by criteria
	* 
	* @param struct criteria 		The critera for deletion (e.g. {"created":{"$lt":now()}})
	**/
	public function deleteMany(required criteria={}){
		
		return getDBCollection().deleteMany(getMongoUtil().toMongo(arguments.criteria));

	}
	/**
	* Replaces one document found by a designated criteria 
	* <br><br><strong>NOTE:</strong> facade for findOneAndReplace()
	* 
	* @param struct criteria 		The critera for replacement (e.g. {"_id":"123456789012456bx"})
	* @param document 				The document which replaces the queried object
	**/
	public function replaceOne(required criteria,required document){
		return findOneAndReplace(argumentCollection=arguments);
	}

	/**
	* Updates one document found by a designated criteria 
	* <br><br><strong>NOTE:</strong> facade for findOneAndUpdate()
	* 
	* @param struct criteria 		The critera for update (e.g. {"_id":"123456789012456bx"})
	* @param operation				The operational struct object which updates the queried object
	**/
	public function updateOne(required criteria,required operation){
		return findOneandUpdate(argumentCollection=arguments);
	}

	/**
	* Updates multiple documents found by a designated criteria 
	* <br><br><strong>NOTE:</strong> facade for findOneAndUpdate()
	* 
	* @param struct criteria 		The critera for update (e.g. {"_id":"123456789012456bx"})
	* @param operation 				The operational struct object which updates the queried object
	**/
	public function updateMany(required criteria,required operation){

		var ops = getMongoUtil().toMongoOperation(arguments.operation);

		return getDBCollection.updateMany(toMongo(arguments.criteria),ops);
	}

	/**
	* Updates a single document found by a designated criteria 
	* 
	* @param struct criteria 		The critera for update (e.g. {"_id":"123456789012456bx"})
	* @param operation 				The operational struct object which updates the queried object
	**/
	public function findOneAndUpdate(required criteria,required operation){

		var ops = getMongoUtil().toMongoOperation(arguments.operation);

		return getDBCollection().findOneAndUpdate(toMongo(arguments.criteria),ops);

	}

	/**
	* Creates multiple indexes
	* 
	* @param array indexes  	The array of index structs.  Each array item should contain the key "operation", with an optional "options" key.  
	**/
	public function createIndexes(required array indexes){

		for(var index in arguments.index){
			createIndex(argumentCollection=index);
		}

	}

	/**
	* Drops an index 			Either a name or a criteria to search the existing indexes should be specified
	* 
	* @param string indexName
	* 
	**/
	public function dropIndex(string indexName,criteria){
		return getDbCollection.dropIndex(!isNull(indexName)?indexName:toMongo(criteria));
	}

	/**
	* Drops all indexes in a collection
	**/
	public function dropIndexes(){

		return getDBCollection().dropIndexes();
	}

	/**
	* Renames the collection
	* 
	* @param required string name 		The new name for the collection
	**/
	public function renameCollection(required string name){

		return getDBCollection().renameCollection(javacast('string',arguments.name));
	}

	/**
	* Finds a single document and replaces it
	* 
	* @param struct criteria 		The critera for replacement (e.g. {"_id":"123456789012456bx"})
	* @param document 				The document which replaces the queried object
	**/
	public function findOneAndReplace(required criteria,required document){

		var utils = getMongoUtil();
		
		var search = utils.toMongo(arguments.criteria);

		var update = utils.toMongoDocument(arguments.document);
		
		return this.getDBCollection().findOneAndReplace(search,update);

	}

	/**
	* Inserts a single document
	* 
	* @param required struct document 	The document to be inserted
	**/
	public function insertOne(required document){

		var doc = getMongoUtil().toMongoDocument(document);
		
		//our doc is updated by reference
		getDBCollection().insertOne( doc );
		
		return doc;

	}

	/**
	* Private Methods
	**/

	/**
	* Utility facade for Mongo.Util.toMongo
	**/
	private function toMongo(required obj){
		return getMongoUtil().toMongo(arguments.obj);
	}

	/**
	* Utility facade for Mongo.Util.toMongoDocument
	**/
	private function toMongoDocument(required doc){
		return getMongoUtil().toMongoDocument(arguments.doc);
	}
}