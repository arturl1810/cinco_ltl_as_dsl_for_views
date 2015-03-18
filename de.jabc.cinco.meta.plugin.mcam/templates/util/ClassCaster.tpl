package ${UtilPackage};

<#list ContainerTypes as container>
import ${GraphModelPackage}.${container};
</#list>

<#list NodeTypes as node>
import ${GraphModelPackage}.${node};
</#list>

<#list EdgeTypes as edge>
import ${GraphModelPackage}.${edge};
</#list>

public class ClassCaster {

	<#list ContainerTypes as type>
	public static ${type} castTo(Object obj, ${type} classTo) {
		if (obj instanceof ${type})
			return (${type}) obj;
		return null;
	}
	</#list>

	<#list NodeTypes as type>
	public static ${type} castTo(Object obj, ${type} classTo) {
		if (obj instanceof ${type})
			return (${type}) obj;
		return null;
	}
	</#list>

	<#list EdgeTypes as type>
	public static ${type} castTo(Object obj, ${type} classTo) {
		if (obj instanceof ${type})
			return (${type}) obj;
		return null;
	}
	</#list>


}	
