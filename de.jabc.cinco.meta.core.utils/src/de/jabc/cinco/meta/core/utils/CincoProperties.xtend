package de.jabc.cinco.meta.core.utils

import java.util.Properties
import org.eclipse.core.resources.IProject

class CincoProperties extends Properties {
	
	// name of the properties file to be expected in the root of a project
	public static String PROPERTIES_FILE_NAME = "cinco.properties";
	
	// Pairs: Property key -> Default value
	private static val MAX_THREADS = "maxThreads" -> 0; // default: no limit
	private static val VM_ARGS = "vmArgs" -> "";
	
	// singleton pattern
	private new() {}
	private static CincoProperties INSTANCE
	public static def getInstance() {
		INSTANCE ?: (INSTANCE = new CincoProperties)
	}
	
	/*
	 * Convenient Getters
	 */
	static def getMaxThreads() {
		MAX_THREADS.intValue
	}
	
	static def getVmArgs() {
		VM_ARGS.strValue
	}
	
	/**
	 * Load properties from properties file in the specified project.
	 */
	def load(IProject project) {
		val file = project.getFile(PROPERTIES_FILE_NAME)
		if (file.exists) {
			super.load(file.contents)
		}
	}
	
	private static def String getStrValue(Pair<String,String> p) {
		instance.getProperty(p.key) ?: p.value
	}
	
	private static def Integer getIntValue(Pair<String,Integer> p) {
		val value = instance.getProperty(p.key)
		if (value != null) 
			Integer.parseInt(value)
		else p.value
	}
}