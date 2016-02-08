/**
* GEO Active Entity Service for MongoDB
*
* Extends the core ActiveEntity to provide geospatial querying
*
* @package cbmongodb.models
* @author Jon Clausen <jon_clausen@silowebworks.com>
* @license Apache v2.0 <http://www.apache.org/licenses/>
*/
component name="GEOEntityService" extends="cbmongodb.models.ActiveEntity" accessors="true" {

	/**
	 *  that a local entity is contains a foreign object
	 *
	 * @param string key - The key of the active entity to use
	 * @param string xKey - The model to use in the format [model].[property/field] (if the model is passed as 'this' the current collection will be used)
	 * @param boolean reduce - Whether to perform the query as a map reduce. Map reductions take more time but may be re-used
	 *
	 * @return object returns the model being queried
	 * @usage   city.where('status','At Home').within('geometry','Person.address.location').findAll();
	 **/
	public function within(required key, xKey, reduce=false){
		return this.comparison('$geoWithin',arguments.key,arguments.xKey,arguments.reduce);
	}

	/**
	 * That the geometry of a foreign field intersect a local one (or vice-versa)
	 *
	 *
	 * @param string key - The key of the active entity to use
	 * @param string xKey - The key of the remote collection to use in the format [collection].field[.subfield (if the collection is passed as 'self' the current collection will be used)
	 * @param boolean reduce - Whether to perform the query as a map reduce. Map reductions take more time but may be re-used
	 *
	 * @reversible the foreign key may be passed as the local key
	 * @usage   this.where('road.construction',FALSE).intersects('road.geometry','commuters.route').findAll()
	 **/
	public function intersects(required key, xKey, reduce=false){
		return this.comparison('$geoIntersects',arguments.key,arguments.xKey,arguments.reduce);
	}

	/**
	*
	* Returns documents which are near to geometry object in ascending proximity
	*
	* @param string key - The key of the active entity to use
	* @param string xKey - The key of the remote collection to use in the format [collection].field[.subfield (if the collection is passed as 'self' the current collection will be used)
	* @param boolean reduce - Whether to perform the query as a map reduce. Map reductions take more time but may be re-used
	* @usage   this.where('person.awake',true).whereNotI().near('person.location','person.location').findAll()
	**/
	public function near(required key, xKey, reduce=false){
		return this.comparison('$near',arguments.key,arguments.xKey,arguments.reduce);
	}

	/**
	 * That a local geometry is contained with a foreign object
	 *
	 * @param string key - The key of the active entity to use
	 * @param string xKey - The key of the remote collection to use in the format [collection].field[.subfield (if the collection is passed as 'self' the current collection will be used)
	 * @param boolean reduce - Whether to perform the query as a map reduce. Map reductions take more time but may be re-used
	 *
	 * @usage	this.where('city','Grand Rapids').where('state','Michigan').within('city.geometry','restaurants.location').findAll()
	 **/
	public function isWithin(required key, xKey, reduce=false){
		return this.comparison('$geoWithin',arguments.key,arguments.xKey,arguments.reduce);
	}

	/**
	* That a field is within a maximum distance of another
	*
	* @chainable
	* @param numeric distance - the maximum distance in units (meters) from the point or polygon boundary (for conversions, use the miles(),feet(), and km() functions)
	*
	* @usage this.near('state','County.geography').maxDistance(this.miles(50)).findAll()
	**/
	public function maxDistance(required distance){
		return this.distanceNear(distance);
	}

	/**
	* Specifies a minimum distance for a $near or $nearSphere operation
	*
	* @chainable
	* @param numeric distance - the maximum distance in units (meters) from the point or polygon boundary (for conversions, use the miles(),feet(), and km() functions)
	* @usage see maxDistance()
	**/
	public function minDistance(required distance){
		return this.distanceNear(distance,"$minDistance");
	}

	/**
	 * The distance operation used in minDistance() and maxDistance()
	 **/
	package function distanceNear(required distance,operator="$maxDistance"){
		var criteria=this.get_criteria();
		for(critter in criteria){
			if( isStruct(criteria[critter]) and structKeyExists(criteria[critter],'$near') ){
				criteria[critter]["$near"][arguments.operator]=arguments.distance;
			} else if (isStruct(criteria[critter]) and structKeyExists(criteria[critter],'$nearSphere')){
				criteria[critter]["$nearSphere"][arguments.operator]=arguments.distance;
			}
		}
		this.criteria(criteria);
		return this;
	}


	/**
	 *  The master comparison method
	 *
	 * @param string operation - the MongoDB spatial operation to use
	 * @param string key - The key of the active entity to use
	 * @param string xKey - The model to use in the format [model].[property/field] (if the model is passed as 'this' the current collection will be used)
	 * @param boolean reduce - Whether to perform the query as a map reduce. Map reductions take more time but may be re-used
	 *
	 * @return object returns the model being queried
	 **/

	package function comparison(required operation,required key, xKey, reduce=false){
		if(arguments.reduce)
			return this.geoReduce(arguments.key,argument.xKey);
		var xName=listGetAt(arguments.xKey,1,'.');
		var xProp=listDeleteAt(arguments.xKey,1,'.');
		//if we are using the self entity
		if(xName EQ 'this'){
			variables._keys=xProp;
			variables._criteria[xProp]={"#arguments.operation#"={"$geometry"=appropriate(arguments.operation,this.locate(arguments.key))}};
			return this;
		}

		var xEntity=this.getWirebox().getInstance(xName);
		var xCriteria=this.get_criteria();

		//it's faster to pull our local object and pass it to the remote
		var xArg=this.locate(arguments.key);

		if(isNull(xArg))
			throw(message="Invalid GEO Comparison",extendedInfo="The key <strong>#xProp#</strong> key was not found in the #xName# entity.");

		//merge our within query
		var searchGeometry = appropriate(arguments.operation,xArg);

		//throw an error if we don't have valid coordinates, to prevent a database error
		if((isArray(searchGeometry) and arrayLen(searchGeometry) == 0) || (isStruct(searchGeometry) and structIsEmpty(searchGeometry))){
			throw(message="Invalid GEO Comparison",extendedInfo="The #arguments.key# key for this entity did not contain valid coordinates. Are you sure you're working with a loaded object?");
		}
		xCriteria[xProp]={"#arguments.operation#"={"$geometry"=searchGeometry}};
		
		xEntity.criteria(xCriteria);

		return xEntity;
	}

	/**
	 *
	 **/
	public function appropriate(operation,geometry){
		
		var local_geometry=duplicate(geometry);

		//convert polygons to a centroid if we are near

		if(findNoCase('near',arguments.operation) and (local_geometry['type'] EQ "Polygon" OR local_geometry['type'] EQ "MultiPolygon")){
				local_geometry=polygonCenter(local_geometry);
		}

		return local_geometry;
	}

	/***************************** UTILS ****************************/
	/**
	 * pull the polygon information from a feature collection
	 *
	 * @param any features - the serialized or unserialized FC JSON object
	 * @return struct  GEOJSON struct if only one element in the collection or an array of GEOJSON structs if multiple elements
	 *
	 * @usage parseFeatureColection(fileOpen('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA.geo.json'))
	 **/
	public function parseFeatureCollection(any features){
		var featureCollection=[];
		if(isJSON(features))
			arguments.features=deSerializeJSON(arguments.features);
		if(structKeyExists(arguments.features,'features'))
			arguments.features=arguments.features.features;
		for(geometry in arguments.features){
			if(structKeyExists(geometry,'geometry') and arrayLen(arguments.features) EQ 1){
				return ensureGEOValid(geometry['geometry']);
			} else {
				arrayAppend(featureCollection,ensureGEOValid(geometry['geometry']));
			}
		}
		return featureCollection;
	}
	/**
	 * Finds the center point of a polygon
	 *
	 * @props http://stackoverflow.com/questions/3081021/how-to-get-the-center-of-a-polygon-in-google-maps-v3
	 **/
	public function polygonCenter(required polygon){
		low=arguments.polygon['coordinates'][1][1][1];
		high=arguments.polygon['coordinates'][1][1][1];
		for(point in arguments.polygon['coordinates'][1][1]){
			//x
			if(point[1]<low[1])
				low[1]=point[1];
			if(point[1]>high[1])
				high[1]=point[1];
			//y
			if(point[2]<low[2])
				low[2]=point[2];
			if(point[2]>high[2])
				high[2]=point[2];
		}

		center=[(low[1] + ((high[1] - low[1]) / 2)),(low[2] + ((high[2] - low[2]) / 2))];

		return this.toGEOJSON(center,'Point');
	}

	/**
	 * Validates geo data types to ensure they meet the engine storage requirements for indexing
	 **/
	public function ensureGEOValid(required geometry){
		var valid=arguments.geometry;
		switch(valid['type']){
			case "Polygon":
			case "MultiPolygon":
				//Close our polygons to make valid
				i=1;
				for(var featureCollection in valid['coordinates'][1]){
					poly_open=duplicate(featureCollection[1]);
					if(arrayToList(featureCollection[arrayLen(featureCollection)]) NEQ arrayToList(poly_open)){
						arrayAppend(valid['coordinates'][1][i],poly_open);
					}
					i=i+1;
				}
				break;
		}

		return valid;
	}

	/**
	* Converts a passed number of miles to meters
	*
	* @param numeric miles
	* @return numeric meters
	**/
	public function miles(miles){
		return (arguments.miles*1609.344);
	}

	/**
	* Converts a passed number of feet to meters
	*
	* @param numeric miles
	* @return numeric meters
	**/
	public function feet(feet){
		return (arguments.feet/0.3048);
	}

	/**
	* Converts a passed number of miles to meters
	*
	* @param numeric miles
	* @return numeric meters
	**/
	public function km(kilometers){
		return (arguments.kilometers/1000);
	}


}