package de.jabc.cinco.meta.plugin.pyro.templates.script

import de.jabc.cinco.meta.plugin.pyro.templates.DefaultTemplate

class DeployCincoFtwTemplate implements DefaultTemplate{

	override create(Object... objects)
		'''
	#!/bin/bash
	echo "Deploing CINCO Product for the web to the DyWA"
	cd «objects.get(0)»/../api
	mvn clean install
	echo "API installed"
	cd «objects.get(0)»
	mvn clean install
	echo "APP installed"
	cp «objects.get(0)»/testapp-presentation/target/testapp.war «objects.get(1)»/standalone/deployments/
	echo "Successfully deployed!"
		
	'''
	
}