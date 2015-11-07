component name="MongoCollection" accessors=true {
	property name="DBCollection";
	property name="MongoUtil" inject="MongoUtil@cbmongodb";

	public function init(required dbCollection){

		setDBCollection(arguments.dbCollection);

		return this;

	}

	public function count(where={}){

		return getDBCollection().count(getMongoUtil().toMongo(arguments.where));

	}

	public function find(required criteria={},required struct options={}){

		var results = getDBCollection().find(getMongoUtil().toMongo(arguments.criteria));
		
		if(structKeyExists(options,'offset')) results.skip(options.offset);
		if(structKeyExists(options,'sort')) results.sort(getMongoUtil().toMongoDocument(options.sort));
		if(structKeyExists(options,'limit') and options.limit > 0) results.limit(options.limit);
			
		return getMongoUtil().encapsulateCursor(results);

	}

	public function findById(id){
		var qObj = getMongoUtil().newIDCriteriaObject(arguments.id);

		var results=this.getDBCollection().find(qObj).limit(1).iterator();
		
		if(!isNull(results.hasNext()) and results.hasNext()){
	
			return results.next();
	
		} else {
	
			return javacast('null',0)
	
		}
	}

	public function drop(){

		return getDBCollection().drop();

	}

	public function createIndex(required operation, required options={}){
		var idxOptions = getMongoUtil().createIndexOptions(options);
		
		try{
		
			this.getDBCollection().createIndex(toMongo(operation),idxOptions);
		
		} catch(any e){
			
			throw("Index on #options['name']# could not be created.  The error returned was: <strong>#e.message#</strong>");
		
		}					


	}

	public function createGeoIndex(required field,required options={},geoType='2dsphere'){

		var idxOptions = getMongoUtil().createIndexOptions(options);
		var doc = { "#arguments.field#" = arguments.geoType };

		try{

			this.getDBCollection().createIndex(toMongo(doc),idxOptions);

		} catch(any e){

			throw("Geo Index on #options['name']# could not be created.  The error returned was: <strong>#e.message#</strong>");
		
		}

	}

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

	public function aggregate(){

	}

	public function distinct(){

	}

	public function mapReduce(){

	}

	public function bulkWrite(){

	}

	public function insertMany(){

	}

	public function remove(required criteria,multiple=true){

		if(arguments.multiple){
			var removed = deleteMany(arguments.criteria).getN();
		} else {
			var removed = deleteOne(arguments.criteria).getN();
		}

		return removed;
	}

	public function deleteOne(required criteria){

		return getDBCollection().deleteOne(getMongoUtil().toMongo(arguments.criteria));

	}

	public function deleteMany(required criteria={}){
		
		return getDBCollection().deleteMany(getMongoUtil().toMongo(arguments.criteria));

	}

	public function replaceOne(required criteria,required document){

	}

	public function updateOne(required criteria,required operation){

	}

	public function updateMany(required criteria,required operation){

	}

	public function findOneAndUpdate(required criteria,required operation){

		var ops = getMongoUtil().toMongoOperation(arguments.operation);

		return getDBCollection().findOneAndUpdate(toMongo(arguments.criteria),ops);

	}

	public function createIndexes(required array indexes){

	}

	public function dropIndex(string indexName,query){

	}

	public function dropIndexes(){

		return getDBCollection().dropIndexes();
	}

	public function renameCollection(required string name){

		return getDBCollection().renameCollection(javacast('string',arguments.name));
	}

	public function findOneAndReplace(required criteria,required document){

		var utils = getMongoUtil();
		
		var search = utils.toMongo(arguments.criteria);

		var update = utils.toMongoDocument(arguments.document);
		
		return this.getDBCollection().findOneAndReplace(search,update);

	}

	public function insertOne(required document){

		var doc = getMongoUtil().toMongoDocument(document);
		
		//our doc is updated by reference
		getDBCollection().insertOne( doc );
		
		return doc;

	}

	/**
	* Private Methods
	**/

	private function toMongo(required obj){
		return getMongoUtil().toMongo(arguments.obj);
	}

	private function toMongoDocument(required doc){
		return getMongoUtil().toMongoDocument(arguments.doc);
	}
}