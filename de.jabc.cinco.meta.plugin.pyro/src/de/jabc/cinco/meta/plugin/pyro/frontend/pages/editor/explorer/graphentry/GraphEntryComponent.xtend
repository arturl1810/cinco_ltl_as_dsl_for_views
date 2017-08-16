package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.graphentry

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.ModelElement
import mgl.ReferencedModelElement

class GraphEntryComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameGraphEntryComponent()'''graph_entry_component.dart'''
	
	def contentGraphEntryComponent()'''
	import 'package:angular2/core.dart';
	
	import '../../../../model/core.dart';
	import '../../../../service/graph_service.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
	«ENDFOR»
	
	@Component(
	    selector: 'graph-entry',
	    templateUrl: 'graph_entry_component.html',
	    directives: const []
	)
	class GraphEntryComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter openGraphModel;
	
	  @Output()
	  EventEmitter delete;
	
	  @Output()
	  EventEmitter hasChanged;
	
	  @Input()
	  GraphModel graph;
	  
	  @Input('currentGraphModel')
	  GraphModel currentOpenGraph;
	
	  bool editMode = false;
	
	  final GraphService graphService;
	  
	  bool open = false;
	  
	  List<IdentifiableElement> primeRefs = new List();
	
	  GraphEntryComponent(GraphService this.graphService)
	  {
	    openGraphModel = new EventEmitter();
	    delete = new EventEmitter();
	    hasChanged = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	  }
	
	  void editGraph(dynamic e)
	  {
	    editMode = true;
	    e.preventDefault();
	  }
	
	  void save(dynamic e)
	  {
	    e.preventDefault();
	    graphService.updateGraphModel(graph).then((g){
	      editMode = false;
	      hasChanged.emit(e);
	    });
	
	  }
	
	  String getExtension(){
	    if(graph==null){
	      return "";
	    }
	    «FOR g:gc.graphMopdels.filter[!fileExtension.nullOrEmpty]»
	    if(graph is «g.name.lowEscapeDart».«g.name.fuEscapeDart»){
	      return ".«g.fileExtension»";
	    }
		«ENDFOR»
	    return "";
	  }
	  
	  bool canContainPrime() {
	  	if(graph==null||currentOpenGraph==null){
	      return false;
	    }
	    //check if current open graph can contaiun prime nodes
	    «FOR g:gc.graphMopdels.filter[!primeRefs.empty]»
	    if(currentOpenGraph is «g.name.lowEscapeDart».«g.name.fuEscapeDart»){
	    	//check if elements of current graph entry can be referenced 
	    	«FOR refG:g.primeReferencedGraphModels»
		    if(graph is «refG.name.lowEscapeDart».«refG.name.fuEscapeDart»){
		      return true;
		    }
		    «ENDFOR»
	    }
		«ENDFOR»
	    return false;
	  }
	  
	  String getPrimeRefName(IdentifiableElement elem) {
	  	if(elem == null||currentOpenGraph==null){
	  		return "null";
	  	}
	  	//check if current open graph can contaiun prime nodes
	    «FOR g:gc.graphMopdels.filter[!primeRefs.empty]»
	    if(currentOpenGraph is «g.name.lowEscapeDart».«g.name.fuEscapeDart»)
	    {
	    	//check if elements of current graph entry can be referenced 
	    	«FOR refG:g.primeReferencedGraphModels»
		    if(graph is «refG.name.lowEscapeDart».«refG.name.fuEscapeDart»)
		    {
		      «FOR pr:g.getPrimeReferencingElements(refG)»
			      if(elem is «refG.name.lowEscapeDart».«pr.referencedElement.name.fuEscapeDart»)
			      {
	      	    		«IF pr.referencedElementAttributeName == null»
						return elem.dywaId.toString();
	      	    		«ELSE»
	      	    		return elem.«pr.referencedElementAttributeName»;
	      	    		«ENDIF»
	      	    	}
      	    	«ENDFOR»
		    }
		    «ENDFOR»
	    }
	    «ENDFOR»
		return elem.dywaId.toString();
	  }
	  
	  String getFolderClass()
	  {
	      if(open){
	        return "glyphicon glyphicon-chevron-down";
	      }
	      return "glyphicon glyphicon-chevron-right";
	  }
	  
	  void openPrimeRefs(dynamic e)
	  {
	      e.preventDefault();
	      if(graph==null||currentOpenGraph==null){
	      	return;
	      }
	      open = !open;
	      if(open==true)
	      {
	      	//fetch primerefs for current graphmodel
	      	primeRefs = new List();
	      	 «FOR g:gc.graphMopdels.filter[!primeRefs.empty]»
	      	if(currentOpenGraph is «g.name.lowEscapeDart».«g.name.fuEscapeDart»)
  		    {
  		    	//check if elements of current graph entry can be referenced 
  		    	«FOR refG:g.primeReferencedGraphModels»
	  			    if(graph is «refG.name.lowEscapeDart».«refG.name.fuEscapeDart»)
	  			    {
	  			    	graphService.loadCommandGraph«refG.name.fuEscapeDart»(graph).then((n){
	  			          var list = n.currentGraphModel.allElements();
	  			          list.forEach((elem){
	  			          	«FOR pr:g.getPrimeReferencingElements(refG).map[referencedElement].toSet»
	  			            if(elem is «refG.name.lowEscapeDart».«pr.name.fuEscapeDart»)
	  			            {
	  			              primeRefs.add(elem);
	  			            }
	  			            «ENDFOR»
	  			          });
	  			       });
	  			    }
      	    	«ENDFOR»
  		    }
  		    «ENDFOR»
	      }
	  }
	  
	  bool hasIcon() {
	  	if(graph==null){
	      return false;
	    }
	    «FOR g:gc.graphMopdels.filter[!iconPath.nullOrEmpty]»
	    if(graph is «g.name.lowEscapeDart».«g.name.fuEscapeDart»){
	      return true;
	    }
		«ENDFOR»
	    return false;
	  }
	  
	  String getIcon() {
	  	 if(graph==null){
	  	      return "";
	  	  }
	  	  «FOR g:gc.graphMopdels.filter[!iconPath.nullOrEmpty]»
	  	    if(graph is «g.name.lowEscapeDart».«g.name.fuEscapeDart»){
	  	      return "asset/«g.iconPath(g.name.lowEscapeDart)»";
	  	    }
	  	  «ENDFOR»
	  	  return "";
	  }
	
	  void selectGraphModel(GraphModel graph,dynamic e)
	  {
	    e.preventDefault();
	    openGraphModel.emit(graph);
	  }
	
	
	}
	

	
	'''
	
	def ModelElement element(ReferencedModelElement element){
		element.eContainer as ModelElement
	}
	


	
}