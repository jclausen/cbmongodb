component name="StatesMock" extends="cbmongodb.models.GEOEntity" accessors=true{
	property name="collection" default="states";
	property name="test_document" default="";
	/**Schema Properties**/
	property name="name" schema=true index=true validate="string";
	property name="abbr" schema=true index=true validate="string";
	property name="geometry" schema=true index="true" validate="array" geo=true geotype="MultiPolygon";
	property name="counties" schema=true index=true validate="array";

	any function init(){
		super.init();
		this.setTest_document({
		name='Michigan',
		abbr='MI',
		geometry=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI.geo.json'))
		});

	}
}