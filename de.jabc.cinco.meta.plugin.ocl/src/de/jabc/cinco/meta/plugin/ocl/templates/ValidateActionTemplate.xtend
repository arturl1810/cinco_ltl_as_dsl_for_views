package de.jabc.cinco.meta.plugin.ocl.templates

class ValidateActionTemplate {
	def create(String packageName)'''
package «packageName»;

import «packageName».ServiceLoader;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IObjectActionDelegate;
import org.eclipse.ui.IWorkbenchPart;

public class ValidateAction implements IObjectActionDelegate {

	private IWorkbenchPart targetPart;
	
	/**
	 * Constructor for Action1.
	 */
	public ValidateAction() {
		super();
	}

	/**
	 * @see IObjectActionDelegate#setActivePart(IAction, IWorkbenchPart)
	 */
	public void setActivePart(IAction action, IWorkbenchPart targetPart) {
		this.targetPart = targetPart; 
	}

	/**
	 * @see IActionDelegate#run(IAction)
	 */
	public void run(IAction action) {
		
		ISelection selection = targetPart.getSite().getPage().getSelection();
		
		if(selection instanceof IStructuredSelection){
			IStructuredSelection isl = (IStructuredSelection) selection;
			ServiceLoader.oclValidation(isl);
		}
				
	}
	
//	private void validate() throws ParserException {
//		OCL ocl = org.eclipse.ocl.ecore.OCL.newInstance();
//		OCLHelper<EClassifier, ?, ?, Constraint> helper = ocl.createOCLHelper();
//
//		helper.setContext(FlowgraphPackage.Literals.FLOW_GRAPH);
//
//		// create a Query to evaluate our query expressio
//		//helper.getProblems();
//		OCLExpression<EClassifier> query=helper.createQuery("context Flowgraph : self.modelName->size() = 1");
//		// create another to check our constraint
////		Query constraintEval = ocl.createQuery(invariant);
////
////		List<Library> libraries = getLibraries();  // hypothetical source of libraries
////
////		// only print the set of book categories for valid libraries
////		for (Library next : libraries) {
////		    if (constraintEval.check(next)) {
////		        // the OCL result type of our query expression is Set(BookCategory)
////		        @SuppressWarnings("unchecked")
////		        Set<BookCategory> categories = (Set<BookCategory>) queryEval.evaluate(next);
////		        
////		        System.out.printf("%s: %s%n", next.getName(), categories);
////		    }
////		}
//	}
	

	/**
	 * @see IActionDelegate#selectionChanged(IAction, ISelection)
	 */
	public void selectionChanged(IAction action, ISelection selection) {
	}

}
	'''
}