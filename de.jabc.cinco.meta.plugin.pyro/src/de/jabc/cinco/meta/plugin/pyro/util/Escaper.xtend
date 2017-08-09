package de.jabc.cinco.meta.plugin.pyro.util

class Escaper {
	def escapeDart(String s){
		return s;
	}
	
	def escapeJava(String s){
		return s;
	}
	
	def fuEscapeDart(String s){
		return s.escapeDart.toFirstUpper;
	}
	
	def fuEscapeJava(String s){
		return s.escapeJava.toFirstUpper;
	}
	
	def lowEscapeDart(String s){
		return s.escapeDart.toLowerCase;
	}
	
	def lowEscapeJava(String s){
		return s.escapeJava.toLowerCase;
	}
}