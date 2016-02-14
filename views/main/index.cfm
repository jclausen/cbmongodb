<cfoutput>
<h1>CBMongoDB</h1>
<p>CBmongoDB test application is up and running:</p>
<ul>
	<li><strong>Coldbox Version:</strong> #getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</li>
	<li><strong>Registered Handlers:</strong>
		<ul>
			<cfloop list="#getSetting("RegisteredHandlers")#" index="handler">
			<li><a href="#event.buildLink( handler )#">#handler#</a></li>
			</cfloop>
		</ul>
	</li>
	<li><strong>Registered Modules:</strong>
		<ul>
			<cfloop collection="#getSetting("Modules")#" item="thisModule">
			<li><a href="#event.buildLink( getModuleConfig( thisModule ).entryPoint )#">#thisModule#</a></li>
			</cfloop>
		</ul>
	</li>
	<li><strong>Test Runner:</strong> <a href="/tests/runner.cfm">/tests/runner.cfm</a></li>
</ul>
</cfoutput>