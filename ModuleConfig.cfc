/**
*
* <strong>CFMongoDB Module Configuration</strong>
*
* <p>A modification of the cfmongodb library for use as a Coldbox Module</p>
*
* @author Bill Shelton <bill@if.io>
* @author Marc Escher <marc.esher@gmail.com>
* @author Jon Clausen <jon_clausen@silowebworks.com>
*
* @link https://github.com/jclausen/cfmongodb [coldbox/master]
*/
component{

	// Module Properties
	this.title 				= "CBMongoDB";
	this.author 			= "Jon Clausen";
	this.webURL 			= "http://https://github.com/jclausen/cbmongodb";
	this.description 		= "Coldbox SDK and Virtual Entity Service for MongoDB";
	this.version			= "0.1";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= false;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = false;
	// Module Entry Point
	this.entryPoint			= "cbmongodb";
	// Model Namespace to use
	this.modelNamespace		= "cbmongodb";
	// CF Mapping to register
	this.cfmapping			= "cbmongodb";
	// Module Dependencies to be loaded in order
	this.dependencies 		= ['cfmongodb'];

	/**
	* Fired on Module Registration
	*/
	function configure(){}

	/**
	* Fired when the module is activated.
	*/
	function onLoad(){}

	/**
	* Fired when the module is unloaded
	*/
	function onUnload(){}

}