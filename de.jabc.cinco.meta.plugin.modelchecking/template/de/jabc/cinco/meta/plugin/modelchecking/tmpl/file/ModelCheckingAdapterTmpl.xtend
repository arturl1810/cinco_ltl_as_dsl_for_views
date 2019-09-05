package de.jabc.cinco.meta.plugin.modelchecking.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension
class ModelCheckingAdapterTmpl extends FileTemplate{
	
	extension ModelCheckingExtension = new ModelCheckingExtension
	
	override getTargetFileName() '''«model.name»ModelCheckingAdapter.java'''
	
	override template() '''
		package «package»;
		
		
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
		«IF model.formulasExist»
			import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaHandler;
		«ENDIF»
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.ModelCheckingAdapter;
		import graphmodel.GraphModel;
		import graphmodel.Node;
		
		import java.util.Set;
		import org.eclipse.graphiti.util.IColorConstant;
		
		
		import «basePackage».builder.«model.name»ModelBuilder;
		«IF model.formulasExist»
			import «basePackage».formulas.«model.name»FormulaFactory;
			import «basePackage».formulas.«model.name»FormulaHandler;
		«ENDIF»
		import «model.package».modelchecking.ProviderHandler;
		
		public class «model.name»ModelCheckingAdapter implements ModelCheckingAdapter{
			
			@Override
			public boolean canHandle(GraphModel model) {
				return model instanceof «model.fqBeanName»;
			}
		
			@Override
			public void buildCheckableModel(GraphModel model, CheckableModel<?,?> checkableModel, boolean withSelection) {
				if (canHandle(model)) {
					«model.name»ModelBuilder builder = new «model.name»ModelBuilder();
					builder.buildModel((«model.fqBeanName») model, checkableModel, withSelection);
				}
			}
			
			«IF model.formulasExist»
				@Override
				public FormulaHandler<«model.fqBeanName», «model.formulasType.fqBeanName»> getFormulaHandler() {
					return new «model.name»FormulaHandler(new «model.name»FormulaFactory());
				}
				
				@Override
				public Class<?> getFormulasTypeClass(){
					return «model.package».«model.name.toLowerCase».impl.«model.formulasTypeName»Impl.class; 
				}
			«ENDIF»
			
			@Override
			public IColorConstant getHighlightColor() {
				return IColorConstant.«model.highlightColor»;
			}
			
			@Override
			public boolean fulfills(GraphModel model, CheckableModel<?,?> checkableModel, Set<Node> satisfyingNodes) {
				if(canHandle(model)) {
					return (new ProviderHandler()).fulfills((«model.fqBeanName») model, checkableModel, satisfyingNodes);
				}
				return false;
			}	
		}
		
	'''
	
}
