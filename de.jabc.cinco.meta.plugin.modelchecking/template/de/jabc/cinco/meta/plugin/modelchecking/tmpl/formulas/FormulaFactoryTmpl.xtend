
package de.jabc.cinco.meta.plugin.modelchecking.tmpl.formulas

import de.jabc.cinco.meta.plugin.template.FileTemplate
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension
import mgl.UserDefinedType

class FormulaFactoryTmpl extends FileTemplate{
	
	extension ModelCheckingExtension = new ModelCheckingExtension
	
	var String expressionAttributeName
	var String descriptionAttributeName
	var String checkAttributeName = ""
	var UserDefinedType formulasType;
	var boolean checkAttributeExists
	
	override getTargetFileName() '''«model.name»FormulaFactory.java'''
	
	
	
	override init(){		
		checkAttributeExists = model.checkAttributeExists
		formulasType = model.formulasType
		expressionAttributeName = model.expressionAttributeName.toFirstUpper
		descriptionAttributeName = model.descriptionAttributeName.toFirstUpper
		if (checkAttributeExists){
			checkAttributeName = model.checkAttributeName.toFirstUpper
		}	
	}
	
	override template() '''
		package «package»;
		
		import java.util.ArrayList;
		import java.util.List;
		
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula;
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaFactory;
		
		import «model.beanPackage».«model.name.toOnlyFirstUpper»Factory;
		import «model.beanPackage».impl.«model.name.toOnlyFirstUpper»FactoryImpl;
		
		public class «model.name»FormulaFactory implements FormulaFactory<«model.fqBeanName», «formulasType.fqBeanName»>{
			
			@Override
			public List<CheckFormula> createFormulas(«model.fqBeanName» model) {
				ArrayList<CheckFormula> list = new ArrayList<>();
				for («formulasType.fqBeanName» formula: model.get«model.formulasAttributeName»()) {
					list.add(createFormula(formula));
				}
				
				return list;
			}
		
			@Override
			public CheckFormula createFormula(«formulasType.fqBeanName» formula) {
				CheckFormula newFormula = new CheckFormula(formula.getId(), formula.get«expressionAttributeName»());
				newFormula.setDescription(formula.get«descriptionAttributeName»());
				«IF checkAttributeExists»
					newFormula.setToCheck(formula.is«checkAttributeName»());
				«ENDIF»
				return newFormula;
			}
		
			@Override
			public «formulasType.fqBeanName» createGraphModelFormula(String exp) {
				«model.name.toOnlyFirstUpper»Factory factory = «model.name.toOnlyFirstUpper»FactoryImpl.init();
				«formulasType.fqBeanName» newFormula = factory.create«formulasType.beanName»();
				newFormula.set«expressionAttributeName»(exp);
				newFormula.set«descriptionAttributeName»("");
				«IF checkAttributeExists»
					newFormula.set«checkAttributeName»(true);
				«ENDIF»
				return newFormula;
			}
			
		}
		
	'''
	
}
