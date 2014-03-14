package de.jabc.cinco.meta.core.pluginregistry.proposalprovider;

import java.util.List;

import mgl.Annotation;

public interface IMetaPluginAcceptor {
	public List<String> getAcceptedStrings(Annotation annotation);
}
