/**
*
* Core MongoDB Document Service
*
* @package cbmongodb.models
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
* @attribute string database 		The database to connect to.  If omitted, the database specified in the hosts config will be used. NOTE:Authentication credentials must match the server-level auth config.
* @attribute string collection 		The name of the collection that the entity should map to
*/
component name="BaseDocumentService" database="test" collection="default" accessors=true{
	/**
	 * Injected Properties
	 **/
	/**
	* The Application Wirebox IOC Instance
	**/
	property name="wirebox" inject="wirebox";
	/**
	* The LogBox Logger for this Entity
	**/
	property name="logbox" inject="logbox:logger:{this}";
	/**
	 *  The Coldbox Application Setttings Structure
	 **/
	property name="appSettings";

	/**
	 * The MongoDB Client
	 **/
	property name="MongoClient" inject="MongoClient@cbmongodb";
	/**
	 * The Mongo Utilities Library
	 **/
	 property name="MongoUtil" inject="MongoUtil@cbmongodb";

	/**
	* The Mongo Indexer Object
	**/
	property name="MongoIndexer" inject="MongoIndexer@cbmongodb";
	 
	/**
	 * The database client w/o a specified collection
	 **/
	property name="db";
	/**
	 * This key is maintained for backward compatibility but is marked as deprecated.  
	 * You should use the component attribute method to declare your collection name.
	 * @deprecated
	 **/
	property name="collection" default="default";
	/**
	 * The instatiated database collection to perform operations on
	 **/
	property name="dbInstance";
	/**
	 * The container for the default document
	 **/
	property name="_default_document";
	/**
	 * package container for the active document entity
	 **/
	property name="_document";
	/**
	 * The id of the loaded document
	 **/
	property name="_id";
	/**
	 * package container for the loaded document before modifications
	 **/
	property name="_existing";
	/**
	 * Validation structure
	 *
	 * @example property name="myfield" schema=true validate="string";
	**/
	property name="_validation";
	/**
	* The schema map which will be persisted for validation and typing
	**/
	property name="_map";

	/**
	 * Constructor
	 **/
	any function init(){
		var meta = getMetaData(this);

		if(structKeyExists(meta,'collection')){
			this.collectionName = trim(meta.collection);
		} else if(structKeyExists(VARIABLES,'collection')) {
			this.collectionName = VARIABLES.collection;
		} else {
			throw('Could not connect to MongoDB.  No Collection property or component attribute exists.');
		}

		/**
		* Backward compatibility
		* @deprecated
		**/
		setCollection(this.collectionName);


		/**
		* 
		*  Make sure our injected properties exist
		**/

		if(isNull(getWirebox()) and structKeyExists(application,'wirebox')){
			application.wirebox.autowire(target=this,targetID=getMetadata(this).name);
		} else if(isNull(getWirebox()) and structKeyExists(application,'cbController')){
			appplication.cbController.getWirebox().autowire(this);
		} else {
			throw('Wirebox IOC Injection is required to use this service');
		}
		
		this.setMongoUtil(getMongoClient().getMongoUtil());
		this.setAppSettings(getWirebox().getBinder().getProperties());

		//Connect to Mongo
		this.setDb(this.getMongoClient());

		//If we have a database attribute
		if(structKeyExists(meta,'database')){
			this.setDbInstance(this.getDb().getDBCollection( this.collectionName, trim(meta.database) ));
		} else {
			this.setDbInstance(this.getDb().getDBCollection( this.collectionName ));
		}

		//Default Document Creation
		this.set_document(structNew());
		this.set_default_document(structNew());
		this.set_map(structNew());
		this.detect();
		return this;

	}

	/*********************** INSTANTIATION AND OPTIMIZATION **********************/
	/**
	 * Evaluate our properties for the default document
	 **/
	any function detect(){

		var properties=getMetaData(this).properties;
		//add our extended properties in case there are schema items
		if(structKeyExists(getMetaData(this),'extends') && structKeyExists(getMetaData(this).extends,'properties')){
			var extendedProperties = getMetaData(this).extends.properties;
			arrayAppend(properties,extendedProperties,true);
		}
		
		for(var prop in properties){
			
			if(structKeyExists(prop,'schema') and prop.schema){
				try {

					//add the property to your our map
					structAppend(this.get_map(),{"#structKeyExists(prop,'parent') ? prop.parent & '.' & prop.name : prop.name#"=prop},true);
					
					if(structKeyExists(prop,"parent")){
						
						//Test for doubling up on our parent attribute and dot notation
						var prop_name=listToArray(prop.name,'.');
						if(prop_name[1] EQ prop.parent){
							throw('IllegalAttributeException: The parent attribute &quot;'&prop.parent&'&quot; has been been duplicated in <strong>'&getMetaData(this).name&'</strong>. Use either dot notation for your property name or specify a parent attribute.')
						}
						//TODO: add upstream introspection to handle infinite nesting
						this.set(prop.parent&'.'&prop.name,this.getPropertyDefault(prop));
					
					} else {
						
						this.set(prop.name,this.getPropertyDefault(prop));

					}

					//test for index values
					if(structKeyExists(prop,'index')){
						this.applyIndex(prop,properties);
					}

					generateSchemaAccessors(prop);


				} catch (any error){
					throw("An error ocurred while attempting to instantiate #prop.name#.  The cause of the exception was #error.message#");	
				}

			}

		}

		this.set_default_document(structCopy(this.get_document()));
	}


	/********************************* INDEXING **************************************/
	/**
	 * Create and apply our indexes
	 *
	 * @param struct prop - the component property structure
	 * @param struct properties - the full properties structure (required if prop contains and "indexwith" attribute)
	 *
	 **/
	public function applyIndex(required prop,properties=[]){
		arguments["dbInstance"]=getDbInstance();
		return MongoIndexer.applyIndex(argumentCollection=arguments);
	}

	/********************************** SETTERS ***********************************/
	void function generateSchemaAccessors(required struct prop){
		var properties=getMetaData(this).properties;
		var varSafeSeparator = "_";
		//now create var safe accessors
		//camel case our accessor
		var propName = replace(prop.name,'.',' ',"ALL");
		propName = REReplace(propName, "\b(\S)(\S*)\b", "\u\1\L\2", "all");
		//now replace our delimiter with a var safe delimiter
		var accessorSuffix = replace(propName,' ',varSafeSeparator,"ALL");
		//we need this to make sure a property name doesn't override a top level function or overload
		if(!hasExistingAccessor(accessorSuffix)){
			//first clear our existing accessors
			structDelete(this,'get' & prop.name);
			structDelete(this,'set' & prop.name);
			this['get'&accessorSuffix]=function(){return locate(prop.name)};
			this['set'&accessorSuffix]=function(required value){return this.set(prop.name,arguments.value)};
		}
	}

	boolean function hasExistingAccessor(required string suffix){
		if(structKeyExists(getMetadata(this),'functions')){
			var functions = getMetaData(this).functions;
		} else{
			functions = [];
		}
		if(arrayContains(functions,'set' & suffix) || arrayContains(functions,'get' & suffix)){
			return true;
		} else {
			return false;
		}
		
	}

	/**
	 * Populate the document object with a structure
	 **/
	any function populate(required struct document){
		var dobj=structCopy(this.get_default_document());
		for(var prop in document){
			if(structKeyExists(dobj,prop) or structKeyExists(variables,prop)){
				this.set(prop,document[prop]);
				//normalize data
				if(isNormalizationKey(prop)){
					normalizeOn(prop);
				}
			}
		}
		return this;
	}

	/**
	 * Sets a document property
	 **/
	any function set(required key, required value){
		var doc =this.get_document();
		var sget="doc";
		var nest=listToArray(key,'.');

		for(var i=1;i LT arrayLen(nest);i=i+1){
		  sget=sget&'.'&nest[i];
		}
		var nested=structGet(sget);
		nested[nest[arrayLen(nest)]]=value;

		this.entity(this.get_document());

		//normalize data after we've scoped our entity
		if(isSimpleValue(value) && len(value) && isNormalizationKey(arguments.key)){
			normalizeOn(arguments.key);
		}

		return this;

	}

	/**
	* Appends to an existing array schema property
	**/
	any function append(required string key, required any value){
		var doc = this.get_document();
		var sget="doc";
		var nest=listToArray(key,'.');

		for(var i=1;i LT arrayLen(nest);i=i+1){
		  sget=sget&'.'&nest[i];
		}

		var nested=structGet(sget);
	
		if(!isArray(nested[nest[arrayLen(nest)]]))
			throw("Schema field #key# is not a valid array.");

		arrayAppend(nested[nest[arrayLen(nest)]],value);

		this.entity(this.get_document());
		return this;
	}

	/**
	* Prepends to an existing array property
	**/
	any function prepend(required string key, required any value){
		var doc = this.get_document();
		var sget="doc";
		var nest=listToArray(key,'.');

		for(var i=1;i LT arrayLen(nest);i=i+1){
		  sget=sget&'.'&nest[i];
		}

		var nested=structGet(sget);
	
		if(!isArray(nested[nest[arrayLen(nest)]]))
			throw("Schema field #key# is not a valid array.");

		arrayPrepend(nested[nest[arrayLen(nest)]],value);

		this.entity(this.get_document());
		return this;
	}

	/**
	 * Alias for get()
	 **/
	any function load(required _id,returnInstance=true){
		this.reset();
		return this.get(ARGUMENTS._id,ARGUMENTS.returnInstance);
	}

	/**
	 * Load a record by _id
	 *
	 * @param _id - the _id value of the document
	 * @param boolean returnInstance - whether to return a loaded instance (true) or a result struct (false)
	 **/
	any function get(required _id,returnInstance=true){
		
		var results = this.getDBInstance().findById(_id);
		
		if(!isNull(results)) this.entity(results);
		
		if(!isNull(results) && !returnInstance){
			return results;
		} else {
			return this;
		}
	}

	/**
	* Returns a CFML copy of the loaded document
	**/
	struct function getDocument(){
		return getMongoUtil().toCF(this.get_document());
	}

	/**
	* Utility facade for getDocument()
	**/
	struct function asStruct(){
		return this.getDocument();
	}

	/**
	 * Deletes a document by ID
	 **/
	any function delete(required _id){

		var deleted=this.getDBInstance().findOneAndDelete(getMongoUtil().newIDCriteriaObject(arguments['_id']));
		
		return true;
	}


	/**
	 * reset the document state
	 *
	 * @chainable
	 **/
	any function reset(){
		this.evict();
		return this;
	}

	/**
	 * Evicts the document entity and clears the query arguments
	 **/
	any function evict(){

		structDelete(variables,'_id');
		
		this.set_document(structCopy(this.get_default_document()));
		this.set_existing(structCopy(this.get_document()));
	}

		/*********************** Auto Normalization Methods **********************/
	

	/**
	* Determines whether a property is a normalization key for another property
	* @param string key 		The property name
	**/
	boolean function isNormalizationKey(required string key){
		var normalizationFields = structFindValue(get_map(),key,"ALL");
		for(var found in normalizationFields){
			var mapping = found.owner;
			if(structKeyExists(mapping,'normalize') && structKeyExists(mapping,'on') && mapping.on == key) return true;
		}
		return false;
	}

	/**
	* Returns the normalized data for a normalization key
	* 
	* @param string key 	The normalization key property name
	**/
	any function getNormalizedData(required string key){

		var normalizationFields = structFindValue(get_map(),key,"ALL");

		for(var found in normalizationFields){
			var mapping = found.owner;
			if(structKeyExists(mapping,'normalize') && structKeyExists(mapping,'on') && mapping.on == key && !isNull(locate(mapping.on)) ){
				var normalizationMap = mapping;
				var normTarget = Wirebox.getInstance(mapping.normalize).getCollectionObject().findById(locate(mapping.on));
				if(!isNull(normTarget)){
					//assemble specified keys, if available
					if(structKeyExists(mapping,'keys')){
						var normalizedData = {};
						for(var normKey in listToArray(mapping.keys)){
							//handle nulls as empty strings
							normalizedData[normKey] = normTarget[normKey];		
						}
						return normalizedData;
					} else {
						return normTarget;
					}

				} else {
					throw ("Normalization data for the property #mapping.name# could not be loaded as a record matching the #mapping.normalize# property value of #VARIABLES[mapping.on]# could not be found in the database.")
				}
			}
		}

		//return a null default
		return javacast('null',0);	
	}

	/**
	* Processes auto-normalization of a field
	* @param string key 	The normalization key property name
	**/
	any function normalizeOn(required string key){
		var normalizationFields = structFindValue(get_map(),key,"ALL");

		for(var found in normalizationFields){
			var mapping = found.owner;
			if(structKeyExists(mapping,'normalize') && structKeyExists(mapping,'on') && mapping.on == key){
				var normalizationMapping = mapping;
				break;
			}
		}

		if(!isNull(normalizationMapping)){
			var farData = getNormalizedData(ARGUMENTS.key);
			var nearData = locate(normalizationMapping.name);
			if(isStruct(nearData)){
				structAppend(nearData,farData,true);	
			} else {
				nearData=farData;	
			}
			if(!isNull(normData)){
				this.set(normalizationMapping.name,nearData);	
			}
		}

		return;

	}


	/********************************* Document Object Location, Searching and Query Utils ****************************************/

	void function criteria(struct criteria){
		
		if(structKeyExists(ARGUMENTS.criteria,'_id')){
			//exclude our nested query obects
			if(!isStruct(ARGUMENTS.criteria['_id']) && isSimpleValue(ARGUMENTS.criteria['_id']))
				ARGUMENTS.criteria['_id']=getMongoUtil().newObjectIDfromID(ARGUMENTS.criteria['_id']);
		}

		this.set_criteria(ARGUMENTS.criteria);
	}

	/**
	 * Helper function to locate deeply nested document items
	 *
	 * @param key the key to locate
	 * @return any the value of the key or null if the key is not found
	 * @usage locate('key.subkey.subsubkey.waydowndeepsubkey')
	 **/
	any function locate(string key){
		var document=this.get_document();

		//if we have an existing document key with that name, return it
		if(structKeyExists(document,ARGUMENTS.key)){
			return document[ARGUMENTS.key];
		} else {
			var mappings = structFindValue(get_map(),key,"ALL");
			//return a null if we have no mapping
			var keyName = ARGUMENTS.key;
			for(var map in mappings){
				if(structKeyExists(map.owner,'parent') && map.owner.name == ARGUMENTS.key){
					keyName = map.owner.parent & '.' & ARGUMENTS.key;
				}
			}

			if(isDefined('document.#keyName#')){
				return evaluate('document.#keyName#');
			}
		}
		
		return;
	}


	/**
	 * Returns the default property value
	 *
	 * Used to populate the document defaults
	 **/
	any function getPropertyDefault(prop){
		var empty_string='';
		if(structKeyExists(prop,'default')){
			if(structKeyExists(prop,'validate')){
				switch(prop.validate){
					case "boolean":
						return javacast('boolean',prop.default);
					default:
						return prop.default;
				}	
			} else {
				return prop.default;
			}
			
		} else if(structKeyExists(prop,'validate')) {
			switch(prop.validate){
				case 'string':
					return empty_string;
				case 'numeric':
				case 'float':
				case 'integer':
					return 0;
				case 'array':
					return arrayNew(1);
				case 'struct':
					return structNew();
				default:
					break;
			}
		}
		return empty_string;

	}

	/**
	 * Handles correct formatting of geoJSON objects
	 *
	 * @param array coordinates - an array of coordinates (e.g.: [-85.570381,42.9130449])
	 * @param array [type="Point"] - the geometry type < http://docs.mongodb.org/manual/core/2dsphere/#geojson-objects >
	 **/
	any function toGeoJSON(array coordinates,string type='Point'){
		var geo={
				"type"=ARGUMENTS.type,
				"coordinates"=ARGUMENTS.coordinates
			};
		/**
		* serializing and deserializing ensures our quoted keys remain intact in transmission
		**/
		return(deserializeJSON(serializeJSON(geo)));
	}

	/**
	 * SQL to Mongo ordering translations
	 **/
	 numeric function mapOrder(required order){
		return getMongoUtil().mapOrder(argumentCollection=arguments);
	 }

	/**
	* Returns the Mongo.Collection object for advanced operations
	* facade for getDBInstance()
	**/
	any function getCollectionObject(){
		return this.getDBInstance();
	}

	/**
	* facade for Mongo.Util.toMongo
	* @param mixed arg 		The struct or array to convert to a Mongo DBObject
	**/
	any function toMongo(required arg){

		return getMongoUtil().toMongo(arg);

	}

	/**
	* facade for Mongo.Util.toMongoDocument
	* 
	* @param struct arg 	The struct to convert to a MongoDB Document Object
	**/
	any function toMongoDocument(required struct arg){

		return getMongoUtil().toMongoDocument(arg);

	}

}
