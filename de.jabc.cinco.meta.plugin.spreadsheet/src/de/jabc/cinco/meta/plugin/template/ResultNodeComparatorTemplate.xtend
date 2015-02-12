package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode

class ResultNodeComparatorTemplate {
		def create(String packageName,ArrayList<ResultNode> nodes)'''
package «packageName»;

import java.util.Comparator;

public class ResultNodeComparator implements Comparator<String> {

	private String resultNode;
	
	public ResultNodeComparator(String resultNode)
	{
		this.resultNode=resultNode;
	}
	
	@Override
	public int compare(String o1,String o2)
	{
		
		if(o1.equals(o2)) {
			return 0;
		}
		//Resultnode first
		if(o1.equals(resultNode)) {
			return 1;
		}
		if(o1.equals(resultNode)) {
			return -1;
		}
		
		
		//Generated Conditions for o1
		if( o1.equals("CalculationNode") || false) {
			return -1;
		}
		//Generated Conditions for o2
		if( o2.equals("CalculationNode") || false) {
			return 1;
		}
		//Alphabetic order for the other nodes
		return o1.compareTo(o2);
	}

}



'''
}