package de.jabc.cinco.meta.core.pluginregistry.validation;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EPackage;
abstract public class AbstractCPDMetaPluginValidator extends org.eclipse.xtext.validation.AbstractDeclarativeValidator{
	@Override
	public List<EPackage> getEPackages() {
	    List<EPackage> result = new ArrayList<EPackage>();
	    result.add(EPackage.Registry.INSTANCE.getEPackage("http://www.jabc.de/meta/productdefinition"));
		return result;
	}	 
	 
}
