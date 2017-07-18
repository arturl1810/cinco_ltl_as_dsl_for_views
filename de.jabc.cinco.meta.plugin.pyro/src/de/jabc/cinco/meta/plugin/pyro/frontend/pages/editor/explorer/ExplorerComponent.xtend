package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class ExplorerComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameExplorerComponent()'''explorer_component.dart'''
	
	def contentExplorerComponent()'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/explorer/graph_entry/graph_entry_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/explorer/folder_entry/folder_entry_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/explorer/folder_entry/create/create_folder_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/explorer/graph_entry/create/create_file_component.dart';
	
	@Component(
	    selector: 'explorer',
	    templateUrl: 'explorer_component.html',
	    directives: const [FolderEntryComponent,GraphEntryComponent,CreateFileComponent,CreateFolderComponent],
	    styleUrls: const ['package:«gc.projectName.escapeDart»/pages/editor/editor_component.css']
	)
	class ExplorerComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter openGraphModel;
	
	  @Output()
	  EventEmitter hasDeleted;
	
	  @Output()
	  EventEmitter hasChanged;
	
	  @Input()
	  PyroUser user;
	  @Input()
	  PyroProject project;
	
	  @ViewChildren(FolderEntryComponent)
	  QueryList<FolderEntryComponent> childFolders;
	
	  bool showCreateFileModal = false;
	  bool showCreateFolderModal = false;
	  PyroFolder currentFolder;
	
	
	  ExplorerComponent()
	  {
	    openGraphModel = new EventEmitter();
	    hasDeleted = new EventEmitter();
	    hasChanged = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	  }
	
	
	  void removeFolder(PyroFolder folder)
	  {
	    project.innerFolders.remove(folder);
	    hasDeleted.emit(folder);
	  }
	
	  void deleteGraph(GraphModel graph)
	  {
	    project.graphModels.remove(graph);
	    hasDeleted.emit(graph);
	  }
	
	  void createEntry(dynamic e)
	  {
	    e.preventDefault();
	  }
	
	  void hideCreateFile(dynamic e)
	  {
	    e.preventDefault();
	    showCreateFileModal=false;
	  }
	
	  void hideCreateFolder(dynamic e)
	  {
	    e.preventDefault();
	    showCreateFolderModal=false;
	  }
	
	  void createFolder(PyroFolder folder)
	  {
	    currentFolder = folder;
	    showCreateFolderModal = true;
	  }
	
	  void createFile(PyroFolder folder)
	  {
	    currentFolder = folder;
	    showCreateFileModal = true;
	  }
	
	  void expandAll(dynamic e)
	  {
	    e.preventDefault();
	    changeFolderStatus(true);
	  }
	
	  void collapseAll(dynamic e)
	  {
	    e.preventDefault();
	    changeFolderStatus(false);
	  }
	
	  void changeFolderStatus(bool o)
	  {
	    childFolders.forEach((n) {
	      n.open = o;
	    });
	  }
	
	
	}
	
	'''
	
	def fileNameExplorerComponentTemplate()'''explorer_component.html'''
	
	def contentExplorerComponentTemplate()'''
	<div class="panel panel-default pyro-panel">
	    <div class="panel-heading pyro-panel-heading">
	        <strong>Project Explorer</strong>
	        <div class="btn-group btn-group-sm pull-right" role="group" style="margin-top: -5px;">
	            <button
	                    type="button"
	                    class="btn btn-sm btn-default btn-link pyro-button"
	                    (click)="expandAll($event)">
	                <span class="glyphicon glyphicon-resize-full"></span>
	            </button>
	            <button
	                    type="button"
	                    class="btn btn-sm btn-default btn-link pyro-button"
	                    (click)="collapseAll($event)">
	                <span class="glyphicon glyphicon-resize-small"></span>
	            </button>
	        </div>
	    </div>
	    <div class="panel-body pyro-panel-body" style="max-width: inherit;
	    overflow-x: scroll;">
	        <span style="white-space: nowrap">
	            <span class="glyphicon glyphicon-home"></span> {{project.name}}
	            <button
	                style="padding-left: 0;padding-right: 0;color: white;"
	                (click)="createFolder(project)"
	                type="button"
	                class="btn btn-xs btn-link btn-success"
	            >
	                <span class="glyphicon glyphicon-folder-close"></span>
	            </button>
	            <button
	                style="padding-left: 0;padding-right: 0;color: white;"
	                (click)="createFile(project)"
	                type="button"
	                class="btn btn-xs btn-link btn-success"
	            >
	                <span class="glyphicon glyphicon-file"></span>
	            </button>
	        </span>
	        <ul style="LIST-STYLE-TYPE: none;">
	            <li *ngFor="let entry of project.innerFolders" style="white-space: nowrap">
	                <folder-entry
	                        [folder]="entry"
	                        (delete)="removeFolder($event)"
	                        (hasDeleted)="hasDeleted.emit($event)"
	                        (hasChanged)="hasChanged.emit($event)"
	                        (createFile)="createFile($event)"
	                        (createFolder)="createFolder($event)"
	                        (openGraphModel)="openGraphModel.emit($event)"
	                ></folder-entry>
	            </li>
	            <li *ngFor="let graph of project.graphModels" style="white-space: nowrap">
	                <graph-entry
	                        [graph]="graph"
	                        (openGraphModel)="openGraphModel.emit($event)"
	                        (hasChanged)="hasChanged.emit($event)"
	                        (createFile)="createFile($event)"
	                        (createFolder)="createFolder($event)"
	                        (delete)="deleteGraph($event)"
	                ></graph-entry>
	            </li>
	        </ul>
	    </div>
	</div>
	<create-file
	    *ngIf="showCreateFileModal"
	    [folder]="currentFolder"
	    (close)="hideCreateFile($event)"
	>
	</create-file>
	<create-folder
	    *ngIf="showCreateFolderModal"
	    [folder]="currentFolder"
	    (close)="hideCreateFolder($event)"
	>
	</create-folder>
	
	'''
	
}