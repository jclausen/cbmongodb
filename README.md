MongoDB Module for Coldbox
==========================

This module uses Bill Shelton and Marc Escher's excellent [cfmongodb project](https://github.com/marcesher/cfmongodb), which is a partial wrapper for the MongoDB Java driver and a document-struct mapper for ColdFusion. It attempts to remove the need for constant javacasting in your CFML when working with MongoDB. Additionally, there's a simple DSL which provides ColdFusion developers the ability to easily search MongoDB document collections.

Compatibility: ColdFusion 9.0.1+ and Railo 3.2+, Coldbox 4+

Installation &amp; Configuration
--------------------------------

1. [Install MongoDB](http://docs.mongodb.org/manual/installation/) and start up an instance of `mongod`
2. Perform a recursive clone `git clone --recursive git@github.com:jclausen/cbmongodb.git modules/cbmongodb` or, once it's added to Forgebox:
2. With [CommmandBox](http://www.ortussolutions.com/products/commandbox) just type `box install cbmongodb` from the root of your project.
3. Add the following (with your own config) to config/Coldbox.cfc*
	
<pre>
		MongoDB = {
			hosts		= [
							{
								serverName='127.0.0.1',
								serverPort='27017'
							}
						  ],
			db 	= "mydbname",
			viewTimeout	= "1000"
		};
</pre>

<small>*MongoDB will create your if it doesn't exist automatically, so you can use any name you choose for your database (or collections) from the get-go.</small>

4. Extend your models to use the Virtual entity service

		component name="MyDocumentModel" extends="cbmongodb.models.ActiveEntity" accessors=true{
		
		}


5. If you need to use cfmongodb client directly, you can also use:

		variables.wirebox.getInstance('MongoClient@cfMongoDB')
		
		



Usage
---------
In your model, you will need to specify the collection to be used.  For those coming from relational databases, for our purposes, a collection is equivalent to a table;
<pre>
		property name="collection" default="peoplecollection";
</pre>	
Now all of our operations will be performed on the "peoplecollection" collection.
	
CBMongoDB will inspect your model properties to create your default document schema.  All you need to do is add `schema=true` to your property and it will be included with the default document.  You can either use a dot notation in the property name field for nested documents (infinite recursion) or specify `parent="myParentProperty"` (single-level recursion).  For example a contact property might be:
<pre>
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
</pre>		
The major difference is that parent notation allows direct usage of the accessor (e.g. `this.getMobile()` ).  Dot notation, however, is more natural with the query syntax and is recommended.


CBMongoDB emulates many of the functions of the cborm ActiveEntity, to make getting started simple.  There is also a chainable querying syntax which makes it easy to incorporate conditionals in to your search queries.  Using inheritance, for example you could call
`
		//Create a new document and then query for (we're maintaining case in this example, but it's not necessary if you've already mapped your schema properties)
		var person=this.properties({
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

		//Once we've created the document, it will be returned as the active entity
		var is_loaded=person.loaded(); //will return true	
		
		//There is a special `_id` value that is created by MongoDB when the document is inserted.  This can serve as your "primary key" (e.g. - when you query for it directly, Mongo is super-duper fast):
		var pkey=person.get_id();
		
		//Now let's reset our entity and re-find it.  The where() method accepts either where('name','value') arguments or where('name','operator','value')
		person = person.reset().where('first_name','John').where('last_name','Doe').find();
		
		//Let's change our phone number
		person.set('phone.home','616-555-8789').update();
		
		//We can use our dot notation to find that record again
		person = person.reset().where('phone.home','616-555-8789').find()
		
		//Now let's duplicate that document so we can play with multiple record sets
		var newperson = structCopy(person.get_document());
		
		structDelete(newperson,'_id');
		
		newperson = this.reset().populate(newperson).set('first_name','Jane').set('last_name','Doe').create();
		
		//Now we can find our multiple records - which will return an array (Note: I probably don't need to use reset(), but it's a good practice to clear any active query criteria from previous queries)
		var people = this.reset().find_all();	
		
		for(var peep in people){
			writeOutput("#peep.first_name# #peep.last_name# is in the house!");
		}
`
Here's where we diverge from RDBMS:  MongoDB has a think called a "cursor" on multiple record sets.  It is also super-duper fast (with some limitations) and, if you're going be returning a large number of documents, is the way to go.  If we use the "asCursor" argument in find_all([boolean asCursor]), we recevie the cursor back:

`		var people = this.reset().find_all(true);  //or find_all(asCursor=true), if you're feeling verbose	
		
		while(people.hasNext()){
			var peep=people.next();
			writeOutput('#peep.first_name# #peep.last_name# is in the house!');
		}
`	
		

Issues
--------------
Post issues with the core libraries to the github issue tracker for the [cfmongodb project](https://github.com/marcesher/cfmongodb). 
For issues with CBMongoDB-specific functionality, post issues to the issue tracker(https://github.com/jclausen/cbmongodb).


Getting Involved
----------------

Fork -- Commit -- Request a pull, either to the upstream project or to this one (upstream changes are merged weekly). For bug fixes and feature additions, commits with unit tests are much more likely to be accepted.

Code well.

