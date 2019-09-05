package de.jabc.cinco.meta.plugin.modelchecking.tmpl.formulas

import de.jabc.cinco.meta.plugin.template.FileTemplate
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension
import mgl.UserDefinedType

class FormulaHandlerTmpl extends FileTemplate{
	
	var String formulasAttributeName
	var String expressionAttributeName
	var String descriptionAttributeName
	var String checkAttributeName = ""
	var UserDefinedType formulasType
	var boolean checkAttributeExists
	
	extension ModelCheckingExtension = new ModelCheckingExtension
	
	override init(){
		checkAttributeExists = model.checkAttributeExists
		formulasType = model.formulasType
		formulasAttributeName = model.formulasAttributeName.toFirstUpper	
		expressionAttributeName = model.expressionAttributeName.toFirstUpper
		descriptionAttributeName = model.descriptionAttributeName.toFirstUpper
		if (checkAttributeExists){
			checkAttributeName = model.checkAttributeName.toFirstUpper
		}	
	}
	
	override getTargetFileName() '''«model.name»FormulaHandler.java'''
	
	override template() '''
		package «package»;
		
		import org.eclipse.emf.common.util.EList;
		
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaFactory;
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaHandler;
		
		public class «model.name»FormulaHandler extends FormulaHandler<«model.fqBeanName», «formulasType.fqBeanName»>{
			
			public «model.name»FormulaHandler(FormulaFactory<«model.fqBeanName», «formulasType.fqBeanName»> formulaFactory) {
				super (formulaFactory);
			}
			
			@Override
			public void addFormulaToModel(«formulasType.fqBeanName» formula) {
				getModel().add«formulasAttributeName»(formula);		
			}
		
			@Override
			public EList<«formulasType.fqBeanName»> getFormulasFromModel() {
				return getModel().get«formulasAttributeName»();
			}
		
			@Override
			public void removeFormulaFromModel(«formulasType.fqBeanName» formula) {
				getModel().remove«formulasAttributeName»(formula);
				
			}
		
			@Override
			public void setExpression(«formulasType.fqBeanName» formula, String exp) {
				formula.set«expressionAttributeName»(exp);
				
			}
		
			@Override
			public void setDescription(«formulasType.fqBeanName» formula, String description) {
				formula.set«descriptionAttributeName»(description);
				
			}
		
			@Override
			public void setToCheck(«formulasType.fqBeanName» formula, boolean toCheck) {
				«IF checkAttributeExists»
					formula.set«checkAttributeName»(toCheck);
				«ENDIF»
			}
		}
	'''
	
}
