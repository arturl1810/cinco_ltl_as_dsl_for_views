package ${ConflictViewPackage}.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Set;

import info.scce.mcam.framework.adapter.EntityId;
import info.scce.mcam.framework.adapter.ModelAdapter;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.processes.MergeProcess;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.osgi.framework.Bundle;

public class MergeProcessTreeRenderer<E extends EntityId, M extends ModelAdapter<E>> {
	
	private Shell shell = null;

	private Tree tree = null;
	private MergeProcess<E, M> mp = null;

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
	
	public MergeProcessTreeRenderer(Tree tree,
			MergeProcess<E, M> mp, Shell shell) {
		super();
		this.tree = tree;
		this.mp = mp;
		this.shell = shell;

		loadIcons();
	}

	public void createTree() {
		for (E id : mp.getMergeInformationMap().keySet()) {
			MergeInformation<E, M> mergeInformation = mp
					.getMergeInformationMap().get(id);

			if (mergeInformation.getType().equals(MergeType.UNCHANGED))
				continue;

			TreeItem idItem = new TreeItem(tree, SWT.NONE);
			
			idItem.setImage(entityOkImg);
			if (mergeInformation.getListOfConflictedChangeSets().size() > 0)
				idItem.setImage(entityErrorImg);
			
			idItem.setText(id.toString());
			idItem.setData("data", id);
			idItem.setData("type", "id");

			int i = 1;
			for (Set<ChangeModule<E, M>> conflictSet : mergeInformation
					.getListOfConflictedChangeSets()) {
				TreeItem conflictItem = new TreeItem(idItem, SWT.NONE);
				conflictItem.setImage(conflictImg);
				conflictItem.setText("Conflict " + i);
				conflictItem.setData("type", "conflict");

				i++;

				for (ChangeModule<E, M> changeModule : conflictSet) {
					TreeItem changeItem = new TreeItem(conflictItem, SWT.NONE);
					changeItem.setImage(boxUnCheckedImg);
					changeItem.setText(changeModule.toString());
					changeItem.setData("data", changeModule);
					changeItem.setData("type", "change");
				}
			}

			for (ChangeModule<E, M> changeModule : mergeInformation
					.getLocalChanges()) {

				if (mergeInformation.isConflictedChange(changeModule))
					continue;

				TreeItem changeItem = new TreeItem(idItem, SWT.NONE);
changeItem.setImage(boxUnCheckedImg);
				
				if (changeModule.canPreExecute(mp.getMergeModelAdapter()) && changeModule.canExecute(mp.getMergeModelAdapter()) && changeModule.canPostExecute(mp.getMergeModelAdapter())) {
					changeModule.preExecute(mp.getMergeModelAdapter());
					changeModule.execute(mp.getMergeModelAdapter());
					changeModule.postExecute(mp.getMergeModelAdapter());
					changeItem.setImage(boxCheckedImg);
				}
				changeItem.setText(changeModule.toString());
				changeItem.setData("data", changeModule);
				changeItem.setData("type", "change");
			}

			for (ChangeModule<E, M> changeModule : mergeInformation
					.getRemoteChanges()) {

				if (mergeInformation.isConflictedChange(changeModule))
					continue;

				TreeItem changeItem = new TreeItem(idItem, SWT.NONE);
changeItem.setImage(boxUnCheckedImg);
				
				if (changeModule.canPreExecute(mp.getMergeModelAdapter()) && changeModule.canExecute(mp.getMergeModelAdapter()) && changeModule.canPostExecute(mp.getMergeModelAdapter())) {
					changeModule.preExecute(mp.getMergeModelAdapter());
					changeModule.execute(mp.getMergeModelAdapter());
					changeModule.postExecute(mp.getMergeModelAdapter());
					changeItem.setImage(boxCheckedImg);
				}
				changeItem.setText(changeModule.toString());
				changeItem.setData("data", changeModule);
				changeItem.setData("type", "change");
			}
		}

		tree.addMouseListener(new MouseListener() {

			@Override
			public void mouseDoubleClick(MouseEvent e) {
			}

			@Override
			public void mouseDown(MouseEvent e) {
				for (TreeItem item : tree.getSelection()) {
					if (item.getImage() != null) {
						if ((e.x > item.getImageBounds(0).x)
								&& (e.x < (item.getImageBounds(0).x + item
										.getImage().getBounds().width))) {
							if ((e.y > item.getImageBounds(0).y)
									&& (e.y < (item.getImageBounds(0).y + item
											.getImage().getBounds().height))) {
								setCheckedForChange(item);
							}
						}
					}
					if (item.getData("type").equals("id")) {
						@SuppressWarnings({ "unchecked", "unused" })
						E id = (E) item.getData("data");
						//MessageDialog.openInformation(shell, "Id clicked", id.toString());
					}
				}
			}

			@Override
			public void mouseUp(MouseEvent e) {
			}
		});
	}

	private void setCheckedForChange(TreeItem item) {
		if (item.getData("type").equals("change")) {
			@SuppressWarnings("unchecked")
			ChangeModule<E, M> change = (ChangeModule<E, M>) item
					.getData("data");
			if (item.getImage().equals(boxUnCheckedImg)) {
				if (change.canPreExecute(mp.getMergeModelAdapter()) && change.canExecute(mp.getMergeModelAdapter()) && change.canPostExecute(mp.getMergeModelAdapter())) {
					item.setImage(boxCheckedImg);
					change.preExecute(mp.getMergeModelAdapter());
					change.execute(mp.getMergeModelAdapter());
					change.postExecute(mp.getMergeModelAdapter());
					//MessageDialog.openInformation(shell, "Change executed",
					//		change.toString());
				} else {
					MessageDialog.openInformation(shell, "Change could not be executed!",
							change.toString());
				}
				
			} else if (item.getImage().equals(boxCheckedImg)) {
				if (change.canUndoPreExecute(mp.getMergeModelAdapter()) && change.canUndoExecute(mp.getMergeModelAdapter()) && change.canUndoPostExecute(mp.getMergeModelAdapter())) {
					item.setImage(boxUnCheckedImg);
					change.undoPostExecute(mp.getMergeModelAdapter());
					change.undoExecute(mp.getMergeModelAdapter());
					change.undoPreExecute(mp.getMergeModelAdapter());
					//MessageDialog.openInformation(shell, "Change reverted",
					//		change.toString());
				} else {
					MessageDialog.openInformation(shell, "Change could not be reverted!",
							change.toString());
				}
			}
		}
	}

	private void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam.libs");
		try {
			InputStream entityOkImgStream = FileLocator.openStream(bundle,
					new Path(entityOkIconPath), true);
			entityOkImg = new Image(tree.getDisplay(), entityOkImgStream);
			InputStream entityErrorImgStream = FileLocator.openStream(bundle,
					new Path(entityErrorIconPath), true);
			entityErrorImg = new Image(tree.getDisplay(), entityErrorImgStream);
			
			InputStream conflictImgStream = FileLocator.openStream(bundle,
					new Path(conflictIconPath), true);
			conflictImg = new Image(tree.getDisplay(), conflictImgStream);
			
			InputStream boxCheckedImgStream = FileLocator.openStream(bundle,
					new Path(boxCheckedIconPath), true);
			boxCheckedImg = new Image(tree.getDisplay(), boxCheckedImgStream);
			InputStream boxUncheckedImgStream = FileLocator.openStream(bundle,
					new Path(boxUnCheckedIconPath), true);
			boxUnCheckedImg = new Image(tree.getDisplay(),
					boxUncheckedImgStream);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}

