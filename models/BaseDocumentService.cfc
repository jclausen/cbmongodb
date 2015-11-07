/**
*
* Core MongoDB Document Service
*
* @package cbmongodb.models
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
*/
component name="BaseDocumentService"  accessors="true"{
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
	 * The database client w/o a specified collection
	 **/
	property name="db";
	/**
	 * The collection to use for this instance.
	 * Override this in your model by specifying the collection to use
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
	 * The array which holds the ensured indexes.
	 *
	 * @example property name="myfield" schema=true index=true;
	 **/
	property name="_indexes";
	/**
	* The schema map which will be persisted for validation and typing
	**/
	property name="_map";

	/**
	 * Constructor
	 **/
	any function init(){
		/**
		*  Make sure our injected properties exist
		**/
		if(isNull(getWirebox()) and structKeyExists(application,'wirebox')){
			application.wirebox.autowire(target=this,targetID=getMetadata(this).name);
		} else {
			throw('Wirebox IOC Injection is required to user this service');
		}
		
		this.setMongoUtil(getMongoClient().getMongoUtil());
		this.setAppSettings(getWirebox().getBinder().getProperties());
		
		//Connect to Mongo
		this.setDb(this.getMongoClient());

		this.setDbInstance(this.getDb().getDBCollection(this.getCollection()));
		
		//Default Document Creation
		this.set_document(structNew());
		this.set_default_document(structNew());
		this.set_indexes(arrayNew(1));
		this.set_map(structNew());
		this.detect();

	}

	/*********************** INSTANTIATION AND OPTIMIZATION **********************/
	/**
	 * Evaluate our properties for the default document
	 **/
	any function detect(){

		var properties=getMetaData(this).properties;
		
		for(var prop in properties){
			
			if(structKeyExists(prop,'schema') and prop.schema){
				//add the property to your our map
				structAppend(this.get_map(),{prop.name=prop},true);
				
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
					//FIXME: Turning off for now
					this.applyIndex(prop,properties);
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
		var idx=structNew();
		var is_unique=false;
		var sparse=false;
		var background=true;
		if(structKeyExists(prop,'unique') and prop.unique){
			is_unique=true;
		}
		if(structKeyExists(prop,'indexwith') or structKeyExists(prop,'indexorder')){
			idx[prop.name]=this.indexOrder(prop);
			//Now test for a combined index
			if(structKeyExists(prop,'indexwith')){
				//re-find our relation since structFind() isn't reliable with nested structs
				for(var rel in properties){
					if(rel.name eq prop.indexwith){
						break;
					}
				}
				idx[rel.name]=this.indexOrder(prop);
			}
		} else {
			idx[arguments.prop.name]=this.indexOrder(prop);
		}

		//Check whether we have records and make it sparse if we're currently empty
		if(this.getDBInstance().count() EQ 0){
			sparse=true;
		}
		//create implicit name so we can overwrite sparse settings
		var index_name=hash(serializeJSON(idx));
		//add our index options

		var options = {
			"name":index_name,
			"sparse":sparse,
			"background":background,
			"unique":is_unique
		}

		arrayAppend(this.get_indexes(),options);
		if(!this.indexExists(index_name)){
			if(structKeyExists(prop,'geo')){
				this.getDBInstance().createGeoIndex(prop.name,options);
			} else {
				this.getDBInstance().createIndex(idx,options);
			}
		}
	}

	/**
	 * Returns whether the index exists
	 **/

	 public function indexExists(required name){
	 	var existing=this.getIndexInfo();
		for(idx in existing){
			if(structKeyExists(idx,'name') and idx['name'] EQ arguments.name) return true;
		}
		return false;
	 }

	/**
	 * Returns the index sort option
	 *
	 * @param any prop (e.g. - ASC/DESC||1/-1)
	 * @return numeric order
	 **/
	public function indexOrder(required prop){
		var order=1;
		if(structKeyExists(prop,'indexorder')){
			order=mapOrder(prop.indexorder);
		}
		return order;
	}

	public function getIndexInfo(){

		return getDbInstance().listIndexes();

	}


	/********************************** SETTERS ***********************************/

	/**
	 * Populate the document object with a structure
	 **/
	any function populate(required struct document){
		var dobj=structCopy(this.get_default_document());
		for(var prop in document){
			if(structKeyExists(dobj,prop) or structKeyExists(variables,prop))
				this.set(prop,document[prop]);
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
		return this;

	}

	/**
	 * Alias for get()
	 **/
	any function load(required _id,returnInstance=true){
		return this.get(arguments._id,arguments.returnInstance);
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


	/********************************* UTILS ****************************************/

	void function criteria(struct criteria){
		
		if(structKeyExists(arguments.criteria,'_id')){
			//exclude our nested query obects
			if(!isStruct(arguments.criteria['_id']) && isSimpleValue(arguments.criteria['_id']))
				arguments.criteria['_id']=getMongoUtil().newObjectIDfromID(arguments.criteria['_id']);
		}

		this.set_criteria(arguments.criteria);
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

		if(structKeyExists(document,arguments.key)){
			return document[arguments.key];
		} else {
			if(isDefined('document.#arguments.key#')){
				//FIXME evaluate()??!?
				return evaluate('document.#arguments.key#');
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
			return prop.default;
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
				"type"=arguments.type,
				"coordinates"=arguments.coordinates
			};
		/**
		* serializing and deserializing ensures our quoted keys remain intact in transmission
		**/
		return(deserializeJSON(serializeJSON(geo)));
	}

	/**
	 * The SQL to Mongo translated ordering statements
	 **/
	 numeric function mapOrder(required order){
		var map={'asc'=1,'desc'=2};
		if(isNumeric(arguments.order)){
			return arguments.order;
		} else if(structKeyExists(map,lcase(arguments.order))) {
			//FIXME?
			return javacast('int',map[lcase(arguments.order)]);
		} else {
			return map.asc;
		}
	 }

	any function toMongo(arg){

		return getMongoUtil().toMongo(arg);

	}

	any function toMongoDocument(arg){

		return getMongoUtil().toMongoDocument(arg);

	}

}