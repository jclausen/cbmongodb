component name="ActiveEntityMock" extends="cbmongodb.models.ActiveEntity" accessors=true{
	property name="collection" default="cbmongodbtestrunner";
	property name="test_document" default="";
	/**Schema Properties**/
	property name="first_name" schema=true validate="string";
	property name="last_name" schema=true valiate="string";
	property name="address" schema=true validate="struct";
	/**Use either dot notation in the name or specify a 'parent' attribute as ways of creating nested documents**/
	property name="address.street" schema=true validate="string";
	property name="address.city" schema=true validate="string";
	property name="address.state" schema=true validate="string" length=2;
	property name="address.postalcode" schema=true validate="zipcode";
	property name="country" schema=true parent="address" validate="string";
	property name="phone" schema=true validate="struct";
	property name="phone.home" schema=true validate="telephone";
	property name="phone.work" schema=true validate="telephone";
	property name="phone.mobile" schema=true validate="telephone";

	any function init(){
		super.init();
		/**OPTIONAL: Explicit Default Document Setter**/
		/*this.setDefault_document({
			'first_name'='',
			'last_name'='',
			'address'={
				'street'='',
				'city'='',
				'state'='',
				'postalcode'='',
				'country'=''
			},
			'phone'={
				'home'='',
				'work'='',
				'mobile'=''
			}
		});
		this.set_document(this.getDefault_document());
		 */

		this.setTest_document({
		'first_name'='firstname_'&toString(createUUID()),
		'last_name'='firstname_'&toString(createUUID()),
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
		});
	}

}