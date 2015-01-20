/**
* Author      :	Jon Clausen <jon_clausen@silowebworks.com>
*
* Description :  This is a Virtual Entity Service for the MongodbClient
*/
component extends="cbmongodb.models.BaseDocumentService" accessors="true"{
	/**
	 * The id of the active entity
	 **/
	property name="_id";

	/**
	 * Default query arguments
	 **/
	property name="_criteria";
	property name="_keys" default="";
	property name="_offset" default=0;
	property name="_limit" default=0;
	property name="_sort";
	property name="_operators";

	/**
	* Virtual Entity Constructor ( if you override it, make sure you call super.init() )
	* */

	function init(){
		super.init();
		this.set_criteria({});
		this.set_sort({});
		//Valid operators for where() clauses
		this.set_operators([
			'=',
			'!=',
			'>=',
			'<=',
			'like'
		]);

		return this;
	}

	/************************************** PUBLIC *********************************************/

	/**
	 * The master query method
	 **/
	any function query(struct criteria=get_criteria(),keys=get_keys(),numeric offset=get_offset(),numeric limit=get_limit(),any sort=get_sort()){
		var results=this.getDbInstance().query()
		.find(criteria=arguments.criteria,keys=arguments.keys,skip=arguments.offset,limit=arguments.limit,sort=arguments.sort);
		this.resetQuery();
		return results;
	}

	/**
	 * Save the current entity
	 * @param boolean upsert - insert the record if it does not exist
	 * @param boolean returnInstance - if passed as true, the loaded instance will be returned.  If false, the _id value will be returned.
	 * @param struct document - optionally pass a raw document to be saved
	 **/
	any function save(upsert=false,returnInstance=false,document){
		var doc=this.getDBInstance().update(doc=this.get_document(),upsert=arguments.upsert);
		if(arguments.upsert){
			this.load(doc);
		}
		if(arguments.returnInstance){
			return this;
		}
		return this.get_id();
	}

	/**
	 * Updates the loaded record
	 *
	 * Alias for save() with an explicit
	 * @param returnInstance whether to return the loaded instance
	 **/
	any function update(returnInstance=false){
		return this.save(returnInstance=false);
	}

	/**
	 * Creates
	 * @param boolean returnInstance - whether to return the loaded object. If false, the _id of the inserted record is returned
	 **/
	any function create(returnInstance=false,document){
		if(!isNull(arguments.document)){
			this.set_document(arguments.document);
		}
		this.set_id(this.getDBInstance().save(this.get_document()));
		if(arguments.returnInstance)
			return this;
		return this.get_id().toString();
	}

	/**
	 * Aliase for update() with an explicit upsert argument
	 **/
	any function upsert(){
		return this.update(upsert=true);
	}


	/**
	 * reset the query params
	 *
	 * @chainable
	 **/
	any function reset(){
		this.evict();
		return this;
	}

	any function where(string key,string operator='=',any value){
		if(!arrayFind(this.get_operators(),operator)){
			return this.where(key=key,value=operator);
		} else {
			var criteria=this.get_criteria();
			variables._criteria[arguments.key]=arguments.value;
			this.set_criteria(criteria);
			return this;
		}
	}

	/**
	 * Set maxrows|limit for query
	 *
	 * @chainable
	 **/
	any function limit(numeric max){
		this.set_limit(arguments.limit);
		return this;
	}

	/**
	 * Set the order|sort for the upcoming query
	 *
	 * @chainable
	 **/
	any function order(key,direction){
		var sort=this.get_sort();
		arrayAppend(sort,{key=direction});
		this.set_sort(sort);
		return this;
	}

	/**
	 * Find one record and return the query
	 *
	 * @chainable
	 **/
	any function find(returnInstance=true){
		var results=this.getDbInstance().findOne(this.get_criteria());
		if(!isNull(results)){
			this.entity(results);
			if(!returnInstance)
				return results;
		} else if(!returnInstance){
			return;
		}
		return this;
	}


	/**
	 * Find all records matching the current query params
	 *
	 * @param boolean asCursor - whether to return the array as a Mongo cursor object (e.g. cursor.next())
	 *
	 **/
	any function findAll(asCursor=false){
		var results=this.query();
		if(asCursor)
			return results.asCursor();

		return results.asArray();
	}

	/**
	 * Test whether a record matching the current criteria exists
	 **/
	 boolean function exists(){
	 	 return (this.count() GT 0);
	 }

	 /**
	  * Count the records in the current query
	  **/
	 numeric function count(){
	 	return this.getDbInstance().count(this.get_criteria());
	 }

	/**
	 * Delete a document, with optional truncate flag
	 *
	 * @param boolean truncate - with this set to false, a delete will not proceed without either a loaded entity or an existing criteria
	 **/
	 boolean function delete(truncate=false){
		var deleted=false;
		if(!truncate and (!this.loaded() or !this.criteriaExists())){
			throw(type="InvalidData",message='No loaded record or criteria specified. If you wish to truncate this collection, pass the truncate=true flag to this method');
		} else if(!this.loaded() and this.criteriaExists){
			deleted=(this.getDBinstance().remove(this.get_criteria()).getN() eq 1);
			this.reset();
		} else {
			deleted=super.delete(this.get_id());
			this.reset();
		}
		return deleted;
	 }


	 /******************************Status Methods *******************************/

	 boolean function loaded(){
	 	 return (!isNull(this.get_id()) and structKeyExists(this.get_document(),'_id'));
	 }

	 any function reload(){
	 	 return this.where('_id',this.get_id()).find();
	 }

	/**************************** Package Methods *********************************/

	/**
	 * Scopes the active entity
	 **/
	any function entity(struct record){
		this.set_document(record);
		this.set_existing(record);
		this.scopeEntity(this.get_document());
	}

	any function scopeEntity(doc){
		for(record in doc){
			variables[record]=doc[record];
		}
	}

	/**
	 * Evicts the virtual entity and clears the query arguments
	 **/
	any function evict(){
		structDelete(variables,'_id');
		this.entity(this.getDefault_document());
		this.resetQuery();
	}


	any function resetQuery(evict=true){
		this.set_criteria(structNew());
		this.set_keys('');
		this.set_offset(0);
		this.set_limit(0);
		this.set_sort(structNew());
	}

	boolean function criteriaExists(){
		return structIsEmpty(this.get_criteria());
	}
}