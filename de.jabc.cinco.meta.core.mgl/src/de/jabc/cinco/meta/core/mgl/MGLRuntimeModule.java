/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl;

import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.scoping.IGlobalScopeProvider;

import de.jabc.cinco.meta.core.mgl.scoping.MGLImportUriGlobalScopeProvider;
import de.jabc.cinco.meta.core.mgl.valueconverters.BoundValueConverter;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class MGLRuntimeModule extends de.jabc.cinco.meta.core.mgl.AbstractMGLRuntimeModule {
	  @Override
	    public Class<? extends IValueConverterService> bindIValueConverterService() {
	        return BoundValueConverter.class;
	    }
	  
	 @Override
	public Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		// TODO Auto-generated method stub
		return MGLImportUriGlobalScopeProvider.class;
	}
}
