package de.jabc.cinco.meta.plugin.gratext.descriptor;

import mgl.ModelElement;
import mgl.UserDefinedType;

public class UserDefinedTypeDescriptor extends ModelElementDescriptor<UserDefinedType> {
	
	public UserDefinedTypeDescriptor(UserDefinedType udt, GraphModelDescriptor model) {
		super(udt, model);
	}
	
	@Override
	protected void initAttributes(ModelElement element) {
		super.initAttributes(element);
		if (((UserDefinedType)element).getExtends() != null) {
			initAttributes(((UserDefinedType)element).getExtends());
		}
	}
	
	public UserDefinedType getSuperType() {
		return instance().getExtends();
	}
}
