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
component name="MongoIndexer" accessors="true" scope="cachebox"{
	property name="mongoUtil" inject="id:MongoUtil@cbmongodb";
	
	public function init(){
		structAppend(variables,{
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
		var idx 		= {};
		var is_unique 	= false;
		var sparse 		= false;
		var background 	= true;

		if(structKeyExists(prop,'unique') and prop.unique){
			is_unique=true;
		}
		
		if(structKeyExists(prop,'indexwith') or structKeyExists(prop,'indexorder')){
			idx[prop.name] = this.indexOrder(prop);
			
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
			idx[arguments.prop.name] = this.indexOrder(prop);
		}

		//Check whether we have records and make it sparse if we're currently empty
		if(arguments.dbInstance.count() EQ 0){
			sparse=true;
		}
		
		//create implicit name so we can overwrite sparse settings
		var index_name=hash(dbInstance.getCollectionName() & serializeJSON(idx));

		if(!arrayContains(variables.indexNames, index_name)){
			//add our index options
			var options = {
				"name":index_name,
				"sparse":sparse,
				"background":background,
				"unique":is_unique
			};

			/**
			* GeoSpatial Indexes have to Re-checked against the db every time, since they will not be created on empty collections
			**/
			if(!this.indexExists(arguments.dbInstance, index_name)){
				if(structKeyExists(prop,'geo')){
					structDelete(options,'sparse');
					//WriteLog(type="Error",  file="cbmongodb", text="prop-name: #prop.name#");
					arguments.dbInstance.createGeoIndex(prop.name, options);
				} else {
					//WriteLog(type="Error",  file="cbmongodb", text="prop-name: #idx.toString()#");
					arguments.dbInstance.createIndex(idx, options);
					arrayAppend(variables.indexMap, options);
					arrayAppend(variables.indexNames, options.name);
				}
			}

		}
	}

	/**
	 * Returns whether the index exists
	 **/

	 public function indexExists(required dbInstance, required name){
	 	var existing=this.getIndexInfo(arguments.dbInstance);
		
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
			order=mongoUtil.mapOrder(prop.indexorder);
		}

		return order;
	}

	public function getIndexInfo(required dbInstance){
		return arguments.dbInstance.getIndexInfo();
	}

	public function getMap(){
		return variables.indexMap;
	}

	public function getIndexNames(){
		return variables.indexNames;
	}
	
}
