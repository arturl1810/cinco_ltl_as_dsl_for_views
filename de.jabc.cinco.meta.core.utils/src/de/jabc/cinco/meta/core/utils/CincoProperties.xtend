package de.jabc.cinco.meta.core.utils

import java.util.Properties
import org.eclipse.core.resources.IProject
import java.nio.file.Paths
import java.io.FileInputStream

class CincoProperties extends Properties {
	
	// name of the Cinco config folder to be expected in the home of the user
	public static String CONFIG_FOLDER = ".cinco";
	
	// name of the properties file to be expected in the root of a project
	public static String PROPERTIES_FILE_NAME = "cinco.properties";
	
	// Pairs: Property key -> Default value
	private static val MAX_THREADS = "maxThreads" -> 0; // default: no limit
	private static val VM_ARGS = "vmArgs" -> "";
	
	// singleton pattern
	private new() {}
	private static CincoProperties INSTANCE
	public static def getInstance() {
		INSTANCE ?: (INSTANCE = new CincoProperties() => [load])
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
	 * Load Cinco properties from user home
	 */
	def load() {
		val home = System.getProperty("user.home")
		if (home != null) try {
			val file = Paths.get(home).resolve(CONFIG_FOLDER).resolve(PROPERTIES_FILE_NAME).toFile
			if (file.exists) {
				load(new FileInputStream(file))
			}
		} catch(Exception e) {
			e.printStackTrace
		}
	}
	
	/**
	 * Load properties from properties file in the specified project.
	 */
	def load(IProject project) {
		println("Loading Cinco Properties...")
		val file = project.getFile(PROPERTIES_FILE_NAME)
		if (file.exists) {
			super.load(file.contents)
		}
		println(this)
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