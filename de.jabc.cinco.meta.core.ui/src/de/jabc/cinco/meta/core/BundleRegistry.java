package de.jabc.cinco.meta.core;

import java.util.HashSet;
import java.util.Set;

public class BundleRegistry {
	public static BundleRegistry INSTANCE = new BundleRegistry();
	private Set<String> pluginIDs;
	private Set<String> fragmentIDs;
	private BundleRegistry(){
		pluginIDs = new HashSet<>();
		fragmentIDs = new HashSet<>();
	}	
	
	public static BundleRegistry resetRegistry(){
		INSTANCE = new BundleRegistry();
		return INSTANCE;
	}
	
	public Set<String> getPluginIDs(){
		return pluginIDs;
	}
	

	public Set<String> getFragmentIDs(){
		return fragmentIDs;
	}
	
	public boolean addBundle(String bundleID,boolean isFragment){
		if(!isFragment)
			return pluginIDs.add(bundleID);
		else
			return fragmentIDs.add(bundleID);
	}
	
	public boolean removeFragment(String fragmentID){
		return fragmentIDs.remove(fragmentID);
	}
	
	public boolean removePlugin(String pluginID){
		return pluginIDs.remove(pluginID);
	}
}
