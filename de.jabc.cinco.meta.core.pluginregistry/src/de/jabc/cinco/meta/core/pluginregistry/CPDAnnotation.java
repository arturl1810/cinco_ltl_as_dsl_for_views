package de.jabc.cinco.meta.core.pluginregistry;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.ICPDMetaPluginAcceptor;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class CPDAnnotation {
	
	private String annotationName;
	
	private ICPDMetaPlugin plugin;
	
	private ICPDMetaPluginAcceptor acceptor;
	
	private IMetaPluginValidator validator;
	
	
	public String getAnnotationName() {
		return annotationName;
	}
	public void setAnnotationName(String annotationName) {
		this.annotationName = annotationName;
	}
	public ICPDMetaPlugin getPlugin() {
		return plugin;
	}
	public void setPlugin(ICPDMetaPlugin plugin) {
		this.plugin = plugin;
	}
	public ICPDMetaPluginAcceptor getAcceptor() {
		return acceptor;
	}
	public void setAcceptor(ICPDMetaPluginAcceptor acceptor) {
		this.acceptor = acceptor;
	}
	public IMetaPluginValidator getValidator() {
		return validator;
	}
	public void setValidator(IMetaPluginValidator validator) {
		this.validator = validator;
	}
	
	
}
