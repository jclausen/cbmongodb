/**
 * GEO Active Entity Service for MongoDB
 *
 * Extends the core ActiveEntity to provide geospatial querying
 *
 * @author Jon Clausen <jon_clausen@silowebworks.com>
 **/
component name="GEOEntityService" extends="cbmongodb.models.ActiveEntity" {

	/**
	 *  that a field of the active entity is within another field
	 *
	 * @param string key - the key of the active entity to use
	 * @param string collection - the collection to be queried (optional - the xKey param may contain the collection as the first dot notation element)
	 * @param string xKey - the key of the remote collection to use
	 *
	 * @usage
	 **/
	public function within(required key,xKey){
		//this.where(,)
	}


	public function intersects(){

	}
}