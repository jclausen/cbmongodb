Changelog:
----------
**v3.2.1.1**

1. Syntax corrections
2. Reverts auto-eviction to pre-v3.2.0.4 spec to prevent removal of normalized data prior to `populate()`
3. Ensures legacy index names, which weren't keyed off of the collection are dropped and re-created using new naming conventions

**v3.2.1.0**

1. Updates Mongo Driver to v3.2.1.0
2. ACF11 compatibility updates
3. Refactors module to use coldbox module skeleton
4. Adds automated Travis CI builds and deployments for source and new `cbmongodb-be` slug to Forgebox

**v3.2.0.4**

1. Fixes a schema issue where a parent struct is being overwritten by the default container when the child attribute is lower aphabetically
2. Fixes an issue with unique validation
3. Fixes population issues when passing nested structs
4. Fixes issues with nested keys on normalization
5. Adds auto-eviction prior to population
6. Adds explicit closing to cursor use for single record retrieval
7. Changes index naming scheme to prevent different collections from having the same index name hash
8. Adds the ability to pass a struct as the first argument to `where()`

**v3.2.0.3**

1. Fixes ACF Compatibility Issues

**v3.2.0.2**

1. Fixes issues with unexpected driver return types
2. Adds `offset()` helper method (alias for `set_offset()`) to ActiveEntity
3. Adds `isObjectId()` helper method to MongoUtil for detecting whether an object is a Mongo _id string


**v3.2.0.1**

1. Fixes issues with module load/unload connection operations
2. Adds GridFS operational support
3. Adds GridFS FileEntity model
4. Fixes issues with `_id` queries not being typed appropriately
5. Fixes error when attempting to truncate a collection

**v3.2.0.0**

1. Updates MongoDB Java driver to version 3.2.0
2. Adds support for readConcern configuration option

**v3.1.0.4:**

1. Adds validation methods for entities and support for new property `ForceValidation`, which will prevent saving of documents which do not validate
2. Adds auto-normalization capabilities for schema properties.  When attributes are configured, schema will auto-normalize when set() and populate() methods are called.
3. Implements full support for component accessors on all schema properties.  Var safe accessor closures are generated to allow recursion through an underscore delimiter (e.g. `getFirstLevel_SecondLevel()` to retrieve `getDocument().FirstLevel.SecondLevel`)
4. Fixes native CFML data types not being sanitized on deeply nested structs and arrays.
5. Add getDocument() and asStruct() utility methods, which can be used on unloaded and unloaded entities.
6. Adds append() and prepend() functions to assit in managing document schema arrays.
7. Fixes issues with property maps not being defined correctly and correct casting of boolean property defaults.
8. Adds MongoIndexer singleton to delegate index management away from Entity instances.

**v3.1.0.3:**

1. Fixes issue with connections not being pooled accurately and adds connection closing to module unload
2. Moves module bindings to onLoad() to ensure availability of cbjavaloader module
3. Changes return type of all single record retrievals inserts and updates to native structs and adds auto-stringification of _id (eliminates the need for toString())
4. Ensures version of returned object from findOneAndUpdate/findOneAndReplace operations is the after-save version

**v3.1.0:**

1.  Removes Requirement For CFMongoDB Module
2.  Adds Requirement for CBJavaloader Module
3.  Implements MongoDB 3.0 Driver
4.  Implements the ability to use multiple databases
5.  Implements the ability to configure databases at the entity level
6.  Implements Native Collection Methods for the 3.0 MongoCollection
7.  Implements CFML [Aggregation](https://docs.mongodb.org/manual/aggregation/) methods while allowing direct access to native driver methods 
8.  Implements CFML [Map-Reduce](https://docs.mongodb.org/manual/core/map-reduce/) methods
9.  Demonstrates 52% reduction in query execution times and database operations from the previous version
10. Implements handlers for API documentation (/cmbongodb/docs) and Unit Tests (/cbmongodb/tests)
11. Fixes issue with near() GEOSpatial operations on Polygon objects
12. Re-factors Test Suite to Require the Framework Context
13. Adds an asJSON argument to find() and findAll() entity queries
14. Encapsulates all Collection Result queries to provide the following delivery methods:  .asResult() - MongoIterable,  .asCursor() - MongoIterator, .asArray(), asJSON()