component name="BaseDocumentService"  accessors="true"{
	/**
	 * Injected Properties
	 **/
	property name="wirebox" inject="wirebox";
	property name="logbox" inject="logbox";
	property name="appSettings";

	/**
	 * The MongoDB client
	 **/
	property name="MongoClient" inject="MongoClient@cfMongoDB";

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
	 * The database instance to perform operations on
	 **/
	property name="dbInstance";
	/**
	 * The container for the default document
	 * Override this in your models to create the schema of required fields
	 **/
	property name="_default_document";
	/**
	 * for the active document entity
	 **/
	property name="_document";
	/**
	 * the loaded document before modifications
	 **/
	property name="_existing";
	/**
	 * Validation structure
	**/
	property name="_validation";
	/**
	 * An array to contain our indexes
	 **/
	property name="_indexes";


	any function init(){
		/**
		*  Make sure our injected properties exist
		**/
		if(isNull(getWirebox()) and structKeyExists(application,'wirebox')){
			application.wirebox.autowire(target=this,targetID=getMetadata(this).name);
		} else {
			throw('Wirebox IOC Injection is required to user this service');
		}
		this.setAppSettings(getWirebox().getBinder().getProperties());
		//Connect to Mongo
		this.setDb(this.getMongoClient());
		this.setDbInstance(this.getDb().getDBCollection(this.getCollection()));
		//Default Document Creation
		this.set_document(structNew());
		this.set_default_document(structNew());
		this.set_indexes(arrayNew(1));
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
					//this.applyIndex(prop,properties);
				}
			}
		}
		this.set_default_document(this.get_document());
	}


	/********************************* INDEXING **************************************/
	/**
	 * Create and apply our indexes
	 *
	 * @param struct prop - the component property structure
	 * @param struct properties - the full properties structure (only required if prop contains and "indexwith" attribute
	 *
	 * @FIXME Javacasting issues with array
	 **/
	public function applyIndex(required prop,properties=[]){
		var idx=arrayNew(1);
		var is_unique=false;
		if(structKeyExists(prop,'unique') and prop.unique){
			is_unique=true;
		}
		if(structKeyExists(prop,'indexwith') or structKeyExists(prop,'indexorder')){
			arrayAppend(idx,{"#prop.name#"=this.indexOrder(prop)});
			//Now test for a combined index
			if(structKeyExists(prop,'indexwith')){
				//re-find our relation since structFind() isn't reliable with nested structs
				for(var rel in properties){
					if(rel.name eq prop.indexwith){
						break;
					}
				}
				arrayAppend(idx,{'#rel.name#'=this.indexOrder(prop)});
			}
		} else {
			arrayAppend(idx,arguments.prop.name);
		}

		if(structKeyExists(prop,'geo')){
			try{
				this.getDBInstance().ensureGeoIndex(idx,is_unique);
			} catch(any e){
				throw("Geo Index on #arguments.prop.name# could not be created.  The error returned was: <strong>#e.message#</strong>");
			}
		} else {
			try{
				this.getDBInstance().ensureIndex(idx,is_unique);
			} catch(any e){
				writeDump(e);
				abort;
			}
		}
	}

	public function indexOrder(required prop){
		var order=1;
		if(structKeyExists(prop,'indexorder')){
			order=mapOrder(prop.indexorder);
		}
		return order;
	}


	/********************************** SETTERS ***********************************/

	/**
	 * Populate the document object with a structure
	 **/
	any function populate(required struct document){
		var dobj=structCopy(this.get_default_document());
		this.reset();
		structAppend(dobj,document,true);
		this.set_document(dobj);
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
		var results=this.getDBInstance().findById(arguments._id);
		if(!isNull(results)){
			this.entity(results);
			if(!returnInstance){
				return results;
			}
		}
		return this;
	}
	/**
	 * Deletes a document by ID
	 **/
	any function delete(required _id){
		var deleted=(this.getDBInstance().removeById(arguments['_id']).getN() eq 1);
		return deleted;
	}


	/********************************* UTILS ****************************************/

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


}