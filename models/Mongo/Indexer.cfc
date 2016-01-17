/**
*
* Mongo Indexer
*
* Maintains and Tracks Collection Indexes for MongoDB Collection Instances 
*
* @singleton
* @package cbmongodb.models.Mongo
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
* 
*/
component name="MongoIndexer" accessors=true scope="cachebox"{
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	
	public function init(){
		structAppend(VARIABLES,{
			"indexMap":[],
			"indexNames":[]
		});
	}

	/**
	 * Create and apply our indexes
	 *
	 * @param struct prop - the component property structure
	 * @param struct properties - the full properties structure (required if prop contains and "indexwith" attribute)
	 *
	 **/
	public function applyIndex(required dbInstance, required prop, properties=[]){
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
			idx[ARGUMENTS.prop.name]=this.indexOrder(prop);
		}

		//Check whether we have records and make it sparse if we're currently empty
		if(ARGUMENTS.dbInstance.count() EQ 0){
			sparse=true;
		}
		//create implicit name so we can overwrite sparse settings
		var index_name=hash(dbInstance.getCollectionName() & serializeJSON(idx));
		if(!arrayContains(VARIABLES.indexNames,index_name)){
			//add our index options
			var options = {
				"name":index_name,
				"sparse":sparse,
				"background":background,
				"unique":is_unique
			}

			/**
			* GeoSpatial Indexes have to Re-checked against the db every time, since they will not be created on empty collections
			**/
			if(!this.indexExists(ARGUMENTS.dbInstance,index_name)){
				if(structKeyExists(prop,'geo')){
					structDelete(options,'sparse');
					ARGUMENTS.dbInstance.createGeoIndex(prop.name,options);
				} else {
					ARGUMENTS.dbInstance.createIndex(idx,options);
					arrayAppend(VARIABLES.indexMap,options);
					arrayAppend(VARIABLES.indexNames,options.name);
				}
			}

		}
	}

	/**
	 * Returns whether the index exists
	 **/

	 public function indexExists(required dbInstance,required name){
	 	var existing=this.getIndexInfo(ARGUMENTS.dbInstance);
		for(idx in existing){
			if(structKeyExists(idx,'name') and idx['name'] EQ ARGUMENTS.name) return true;
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
			order=MongoUtil.mapOrder(prop.indexorder);
		}
		return order;
	}

	public function getIndexInfo(required dbInstance){

		return ARGUMENTS.dbInstance.getIndexInfo();

	}

	public function getMap(){
		return VARIABLES.indexMap;
	}

	public function getIndexNames(){
		return VARIABLES.indexNames;
	}
}
