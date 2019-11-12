package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import org.eclipse.jface.viewers.StructuredSelection
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.Result
import de.jabc.cinco.meta.plugin.modelchecking.runtime.util.ModelCheckingRuntimeExtension

class StatusTextProvider {
	
	static extension ModelCheckingRuntimeExtension = new ModelCheckingRuntimeExtension
	
	static def getStatusText(String prefix, String suffix, boolean resultUpToDate, StructuredSelection viewerSelection){
		var statusText = (new StringBuilder).append("Status:")
		if (prefix != ""){
			statusText.append(" ").append(prefix)
		}
		
		var outOfDateText= "";
		
		if (viewerSelection.toList.exists[!resultUpToDate]) {
			outOfDateText = "*"
		}
		
		val selectedNodes = selectedElementIds.size();
		switch (selectedNodes){			
			case 1: statusText.append(" 1 selected node.")
			case selectedNodes > 1: statusText.append(" ").append(selectedNodes).append(" selected nodes.")
		}
		
		val selectedFormulas = viewerSelection.size();
		switch (selectedFormulas) {
			case 1: {
				statusText.append( " 1 selected formula.")
				val formula = viewerSelection.getFirstElement() as CheckFormula
				
				
				switch (formula.getResult() ) {
					case TRUE: statusText.append(" Result").append(": true").append(outOfDateText).append(".")
					case FALSE: statusText.append(" Result").append(": false").append(outOfDateText).append(".")
					case ERROR: statusText.append(" Error: ").append(formula.getErrorMessage()).append(".")
					case NOT_CHECKED: statusText.append(" Not checked.")
				}
			}
			case selectedFormulas > 1:{
				statusText.append(" " + selectedFormulas + " selected formulas.")
				var result = Result.TRUE
				var i = 0
				val selectionAsList = viewerSelection.toList()
				while (i<selectionAsList.size && result != Result.ERROR){
					val formula = selectionAsList.get(i) as CheckFormula
					if (!formula.result.isValid || (result == Result.TRUE && formula.result == Result.FALSE)){
						result = formula.result
					}
					i++						
				}
				
				switch(result) {
					case TRUE: statusText.append(" Result of conjunction").append(": true").append(outOfDateText).append(".")
					case FALSE: statusText.append(" Result of conjunction").append(": false").append(outOfDateText).append(".")
					case NOT_CHECKED: statusText.append(" Not every selected formula is checked yet.")
					case ERROR: statusText.append(" Selection contains errors.")
				}
			}
		}
		
		if (suffix != ""){
			statusText.append(" ").append(suffix)
		}
		
		statusText.toString
	}
	
	static def getStatusText(int satisfyingSize, Result result){
		var statusText = (new StringBuilder).append("Status:")
		
		switch(satisfyingSize){
			case 0: statusText.append(" No satisfying nodes.")
			case 1: statusText.append(" ").append(satisfyingSize)
				.append(" node satisfies the formula.")
			default: statusText.append(" ").append(satisfyingSize)
				.append(" nodes satisfy the formula.")
		}
		
		switch(result){
			case TRUE: statusText.append(" Result: true.")
			case FALSE: statusText.append(" Result: false.")
		}
		
		statusText.toString
	}
	
}