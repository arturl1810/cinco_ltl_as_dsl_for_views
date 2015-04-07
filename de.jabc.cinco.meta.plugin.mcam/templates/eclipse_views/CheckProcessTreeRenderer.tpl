package ${ViewPackage}.util;

import java.io.IOException;
import java.io.InputStream;

import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.modules.CheckModule.CheckResultType;
import info.scce.mcam.framework.processes.CheckProcess;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.osgi.framework.Bundle;

public class CheckProcessTreeRenderer {

	private Shell shell = null;

	private Tree tree = null;
	private CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = null;

	private String checkErrorIconPath = "icons/error.png";
	private String checkOkIconPath = "icons/ok.png";
	private String checkWarningIconPath = "icons/warning.png";

	private Image checkOkImg = null;
	private Image checkErrorImg = null;
	private Image checkWarningImg = null;

	public CheckProcessTreeRenderer(Tree tree,
			CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp, Shell shell) {
		super();
		this.tree = tree;
		this.cp = cp;
		this.shell = shell;

		loadIcons();
	}

	public void runInitialChangeExecution() {
	}

	public void createTree() {
		for (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> module : cp.getResults()) {

			TreeItem moduleItem = new TreeItem(tree, SWT.NONE);

			moduleItem.setImage(checkOkImg);
			if (module.result.equals(CheckResultType.ERROR))
				moduleItem.setImage(checkErrorImg);
			if (module.result.equals(CheckResultType.WARNING))
				moduleItem.setImage(checkWarningImg);

			String resultMsg = module.getClass().getSimpleName() + ": " + module.result;
			if (!module.resultMsg.equals(""))
				resultMsg += " (" + module.resultMsg + ")";
			
			moduleItem.setText(resultMsg);
			moduleItem.setData("data", module);
			moduleItem.setData("type", "check");

			for (${GraphModelName}Id id : module.resultList.keySet()) {
				TreeItem idItem = new TreeItem(moduleItem, SWT.NONE);
				idItem.setText(id + ": " + module.resultList.get(id));
				idItem.setData("type", "id");
				idItem.setData("data", id);
			}

		}

		tree.addMouseListener(new MouseListener() {

			@Override
			public void mouseDoubleClick(MouseEvent e) {
			}

			@Override
			public void mouseDown(MouseEvent e) {
				for (TreeItem item : tree.getSelection()) {
					if (item.getData("type").equals("id")) {
						${GraphModelName}Id id = (${GraphModelName}Id) item.getData("data");
						cp.getModel().highlightElement(id);
					}
				}
			}

			@Override
			public void mouseUp(MouseEvent e) {
			}
		});
	}

	private void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam.libs");
		try {
			InputStream entityOkImgStream = FileLocator.openStream(bundle,
					new Path(checkOkIconPath), true);
			checkOkImg = new Image(tree.getDisplay(), entityOkImgStream);
			InputStream entityErrorImgStream = FileLocator.openStream(bundle,
					new Path(checkErrorIconPath), true);
			checkErrorImg = new Image(tree.getDisplay(), entityErrorImgStream);
			InputStream checkWarningImgStream = FileLocator.openStream(bundle,
					new Path(checkWarningIconPath), true);
			checkWarningImg = new Image(tree.getDisplay(), checkWarningImgStream);

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}


