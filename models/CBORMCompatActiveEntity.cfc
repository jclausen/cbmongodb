/**
*
* CBORM Compatible ActiveEntity Service
*
* Mimics the functionality of the CBORM Active Entity Methods
*
* @package cbmongodb.models
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
*
*/
component extends="cbmongodb.models.ActiveEntity"{
	/************************************ CBORM Compat VES Methods********************************/
	any function list(struct criteria=get_criteria(),keys=get_keys(),numeric offset=get_offset(),numeric limit=get_limit(),any sort=get_sort(),boolean asQuery=getDefaultAsQuery()){
		 results=this.query(argumentCollection=arguments);
		 if(ARGUMENTS.asQuery()){
		 	results=this.convertToQuery(results);
		 }
		 return results;
	}


	any function findWhere(required struct criteria){
		this.criteria(ARGUMENTS.criteria);
		return this.query();
	}

	array function findAllWhere(required struct criteria, string sortOrder=""){
		this.criteria(ARGUMENTS.criteria);
		if(len(ARGUMENTS.SortOrder)){
			var sort=listToArray(ARGUMENTS.sortOrder,' ');
			
			this.setSort({sort[1]=sort[2]});
		}
		return this.query();
	}


	//TODO: Figure
	any function new(struct properties=structnew(), boolean composeRelationships=true, nullEmptyInclude="", nullEmptyExclude="", boolean ignoreEmpty=false, include="", exclude=""){

	}


	boolean function exists(required any id) {
		ARGUMENTS.entityName = this.getEntityName();
		return super.exists(argumentCollection=arguments);
	}

	any function get(required any id,boolean returnNew=true) {
		ARGUMENTS.entityName = this.getEntityName();
		return super.get(argumentCollection=arguments);
	}

	array function getAll(any id,string sortOrder="") {
		ARGUMENTS.entityName = this.getEntityName();
		return super.getAll(argumentCollection=arguments);
	}

	numeric function deleteAll(boolean flush=false,boolean transactional=getUseTransactions()){
		ARGUMENTS.entityName = this.getEntityName();
		return super.deleteAll(ARGUMENTS.entityName,ARGUMENTS.flush);
	}

	boolean function deleteByID(required any id, boolean flush=false,boolean transactional=getUseTransactions()){
		ARGUMENTS.entityName = this.getEntityName();
		return super.deleteByID(argumentCollection=arguments);
	}

	any function deleteByQuery(required string query, any params, numeric max=0, numeric offset=0, boolean flush=false, boolean transactional=getUseTransactions() ){
		ARGUMENTS.datasource = this.getDatasource();
		return super.deleteByQuery(argumentCollection=arguments);
	}

	numeric function deleteWhere(boolean transactional=getUseTransactions()){
		ARGUMENTS.entityName = this.getEntityName();
		return super.deleteWhere(argumentCollection=arguments);
	}

	numeric function count(string where="", any params=structNew()){
		ARGUMENTS.entityName = this.getEntityName();
		return super.count(argumentCollection=arguments);
	}

	numeric function countWhere(){
		ARGUMENTS.entityName = this.getEntityName();
		return super.countWhere(argumentCollection=arguments);
	}

	void function evict(string collectionName, any id){
		ARGUMENTS.entityName = this.getEntityName();
		super.evict(argumentCollection=arguments);
	}

	any function clear(string datasource=this.getDatasource()){
		return super.clear(argumentCollection=arguments);
	}

	boolean function isSessionDirty(string datasource=this.getDatasource()){
		ARGUMENTS.datasource = this.getDatasource();
		return super.isSessionDirty(argumentCollection=arguments);
	}

	struct function getSessionStatistics(string datasource=this.getDatasource()){
		ARGUMENTS.datasource = this.getDatasource();
		return super.getSessionStatistics(argumentCollection=arguments);
	}

	string function getKey(){
		return super.getKey( this.getEntityName() );
	}

	array function getPropertyNames(){
		return super.getPropertyNames(this.getEntityName());
	}

	string function getCollectionName(){
		return this.getCollection());
	}

}
}