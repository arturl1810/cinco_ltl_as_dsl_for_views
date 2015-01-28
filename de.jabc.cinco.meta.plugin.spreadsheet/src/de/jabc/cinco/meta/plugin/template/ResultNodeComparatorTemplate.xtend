package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode

class ResultNodeComparatorTemplate {
		def create(String packageName,ArrayList<ResultNode> nodes)'''
package «packageName»;

import java.util.Comparator;

public class ResultNodeComparator implements Comparator<String> {

	@Override
	public int compare(
			String o1,
			String o2) {
		if(o1.equals(o2)) {
			return 0;
		}

		//Generated Conditions for o1
		if(«FOR n : nodes» o1.equals("«n.nodeName.toFirstUpper»") ||«ENDFOR» false) {
			return -1;
		}
		//Generated Conditions for o2
		if(«FOR n : nodes» o2.equals("«n.nodeName.toFirstUpper»") ||«ENDFOR» false) {
			return 1;
		}
		//Alphabetic order for the other nodes
		return o1.compareTo(o2);
	}

}



'''
}