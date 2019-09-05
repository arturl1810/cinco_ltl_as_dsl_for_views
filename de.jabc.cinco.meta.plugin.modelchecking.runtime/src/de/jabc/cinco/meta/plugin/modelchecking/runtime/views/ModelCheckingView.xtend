package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Arrays
import java.util.List
import java.util.Set
import org.eclipse.jface.layout.TableColumnLayout
import org.eclipse.jface.viewers.ArrayContentProvider
import org.eclipse.jface.viewers.ColumnLabelProvider
import org.eclipse.jface.viewers.ColumnWeightData
import org.eclipse.jface.viewers.DoubleClickEvent
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.jface.viewers.TableViewerColumn
import org.eclipse.swt.SWT
import org.eclipse.swt.events.FocusEvent
import org.eclipse.swt.events.FocusListener
import org.eclipse.swt.events.ModifyEvent
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.events.SelectionListener
import org.eclipse.swt.events.TraverseEvent
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Table
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IPartListener2
import org.eclipse.ui.IWorkbenchPartReference
import org.eclipse.ui.part.ViewPart
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.CheckExecution
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.CheckExecution.CheckExecutionListener
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaHandler
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.ModelCheckingAdapter
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.Result
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula
import de.jabc.cinco.meta.plugin.modelchecking.runtime.util.ModelCheckingRuntimeExtension
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import de.jabc.cinco.meta.plugin.modelchecking.runtime.views.TopicalityHelper.TopicalityListener
import graphmodel.Node
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.ModelChecker
import org.eclipse.jface.action.Action
import org.eclipse.jface.action.MenuManager
import java.util.ArrayList
import org.eclipse.jface.action.IMenuListener
import org.eclipse.jface.action.IMenuManager
import org.eclipse.jface.action.Separator
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel
import org.eclipse.swt.events.KeyListener
import org.eclipse.swt.events.KeyEvent
import java.util.regex.Pattern

class ModelCheckingView extends ViewPart implements TopicalityListener, IPartListener2, CheckExecutionListener{
	extension WorkbenchExtension = new WorkbenchExtension
	extension ModelCheckingRuntimeExtension =new ModelCheckingRuntimeExtension
	
	public static val String ID="de.jabc.cinco.meta.plugin.modelchecking.runtime.views.ModelCheckingView"
	
	Action actionToggleShowingDescription
	Action actionToggleShowingHighlight
	Action actionToggleWithSelection
	Action actionToggleAutoCheck
	List<Action> checkerSetUpActions 
	List<ModelChecker<?,?,?>> modelCheckers
	
	Composite frameComposite
	Composite formulasComposite
	Composite buttonComposite
	Composite bottomComposite
	Composite searchBarComposite
	
	TableViewer viewer
	Table table
	TableViewerColumn colFormula
	TableViewerColumn colCheck
	
	Text textFieldFormulas
	
	Label labelStatus
	Label labelLastCheck
	
	Button buttonDeleteFormula
	Button buttonAddFormula
	Button buttonCheckFormulas
	Button buttonCheck
	Button buttonShowHighlight
	Button buttonShowDescription
	Button buttonWithSelection
	Button buttonAutoCheck
	
	private enum State {
		IDLE, FORMULAS_CHECK, AUTO_CHECK, AUTO_CHECK_ALL
	}
	
	State state
	
	boolean resultUpToDate
	
	OptionManager optionManager
	FormulaHandler<?, ?> handler
	CheckExecution execution
	ModelCheckingAdapter activeAdapter
	TopicalityHelper topicalityHelper
	
	IEditorPart activeEditor
	FormulaEditingSupport formulaEditingSupport
	DescriptionEditingSupport descriptionEditingSupport
	CheckEditingSupport checkEditingSupport
	
	override createPartControl(Composite parent) {
		frameComposite = new Composite(parent,SWT.NONE) 
		var gridLayout = new GridLayout(1,false) 
		frameComposite.layout = gridLayout
		val gridData = new GridData(SWT.FILL,SWT.FILL,true,true)
		frameComposite.shell.setMinimumSize(200,200)
		frameComposite.layoutData = gridData
		frameComposite.createSearchBarComposite				
		frameComposite.createFormulasComposite
		frameComposite.createBottomComposite
		state=State.IDLE 
		activePage.addPartListener(this)
		frameComposite.pack
		
		site.shell.setMinimumSize(600,330)
		 
		
		this.execution = new CheckExecution
		execution.addCheckExecutionListener(this)
		
		this.topicalityHelper = new TopicalityHelper
		activePage.addSelectionListener(topicalityHelper)
		topicalityHelper?.addTopicalityListener(this)
		topicalityHelper.start 
		
		modelCheckers = getModelCheckers
		optionManager = new OptionManager(modelCheckers.head)
		
		makeActions(modelCheckers)
		hookMenus
		hide
		reloadView 
	}
	
	
	def reloadView() {
		topicalityHelper.pause
		 
		var newEditor = activeDiagramEditor
		if (newEditor === null) {
			if (activeEditor === null) return;
			activeEditor = null 
			hide
			return
		} else if (newEditor == activeEditor && handler !== null) {
			topicalityHelper.unpause
			return
		}
		
		hide 
		
		activeEditor = newEditor 
		this.activeAdapter = getActiveAdapter
		handler = activeAdapter?.formulaHandler
		if (activeAdapter !== null){
			optionManager.loadOptions(activeGraphModel)
			setUpModelChecker
			topicalityHelper.reloadAdapters
			searchBarComposite.visible = true
			bottomComposite.visible = true
		}else{
			println("===ADAPTER IS NULL===")
		}
		
		if (handler !== null){
			formulasComposite.visible = true
			formulaEditingSupport.formulaHandler = handler  
			descriptionEditingSupport.formulaHandler = handler 
			checkEditingSupport.formulaHandler = handler 
			buttonAutoCheck.enabled = true
			actionToggleAutoCheck.enabled = true
			actionToggleShowingDescription.enabled = true
			checkAllFormulas 
		}else{
			actionToggleShowingDescription.enabled = false
			actionToggleAutoCheck.enabled = false
			buttonAutoCheck.enabled = false
		}
		
		refreshAll
	}
	
	private def hide(){
		searchBarComposite.visible = false
		formulasComposite.visible = false
		bottomComposite.visible = false
	}
	
	def refreshAll() {
		refreshTableViewer
		refreshButtons
		refreshActions
		refreshStatusText
		layout
	}
	
	def layout(){
		formulasComposite.layout()
		bottomComposite.layout()
		frameComposite.layout() 
		buttonComposite.layout()
	}
	
	def refreshActions(){
		actionToggleAutoCheck.checked = withAutoCheck
		actionToggleShowingDescription.checked = showingDescription
		actionToggleShowingHighlight.checked = showingHighlight
		actionToggleWithSelection.checked = withSelection
		checkerSetUpActions.forEach[checked = false]
		checkerSetUpActions.get(modelCheckers.indexOf(optionManager.modelChecker)).checked = true
	}
	
	def refreshTableViewer() {
		viewer.refresh 
	}
	
	private def refreshButtons() {
		buttonShowDescription.selection = showingDescription
		buttonShowHighlight.selection = showingHighlight
		buttonWithSelection.selection = withSelection
		buttonAutoCheck.selection = withAutoCheck
		if (handler !== null) {
			if (state != State.IDLE) {
				buttonAddFormula.enabled = false
				buttonDeleteFormula.enabled = false
				buttonCheckFormulas.enabled = false 
			} else {
				buttonAddFormula.enabled = textFieldFormulas.text.trim != "" 
					&& !handler.contains(textFieldFormulas.text)
				
				buttonDeleteFormula.enabled = !viewer.selection.empty
				
				buttonCheckFormulas.enabled = !handler.formulas.empty && handler.hasToCheck
			}
		}
	}
	
	private def refreshStatusText(String prefix, String suffix) {
		var selection = (viewer.structuredSelection as StructuredSelection) 
		var statusText = StatusTextProvider.getStatusText(prefix, suffix, resultUpToDate, selection) 
		labelStatus.text = statusText
		bottomComposite.layout();
	}
	
	private def setNewHighlight(Set<Node> nodes) {
		nodes.newHighlight = activeAdapter.highlightColor
		if (showingHighlight) {
			highlightOn
		}
	}
	
	private def refreshStatusText() {
		refreshStatusText("", "") 
	}
	
	private def hookMenus(){
		val bars = viewSite.actionBars
		val pulldownManager = bars.menuManager
		
		fillMenu(pulldownManager)
		
		val menuMgr = new MenuManager
		menuMgr.removeAllWhenShown = true
		menuMgr.addMenuListener(new IMenuListener{
			
			override menuAboutToShow(IMenuManager manager) {
				ModelCheckingView.this.fillMenu(manager)
			}
			
		})
		frameComposite.hookContextMenu(menuMgr)
		site.registerContextMenu(menuMgr,viewer)		
	}
	
	private def void hookContextMenu(Composite control, MenuManager menuMgr){
		val menu = menuMgr.createContextMenu(control)
		control.menu = menu
		control.children.forEach[
			if (it instanceof Composite){
				it.hookContextMenu(menuMgr)
			}
		]
	}
	
	def fillMenu(IMenuManager manager){
		manager.add(actionToggleShowingDescription)
		manager.add(new Separator)
		manager.add(actionToggleAutoCheck)
		manager.add(actionToggleShowingHighlight)
		manager.add(actionToggleWithSelection)
		manager.add(new Separator)
		val submanager = new MenuManager("Choose Model Checker")
		manager.add(submanager)
		
		for (action:checkerSetUpActions){
			submanager.add(action)
		}
	}
	
	private def makeActions(List<ModelChecker<?,?,?>> modelCheckers){
		actionToggleAutoCheck = new Action{
			
			override run() {
				optionManager.toggleAutoCheck
				refreshButtons
				refreshActions
				autoCheckAllFormulas
			}
			
			override getStyle() {
				AS_CHECK_BOX
			}
			
		}
		actionToggleAutoCheck.text = "Enable Auto Check"
		actionToggleShowingHighlight = new Action{
			
			override run() {
				optionManager.toggleShowingHighlight
				refreshButtons
				refreshActions
				if (showingHighlight){
					highlightOn
				}else{
					highlightOff
				}
			}
			
			override getStyle() {
				AS_CHECK_BOX
			}
			
		}
		actionToggleShowingHighlight.text = "Highlight satisfying nodes"
		
		actionToggleShowingDescription = new Action{
			
			override run() {
				optionManager.toggleShowingDescription
				if (showingDescription) {
					colFormula.setEditingSupport(descriptionEditingSupport) 
				} else {
					colFormula.setEditingSupport(formulaEditingSupport) 
				}
				refreshAll
			}
			
			override getStyle() {
				AS_CHECK_BOX
			}
		}
		actionToggleShowingDescription.text = "Show Descriptions"
		
		actionToggleWithSelection = new Action{
			
			override run() {
				optionManager.toggleWithSelection
				topicalityHelper.withSelection = withSelection
				refreshButtons
				refreshActions
				topicalityHelper.selectionChanged(null, null)
			}
			
			override getStyle() {
				AS_CHECK_BOX
			}
		}
		actionToggleWithSelection.text = "Consider Selection"
		
		checkerSetUpActions = new ArrayList
		
		for (it:modelCheckers){
			val action = new Action{
				
				override run() {
					optionManager.modelChecker = it
					setUpModelChecker
					if (handler !== null){
						checkAllFormulas
					}
					checkerSetUpActions.forEach[checked = false]
					checked = true
				}
				
				override getStyle() {
					AS_RADIO_BUTTON
				}
				
			}
			action.text = it.name
			checkerSetUpActions.add(action)
		}
	}
	
	private def void setUpModelChecker(){
		val checker = optionManager.modelChecker as ModelChecker<CheckableModel<?,?>,?,?>
		execution.modelChecker = checker
		topicalityHelper.modelChecker = checker
	}
	
	
	//Checking methods
	private def checkTextFieldFormula(String expression) {
		val formula = new CheckFormula(null, expression)
		buttonCheck.enabled = false
		checkFormulas(#[formula])
	}
	
	private def checkAllFormulas() {
		state = State.FORMULAS_CHECK
		handler.formulas.checkFormulas
	}
	
	private def checkFormulas(List<CheckFormula> formulas) {
		labelStatus.text = "Status: checking..." 
		refreshButtons
		bottomComposite.layout()
		frameComposite.layout()
		val withSelection = withSelection
		new Thread[
			execution.executeFormulasCheck(activeAdapter, activeModel, formulas, withSelection )
		].start
	}
	
	def void autoCheckAllFormulas() {
		state = State.AUTO_CHECK_ALL
		handler.formulas.autoCheck 
	}
	
	def void autoCheck(List<CheckFormula> formulas) {
		if (withAutoCheck) {
			formulas.checkFormulas
			if (state == State.IDLE) state = State.AUTO_CHECK
		}
	}
	
	private def getSatisfyingOfFormulas(List<CheckFormula> formulas) {
		var satisfyingAllFormulas = newHashSet
		
		
		if (formulas.size > 0) {
			if (formulas.size == 1){
				return formulas.head.satisfyingNodes
			}
			
			for (node : formulas.head.satisfyingNodes) {
				var satisfyingAll = !formulas.subList(1,formulas.size).exists[
					satisfyingNodes.map[id].forall[it != node.id]
				] 
				
				if (satisfyingAll) {
					satisfyingAllFormulas.add(node) 
				}
			}
		}
		return satisfyingAllFormulas 
	}
	
	private def createSearchBarComposite(Composite parent) {
		searchBarComposite = new Composite(parent,SWT.NONE) 
		var searchBarGridLayout = new GridLayout(2,false) 
		var searchBarGridData = new GridData(SWT.FILL,SWT.NONE,true,false) 
		//searchBarGridData.horizontalSpan = 4 
		searchBarComposite.layout = searchBarGridLayout 
		searchBarComposite.layoutData = searchBarGridData 
		
		// SearchField for Formula
		textFieldFormulas = new Text(searchBarComposite,SWT.SINGLE.bitwiseOr(SWT.BORDER)) 
		textFieldFormulas.layoutData = new GridData(SWT.FILL,SWT.NONE,true,false)
		
		textFieldFormulas.addTraverseListener([TraverseEvent e|if (buttonCheck.isEnabled && e.detail === SWT.TRAVERSE_RETURN) {
			checkTextFieldFormula(textFieldFormulas.text) 
		}]) 
		
		textFieldFormulas.addModifyListener([ModifyEvent e|refreshButtons]) 
		textFieldFormulas.addFocusListener(new FocusListener(){
			override focusLost(FocusEvent e) {}
			
			override focusGained(FocusEvent e) {
				viewer.selection = new StructuredSelection
			}
		})
		
//		FormulaProvider
//		textFieldFormulas.addKeyListener(new KeyListener{
//			
//			override keyPressed(KeyEvent e) {
//				
//			}
//			
//			override keyReleased(KeyEvent e) {
//				if (Pattern.matches("\\p{Print}", e.character.toString)){
//				
//					val pos = textFieldFormulas.caretPosition
//					val newText = textFieldFormulas.text + " - test"
//					textFieldFormulas.text = newText
//					textFieldFormulas.setSelection(pos, newText.length)
//				}
//			}
//			
//		})
		 
		// Check Button to start check
		buttonCheck = createButton(searchBarComposite, SWT.PUSH, "check", true, false)
		buttonCheck.layoutData = new GridData(SWT.RIGHT,SWT.NONE,false,false) 
		buttonCheck.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent event) {
				checkTextFieldFormula(textFieldFormulas.text) 
			}
			
			override widgetDefaultSelected(SelectionEvent e) {}
		}) 
		searchBarComposite.layout()
	}
	
	private def createFormulasComposite(Composite parent){
		formulasComposite = new Composite(parent, SWT.NONE)
		formulasComposite.layout = new GridLayout(1,false)
		formulasComposite.layoutData = new GridData(SWT.FILL, SWT.FILL, true, true)
		
		val labelFormulas = new Label(formulasComposite,SWT.LEFT) 
		labelFormulas.text = "Formulas:" 
		labelFormulas.layoutData = new GridData(SWT.LEFT,SWT.NONE,true,false)
		
		formulasComposite.createTableComposite
		formulasComposite.createButtonComposite
		formulasComposite.layout()
	}
	
	private def createTableComposite(Composite parent) {
		var tableComposite = new Composite(parent,SWT.NONE) 
		var tableColumnLayout = new TableColumnLayout
		tableComposite.layout = tableColumnLayout		 	
		
		viewer = new TableViewer(tableComposite,SWT.MULTI.bitwiseOr(SWT.H_SCROLL).bitwiseOr(SWT.V_SCROLL).bitwiseOr(SWT.FULL_SELECTION).bitwiseOr(SWT.BORDER)){
			override refresh() {
				if (handler !== null) {
					this.input = handler.formulas
				}
				selection = new StructuredSelection
				super.refresh
			}
		} 
		
		tableComposite.layoutData = new GridData(SWT.FILL,SWT.FILL,true,true) 
		viewer.table.layoutData = new GridData(SWT.FILL,SWT.FILL,true,true)  
		table = viewer.table
		 
		tableColumnLayout.createColumns
		
		table.headerVisible = true
		table.linesVisible = true
		 
		viewer.contentProvider = new ArrayContentProvider 
		viewer.addDoubleClickListener([DoubleClickEvent event|
			var selection=(event.selection as StructuredSelection) 
			var formula=(selection.firstElement as CheckFormula) 
			textFieldFormulas.text = formula.expression
		]) 
		
		viewer.addSelectionChangedListener([SelectionChangedEvent event|
			var suffix = "" 
			if (viewer.structuredSelection.size > 0) {
				var selectedFormulas = newArrayList
				
				for (formula : (viewer.structuredSelection as StructuredSelection).toList) {
					selectedFormulas.add((formula as CheckFormula)) 
				}
				
				var satisfyingAllFormulas = selectedFormulas.satisfyingOfFormulas
				
				if (resultUpToDate) {
					newHighlight = satisfyingAllFormulas
				}
			
				switch satisfyingAllFormulas {
					case satisfyingAllFormulas.size == 1: suffix="1 satisfying node." 
					case satisfyingAllFormulas.size > 1:
						suffix='''«satisfyingAllFormulas.size» satisfying nodes.'''
				}
			}
			refreshButtons
			refreshStatusText("", suffix) 
		])
	}
	
	private def createColumns(TableColumnLayout layout) {
		colFormula = createTableViewerColumn("formula", 0, SWT.LEFT, SWT.LEFT) 
		colFormula.labelProvider = new ColumnLabelProvider(){
			override getText(Object element) {
				var formula = (element as CheckFormula) 
				if (showingDescription) {
					var descriptionText = formula.description 
					if (descriptionText == "") {
						return '''Description for [«formula.expression»]''' 
					}
					return descriptionText 
				}
				return formula.expression
			}
		}
		
		formulaEditingSupport = new FormulaEditingSupport(this) 
		descriptionEditingSupport = new DescriptionEditingSupport(this) 
		colFormula.editingSupport = formulaEditingSupport
		
		var colResult = createTableViewerColumn("result", 1, SWT.CENTER, SWT.RIGHT) 
		colResult.labelProvider = new ColumnLabelProvider(){
			override getText(Object element) {
				var result = "" 
				var formula = (element as CheckFormula) 
				if (!resultUpToDate) {
					result = ''' [out-of-date]''' 
				}
				
				switch (formula.result) {
					case TRUE:{
						return '''true«result»''' 
					}
					case FALSE:{
						return '''false«result»''' 
					}
					case ERROR:{
						return '''error''' 
					}
					default :{
						return '''-''' 
					}
				}
			}
			
			override getBackground(Object element) {
				var display = Display.getCurrent() 
				var formula = (element as CheckFormula) 
				if (!resultUpToDate) {
					return display.getSystemColor(SWT.COLOR_WHITE) 
				}
				
				switch (formula.result) {
					case TRUE:{
						return display.getSystemColor(SWT.COLOR_GREEN) 
					}
					case FALSE:{
						return display.getSystemColor(SWT.COLOR_RED) 
					}
					case ERROR:{
						return display.getSystemColor(SWT.COLOR_YELLOW) 
					}
					default :{
						return display.getSystemColor(SWT.COLOR_WHITE) 
					}
				}
			}
		} 
		
		colCheck = createTableViewerColumn("check", 2, SWT.CENTER, SWT.RIGHT) 
		colCheck.labelProvider = new ColumnLabelProvider(){
			override getText(Object element) {
				if (((element as CheckFormula)).toCheck) {
					return "X" 
				} else {
					return "" 
				}
			}
		}
		
		checkEditingSupport = new CheckEditingSupport(this) 
		colCheck.editingSupport = checkEditingSupport
		
		layout.setColumnData(table.getColumn(0), new ColumnWeightData(70,100,true)) 
		layout.setColumnData(table.getColumn(1), new ColumnWeightData(20,40,true)) 
		layout.setColumnData(table.getColumn(2), new ColumnWeightData(10,10,true)) 
	}
	
	private def createTableViewerColumn(String title, int colNumber, int alignment, int style) {
		val viewerColumn = new TableViewerColumn(viewer,style) 
		val column = viewerColumn.column
		column.text = title
		column.resizable = true
		column.moveable = true
		column.alignment = alignment
		return viewerColumn 
	}
	
	private def createButtonComposite(Composite parent) {
		buttonComposite = new Composite(parent,SWT.NONE) 
		var buttonGridLayout = new GridLayout(5,false) 
		buttonComposite.layout = buttonGridLayout 
		buttonComposite.layoutData = new GridData(SWT.FILL,SWT.FILL,true,false) 
		
		buttonAddFormula = createButton(buttonComposite,SWT.PUSH, "add", false, false)
		buttonAddFormula.layoutData = new GridData(SWT.LEFT,SWT.NONE,false,false) 
		buttonAddFormula.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent e) {
				var formula = textFieldFormulas.text 
				handler.add(formula) 
				refreshAll
				autoCheck(Arrays.asList(handler.getFormulaByExpression(formula))) 
			}
			override widgetDefaultSelected(SelectionEvent e) {}
		}) 			
		
		buttonDeleteFormula = createButton(buttonComposite, SWT.PUSH, "delete", false, false)
		buttonDeleteFormula.setLayoutData(new GridData(SWT.LEFT,SWT.NONE,false,false)) 
		buttonDeleteFormula.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent e) {
				val selection = viewer.structuredSelection.toList
				
				activeGraphModel.transact("Delete Formulas",[
					selection.forEach[
						handler.remove(it as CheckFormula)
					]
				])
				refreshAll
			}
			override widgetDefaultSelected(SelectionEvent e) {}
		}) 
		
		
		buttonCheckFormulas = createButton(buttonComposite, SWT.PUSH, "check formulas", true, false)
		buttonCheckFormulas.setLayoutData(new GridData(SWT.LEFT,SWT.NONE,false,false)) 
		buttonCheckFormulas.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent e) {
				checkAllFormulas 
			}
			
			override widgetDefaultSelected(SelectionEvent e) {}
		}) 
			
			
		labelLastCheck = new Label(buttonComposite,SWT.LEFT) 
		labelLastCheck.text = '''Last Check: not checked...'''
		
		buttonShowDescription = createButton(buttonComposite,SWT.CHECK, "Description", true, false)
		buttonShowDescription.setLayoutData(new GridData(SWT.RIGHT,SWT.NONE,true,false)) 
		buttonShowDescription.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent e) {
				actionToggleShowingDescription.run
			}
			
			override widgetDefaultSelected(SelectionEvent e) {}
		}) 
		
		buttonComposite.layout()
	}
	
	private def createBottomComposite(Composite parent){
		bottomComposite = new Composite(parent, SWT.NONE)
		bottomComposite.layout = new GridLayout(2,false)
		bottomComposite.layoutData = new GridData(SWT.FILL, SWT.NONE, true, false)
		
		labelStatus = new Label(bottomComposite,SWT.WRAP) 
		labelStatus.layoutData = new GridData(SWT.BEGINNING,SWT.TOP,true,false) 
		labelStatus.text = "Status: " 
		
		bottomComposite.createOptionComposite
		bottomComposite.layout()
	}
	
	
	private def createOptionComposite(Composite parent) {
		val optionComposite = new Composite(parent, SWT.NONE)
		optionComposite.layoutData = new GridData(SWT.RIGHT,SWT.NONE,false,false)
		optionComposite.layout = new GridLayout(3,false)
		
		buttonAutoCheck = createButton(optionComposite, SWT.CHECK, "auto check", true, true)
		buttonAutoCheck.layoutData = new GridData(SWT.RIGHT,SWT.NONE,false,false)
		buttonAutoCheck.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent e) {
				actionToggleAutoCheck.run
			}
			
			override widgetDefaultSelected(SelectionEvent e) {}
				
		}) 
		
		// ShowButton to toggle show
		buttonShowHighlight = createButton(optionComposite, SWT.CHECK, "show", true, true)
		buttonShowHighlight.layoutData = new GridData(SWT.RIGHT,SWT.NONE,false,false)
		buttonShowHighlight.addSelectionListener(new SelectionListener(){
			override widgetSelected(SelectionEvent e) {
				actionToggleShowingHighlight.run
			}
			
			override widgetDefaultSelected(SelectionEvent e) {}
		})
		
		buttonWithSelection = createButton(optionComposite, SWT.CHECK, "Selection", true, false)
		buttonWithSelection.layoutData = new GridData(SWT.RIGHT,SWT.NONE,false,false)
		buttonWithSelection.addSelectionListener(new SelectionListener{
			override widgetSelected(SelectionEvent e) {
				actionToggleWithSelection.run
			}
			
			override widgetDefaultSelected(SelectionEvent e) {}
		}) 	

		optionComposite.layout()
	}
	
	private def createButton(Composite parent, int style, String text, boolean enabled, boolean selection){
		var button = new Button(parent, style)
		button.text = text
		button.enabled = enabled
		button.selection = selection
		button
	}
	
	private def isShowingHighlight() {
		optionManager.showingHighlight
	}
	
	private def isWithSelection() {
		optionManager.withSelection
	}
	
	private def isShowingDescription() {
		handler !== null && optionManager.showingDescription
	}
	
	private def isWithAutoCheck() {
		handler !== null && optionManager.withAutoCheck
	}
	
	def getViewer() {
		viewer 
	}
	
	override setFocus() {
		textFieldFormulas.setFocus
	}
	
	override dispose() {
		activePage?.removePartListener(this)
		if (topicalityHelper !== null) topicalityHelper.cleanup 
		super.dispose
	}
	
	override partActivated(IWorkbenchPartReference partRef) {
		reloadView() 
	}
	
	override partBroughtToTop(IWorkbenchPartReference partRef) {
		//System.out.println("Part brought to top");
	}
	
	override partClosed(IWorkbenchPartReference partRef) {
		reloadView() 
	}
	
	override partDeactivated(IWorkbenchPartReference partRef) {
		
	}
	
	override partOpened(IWorkbenchPartReference partRef) {
		//System.out.println("Part opened");		
	}
	
	override partHidden(IWorkbenchPartReference partRef) {
		//System.out.println("Part hidden");
	}
	
	override partVisible(IWorkbenchPartReference partRef) {
		//System.out.println("Part visible");
	}
	
	override partInputChanged(IWorkbenchPartReference partRef) {
		System.out.println("Part input changed");
	}
	
	override onNewResult(CheckFormula formula) {
		if (formula.id === null){
			if (formula.result == Result.ERROR){
				labelStatus.text = '''Status: Error. «formula.errorMessage»''' 
			}else{
				val satisfying = formula.satisfyingNodes
				satisfying.setNewHighlight
				labelStatus.text = StatusTextProvider.getStatusText(satisfying.size, formula.result)
			}
			 
			buttonCheck.enabled = true
			bottomComposite.layout()
			frameComposite.layout() 
		}else{ 
			refreshTableViewer
		}
	}
	
	override onFinished() {
		if (state == State.AUTO_CHECK_ALL || state == State.FORMULAS_CHECK){
			topicalityHelper.refreshCheckModel
			resultUpToDate = true
			clearHighlight
			var datetime = LocalDateTime.now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) 
			labelLastCheck.text = '''Last Check: «datetime»''' 
		}
		if (state != State.IDLE){
			state = State.IDLE 
			refreshAll
		}
		
		state = State.IDLE 
		
	}
	
	override checkModelChanged(boolean resultUpToDate) { 
		if (withAutoCheck && !resultUpToDate) {
			autoCheckAllFormulas
		} else {
			this.resultUpToDate=resultUpToDate 
			clearHighlight 
			refreshAll
		}
	}
	
	override formulasChanged() {
		
		if (!handler.editing){
			handler.reloadFormulas
			autoCheckAllFormulas
			clearHighlight
			refreshAll
		}
	}
}