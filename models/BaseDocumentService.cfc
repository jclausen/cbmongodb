component name="BaseDocumentService"  accessors="true"{
	/**
	 * Injected Properties
	 **/
	property name="wirebox" inject="wirebox";
	property name="logbox" inject="logbox";

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
	property name="default_document";
	/**
	 * for the active document entity
	 **/
	property name="_document";

	/**
	 * the loaded document before modifications
	 **/
	property name="_existing";


	any function init(){
		/**
		*  Make sure our injected properties exist
		**/
		if(isNull(getWirebox()) and structKeyExists(application,'wirebox')){
			application.wirebox.autowire(target=this,targetID=getMetadata(this).name);
		} else {
			throw('Wirebox IOC Injection is required to user this service');
		}
		//Connect to Mongo
		this.setDb(this.getMongoClient());
		this.setDbInstance(this.getDb().getDBCollection(this.getCollection()));
		//Default Document Creation
		this.set_document(structNew());
		this.setDefault_document(structNew());
		this.detect();
	}

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
			}
		}
		this.setDefault_document(this.get_document());
	}

	/********************************** SETTERS ***********************************/

	/**
	 * Populate the document object with a structure
	 **/
	any function populate(required struct document){
		var dobj=structCopy(this.getDefault_document());
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


}