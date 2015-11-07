<!DOCTYPE html>
 <html>
 	<head>
 		<title>ColdDocs Generator</title>
		<style type='text/css'>
			* {margin:0px;padding:0px;}
			body {font-family:Verdana, Geneva, Arial, Helvetica, sans-serif;background:#fff;}
			#title {padding:4px;border-bottom:2px solid #000;background:#ccc;}
			#main {padding:10px;}
		</style>
	</head>
	<body>
		<h1 id="title">ColdDoc Generator</h1>
		<div id="main">
		<cfscript>
			boxJSON = fileRead(expandPath('../box.json'));
			packageSpecs = deserializeJSON(boxJSON);
			// Config - The default will generate documentation for ColdDoc
			//sourcePaths = "/cbmongodb/"; // The source code folder we are generating documentation for
			
			sourcePaths = [
			          { inputDir = expandPath("/cbmongodb"),inputMapping = "cbmongodb"}
			];
			mapping = "cbmongodb"; // The folder name used for mapping
			docPath = "/cbmongodb/apidocs/" & 'v' & listFirst(packageSpecs.version,'.'); // The location of where we are putting the documentation

			colddoc = createObject("component", "colddoc.ColdDoc").init();
			strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(expandPath(docPath), "CBMongoDB");
			colddoc.setStrategy(strategy);

			WriteOutput("<h3>Creating ColdDoc</h3><br />");
			WriteOutput("<table>");
			WriteOutput("<tr><td>------ Source: </td><td>'<strong>" & packageSpecs.name & "</strong>'</td></tr>");
			WriteOutput("<tr><td>------ Mapping: </td><td>'<strong>" & mapping & "</strong>'</td></tr>");
			WriteOutput("<tr><td>------ Doc Path: </td><td>'<strong>" & docPath & "</strong>'</td></tr>");
			WriteOutput("</table>");

			colddoc.generate(sourcePaths);
		</cfscript>
		<cfoutput>
			<br />
			<h3>Done!</h3>
			<br />
			Relative Path: <a href="#docPath#/">Link to Documentation</a>
			<br />
			Absolute Path: #ExpandPath(docPath)#
		</cfoutput>
	</div>
</body>
</html>