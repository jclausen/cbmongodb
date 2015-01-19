CFMongoDB for Coldbox
=====================

This library has been adapted for Coldbox from Bill Shelton and Marc Escher's excellent [cfmongodb project](https://github.com/marcesher/cfmongodb). CFMongoDB is both partial wrapper for the MongoDB Java driver and a document-struct mapper for ColdFusion. It attempts to remove the need for constant javacasting in your CFML when working with MongoDB. Additionally, there's a simple DSL which provides ColdFusion developers the ability to easily search MongoDB document collections.

CFMongoDB works with Adobe ColdFusion 9.0.1+ and Railo 3.2+

Installation &amp; Configuration
--------------------------------

1. First install [MongoDB](http://docs.mongodb.org/manual/installation/),
2. With [CommmandBox](http://www.ortussolutions.com/products/commandbox) just type `box install cfmongodb` from the root of your project.  Otherwise, download the source code and drop in your /modules directory.
3. Add the following (with your own config) to config/Coldbox.cfc*
	
<pre>
		MongoDB = {
			hosts		= [
							{
								serverName='127.0.0.1',
								serverPort='27017'
							}
						  ],
			db 	= "test",
			viewTimeout	= "1000"
		};
</pre>

<small>*MongoDB will create the db if it doesn't exist automatically, so you can use any name you choose for your database (or collections) from the get-go.</small>

4.  Call Mongo db from your controllers:

		variables.wirebox.getInstance('MongoClient@cfMongoDB')
		
		



Some Code
---------

Data can be created as a ColdFusion structure and persisted. Example:

<pre>
component name="MongoTester" accessors=true {
	property name="MongoClient" inject="MongoClient@cfMongoDB" setter=false;
	property name="collection" default="local";
	
	public function db(){
		return variables.MongoClient;
	}
	
	public function collection(){
		return this.db().getDBCollection(this.getCollection());
	}
	
	public function mongo_example(){
		col=this.collection();
		my_struct = {
  			name = 'Orc #getTickCount()#'
  			foo = 'bar'
  			bar = 123
  			'tags'=[ 'cool', 'distributed', 'fast' ]
		};

		col.save( my_struct );

		//query
		result = col.query().startsWith('name','Orc').find(limit=20);
		writeOutput("Found #result.size()# of #result.totalCount()# Orcs");

		//use the native mongo cursor. it is case sensitive!
		cursor = result.asCursor();
		while( cursor.hasNext() ){
  			thisOrc = cursor.next();
  		writeOutput(" name = #thisOrc['name']# <br>");
		}

		//use a ColdFusion array of structs. this is not case sensitive
		orcs = result.asArray();
		for(orc in orcs){
  			writeOutput(" name = #orc.name# <br>");
		}		
		
		return;
	
	}

}
</pre>

More Examples
-------------

See examples/gettingstarted.cfm to start.

Additional examples are in the various subdirectories in examples/

The Wiki
--------

Check out the base project wiki for additional info: "http://wiki.github.com/marcesher/cfmongodb/":http://wiki.github.com/marcesher/cfmongodb/

Getting Help
------------

We have a Google group: "http://groups.google.com/group/cfmongodb":http://groups.google.com/group/cfmongodb

Please limit conversations to MongoDB and ColdFusion. General MongoDB questions are best asked on the MongoDB group at "http://groups.google.com/group/mongodb-user":http://groups.google.com/group/mongodb-user

Posting Issues
--------------

Post issues with the core libraries to the github issue tracker for the [upstream project](https://github.com/marcesher/cfmongodb). Better: post fixes. Best: post fixes with unit tests. 

For issues with Colbox-specific functionality, post issues to the [forked repo issue tracker](https://github.com/jclausen/cfmongodb).

Getting Involved
----------------

Fork -- Commit -- Request a pull, either to the upstream project or to this one (upstream changes are merged weekly). For bug fixes and feature additions, commits with unit tests are much more likely to be accepted.

Code well.

