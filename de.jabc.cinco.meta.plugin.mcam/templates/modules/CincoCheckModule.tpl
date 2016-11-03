package ${CheckModulePackage};

import graphmodel.IdentifiableElement
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import info.scce.mcam.framework.modules.CheckModule
import java.util.Map

import static extension de.jabc.cinco.meta.core.utils.CollectionExtensions.*
import static extension org.jooq.lambda.Seq.*

public abstract class ${ClassName} extends CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> {
	
	protected ${GraphModelName}Adapter adapter;
	
	protected Map<IdentifiableElement, ${GraphModelName}Id> cache;

	override init() {}
	
	override execute(${GraphModelName}Adapter adapter) {
		System.out.println("executing check: " + this.name);
		this.adapter = adapter;
		cache = adapter.entityIds.associateWithKey[adapter.getElementById(it)]
			.filterKeys(IdentifiableElement).toMap
		adapter.model.check;
	}
	
	def abstract void check(${GraphModelName} model);
	
	def addError(IdentifiableElement element, String msg) {
		cache.get(element).addError(msg)
	}
	
	def addWarning(IdentifiableElement element, String msg) {
		cache.get(element).addWarning(msg)
	}
	
	def addInfo(IdentifiableElement element, String msg) {
		cache.get(element).addInfo(msg)
	}

}