package ${ViewPackage}.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeProcess;

import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;

public class MergeProcessContentProvider implements ITreeContentProvider {
	
	private static Object[] EMPTY_ARRAY = new Object[0];
	
	private MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = null;

	@Override
	public void dispose() {}

	@SuppressWarnings("unchecked")
	@Override
	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		this.mp = (MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter>) newInput;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object[] getChildren(Object parentElement) {
		List<Object> elements = new ArrayList<>();
		if(parentElement instanceof ${GraphModelName}Id) {
			${GraphModelName}Id id = (${GraphModelName}Id) parentElement;
			MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInfo = mp.getMergeInformationMap().get(id);
			for (Set<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> conflictSet : mergeInfo.getListOfConflictedChangeSets()) {
				elements.add(conflictSet);
			}
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : mergeInfo.getLocalChanges()) {
				if (!mergeInfo.isConflictedChange(change))
					elements.add(change);
			}
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : mergeInfo.getRemoteChanges()) {
				if (!mergeInfo.isConflictedChange(change))
					elements.add(change);
			}
			return elements.toArray();
		}
		if (parentElement instanceof Set<?>) {
			Set<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> conflictSet = (Set<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>>) parentElement;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : conflictSet) {
				elements.add(change);
			}
			return elements.toArray();
		}
		return EMPTY_ARRAY;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public Object[] getElements(Object inputElement) {
		if (inputElement instanceof MergeProcess<?,?>) {
			MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = (MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter>) inputElement;
			List<${GraphModelName}Id> ids = new ArrayList<>();
			for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInfo : mp.getMergeInformationMap().values()) {
				if (mergeInfo.getLocalChanges().size() > 0 || mergeInfo.getRemoteChanges().size() > 0)
					ids.add(mergeInfo.getId());
			}
			return ids.toArray();
		}
		return EMPTY_ARRAY;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object getParent(Object element) {
		if (element instanceof ChangeModule<?, ?>) {
			ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change = (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>) element;
			if (!mp.getMergeInformationMap().get(change.id).isConflictedChange(change)) {
				return change.id;
			} else {
				for (Set<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> conflictSet : mp.getMergeInformationMap().get(change.id).getListOfConflictedChangeSets()) {
					if (conflictSet.contains(change))
						return conflictSet;
				}
			}
		}
		return null;
	}

	@Override
	public boolean hasChildren(Object element) {
		return getChildren(element).length > 0;
	}

}

