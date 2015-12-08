package de.jabc.cinco.meta.core.mgl;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.emf.ecore.EPackage;

public class MGLEPackageRegistry {
	public static MGLEPackageRegistry INSTANCE = new MGLEPackageRegistry();
	
	private Set<EPackage> mglEPackages;
	
	private MGLEPackageRegistry(){
		this.mglEPackages = new HashSet<>();
	}
	
	public Set<EPackage> getMGLEPackages(){
		return Collections.unmodifiableSet(this.mglEPackages);
		
	}
	
	public void addMGLEPackage(EPackage ePkg){
		this.mglEPackages.add(ePkg);
	}

	public static void resetRegistry() {
		INSTANCE = new MGLEPackageRegistry();
		
	}
}
