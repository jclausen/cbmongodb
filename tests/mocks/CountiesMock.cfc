component name="CountiesMock" extends="cbmongodb.models.GEOEntity" database="cbmongo_unit_tests" accessors=true{
	/**
	* Leave our collection property in place to ensure backward compatibility
	* @deprecated
	**/
	property name="collection" default="counties";
	property name="test_documents" default="";
	/**Schema Properties**/
	property name="name" schema=true index=true validate="string";
	property name="geometry" schema=true index=true validate="array" geo=true geotype="MultiPolygon";


	function getTestDocuments(){
		return [
			{'name'='Kent','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Kent.geo.json'))},
			{'name'='Newaygo','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Newaygo.geo.json'))},
			{'name'='Ionia','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Ionia.geo.json'))},
			{'name'='Kalamazoo','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Kalamazoo.geo.json'))}
		  ];
	}
}