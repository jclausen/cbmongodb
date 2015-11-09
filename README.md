
MongoDB Module for Coldbox
==========================
CBMongoDB provides Active Record(ish) functionality for managing MongoDB documents and schema using a familiar syntax for CRUD operations and recordset processing and retrieval. 

- <strong>Compatibility:</strong> ColdFusion 9.0.1+/Lucee 4.2+ w/ Coldbox 4+
- <strong>Module Version:</strong> 3.1.0.1 <em>(Release Date: 11/09/2015)</em>
- <strong>Mongo Java Driver Version:</strong> 3.1.0
- <strong>Release Notes:</strong>

-- 1.  Removes Requirement For CFMongoDB Module
-- 2.  Adds Requirement for CBJavaloader Module
-- 3.  Implements MongoDB 3.0 Driver
-- 4.  Implements the ability to use multiple databases
-- 5.  Implements the ability to configure databases at the entity level
-- 6.  Implements Native Collection Methods for the 3.0 MongoCollection
-- 7.  Implements CFML [Aggregation](https://docs.mongodb.org/manual/aggregation/) methods while allowing direct access to native driver methods 
-- 8.  Implements CFML [Map-Reduce](https://docs.mongodb.org/manual/core/map-reduce/) methods
-- 9.  Demonstrates 52% reduction in query execution and database operational functions from the previous version
-- 10. Implements handlers for API documentation (/cmbongodb/docs) and Unit Tests (/cbmongodb/tests)
-- 11. Fixes issue with near() GEOSpatial operations on Polygon objects
-- 12. Re-factors Test Suite to Require the Framework Context
-- 13. Adds an asJSON argument to find() and findAll() entity queries
-- 14. Encapsulates all Collection Result queries to provide the following delivery methods:  .asResult() - MongoIterable,  .asCursor() - MongoIterator, .asArray(), asJSON()


Installation &amp; Configuration
--------------------------------

1. [Install MongoDB](http://docs.mongodb.org/manual/installation/) and start up an instance of `mongod` or sign up for a free account with a third party DB service like [MongoLab](https://mongolab.com/plans/)
2. Create a Coldbox application ( `box install coldbox && box coldbox create app` ) or use an existing one
3. With [CommmandBox](http://www.ortussolutions.com/products/commandbox) just type `box install cbmongodb` from the root of your project.
4. Add your settings (with your own config) within the settings struct config/Coldbox.cfc*

**Localhost Example Without Authentication**
	
```
MongoDB = {
	hosts= [
	{
		serverName='127.0.0.1',
		serverPort='27017'
	}
  ],
	db 	= "mydbname",
	viewTimeout	= "1000"
};
```



**Connection with Authentication Example**

<small>*Note that some third-party providers (e.g. [MongoLab](https://mongolab.com/plans/)) use the connnection database as the authentication database.  Nine times out of ten, however, the `authenticationDB` value will be &quot;admin&quot;. If you omit that host key, the connection will default to &quot;admin&quot;.*</small>
	
```
MongoDB = {
	hosts= [

	{
		serverName='ds012345.mongolab.com',
		serverPort='12345',
		username="myUsername",
		password="my53cUr3P455",
		authenticationDB="myremotedb"
	}
	
  ],
	db 	= "mydbname",
	viewTimeout	= "1000"
};
```

<small>*If using a connection which authenticates against an admin database, MongoDB will create your database if it doesn't exist automatically, so you can use any name you choose for your database (or collections) from the get-go.</small>

4. Extend your models to use the Active Entity service, add your collection attribute and, optionally, a database attribute - if not specified, the database from your configuration will be used

<em>
In your component attributes, you will also need to specify the collection to be used.  For those coming from relational databases, for our purposes, a collection is equivalent to a table.

Now all of our operations will be performed on the "peoplecollection" collection (which will created if it doesn't exist).
</em>

```
component name="MyDocumentModel" extends="cbmongodb.models.ActiveEntity" collection="peoplecollection" database="MyNewDatabase" accessors=true{

}
```


Usage
---------	
CBMongoDB will inspect your model properties to create your default document schema.  All you need to do is add `schema=true` to your property and it will be included with the default document.  You can either use a dot notation in the property name field for nested documents (infinite recursion) or specify `parent="myParentProperty"` (single-level recursion).  For example a contact property might be:
```
/**Schema Properties**/
property name="first_name" schema=true validate="string";
property name="last_name" schema=true valiate="string";
property name="address" schema=true validate="struct";
/**Use either dot notation in the name or specify a 'parent' attribute as ways of creating nested documents**/
/**Dot Notation Examples**
property name="address.street" schema=true validate="string";
property name="address.city" schema=true validate="string";
property name="address.state" schema=true validate="string" length=2;
property name="address.postalcode" schema=true validate="zipcode";
property name="address.country" schema=true validate="string";
/**Parent attribute**/
property name="phone" schema=true validate="struct";
property name="home" schema=true parent="phone" validate="telephone";
property name="work" schema=true parent="phone" validate="telephone";
property name="mobile" schema=true parent="phone" validate="telephone";
```
The major difference is that parent notation allows direct usage of the accessor (e.g. `this.getMobile()` ).  Dot notation, however, is more natural with the query syntax and is recommended.


CBMongoDB emulates many of the functions of the cborm ActiveEntity, to make getting started simple.  There is also a chainable querying syntax which makes it easy to incorporate conditionals in to your search queries. The following examples assume model inheritance.

Create a new document and then query for (we're maintaining case in this example, but it's not necessary if you've already mapped your schema properties, which maintain case automatically)
```
var person=this.populate({
	'first_name'='John',
	'last_name'='Doe',
	'testvar'='here',
	'address'={
		'street'='123 Anywhere Lane',
		'city'='Grand Rapids',
		'state'='Michigan',
		'postalcode'='49546',
		'country'='USA'
	},
	'phone'={
		'home'='616-123-4567',
		'work'='616-321-7654',
		'mobile'='616-987-6543'
	}
	}).create();
```
Once we've created the document, it becomes the Active Entity.
```
var is_loaded=person.loaded(); //will return true	
```

There is a special `_id` value that is created by MongoDB when the document is inserted.  This can serve as your "primary key" (e.g. - when you query for it directly, Mongo is really, really fast):
```
var pkey=person.get_id();
```

or you can add human readable unique values (tags/slugs) and index them:
```
property name="tag" schema=true index=true;
```

Now let's reset our entity and re-find it.  The where() method accepts either where('name','value') arguments or where('name','operator','value') <sup>[1](#fn1)</sup>
```
person = person.reset().where('first_name','John').where('last_name','Doe').find();
```

Let's change our phone number
```
person.set('phone.home','616-555-8789').update();
```

We can use our dot notation to find that record again
```
person = person.reset().where('phone.home','616-555-8789').find()
```

Now let's duplicate that document so we can play with multiple record sets
```
var newperson = structCopy(person.get_document());

structDelete(newperson,'_id');

newperson = this.reset().populate(newperson).set('first_name','Jane').set('last_name','Doe').create();
```

Now we can find our multiple records - which will return an array (Note: I probably don't need to use reset(), but it's a good practice to clear any active query criteria from previous queries)

```
var people = this.reset().find_all();	

for(var peep in people){
	writeOutput("#peep.first_name# #peep.last_name# is in the house!");
}
```

Here's where we diverge from RDBMS:  MongoDB uses a "cursor" on multiple record sets.  It is extremely fast (with some limitations) and, if you're going be looping through a large number of documents, is the way to go. Because of the way the cursor is designed, it doesn't actually start executing queries on the database until the first time a record is requested.  If we use the "asCursor" argument in find_all([boolean asCursor]), we recevie the cursor back:

```
var people = this.reset().find_all(true);  //or find_all(asCursor=true), if you're feeling verbose	

while(people.hasNext()){
	var peep=people.next();
	writeOutput('#peep.first_name# #peep.last_name# is in the house!');
}
```	

Lastly, let's clean up our test documents.  The `delete()` function allows a boolean of "truncate" which defaults to FALSE. If you set this argument to true, without a loaded record or existing criteria, it will delete all documents from the collection.  In this case, we're just going to delete our records one at a time, using our cursor:

```
var people = this.reset().find_all(true);

while(people.hasNext()){
	var peep=people.next();
	//notice how we're using bracket notation for our _id value. This is necessary because calling peep._id on the cursor object will throw an error  
	this.get(peep['_id']).delete();
}
	
```

Optionally, you could delete all records matching a given criteria using a where() clause:
```
var noDoes = this.reset().where('last_name','Doe').delete();
```

That's basic CRUD functionality.  Read the API documentation for details on the individual functions and arguments.

Aggregation
-----------

[Aggregation](https://docs.mongodb.org/manual/aggregation/) of your results allows you to filter, calculate new values and group them in a result set.

CBMongoDB has suppoort for the aggregation methods of $group, $match, $projection (along with $sort) in its Collection object.

Here's an example, using our people collection.  In this case we want to return a query that returns the number of people, by Zip Code, in Grand Rapids, Michigan.  Our aggregation query would be assembled like so:


```
//We'll need our db collection object for this operation
var Collection = people.getDBInstance();

//Match Grand Rapids, Michigan
var agMatch={"city":"Grand Rapids","state":"Michigan"};

//Create the group parameters for our results.  Note the self-referential use of "$" before postalcode
var agGroup={"_id":"$postalcode","count":{"$sum":1}};
//Sort those records ascending
var agSort={"_id":1};
var aggregation = Collection.aggregate(
	criteria=agMatch,
	group=agGroup,
	sort=agSort
);

```

This would return a result in which the result array (represented as JSON below), would look like:

```
[
	{
		"_id":49503,
		"count":25
	},
	{
		"_id":49506,
		"count":15
	},
	{
		"_id":49512,
		"count":1
	}
]
```


For more information on Aggregation functionality see the API docs for the module and view [Mongo's Documentation](https://docs.mongodb.org/manual/aggregation/).

Map-Reduce
----------

[Map-Reduce](https://docs.mongodb.org/manual/core/map-reduce/) functionality expands aggregation by allowing you uto use javascript to return customized results. 

Using the people collection, again, let's perform the same aggregation function  using Map-Reduce:

```
//We'll need our db collection object again
var Collection = people.getDBInstance();
//Define our mapping function, which emits the records we will reduce
var map="
	function(){
		if(this.city === 'Grand Rapids' && this.state === 'Michigan') emit(this._id,this.iteration)
	}
";

//Define our reduction of those mapped records, which duplicates our aggregation functionality and key names
var reduce = "
	function(key,iterations){
	    var groupedZipCodes = [];
		for (var i in iterations){
			var existing = groupZipCodes.find(function (d) {
			    return d.postalcode === iterations[i].postalcode;
			});
			if(typeof(existing === 'undefined')){
				groupedZipCodes.push({"_id":iterations[i].postalcode,"count":1});	
			} else {
				//we can modify this by reference
				existing.count++;
			}
		} 
		return groupedZipCodes;
	}
";

//Finally Run our query, which will produce the same result as aggregate()
var reduction = Collection.mapReduce(map,reduce);
```

For more information on how to use Map-Reduce, see [Mongo's documentation examples](https://docs.mongodb.org/manual/tutorial/map-reduce-examples/).



Geospatial Functions
--------------------
To enable geospatial operations in your models, you will need to use `extends="cbmongodb.models.GEOEntity"` as your model inheritance.  MongoDB handles geospatial data in GEOJSON format, and there are a number of spatial libraries available on GitHub (e.g. - we use [this basic world map](https://github.com/johan/world.geo.json) in our unit tests).

First you'll need to define the geospatial properties in your model. Let's add the following to our address property from above:
```
property name="address.location" schema=true index=true validate="array" geo=true geotype="Point";
```

With this, the object will be instantiated as a special type.  If `index=true` is specified a geospatial index will be created on that document field using the "geotype" attribute as the the spatial type.  Setting the index flag, however, will also prevent you from storing objects which don't meet the database specification for that type (e.g. - all polygons have to be closed, which means the starting coordinate and ending coordinate need to be the same).

Now let's create a model (in this example, we'll use one of our test mocks):
```
component name="States" extends="cbmongodb.models.GEOEntity" accessors=true{
	property name="collection" default="states";
	/**Schema Properties**/
	property name="name" schema=true index=true validate="string";
	property name="abbr" schema=true index=true validate="string";
	property name="geometry" schema=true index="true" validate="array" geo=true geotype="MultiPolygon";
}
```

Just instantiating the component takes care of the indexing. Now we'll create a state:
```
states=getModel("States");
michigan = states.populate({
		name='Michigan',
		abbr='MI',
		geometry=states.parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI.geo.json'))
		})
		.create();
```
*Note: In the above, we loaded our data from a the remote repository. Loading remote datasets at runtime isn't a good idea (read "very bad idea"), but you can use them to populate your data collections. If your remote data is formatted in a feature collection, make sure to use the parseFeatureCollection() helper method.* 

The create() returns our _id value, so let's load up our entity:
```
michigan = states.get(michigan);
```
First we'll find all of the people in michigan:
```
people=michigan.within('geometry','Person.address.location').findAll(); 
```
Note that "michigan" is still loaded, but once we call the near/far spatial operator, the instance returned is the "far" entity.  Any where() clauses before or after the spatial comparison method will be exectuted on the far entity. The above might return a large recordset so let's restrict that a bit.  (We'll use our spatial query to prevent loading folks from Grand Rapids, Minnesota):
```
gr_peeps=michigan.where('address.city','Grand Rapids').within('geometry','People.address.location').findAll();
```

Now let's looks at those some of those people returned.  In this case we'll take our first person and see all of the other people within a 10 mile radius.
```
some_person=gr_peeps[1];
nearby_peeps=some_person
	.whereNotI()
	.near('address.location','this.address.location')
	.maxDistance(gr_peeps.miles(10))
	.findAll();
```
*Note: We used a helper method of `whereNotI()` which excludes the active entity from being returned in the results.  We also used a helper method `miles()` to convert miles to meters, which is the default unit measurement for [WGS84](http://en.wikipedia.org/wiki/World_Geodetic_System) projected data.  There are equivalent helper methods of `feet()` and `km()`.*

*Function note: `near()` operations can only be performed, at this time, if the "far" field being compared is a point.  If the "near" field is a polygon, a center point will be generated for comparison.*

Currently all of the MongoDB supported core spatial functions are represented, including `intersects()` so feel free to browse the many free data sets on GitHub and play around.

Advanced Usage
-------------

1. Explore the API Documentation by navigating, from the webroot of your Coldbox App, to [index.cfm - which you may need if you're not using SES]/cbmongodb/docs
2. All of the driver native methods are available through the collection object, as well as is direct access to the driver collection object.  For more information, [check out the Mongo Driver Documentation](http://mongodb.github.io/mongo-java-driver/3.0/driver/getting-started/quick-tour/).


Issues
--------------

***NULL* support:** At the present time, in order to maintain compatibility for ACF, the conventions of this module assume a lack of full null support.  As such, testing for null values must be done with `len(field)`, and empty schema document properties are inserted as empty strings. The option for full null support is planned in a future patch.

Issues with the module may be [posted here](https://github.com/jclausen/cbmongodb).


Getting Involved
----------------

Fork -- Commit -- Request a pull, either to the upstream project or to this one (upstream changes are merged weekly). For bug fixes and feature additions, commits with unit tests written (cbmongodb/tests/specs/) would be peachy.

------------------------------------------------------------

<a id="fn1"></a>
<sup>1</sup> <small>Valid operators currently include "=","!=","<",">",">=","<=","IN" and "Exists"</small>

