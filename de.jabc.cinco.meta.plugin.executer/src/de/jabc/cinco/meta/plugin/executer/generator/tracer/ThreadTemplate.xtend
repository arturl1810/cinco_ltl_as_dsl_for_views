package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ThreadTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "Thread.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	
	import java.util.LinkedList;
	import java.util.List;
	import java.util.Queue;
	import java.util.Set;
	import java.util.stream.Collectors;
	import java.util.stream.Stream;
	
	import graphmodel.ModelElement;
	import «graphmodel.tracerPackage».extension.AbstractContext;
	import «graphmodel.tracerPackage».extension.AbstractSemantic;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».stepper.utils.ContentView;
	import «graphmodel.tracerPackage».stepper.utils.Highlighter;
	import «graphmodel.tracerPackage».stepper.utils.TracerException;
	import «graphmodel.tracerPackage».stepper.utils.WaitingException;
	/**
	 * The Thread defines a single instance of a control flow.
	 * All threads share a global context, which can be separated.
	 * The Thread holds a stack and the history of levels.
	 * @author zweihoff
	 *
	 */
	public final class Thread {
		private Level currentLevel;
		private List<Level> levelHistory;
		private LinkedList<Level> levelQueue;
		private List<Match> globalHistory;
		
		private AbstractContext context;
		
		private AbstractSemantic semantic;
		
		private Highlighter highlighter;
		
		
		/**
		 * Creates the History and Stack of levels.
		 * Creates the first level and initializes it with the first modelelement
		 * @param firstGraph The current graphmodel
		 * @param firstElement The first modelelement for execution
		 * @param context The global shared context
		 * @param semantic The gloabel shared semantics
		 */
		public Thread(LTSMatch firstGraph,Match firstElement, AbstractContext context, AbstractSemantic semantic)
		{
			//create the context
			this.context = context;
			
			//set semantics
			this.semantic = semantic;
			
			//create a highlighter
			this.highlighter = new Highlighter();
			
			
			levelHistory = new LinkedList<Level>();
			levelQueue = new LinkedList<Level>();
			globalHistory = new LinkedList<Match>();
			
			
			Level firstLevel = new Level(firstElement,semantic,globalHistory);
			
			currentLevel = firstLevel;
			
			levelHistory.add(firstLevel);
			levelQueue.addFirst(firstLevel);
		}
		
		/**
		 * Creates a new level, sets the first element
		 * and updates the level stack and history
		 * @param stepResult The StepResult to be executed
		 */
		private final void levelDown(StepResult stepResult)
		{
			currentLevel.setCurrenElement(stepResult.getPreElement());
			//Create new Level
			Level level = new Level(stepResult.getFollowingElement(), semantic,globalHistory);
			levelHistory.add(level);
			levelQueue.addFirst(level);
			currentLevel = level;
		}
		
		/**
		 * Removes the current level, which execution has been ended
		 * and goes back to the previous level if available
		 * @param stepResult
		 * @return
		 */
		private final boolean levelUp(StepResult stepResult)
		{
			levelQueue.removeFirst();
			if(levelQueue.isEmpty()){
				//End of Execution on top level
				return false;
			}
			else {
				currentLevel = levelQueue.getFirst();
			}
			return true;
		}
		
		public final ThreadStepResult doStep(List<Thread> threads) throws TracerException, WaitingException
		{
			ThreadStepResult result = new ThreadStepResult();
			StepResult sr = currentLevel.doStep(this.context,threads);
			if(sr == null){
				return null;
			}
			result.setStepResult(sr);
			result.setThread(this);
			return result;
		}
		
		
		
		public final boolean executeStep(StepResult stepResult,List<Thread> threads,AbstractSemantic semantic) throws TracerException
		{
			//Execute the Step and set the new current Modelelement
			//and synchronize the history
			stepResult = currentLevel.executeStep(stepResult,globalHistory,context);
			
			//Spawn new threads if needed
			//Add the new threads to the active threads to be executed in parallel
			for(Match match:stepResult.getNewElements()){
				semantic.preSpawnNewThread(this);
				Thread newThread = new Thread(match.getRoot(),match,context,semantic);
				threads.add(newThread);
				semantic.postSpawnNewThread(newThread);
			}
			
			System.out.println(stepResult);
			
			//If Level is terminated, look for upper level
			if(stepResult.getStepType()==StepType.Terminating){
				semantic.preLeaveLevel(this,currentLevel);
				return levelUp(stepResult);
			}
			//If new Level is activated, jump to new level
			else if (stepResult.getStepType() == StepType.Level) {
				semantic.preEnterNewLevel(this,currentLevel);
				levelDown(stepResult);
				semantic.postEnterNewLevel(this,currentLevel);
			}
			return true;
		}
	
		public final Level getCurrentLevel() {
			return currentLevel;
		}
	
		public final void setCurrentLevel(Level currentLevel) {
			this.currentLevel = currentLevel;
		}
	
		public final List<Level> getLevelHistory() {
			return levelHistory;
		}
	
		public final void setLevelHistory(LinkedList<Level> levelHistory) {
			this.levelHistory = levelHistory;
		}
	
		public final Queue<Level> getLevelQueue() {
			return levelQueue;
		}
	
		public final void setLevelQueue(LinkedList<Level> levelQueue) {
			this.levelQueue = levelQueue;
		}
		
		public final Object[] displayHistory()
		{
			List<ContentView> result = new LinkedList<ContentView>();
			for(Match match:this.globalHistory){
				result.add(new ContentView(semantic.displayElement(match),match,this));
			}
			return result.toArray();
			
		}
		
		public final void highlightHistory() {
			this.highlighter.highlight(this.globalHistory.stream().flatMap(n->n.getElements().stream()).collect(Collectors.toSet()));
			
		}
		
		public final void highlightCurrent() {
			this.highlighter.highlight(this.currentLevel.getCurrenElement().getElements());
			
		}
		
		public final Object[] displayLevel()
		{
			List<ContentView> result = new LinkedList<ContentView>();
			for(Level l:this.levelQueue){
				result.add(new ContentView(
						semantic.displayLevel(l.getCurrentContainer().getContainer())+":"+semantic.displayElement(l.getCurrenElement()),
						l.getCurrenElement(),
						this
						));
			}
			return result.toArray();
			
		}
		
		public final void highlightLevels()
		{
			Set<ModelElement> activeElements = Stream.concat(
					this.levelQueue.stream().map(n->n.getCurrentContainer().getContainer()).filter(n->n!=null).filter(n->n instanceof ModelElement).map(n->(ModelElement)n),
					this.levelQueue.stream().flatMap(n->n.getCurrenElement().getElements().stream())
					).collect(Collectors.toSet());
			this.highlighter.highlight(activeElements);
		}
	
		public final List<Match> getGlobalHistory() {
			return globalHistory;
		}
	
		public final void setGlobalHistory(List<Match> globalHistory) {
			this.globalHistory = globalHistory;
		}
	
		public final AbstractContext getContext() {
			return context;
		}
	
		public final void setContext(AbstractContext context) {
			this.context = context;
		}
	
		public final AbstractSemantic getSemantic() {
			return semantic;
		}
	
		public final void setSemantic(AbstractSemantic semantic) {
			this.semantic = semantic;
		}
	
		public final Highlighter getHighlighter() {
			return highlighter;
		}
	
		public final void setHighlighter(Highlighter highlighter) {
			this.highlighter = highlighter;
		}
	
		public final void setLevelHistory(List<Level> levelHistory) {
			this.levelHistory = levelHistory;
		}
	
		
		
		
		
	}
	
	'''
	
}