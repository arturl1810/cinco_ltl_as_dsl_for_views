package de.jabc.cinco.meta.plugin.pyro.frontend

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class Pubspec extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNamePubspec()'''pubspec.yaml'''
	
	def contentPubspec()
	'''
	name: «gc.projectName.escapeDart»
	description: A Pyro app that uses Angular 2
	version: 0.0.1
	environment:
	  sdk: '>=1.19.0 <2.0.0'
	dependencies:
	  angular2: '>=2.2.0 <2.3.0'
	  angular2_components: '>=0.2.2 <0.3.0'
	dev_dependencies:
	  browser: ^0.10.0
	  dart_to_js_script_rewriter: ^1.0.1
	transformers:
	- angular2:
	    platform_directives:
	    - 'package:angular2/common.dart#COMMON_DIRECTIVES'
	    platform_pipes:
	    - 'package:angular2/common.dart#COMMON_PIPES'
	    entry_points: web/main.dart
	- dart_to_js_script_rewriter
	
	'''
	
}