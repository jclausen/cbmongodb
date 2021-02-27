component name="ActiveEntityMock" extends="cbmongodb.models.ActiveEntity" collection="people" database="cbmongo_unit_tests" accessors=true{
	property name="ForceValidation" default=true;
	property name="test_document" default="";
	//Schema Properties
	property name="first_name" schema index=true indexwith="last_name" indexorder="ASC" validate="string";
	property name="last_name" schema validate="string" indexsort="DESC";
	property name="address" schema validate="struct";
	//Use either dot notation in the name or specify a 'parent' attribute as ways of creating nested documents
	property name="address.street" schema validate="string";
	property name="address.city" schema validate="string";
	property name="address.state" schema validate="string" length=2;
	property name="address.postalcode" schema validate="zipcode";
	property name="country" schema parent="address" validate="string";
	property name="address.location" schema index="true" validate="struct" geo=true geotype="Point";
	property name="phone" schema validate="struct";
	property name="phone.home" schema required=true validate="telephone";
	property name="phone.work" schema validate="telephone";
	property name="phone.mobile" schema validate="telephone";

	//Auto Normalization Test Properties
	property name="county" schema validate="struct" normalize="Counties@CBMongoTestMocks" on="county.id" keys="name,geometry";
	property name="county.id" schema;
	property name="countyId" schema;
	property name="countyTwo" schema validate="struct" normalize="Counties@CBMongoTestMocks" on="countyId" keys="name,geometry";

	function getTestDocument(){
		return {
		'first_name'='firstname_'&toString(createUUID()),
		'last_name'='lastname_'&toString(createUUID()),
		'testvar'='here',
		'address'={
			'street'='123 Anywhere Lane',
			'city'='Grand Rapids',
			'state'='MI',
			'postalcode'='49546',
			'country'='USA',
			'location'=this.toGeoJSON([-85.570381,42.9130449])
		},
		'phone'={
			'home'='616-515-2121',
			'work'='616-321-7654',
			'mobile'='616-987-6543'
		}
		};
	}

	function getTestDocument2(){
		return {
		'first_name'='firstname_'&toString(createUUID()),
		'last_name'='lastname_'&toString(createUUID()),
		'testvar'='here',
		'address'={
			'street'='8901 Anywhere Court',
			'city'='Chicago',
			'state'='IL',
			'postalcode'='60622',
			'country'='USA',
			'location'=this.toGeoJSON([-85.570381,42.9130449])
		},
		'phone'={
			'home'='312-515-2121',
			'work'='312-321-7654',
			'mobile'='312-987-6543'
		}
		};
	}

}