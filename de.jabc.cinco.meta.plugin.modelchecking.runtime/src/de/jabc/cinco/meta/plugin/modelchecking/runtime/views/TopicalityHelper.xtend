package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import de.jabc.cinco.meta.plugin.modelchecking.runtime.util.ModelCheckingRuntimeExtension
import de.jabc.cinco.meta.core.utils.job.ReiteratingThread
import org.eclipse.emf.ecore.resource.Resource
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.ModelCheckingAdapter
import java.util.Set
import java.util.HashSet
import org.eclipse.emf.ecore.util.EContentAdapter
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.emf.common.notify.Notification
import graphmodel.internal.impl.InternalGraphModelImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.jface.viewers.ISelection
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.ISelectionListener
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.ModelChecker
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.ModelComparator

class TopicalityHelper implements ISelectionListener{
	extension WorkbenchExtension = new WorkbenchExtension
	extension ModelCheckingRuntimeExtension = new ModelCheckingRuntimeExtension
	
	ReiteratingThread thread
	Resource activeResource
	CheckableModel<?,?> activeCheckModel
	ModelChecker<?,?,?> checker
	ModelCheckingAdapter activeAdapter
	ModelComparator<CheckableModel<?,?>> comparator
	boolean withSelection
	Set<TopicalityListener> listeners = new HashSet
	EContentAdapter resourceEContentAdapter
	
	enum EditState{NO_CHANGE, MODEL_EDIT, NEW_MODEL}
	
	AtomicReference<TopicalityHelper.EditState> editState
	
	new (){
		
		editState = new AtomicReference
		editState.set(EditState.NO_CHANGE)
		withSelection = false	
		resourceEContentAdapter = new EContentAdapter() {
			
			override notifyChanged(Notification notification) {
				if (notification.formulasChanged){//} || notification.descriptionEdit){
					listeners.forEach[formulasChanged]
				}
				if (notification.newGraphModel){
					editState.set(EditState.NEW_MODEL)
					
					//async[listeners.forEach[formulasChanged]]
				}
				editState.compareAndSet(EditState.NO_CHANGE, EditState.MODEL_EDIT)
				//println("Notification: " + notification)
			}
			
		}
		initThread
	}
	
	def setModelChecker(ModelChecker<CheckableModel<?,?>,?,?> checker){
		this.checker = checker
		comparator = checker.comparator as ModelComparator<CheckableModel<?,?>>
	}
	
	def isNewGraphModel(Notification notification){
		!notification.touch &&
		notification.eventType == Notification.ADD && 
		notification.newValue instanceof InternalGraphModelImpl
	}
	
	def formulasChanged(Notification notification){
		
		if (!notification.touch && notification.notifier instanceof EObject){
			//println("formulas changed")
			val notifier = (notification.notifier as EObject)?.eContainer?.class
			val formulasTypeClass = activeAdapter?.formulasTypeClass
			if (activeAdapter === null) {println("adapter null")}
			if (formulasTypeClass === null) {println("formulas null");return false;}
			
			notifier?.isAssignableFrom(formulasTypeClass) ||
			notification.oldValue?.class?.isAssignableFrom(formulasTypeClass) ||
			notification.newValue?.class?.isAssignableFrom(formulasTypeClass)			
		}
		
	}
	
	def refreshCheckModel(){
		if (activeAdapter !== null){
			activeCheckModel = getActiveCheckModel
			editState.set(EditState.NO_CHANGE)
			unpause
		}else{
			//println("active adapter null")
			pause
			activeCheckModel = null
		}
	}
	
	
	
	def setWithSelection(boolean withSelection){
		if (this.withSelection != withSelection){
			editState.compareAndSet(EditState.NO_CHANGE, EditState.MODEL_EDIT)
		}
		this.withSelection = withSelection
	}
	
	def reloadAdapters(){
		//println("reload adapters")
		this.activeAdapter = getActiveAdapter
		
		//println("Formula type:" + activeAdapter.formulaHandler.formulasFromModel.head.class.simpleName)
		setResourceAdapter
	}
	
	
	def isEqualCheckModel(){		
		
		comparator.areEqualModels(getActiveCheckModel,activeCheckModel)
	}
	
	def getActiveCheckModel(){
		val newCheckModel = checker?.createCheckableModel
		activeAdapter?.buildCheckableModel(newCheckModel,withSelection)
		newCheckModel
	}
	def initThread() {
		thread = new ReiteratingThread(2000){			
			override protected work() {
				if (activeCheckModel === null){
					pause
				}
				if (editState.get == EditState.NO_CHANGE){
					//println("[Thread] nothing to do")
				}else {
					//println("[Thread] model edited")
					val state = editState.get					
					editState.set(EditState.NO_CHANGE)
					
					if (state == EditState.NEW_MODEL){
						//println("DESCRIPTION_EDIT")
						async[listeners.forEach[formulasChanged]]
					}
					
					if (!isEqualCheckModel){
						//println("[Thread] CheckModel changed")
						async[listeners.forEach[checkModelChanged(false)]]	
					}else{
						//println("[Thread] CheckModel did not change")
						async[listeners.forEach[checkModelChanged(true)]]
					}					
				}
			}
			
		}
	}
	
	def start(){
		thread?.start
	}
	
	def void setResourceAdapter(){		
		activeResource?.eAdapters?.remove(resourceEContentAdapter)		
		activeResource = activeGraphModel?.eResource
		activeResource?.eAdapters?.add(resourceEContentAdapter)
	}
	
	def togglePause(){
		if (thread.paused) unpause
		else pause
	}
	
	def pause(){
		thread.pause
	}
	
	def unpause(){
		thread.unpause
	}
	
	def cleanup() {
		PlatformUI.workbench.activeWorkbenchWindow.activePage.removeSelectionListener(this)	
		activeResource?.eAdapters?.remove(resourceEContentAdapter)		
		thread?.quit
	}
	
	override selectionChanged(IWorkbenchPart part, ISelection selection) {
		if (withSelection){
			editState.compareAndSet(EditState.NO_CHANGE, EditState.MODEL_EDIT)
		}
	}

	//Listener
	
	def addTopicalityListener(TopicalityListener listener){		
		if (listener !== null) listeners.add(listener) 
	}
	
	def removeTopicalityListener(TopicalityListener listener){
		listeners.remove(listener)
	}
	
	interface TopicalityListener  {
		def void checkModelChanged(boolean resultUpToDate)
		def void formulasChanged()
	}
}