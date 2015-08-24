package de.jabc.cinco.meta.plugin.pyro.templates.script

import de.jabc.cinco.meta.plugin.pyro.templates.DefaultTemplate

class DeployPyroWindowsTemplate implements DefaultTemplate{

	override create(Object... objects)
		'''
	echo "Deploing CINCO Product for the web to the DyWA"	
	mode 120,80
	cd «objects.get(0)»
	mvn clean install
	copy /b/v/y «objects.get(0)»\testapp-presentation\target\testapp.war «objects.get(1)»\standalone\deployments
	echo "Successfully deployed!"
	pause>nul
		
	'''
	
}