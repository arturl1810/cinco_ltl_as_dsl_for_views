package ${ViewPackage}.util;

import java.util.Set;

import ${AdapterPackage}.${GraphModelName}Id;

import org.eclipse.jface.viewers.ViewerSorter;

public class MergeProcessSorterAlphabetical extends ViewerSorter {

	@Override
	public int category(Object element) {
		if (element instanceof ${GraphModelName}Id)
			return 1;
		if (element instanceof Set<?>)
			return 2;
		return 3;
	}
}

