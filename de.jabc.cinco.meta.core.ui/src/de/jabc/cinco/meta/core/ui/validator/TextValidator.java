package de.jabc.cinco.meta.core.ui.validator;

import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.fieldassist.ControlDecoration;
import org.eclipse.jface.fieldassist.FieldDecoration;
import org.eclipse.jface.fieldassist.FieldDecorationRegistry;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Text;

public class TextValidator implements ModifyListener {

	private ControlDecoration decoration;
	
	private EDataType eAttributeType;
	
	public TextValidator(EDataType type) {
		eAttributeType = type;
	}

	@Override
	public void modifyText(ModifyEvent e) {
		Text text = (Text) e.getSource();
		String value = text.getText();
		validate(text, value);
	}
	
	private void validate(Text text, String value) {
		try {
			if (eAttributeType.getName().equals("EChar") && value.length() > 1) {
				getDecorator(text, value).show();
				return;
			}
			if (value.isEmpty()) {
				getDecorator(text, value).hide();
				return;
			}
			EcoreUtil.createFromString(eAttributeType, value);
			getDecorator(text, value).hide();
		} catch (Exception e) {
			getDecorator(text, value).show();
		}
	}

	private ControlDecoration getDecorator(Text text, String value) {
		if (decoration == null) {
			decoration = new ControlDecoration(text, SWT.TOP | SWT.LEFT);
			FieldDecoration fieldDecoration = FieldDecorationRegistry.getDefault().getFieldDecoration(FieldDecorationRegistry .DEC_ERROR);
			Image img = fieldDecoration.getImage();
			decoration.setImage(img);
			decoration.hide();
		}
		decoration.setDescriptionText("\""+value+"\" is invalid " + eAttributeType.getInstanceTypeName()+" input.");
		return decoration;
	}
	
}
