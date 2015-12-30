/*******************************************************************************
*	Integration Test for /cfmongodb/models/FileEntity.cfc
*******************************************************************************/
component name="TestModelFileEntity" extends="cbmongodb.tests.specs.CBMongoDBBaseTest"{
	
	function beforeAll(){
		//custom methods
		super.beforeAll();
	}

	function afterAll(){
        super.afterAll();
	}

	function run(testResults, testBox){
		describe("Test the the file/entity relationships",function(){

			it("Tests the ability to create a File entity",function(){
				//create a test person
				var personId = VARIABLES.people.reset().populate(variables.people.getTestDocument()).create();
				expect(personId).toBeString();

				var FileEntity = VARIABLES.FileEntity;
				FileEntity.setPerson_id(personId);
				//test our normalization
				expect(FileEntity.getPerson()).toBeStruct();
				expect(FileEntity.getPerson()).toHaveKey('first_name');
				expect(FileEntity.getPerson()).toHaveKey('last_name');
				//test that validation has failed because we don't have a file set
				expect(FileEntity.isValid()).toBeFalse();
				var testFiles = DirectoryList(path=expandPath('/cbmongodb/tests/assets'),filter="*.jpeg");
				//make sure we have at least two files to test
				expect(arrayLen(testFiles)).toBeGT(1,"Test image files were not found to test GridFS methods. You may add your own images to /cbmongodb/tests/assets/ to test the GridFS functionality");
				var testFile1 = testFiles[1];
				var testFile2 = testFiles[2];
				//now set some file associations
				FileEntity.loadFile(testFile1);
				expect(FileEntity.getFileId()).toBeString();
				expect(FileEntity.isValid()).toBeTrue();

				var fileEntityId = FileEntity.create();

				Expect(fileEntityId).toBeString();
				Expect(FileEntity.loaded()).toBeTrue();

				describe("Tests the ability to retreive and update File Entities",function(){
					it("Tests the baility to update a File Entity",function(){
						var retrieved = FileEntity.reset().load(fileEntityId);
						expect(retrieved.loaded()).toBeTrue();

						//store our file so that we can verify it has been deleted
						var file1Id = retrieved.getFileId();
						expect(file1Id).toBeString();

						//now replace our file - using our alias function this time
						retrieved.setFile(testFile2).update();

						expect(retrieved.getFileId() == file1Id).toBeFalse();

						expect(isNull(retrieved.getGridFSInstance().findById(file1Id))).toBeTrue();
					});

					it("Test the ability to delete a File Entity",function(){
						var testDeletion = FileEntity.reset().load(fileEntityId);
						expect(testDeletion.loaded()).toBeTrue();

						var fileId = testDeletion.getFileId();
						expect(len(fileId)).toBeGt(0);

						testDeletion.delete();

						expect(FileEntity.reset().load(fileEntityId).loaded()).toBeFalse();
						expect(isNull(FileEntity.getGridFSInstance().findById(fileId))).toBeTrue();

					});

				});

			});
		});
	}

}