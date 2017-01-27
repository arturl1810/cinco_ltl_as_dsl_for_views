package ${CheckModulePackage};

import graphmodel.IdentifiableElement
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import info.scce.mcam.framework.modules.CheckModule
import java.util.Map

import de.jabc.cinco.meta.util.xapi.CollectionExtension

public abstract class ${ClassName} extends CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> {
	
	protected extension CollectionExtension = new CollectionExtension
	
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
