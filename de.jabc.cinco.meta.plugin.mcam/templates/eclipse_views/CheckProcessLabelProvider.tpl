package ${ViewUtilPackage};

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.modules.CheckModule.CheckResultType;

import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.collections.keyvalue.DefaultKeyValue;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;
import org.osgi.framework.Bundle;

public class CheckProcessLabelProvider extends LabelProvider {
	private String checkErrorIconPath = "icons/error.png";
	private String checkOkIconPath = "icons/ok.png";
	private String checkWarningIconPath = "icons/warning.png";

	private Image checkOkImg = null;
	private Image checkErrorImg = null;
	private Image checkWarningImg = null;

	public CheckProcessLabelProvider() {
		super();
		loadIcons();
	}

	private Display getDisplay() {
		Display display = Display.getCurrent();
		// may be null if outside the UI thread
		if (display == null)
			display = Display.getDefault();
		return display;
	}

	private void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam");
		try {
			InputStream entityOkImgStream = FileLocator.openStream(bundle,
					new Path(checkOkIconPath), true);
			checkOkImg = new Image(getDisplay(), entityOkImgStream);
			InputStream entityErrorImgStream = FileLocator.openStream(bundle,
					new Path(checkErrorIconPath), true);
			checkErrorImg = new Image(getDisplay(), entityErrorImgStream);
			InputStream checkWarningImgStream = FileLocator.openStream(bundle,
					new Path(checkWarningIconPath), true);
			checkWarningImg = new Image(getDisplay(), checkWarningImgStream);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/*
	 * @see ILabelProvider#getImage(Object)
	 */
	@SuppressWarnings("unchecked")
	public Image getImage(Object element) {
		if (element instanceof DefaultKeyValue) {
			return null;
		}
		if (element instanceof CheckModule<?, ?>) {
			CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> module = (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter>) element;
			if (module.result.equals(CheckResultType.PASSED))
				return checkOkImg;
			if (module.result.equals(CheckResultType.ERROR))
				return checkErrorImg;
			if (module.result.equals(CheckResultType.WARNING))
				return checkWarningImg;
		}
		throw unknownElement(element);
	}

	/*
	 * @see ILabelProvider#getText(Object)
	 */
	@SuppressWarnings("unchecked")
	public String getText(Object element) {
		if (element instanceof DefaultKeyValue) {
			DefaultKeyValue pair = (DefaultKeyValue) element;
			${GraphModelName}Id id = (${GraphModelName}Id) pair.getKey();
			String msg = (String) pair.getValue();
			return id + ": " + msg;
		}
		if (element instanceof CheckModule<?, ?>) {
			CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> module = (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter>) element;
			String resultMsg = module.getClass().getSimpleName() + ": " + module.result;
			if (!module.resultMsg.equals(""))
				resultMsg += " (" + module.resultMsg + ")";
			return resultMsg;
		}
		throw unknownElement(element);
	}

	public void dispose() {
		checkOkImg.dispose();
		checkErrorImg.dispose();
		checkWarningImg.dispose();
	}

	protected RuntimeException unknownElement(Object element) {
		return new RuntimeException("Unknown type of element in tree of type "
				+ element.getClass().getName());
	}
}

