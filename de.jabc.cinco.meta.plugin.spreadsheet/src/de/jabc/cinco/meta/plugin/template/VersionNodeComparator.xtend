package de.jabc.cinco.meta.plugin.template

class VersionNodeComparator {
	def create(String packageName) '''
package «packageName»;

import java.util.Comparator;
import «packageName».VersionNode;

public class VersionNodeComparator<T> implements Comparator<VersionNode>
{

	private String resultNodeId;

	public VersionNodeComparator(String resultNodeId)
	{
		this.resultNodeId = resultNodeId;
	}
	@Override
	public int compare(VersionNode o1, VersionNode o2) {
		if(o1.node.getId().equals(o2.node.getId())) {
			return 0;
		}
		if(o1.node.getId().equals(resultNodeId)) {
			return -1;
		}
		if(o2.node.getId().equals(resultNodeId)) {
			return 1;
		}
		return o1.node.getId().compareTo(o2.node.getId());
	}

}
	'''
}