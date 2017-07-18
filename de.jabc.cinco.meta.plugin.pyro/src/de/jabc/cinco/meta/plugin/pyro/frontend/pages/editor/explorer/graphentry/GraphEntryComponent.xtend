package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.graphentry

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class GraphEntryComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameGraphEntryComponent()'''graph_entry_component.dart'''
	
	def contentGraphEntryComponent()'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
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
	
	  bool editMode = false;
	
	  GraphEntryComponent()
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
	    editMode = false;
	    e.preventDefault();
	    hasChanged.emit(e);
	  }
	
	  void selectGraphModel(GraphModel graph,dynamic e)
	  {
	    e.preventDefault();
	    openGraphModel.emit(graph);
	  }
	
	
	}
	
	'''
	
	def fileNameGraphEntryComponentTemplate()'''graph_entry_component.html'''
	
	def contentGraphEntryComponentTemplate()'''
	<span>
	    <span *ngIf="editMode">
	        <span class="glyphicon glyphicon-file"></span>
	        <input type="text" [(ngModel)]="graph.filename" style="color: #8e8e8e;">
	        <button
	            class="btn btn-default btn-xs btn-link"
	            style="padding-left: 0;padding-right: 0;color: white;"
	            (click)="save($event)"
	            type="button"
	        >
	            <span class="glyphicon glyphicon-ok"></span>
	        </button>
	    </span>
	    <span *ngIf="!editMode">
	        <span class="glyphicon glyphicon-file"></span> <span (click)="selectGraphModel(graph,$event)"><a href (click)="selectGraphModel(graph,$event)" style="color: white;">{{graph.filename}}</a></span>
	        <button
	            class="btn btn-xs btn-link btn-default"
	            type="button"
	            (click)="editGraph($event)"
	            style="padding-left: 0;padding-right: 0;color: white;"
	        >
	            <span class="glyphicon glyphicon-pencil"></span>
	        </button>
	        <button
	            class="btn btn-xs btn-link btn-danger"
	            type="button"
	            (click)="delete.emit(graph)"
	            style="padding-left: 0;padding-right: 0;color: white;"
	        >
	            <span class="glyphicon glyphicon-trash"></span>
	        </button>
	    </span>
	</span>
	
	'''
	
}