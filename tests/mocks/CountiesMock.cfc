component name="CountiesMock" extends="cbmongodb.models.GEOEntity" accessors=true{
	property name="collection" default="counties";
	property name="test_documents" default="";
	/**Schema Properties**/
	property name="name" schema=true index=true validate="string";
	//FIXME: Index+Insert is failing with this
	property name="geometry" schema=true validate="array" geo=true geotype="MultiPolygon";

	any function init(){
		super.init();

		this.setTest_documents([
			{'name'='Kent','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Kent.geo.json'))},
			{'name'='Allegan','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Allegan.geo.json'))},
			{'name'='Ionia','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/Ionia.geo.json'))},
			{'name'='St.Clair','geometry'=parseFeatureCollection(fileRead('https://raw.githubusercontent.com/jclausen/world.geo.json/master/countries/USA/MI/St.%20Clair.geo.json'))}
		  ]);

	}
}