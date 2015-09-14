package de.jabc.cinco.meta.core.ui.properties;

import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.jface.dialogs.IInputValidator;
import org.eclipse.jface.dialogs.InputDialog;
import org.eclipse.swt.widgets.Display;

public class AttributeCreator {

	public static String createAttribute(EAttribute attr) {
		String retval = null;
		InputDialog dialog = getDialog(attr);
		if (dialog.open() == Dialog.OK)
			return dialog.getValue();
		
		return retval;
	}

	private static InputDialog getDialog(EAttribute attr) {
		
		return new InputDialog(
				Display.getCurrent().getActiveShell(), 
				"New " + attr.getName(), 
				"Create a new " + attr.getName() + " value", 
				getInitialValue(attr), 
				getValidator(attr));
	}
	

	private static IInputValidator getValidator(final EAttribute attr) {
		return new IInputValidator() {
			
			@Override
			public String isValid(String newText) {
				try {
					EcoreUtil.createFromString(attr.getEAttributeType(), newText);
				} catch (Exception e) {
					return "Input: \"" + newText + "\" is not a valid " + attr.getEAttributeType().getName();
				}
				return null;
			}
		};
		
	}

	private static String getInitialValue(EAttribute attr) {
		EDataType eAttributeType = attr.getEAttributeType();
		switch (eAttributeType.getName()) {
		case "EInt":
			return "0";

		default:
			break;
		}
		return null;
	}
	
}
