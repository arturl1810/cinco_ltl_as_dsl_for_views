package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.folderentry

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class FolderEntryComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameFolderEntryComponent()'''folder_entry_component.dart'''
	
	def contentFolderEntryComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/explorer/graph_entry/graph_entry_component.dart';
	
	@Component(
	    selector: 'folder-entry',
	    templateUrl: 'folder_entry_component.html',
	    directives: const [FolderEntryComponent,GraphEntryComponent]
	)
	class FolderEntryComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter openGraphModel;
	
	  @Output()
	  EventEmitter delete;
	
	  @Output()
	  EventEmitter hasChanged;
	
	  @Output()
	  EventEmitter hasDeleted;
	
	  @Output()
	  EventEmitter createFile;
	
	  @Output()
	  EventEmitter createFolder;
	
	  @Input()
	  PyroFolder folder;
	
	  @ContentChildren(FolderEntryComponent)
	  QueryList<FolderEntryComponent> childFolders;
	
	
	  bool open = false;
	  bool editMode = false;
	
	  FolderEntryComponent()
	  {
	    openGraphModel = new EventEmitter();
	    delete = new EventEmitter();
	    createFile = new EventEmitter();
	    createFolder = new EventEmitter();
	    hasDeleted = new EventEmitter();
	    hasChanged = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	  }
	
	  String getFolderClass()
	  {
	    if(open){
	      return "glyphicon glyphicon-chevron-down";
	    }
	    return "glyphicon glyphicon-chevron-right";
	  }
	
	  void openFolder(dynamic e)
	  {
	    open = !open;
	    e.preventDefault();
	  }
	
	  void removeFolder(PyroFolder folder)
	  {
	    //todo remove
	    this.folder.innerFolders.remove(folder);
	    hasDeleted.emit(folder);
	  }
	
	  void deleteGraph(GraphModel graph)
	  {
	    //todo persist
	    folder.graphModels.remove(graph);
	    hasDeleted.emit(graph);
	  }
	
	  void editEntry(dynamic e)
	  {
	    e.preventDefault();
	    editMode =true;
	  }
	
	  void save(dynamic e)
	  {
	    e.preventDefault();
	    editMode = false;
	    hasChanged.emit(e);
	  }
	
	  void createInnerFolder(PyroFolder folder)
	  {
	    open = true;
	    createFolder.emit(folder);
	  }
	
	  void createInnerFile(PyroFolder folder)
	  {
	    open = true;
	    createFile.emit(folder);
	  }
	
	}
	
	'''
	
	def fileNameFolderEntryComponentTemplate()'''folder_entry_component.html'''
	
	def contentFolderEntryComponentTemplate()'''
	<span *ngIf="!editMode">
	    <span
	        (click)="openFolder($event)"
	        [ngClass]="getFolderClass()"
	    ></span> <a href (click)="openFolder($event)" style="color: white;">{{folder.name}}</a>
	    <button
	        style="padding-left: 0;padding-right: 0;color: white;"
	        (click)="createInnerFolder(folder)"
	        type="button"
	        class="btn btn-xs btn-link btn-success"
	    >
	        <span class="glyphicon glyphicon-folder-close"></span>
	    </button>
	    <button
	        style="padding-left: 0;padding-right: 0;color: white;"
	        (click)="createInnerFile(folder)"
	        type="button"
	        class="btn btn-xs btn-link btn-success"
	    >
	        <span class="glyphicon glyphicon-file"></span>
	    </button>
	    <button
	        style="padding-left: 0;padding-right: 0;color: white;"
	        (click)="editEntry($event)"
	        type="button"
	        class="btn btn-xs btn-link btn-default"
	    >
	        <span class="glyphicon glyphicon-pencil"></span>
	    </button>
	    <button
	        style="padding-left: 0;padding-right: 0;color: white;"
	        (click)="delete.emit(folder)"
	        type="button"
	        class="btn btn-xs btn-link btn-danger"
	    >
	        <span class="glyphicon glyphicon-trash"></span>
	    </button>
	</span>
	<span *ngIf="editMode">
	    <span
	        (click)="openFolder($event)"
	        [ngClass]="getFolderClass()"
	    ></span>
	    <input type="text" [(ngModel)]="folder.name" style="color: #8e8e8e;" required>
	    <button
	        style="padding-left: 0;padding-right: 0;color: white;"
	        class="btn btn-default btn-xs btn-link"
	        (click)="save($event)"
	        type="button"
	    >
	        <span class="glyphicon glyphicon-ok"></span>
	    </button>
	</span>
	<ul [hidden]="!open" style="LIST-STYLE-TYPE: none;">
	    <li *ngFor="let entry of folder.innerFolders" style="white-space: nowrap">
	        <folder-entry
	            [folder]="entry"
	            (createFile)="createInnerFile($event)"
	            (createFolder)="createInnerFolder($event)"
	            (hasDeleted)="hasDeleted.emit($event)"
	            (delete)="removeFolder($event)"
	            (openGraphModel)="openGraphModel.emit($event)"
	        ></folder-entry>
	    </li>
	    <li *ngFor="let graph of folder.graphModels" style="white-space: nowrap">
	        <graph-entry
	            [graph]="graph"
	            (openGraphModel)="openGraphModel.emit($event)"
	            (delete)="deleteGraph($event)"
	        ></graph-entry>
	    </li>
	</ul>
	'''
}