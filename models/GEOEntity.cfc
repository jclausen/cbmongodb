/**
 * GEO Active Entity Service for MongoDB
 *
 * Extends the core ActiveEntity to provide geospatial querying
 *
 * @author Jon Clausen <jon_clausen@silowebworks.com>
 * @license Apache v2.0 <http://www.apache.org/licenses/>
*/
component name="GEOEntityService" extends="cbmongodb.models.ActiveEntity" accessors=true {

	/**
	 *  that a local entity is within a foreign object
	 *
	 * @param string key - the key of the active entity to use
	 * @param string xKey - the key of the remote collection to use
	 *
	 * @usage   this.where('status','At Home').within('address.location','cities.grandrapids.geometry').findAll()
	 **/
	public function within(required key, xKey){

	}

	/**
	 * That the geometry of a foreign field intersect a local one (or vice-versa)
	 *
	 * @reversible the foreign key may be passed as the local key
	 * @usage   this.where('road.construction',FALSE).intersects('road.geometry','commuters.route').findAll()
	 **/
	public function intersects(required key, xKey){

	}

	/**
	*
	* Returns documents which are near to geometry object in ascending proximity
	*
	* @usage   this.where('person.awake',true).whereNotI().near('person.location','person.location').findAll()
	**/
	public function near(required key, xKey){

	}

	/**
	 * That a local collection geometry contains a foreign object
	 *
	 * @usage	this.where('city','Grand Rapids').where('state','Michigan').within('city.geometry','restaurants.location').findAll()
	 **/
	public function hasWithin(required key, xKey){


	}

	/**
	* That a field is within a maximum distance of another
	*
	* @usage near() with max distance
	**/
	public function maxDistance(required key, required distance,xKey){

	}

	/**
	* That a field is within a minium distance of a another
	*
	* @usage near() with max distance
	**/
	public function minDistance(required key, required distance,xKey){

	}

}