package de.jabc.cinco.meta.core.ui.converter;

import org.eclipse.core.databinding.conversion.IConverter;

public class CharStringConverter implements IConverter {
	@Override
	public Object getToType() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object getFromType() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object convert(Object fromObject) {
		if (fromObject instanceof Character) {
			if ((Character) fromObject == '\0')
				return new String("a");
			return String.valueOf(fromObject);
		}
		if (fromObject instanceof String) {
			if ("0".equals(fromObject))
				return new Character('\0');
			return ((String) fromObject).charAt(0);
		}
		
		return fromObject;
	}
}
