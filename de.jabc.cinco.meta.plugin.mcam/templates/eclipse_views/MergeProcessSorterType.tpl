package ${ViewUtilPackage};

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.processes.MergeProcess;

import java.util.ArrayList;
import java.util.Set;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerSorter;

public class MergeProcessSorterType extends ViewerSorter {
	
	private ArrayList<MergeType> typeSorting = new ArrayList<>();
	
	public MergeProcessSorterType() {
		super();
		typeSorting.add(MergeType.CONFLICTED);
		typeSorting.add(MergeType.CHANGED);
		typeSorting.add(MergeType.ADDED);
		typeSorting.add(MergeType.DELETED);
	}

	@Override
	public int category(Object element) {
		if (element instanceof ${GraphModelName}Id)
			return 1;
		if (element instanceof Set<?>)
			return 2;
		return 3;
	}

	@SuppressWarnings("unchecked")
	@Override
	public int compare(Viewer viewer, Object e1, Object e2) {
		int cat1 = category(e1);
		int cat2 = category(e2);
		if (cat1 != cat2)
			return cat1 - cat2;

		if (e1 instanceof ${GraphModelName}Id && e2 instanceof ${GraphModelName}Id) {
			${GraphModelName}Id id1 = (${GraphModelName}Id) e1;
			${GraphModelName}Id id2 = (${GraphModelName}Id) e2;
			Object input = viewer.getInput();
			if (input instanceof MergeProcess<?, ?>) {
				MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = (MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter>) input;
				MergeType type1 = mp.getMergeInformationMap().get(id1).getType();
				MergeType type2 = mp.getMergeInformationMap().get(id2).getType();
				return typeSorting.indexOf(type1) - typeSorting.indexOf(type2);
			}
		}

		return super.compare(viewer, e1, e2);
	}

}

