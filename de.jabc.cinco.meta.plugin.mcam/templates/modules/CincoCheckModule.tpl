package ${CheckModulePackage};

import de.jabc.cinco.meta.plugin.mcam.runtime.core.CincoCheckModule
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

abstract class ${ClassName} extends CincoCheckModule<${GraphModelName}Id, ${GraphModelName}, ${GraphModelName}Adapter> {
	
	override check(${GraphModelName} model)
}
