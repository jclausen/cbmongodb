component name="ActiveEntityMock" extends="cbmongodb.models.ActiveEntity" accessors=true{
	property name="collection" default="people";
	property name="test_document" default="";
	/**Schema Properties**/
	property name="first_name" schema=true index=true indexwith="last_name" indexorder="ASC" validate="string";
	property name="last_name" schema=true valiate="string" indexsort="DESC";
	property name="address" schema=true validate="struct";
	/**Use either dot notation in the name or specify a 'parent' attribute as ways of creating nested documents**/
	property name="address.street" schema=true validate="string";
	property name="address.city" schema=true validate="string";
	property name="address.state" schema=true validate="string" length=2;
	property name="address.postalcode" schema=true validate="zipcode";
	property name="country" schema=true parent="address" validate="string";
	property name="address.location" schema=true index="true" validate="array" geo=true geotype="Point";
	property name="phone" schema=true validate="struct";
	property name="phone.home" schema=true validate="telephone";
	property name="phone.work" schema=true validate="telephone";
	property name="phone.mobile" schema=true validate="telephone";

	function getTestDocument(){
		return {
		'first_name'='firstname_'&toString(createUUID()),
		'last_name'='lastname_'&toString(createUUID()),
		'testvar'='here',
		'address'={
			'street'='123 Anywhere Lane',
			'city'='Grand Rapids',
			'state'='Michigan',
			'postalcode'='49546',
			'country'='USA',
			'location'=this.toGeoJSON([-85.570381,42.9130449])
		},
		'phone'={
			'home'='616-123-4567',
			'work'='616-321-7654',
			'mobile'='616-987-6543'
		}
		};
	}

}