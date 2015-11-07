/**
*
* The Virtual Entity Service for the CFMongoDB Client
*
*
* @package cbmongodb.models
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
*/
component extends="cbmongodb.models.BaseDocumentService" accessors="true"{

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
	 * A separate collection to be queried
	 *
	 * As MongoDB doesn't support joins in the RDBMS fashion,
	 * we'll need to pass our active entity document objects rather than as comparisons
	 **/
	property name="xCollection";
	/**
	 * The map reduction
	 **/
	property name="xReduce";
	/**
	* Virtual Entity Constructor ( if you override it, make sure you call super.init() )
	* */

	function init(){
		super.init();
		this.criteria({});
		this.set_sort({});
		//Valid operators for where() clauses
		this.set_operators([
			'=',
			'!=',
			'>=',
			'<=',
			'<>',
			'like'
		]);

		return this;
	}

	/************************************** PUBLIC *********************************************/

	/**
	 * The master query method
	 **/
	any function query(struct criteria=get_criteria(),numeric offset=get_offset(),numeric limit=get_limit(),any sort=get_sort()){
		
		var results = this.getDBInstance().find(
			criteria,
			{"offset":arguments.offset,"limit":arguments.limit,"sort":arguments.sort}
		);
			
		this.resetQuery();

		return results;
	}

	/**
	 * Map reduce query method
	 **/
	any function mr(){
		//TODO: Implement
	}


	/**
	 * Save the current entity
	 * @param boolean upsert - insert the record if it does not exist
	 * @param boolean returnInstance - if passed as true, the loaded instance will be returned.  If false, the _id value will be returned.
	 * @param struct document - optionally pass a raw document to be saved
	 **/
	any function save(required document,upsert=false,returnInstance=false){
		
		var doc = getDbInstance().save(arguments.document,arguments.upsert);
		
		if(arguments.upsert){
			this.evict().load(doc);
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

		return this.save(this.get_document());
	}

	/**
	 * Creates
	 * @param boolean returnInstance - whether to return the loaded object. If false, the _id of the inserted record is returned
	 **/
	any function create(returnInstance=false,required document=get_document()){

		var doc = getDbInstance().insertOne(arguments.document);
		
		this.set_document(doc);
		
		this.set_id(doc['_id']);
		
		if(arguments.returnInstance) return this;

		return this.get_id().toString();
	}

	/**
	 * Aliase for update() with an explicit upsert argument
	 **/
	any function upsert(){

		return this.update(upsert=true);

	}

	any function where(string key,string operator='=',any value){
		if(key == '_id'){
			arguments.value = getMongoUtil().newObjectIdFromId(arguments.value);
		}
		if(!arrayFind(this.get_operators(),operator)){
			return this.where(key=key,value=operator);
		} else {
			var criteria=this.get_criteria();
			switch(arguments.operator){
				case '!=':
				case '<>':
					variables._criteria[arguments.key]={"$ne"=arguments.value};
					break;
				case '>':
					variables._criteria[arguments.key]={"$gt"=arguments.value};
					break;
				case '<':
					variables._criteria[arguments.key]={"$lt"=arguments.value};
					break;
				case '>=':
					variables._criteria[arguments.key]={"$gte"=arguments.value};
					break;
				case '<=':
					variables._criteria[arguments.key]={"$lte"=arguments.value};
					break;
				default:
					variables._criteria[arguments.key]=arguments.value;
					break;
			}
			this.criteria(criteria);
			return this;
		}
	}

	/**
	 * Convenience function to exclude the current active entity
	 *
	 * If the entity is not loaded, no query restrictions will be added
	 **/
	 any function whereNotI(){
		if(this.loaded()){

			this.where('_id','!=',this.get_id());

		}
		return this;
	 }

	/**
	 * Set maxrows|limit for query
	 *
	 * @chainable
	 **/
	any function limit(numeric max){

		this.set_limit(arguments.max);

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
		var results=this.limit(1).findAll();
		if(arrayLen(results)){
			this.entity(results[1]);
			if(!returnInstance)
				return results[1];
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
	any function findAll(asCursor=false,asResult=false){
		if(isNull(this.getXCollection())){
			var results=this.query();
		} else {
			var results=this.mr();
		}

		if(arguments.asResult)
			return results;

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

		if(!truncate and !this.loaded() and !this.criteriaExists()){
			//protect from an accidental truncation
			throw(type="InvalidData",message='No loaded record or criteria specified. If you wish to truncate this collection, pass the truncate=true flag to this method');
		
		} else if(!this.loaded() and this.criteriaExists()){
			//delete by criteria
			deleted=getDBInstance().remove(this.get_criteria());	
			this.reset();
		
		} else if(!this.loaded() and !this.criteriaExists() and truncate){
			//authorized truncation
			this.getDBInstance().remove();
		
		} else if(this.loaded()) {
			//defaults to delete by the loaded id
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

	/**************************** Cross Collection Queries ************************/

	any function join(required collection){
		this.setXCollection(arguments.collection);
		return this;
	}

	any function on(required key,operator='=',required xKey){
		if(isNull(this.getXCollection()))
			throw("The collection to be joined does not exist.  Please use the <strong>join(required collection)</strong> function to specify this collection before calling <strong>on()</strong>.");
		
		//TODO: this methodology needs to be adjusted so we can use this for many-to-many through relationship
		var mapkey=getMetaData(this).name&arguments.key&this.getXCollection()&operator&arguments.xKey;

		if(this.loaded()){
			mapkey=this.get_id()&mapkey;
		}

		var mr={
			'map'=hash(mapkey)
		};
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
		for(var record in doc){
			variables[record]=doc[record];
		}
	}

	any function clearScope(){
		//TODO: Clean up the encapsulation issues between the super scope and this
		this.resetQuery();
		this.set_id('');
		for(var prop in get_map()){
			this.set(prop,this.getPropertyDefault(variables._map[prop]));
		}
	}

	/**
	 * overload the upstream evict to clear query params
	 **/
	any function evict(){
		super.evict();
		this.clearScope();
	}


	any function resetQuery(evict=true){
		this.criteria(structNew());
		this.set_keys('');
		this.set_offset(0);
		this.set_limit(0);
		this.set_sort(structNew());
		//clear our cross-collection params
		structDelete(variables,'xCollection');
		structDelete(variables,'xReduce');
	}

	boolean function criteriaExists(){
		if(structIsEmpty(this.get_criteria()))
			return false;

		return true;
	}

}
