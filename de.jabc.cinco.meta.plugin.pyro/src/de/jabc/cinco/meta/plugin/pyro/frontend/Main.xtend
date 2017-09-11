package de.jabc.cinco.meta.plugin.pyro.frontend

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class Main extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameMain()'''main.dart'''
	
	def contentMain()
	'''
	import 'package:angular2/platform/browser.dart';
	
	import 'package:«gc.projectName.escapeDart»/app_component.dart';
	
	main() {
	  bootstrap(AppComponent);
	}
	
	'''
}