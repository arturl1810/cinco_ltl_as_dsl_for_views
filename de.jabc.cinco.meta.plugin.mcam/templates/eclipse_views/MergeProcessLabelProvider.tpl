package ${ViewPackage}.util;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Set;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;
import org.osgi.framework.Bundle;

public class MergeProcessLabelProvider extends LabelProvider {

	private String boxCheckedIconPath = "icons/box_checked.png";
	private String boxUnCheckedIconPath = "icons/box_unchecked.png";
	private String conflictIconPath = "icons/lightning.png";
	private String entityErrorIconPath = "icons/error.png";
	private String entityOkIconPath = "icons/info.png";

	private Image entityOkImg = null;
	private Image entityErrorImg = null;
	private Image conflictImg = null;
	private Image boxCheckedImg = null;
	private Image boxUnCheckedImg = null;
	
	private List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone = null;
	private MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = null;
	
	public MergeProcessLabelProvider(MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp, List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone) {
		super();
		loadIcons();
		this.changesDone = changesDone;
		this.mp = mp;
	}
	
	private Display getDisplay() {
	      Display display = Display.getCurrent();
	      //may be null if outside the UI thread
	      if (display == null)
	         display = Display.getDefault();
	      return display;		
	   }
	
	private void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam.libs");
		try {
			InputStream entityOkImgStream = FileLocator.openStream(bundle,
					new Path(entityOkIconPath), true);
			entityOkImg = new Image(getDisplay(), entityOkImgStream);
			InputStream entityErrorImgStream = FileLocator.openStream(bundle,
					new Path(entityErrorIconPath), true);
			entityErrorImg = new Image(getDisplay(), entityErrorImgStream);

			InputStream conflictImgStream = FileLocator.openStream(bundle,
					new Path(conflictIconPath), true);
			conflictImg = new Image(getDisplay(), conflictImgStream);

			InputStream boxCheckedImgStream = FileLocator.openStream(bundle,
					new Path(boxCheckedIconPath), true);
			boxCheckedImg = new Image(getDisplay(), boxCheckedImgStream);
			InputStream boxUncheckedImgStream = FileLocator.openStream(bundle,
					new Path(boxUnCheckedIconPath), true);
			boxUnCheckedImg = new Image(getDisplay(),
					boxUncheckedImgStream);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	/*
	 * @see ILabelProvider#getImage(Object)
	 */
	@SuppressWarnings("unchecked")
	public Image getImage(Object element) {
		if (element instanceof ${GraphModelName}Id) {
			${GraphModelName}Id id = (${GraphModelName}Id) element;
			if (mp.getMergeInformationMap().get(id).getListOfConflictedChangeSets().size() > 0)
				return entityErrorImg;
			return entityOkImg;
		}
		if (element instanceof ChangeModule<?, ?>) {
			ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change = (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>) element;
			if (changesDone.contains(change))
				return boxCheckedImg;
			return boxUnCheckedImg;
		}
		if (element instanceof Set<?>)
			return conflictImg;
		throw unknownElement(element);
	}

	/*
	 * @see ILabelProvider#getText(Object)
	 */
	@SuppressWarnings("unchecked")
	public String getText(Object element) {
		if (element instanceof ${GraphModelName}Id)
			return ((${GraphModelName}Id) element).toString();
		if (element instanceof ChangeModule<?, ?>)
			return ((ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>) element).toString();
		if (element instanceof Set<?>) {
			for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInfo : mp.getMergeInformationMap().values()) {
				int i = 0;
				for (Set<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> conflictSet : mergeInfo.getListOfConflictedChangeSets()) {
					i++;
					if (conflictSet.equals((Set<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>>) element))
						return "Conflict " + i;
				}
			}
			return "Conflict";
		}
		throw unknownElement(element);
	}

	public void dispose() {
		entityOkImg.dispose();
		entityErrorImg.dispose();
		conflictImg.dispose();
		boxCheckedImg.dispose();
		boxUnCheckedImg.dispose();
	}

	protected RuntimeException unknownElement(Object element) {
		return new RuntimeException("Unknown type of element in tree of type "
				+ element.getClass().getName());
	}
}

