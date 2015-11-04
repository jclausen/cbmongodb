component name="MongoUtil" accessors=true singleton{
	property name="MongoConfig" inject="MongoConfig@cbmongodb";

	/**
	* Converts a ColdFusion structure to a CFBasicDBobject, which  the Java drivers can use
	*/
	function toMongo(any obj,basic=false){

		// if (isStruct(obj))
		// {
		// 	var dbObject = createObject("java", "com.mongodb.BasicDBObject").init();

		// 	for (local.key in obj)
		// 	{
		// 		// convert '_id' and Modifier Operations into the correct case
		// 		if (compareNoCase(key,"_ID")==0)
		// 			key = "_id";
		// 		else if (key.startsWith("$"))
		// 			key = replaceList(lcase(key), "$addtoset,$pushall,$putall,$maxdistance", "$addToSet,$pushAll,$putAll,$maxDistance");

		// 		if (!structKeyExists(obj, key))
		// 			dbObject[key] = javacast("null","");
		// 		else
		// 		{
		// 			var value =  obj[key];

		// 			if (isStruct(value) || (isArray(value) && !isBinary(value)))
		// 				value = dbObjectNew(value);

		// 			dbObject[key] = value;
		// 		}
		// 	}

		// 	return dbObject;
		// }
		// else if (isArray(obj))
		// {
		// 	var dbObject = createObject("java", "com.mongodb.BasicDBList").init();

		// 	for (local.item in obj)
		// 	{
		// 		if (isNull(item))
		// 			arrayAppend(dbObject, javacast("null",""));
		// 		else
		// 		{
		// 			if (isStruct(item) || (isArray(item) && !isBinary(item)))
		// 				item = dbObjectNew(item);

		// 			arrayAppend(dbObject, isNull(item) ? javacast("null","") : item);
		// 		}
		// 	}

		// 	return dbObject;
		// }

		return dbObjectnew(obj,basic);
	}

	function toMongoDocument(data){
		var doc = createObject('java','org.bson.Document');
		doc.putAll(data);
		return doc;
	}

	function toMongoConversion(data){
		// var conversion = createObject('java','org.bson.conversions.Bson');
		// conversion.toBsonDocument(toMongoDocument(data))
		return toMongoDocument(data);
	}

	/**
	* Converts a ColdFusion structure to a CFBasicDBobject which ensures 1 and -1 remain ints
	*/
	function toMongoOperation( struct data ){
		if( isCFBasicDBObject(data) ) return data;
		var dbo = newOperationalDBObject();
		dbo.putAll( data );
		return dbo;
	}

	/**
	* Converts a Mongo DBObject to a ColdFusion structure
	*/
	function toCF(BasicDBObject){
		var s = {};
		s.putAll(BasicDBObject);
		return s;
	}

	/**
	* Convenience for turning a string _id into a Mongo ObjectId object
	*/
	function newObjectIDFromID(String id){
		if( not isSimpleValue( id ) ) return id;
		return createObject("java","org.bson.types.ObjectId").init(id);
	}

	/**
	* Convenience for creating a new criteria object based on a string _id
	*/
	function newIDCriteriaObject(String id){
		var dbo = newDBObject();
		dbo.put("_id",newObjectIDFromID(id));
		return dbo;
	}

	/**
	* Creates a Mongo CFBasicDBObject whose order matches the order of the keyValues argument
	  keyValues can be:
	  	1) a string in k,k format: "STATUS,TS". This will set the value for each key to "1". Useful for creating Mongo's 'all true' structs, like the "keys" argument to group()
	    2) a string in k=v format: STATUS=1,TS=-1
		3) an array of strings in k=v format: ["STATUS=1","TS=-1"]
		4) an array of structs (often necessary when creating "command" objects for passing to db.command()):
		  createOrderedDBObject( [ {"mapreduce"="tasks"}, {"map"=map}, {"reduce"=reduce} ] )
	*/
	function createOrderedDBObject( keyValues, dbObject="" ){
		if( isSimpleValue(dbObject) ){
			dbObject = newDBObject();
		}
		var kv = "";
		if( isSimpleValue(keyValues) ){
			keyValues = listToArray(keyValues);
		}
		for(kv in keyValues){
			if( isSimpleValue( kv ) ){
				var key = listFirst(kv, "=");
				var value = find("=",kv) ? listRest(kv, "=") : 1;
			} else {
				var key = structKeyList(kv);
				var value = kv[key];
			}
			dbObject[key]=value;
		}
		return dbObject;
	}

	function listToStruct(list){
		var item = '';
		var s = {};
		var i = 1;
		var items = listToArray(list);
		var itemCount = arrayLen(items);
		for(i; i lte itemCount; i++) {
			s.put(items[i],1);
		}
		return s;
	}

	/**
	* Extracts the timestamp from the Doc's ObjectId. This represents the time the document was added to MongoDB
	*/
	function getDateFromDoc( doc ){
		var ts = doc["_id"].getTime();
		return createObject("java", "java.util.Date").init(ts);
	}

	/**
	* Whether this doc is an instance of a CFMongoDB CFBasicDBObject
	*/
	function isCFBasicDBObject( doc ){
		return NOT isSimpleValue( doc ) AND getMetadata( doc ).getCanonicalName() eq "com.mongodb.CFBasicDBObject";
	}

	/**
	* Create a new instance of the CFBasicDBObject. You use these anywhere the Mongo Java driver takes a DBObject
	*/
	function newDBObject(){
		var dbo = createObject('java','com.mongodb.BasicDBObject');	
		return dbo;
	}

	function dbObjectNew(contents,basic=true){
		var dbo = newDBObject();
		dbo.putAll(toMongoDocument(contents));
		//if(basic){
			return dbo;
		// } else {
		// 	try{
		// 		var map = createObject('java','java.util.HashMap');
		// 		map.putAll(contents);
		// 		return dbo.putAll(map);
		// 	} catch (any e){
		// 		writeDump(var=e,top=1);
		// 		abort;
		// 	}
		// }
		
	}

	function encapsulateCursor(dbResult){
		var enc = {};
		enc['asCursor']=function(){return dbResult.iterator()};
		enc['asArray']=function(){return this.asArray(dbResult)};
		enc['forEach']=function(required fn){return dbResult.forEach(fn)};
		enc['asJSON']=function(required fn){return serializeJSON(this.asArray(dbResult,true))};
		return enc;
	}

	/**
	* Returns the results of a dbResult object as an array of documents
	**/
	function asArray(dbResult,stringify=false){
		var aResults = [];
		var cursor = dbResult.iterator();
		while(cursor.hasNext()){
			var nextResult = cursor.next();
			//TODO:  Add conversion function to recurse the document and convert all BSON ID's
			if(stringify) nextResult['_id']=nextResult['_id'].toString();

			arrayAppend(aResults,nextResult);
		}
		return aResults;
	}

}