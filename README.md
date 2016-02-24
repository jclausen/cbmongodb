
MongoDB Module for Coldbox
==========================

CBMongoDB applies an Active Record pattern to manage MongoDB documents and schema.  It allows the use of a familiar syntax for CRUD operations, recordset processing and retrieval. 
The module makes direct use of and provides a CFML interface to the Mongo v3+ Java driver for advanced operations.

- <strong>Compatibility:</strong> ColdFusion 9.0.1+/Lucee 4.2+ w/ Coldbox 4+
- <strong>Module Version:</strong> 3.2.1.0 <em>(Release Date: 12/12/2015)</em>
- <strong>Mongo Java Driver Version:</strong> 3.2.1

Changelog:
----------
**v3.2.1.1**

1. Syntax corrections
2. Reverts auto-eviction to pre-v3.2.0.4 spec to prevent removal of normalized data prior to `populate()`

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


[Installation and Usage Instructions](https://github.com/jclausen/cbmongodb/wiki)
--------------------------------------------------------------------------------

<ul class="wiki-pages" data-filterable-for="wiki-pages-filter" data-filterable-type="substring">
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki" class="wiki-page-link">Home</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/1.-Installation-&amp;-Configuration" class="wiki-page-link">1. Installation &amp; Configuration</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/1A.-Advanced-Connections" class="wiki-page-link">1A. Advanced Connections</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/2.-Usage" class="wiki-page-link">2. Usage</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/2A.-Creating-Documents" class="wiki-page-link">2A. Creating Documents</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/2B.-Validation" class="wiki-page-link">2B. Validation</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/2C.-Loading-and-Querying-Documents" class="wiki-page-link">2C. Loading and Querying Documents</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/2E.-Deleting-Documents" class="wiki-page-link">2E. Deleting Documents</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/3.-GridFS-File-Storage" class="wiki-page-link">3. GridFS File Storage</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/4.-Geospatial-Functions" class="wiki-page-link">4. Geospatial Functions</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/5.-Map-Reduce" class="wiki-page-link">5. Map Reduce</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/6.-Aggregation" class="wiki-page-link">6. Aggregation</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/7.-Advanced-Usage" class="wiki-page-link">7. Advanced Usage</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/8.-Issues" class="wiki-page-link">8. Issues</a></strong>
    </li>
    <li>
      <strong><a href="https://github.com/jclausen/cbmongodb/wiki/9.-Get-Involved" class="wiki-page-link">9. Get Involved</a></strong>
    </li>
  </ul>

Issues
--------------

***NULL* support:** At the present time, in order to maintain compatibility for ACF, the conventions of this module assume a lack of full null support.  As such, testing for null values must be done with `len(field)`, and empty schema document properties are inserted as empty strings. The option for full null support is planned in a future patch.

Issues with the module may be [posted here](https://github.com/jclausen/cbmongodb).


Getting Involved
----------------

Fork -- Commit -- Request a pull, contributions are welcome. For bug fixes and feature additions, commits with unit tests written (cbmongodb/tests/specs/) would be peachy.  Feel free to add issues or feature suggestions as they arise in your development. 



