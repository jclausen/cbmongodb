/*******************************************************************************
*	Unit Tests for cbmongodb.models.mongo.MongoCollection
*******************************************************************************/
component name="TestGridFS" extends="tests.specs.CBMongoDBBaseTest" appMapping="/root"{
	property name="GridFS" inject="id:GridFS@cbmongodb";
	property name="GFSInstance";

	function afterAll(){
		if(!isNull(variables.GFSInstance)){
			GFSInstance.remove({});
		}
	}

	function run(testResults, testBox){

		describe("Test GridFS Storage Methods",function(){
			it("Tests the ability to store a GridFS file",function(){
				//var testFiles = DirectoryList(path=expandPath('/cbmongodb/tests/assets'),filter="*.jpeg");
				var testFiles = DirectoryList(expandPath('/tests/assets'), false, "all", "*.jpeg");
				
				expect(arrayLen(testFiles)).toBeGT(0,"Test image files were not found to test GridFS methods. You may add your own images to /tests/assets/ to test the GridFS functionality");
				
				variables.GFSInstance = GridFS.init('cbmongo_gridfs_tests');
				
				var i = 1;
				
				for(var fl in testFiles){
					var created = GFSInstance.createFile(fl);
					expect(created).toBeString();
					/**
					* Test Single Record Retreival
					**/
					//findById()
					var fileRetrieved = GFSInstance.findById(created);
					var fileInfo = fileRetrieved.get('fileInfo');
					//test our default file info information
					expect(isNull(fileInfo)).toBeFalse();
					expect(fileInfo).toBeStruct();
					expect(fileInfo).toHaveKey('name');
					expect(fileInfo['name']).toBe(listLast(file,'/'));
					expect(fileInfo).toHaveKey('mimetype');
					expect(fileInfo).toHaveKey('extension');
					expect(isNull(fileRetrieved)).toBeFalse();

					expect(fileRetrieved.getId().toString()).toBe(created);
					//findOne()
					var fileFindOne = GFSInstance.findOne({"_id":created});
					expect(isNull(fileFindOne)).toBeFalse();
					expect(fileFindOne.getId().toString()).toBe(created);
					//getFileList() - returns cursor
					var filesList = GFSInstance.getFileList();
					expect(filesList.count()).toBe(i);
					//find - returns array
					var fileSearch = GFSInstance.find({});
					expect(fileSearch).toBeArray();
					expect(arrayLen(fileSearch)).toBe(i);
					i++;
				}

				describe("Test GridFS removal operations",function(){					
					it("Tests the ability to delete files",function(){
						var filesList = GFSInstance.getFileList();
						expect(filesList.count()).toBeGT(0);
						while(filesList.hasNext()){
							var gfsFile = filesList.next();
							var fileId = gfsFile.getId().toString();
							GFSInstance.removeById(fileId);
							expect(isNull(GFSInstance.findById(fileId))).toBeTrue();
						}
					});
				});

			});
		});

		
	}

}