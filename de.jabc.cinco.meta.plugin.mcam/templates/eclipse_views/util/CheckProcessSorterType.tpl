package ${ViewUtilPackage};

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.modules.CheckModule.CheckResultType;

import java.util.ArrayList;
import java.util.Set;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerSorter;

public class CheckProcessSorterType extends ViewerSorter {

	private ArrayList<CheckResultType> typeSorting = new ArrayList<>();

	public CheckProcessSorterType() {
		super();
		typeSorting.add(CheckResultType.ERROR);
		typeSorting.add(CheckResultType.WARNING);
		typeSorting.add(CheckResultType.PASSED);
		typeSorting.add(CheckResultType.NOT_CHECKED);
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

		if (e1 instanceof CheckModule && e2 instanceof CheckModule) {
			CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> cm1 = (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter>) e1;
			CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> cm2 = (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter>) e2;
			return typeSorting.indexOf(cm1.result)
					- typeSorting.indexOf(cm2.result);
		}

		return super.compare(viewer, e1, e2);
	}
}

