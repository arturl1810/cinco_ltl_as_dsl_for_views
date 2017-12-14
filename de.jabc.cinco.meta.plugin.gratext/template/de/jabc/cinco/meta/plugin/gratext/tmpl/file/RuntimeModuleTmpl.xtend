package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class RuntimeModuleTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextRuntimeModule.java'''
	
	override template() '''	
		package «package»;
		
		import org.eclipse.emf.ecore.EValidator.Registry;
		import org.eclipse.emf.ecore.resource.Resource;
		import org.eclipse.xtext.conversion.IValueConverterService;
		import org.eclipse.xtext.linking.ILinker;
		import org.eclipse.xtext.linking.ILinkingService;
		import org.eclipse.xtext.linking.impl.Linker;
		import org.eclipse.xtext.parser.IAstFactory;
		import org.eclipse.xtext.resource.XtextResource;
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.util.GratextEValidatorRegistry;
		import de.jabc.cinco.meta.plugin.gratext.runtime.util.TerminalConverters;
		
		public class «model.name»GratextRuntimeModule extends «package».Abstract«model.name»GratextRuntimeModule {
		
			@Override
			public Class<? extends IValueConverterService> bindIValueConverterService() {
			    return TerminalConverters.class;
			}
		
			@Override
			public Class<? extends IAstFactory> bindIAstFactory() {
				return «model.name»GratextAstFactory.class;
			}
		    
		    @Override
			public Class<? extends ILinker> bindILinker() {
				return MyLinker.class;
			}
			
			static class MyLinker extends Linker {
				
				@Override
				protected boolean isClearAllReferencesRequired(Resource resource) {
					return false;
				}
			}
			
			@Override
			public Class<? extends ILinkingService> bindILinkingService() {
				return «model.name»GratextLinkingService.class;
			}
		    
		    @Override
		    public Class<? extends XtextResource> bindXtextResource() {
		    	return «model.name»GratextResource.class;
		    }
			
			@Override
			public Registry bindEValidatorRegistry() {
				return new GratextEValidatorRegistry();
			}
		}
	'''
	
}