package de.jabc.cinco.meta.plugin.pyro.templates

class PresentationStaticContent {
	def editProjectDialog()
	'''
	package de.mtf.dywa.components.modals.project;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import de.mtf.dywa.pages.Projects;
import org.apache.tapestry5.alerts.AlertManager;
import org.apache.tapestry5.alerts.Duration;
import org.apache.tapestry5.alerts.Severity;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Parameter;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;

import java.util.ArrayList;
import java.util.Date;

public class EditProjectDialog {

    @Inject
    private ProjectController projectController;

    @Parameter
    @Property
    private Project projectToEdit;

    @Inject
    private AlertManager alertManager;

    @Inject
    private Messages messages;

    @InjectPage
    private Projects projectsPage;

    @Component
    private Form editProjectDialogForm;

    @Property
    private String editProjectDialogName;

    @Property
    @Parameter
    private String linkCss;

    public void onValidateFromeditProjectDialogForm() {
        if (this.editProjectDialogName != null && !this.editProjectDialogName.isEmpty()) {
            if (!projectController.fetchProject().isEmpty()) {
                for(Project project : this.projectController.fetchProject())
                {
                    if(project.getName().equals(editProjectDialogName)){
                        editProjectDialogForm.recordError(messages.get("name-in-use"));
                        return;
                    }
                }
                //TODO Validate Unique Name depending on the user
            }
        }
        else {
            editProjectDialogForm.recordError(messages.get("invalid-name"));
        }
    }


    public void onFailureFromeditProjectDialogForm() {
        for (String str : editProjectDialogForm.getDefaultTracker().getErrors()) {
            alertManager.alert(Duration.TRANSIENT, Severity.ERROR, str);
        }
    }

    public void onSuccessFromeditProjectDialogForm() {

        this.projectToEdit.setName(editProjectDialogName);
        this.projectToEdit.setedited(new Date());

        alertManager.alert(Duration.TRANSIENT, Severity.INFO,
                messages.format("successfully-edited", editProjectDialogName));

    }

    public Object onSubmitFromeditProjectDialogForm() {
        return this.projectsPage;
    }

    public void setupRender() {
        this.editProjectDialogName = projectToEdit.getName();
    }

    public void onPrepare(long projectId) {
        this.projectToEdit = projectController.readProject(projectId);
    }
}
	
	'''
	
	def newProjectDialog()
	'''
	package de.mtf.dywa.components.modals.project;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import de.mtf.dywa.pages.Pyro;
import de.mtf.dywa.pages.Projects;
import org.apache.tapestry5.alerts.AlertManager;
import org.apache.tapestry5.alerts.Duration;
import org.apache.tapestry5.alerts.Severity;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Parameter;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.services.PageRenderLinkSource;

import java.util.Date;

public class NewProjectDialog {

    @InjectPage
    private Pyro pyroPage;

    @Inject
    private ProjectController projectController;

    @Inject
    private AlertManager alertManager;

    @Inject
    private Messages messages;

    @InjectPage
    private Projects projectsPage;

    @Component
    private Form newProjectDialogForm;

    @Property
    private String newProjectDialogName;

    @Inject
    private PageRenderLinkSource pageRenderLS;

    private Project newProject;

    @Property
    @Parameter
    private String linkCss;

    @Parameter
    @Property
    private boolean isExplorerPage = true;

    public void onValidateFromNewProjectDialogForm() {
        if (this.newProjectDialogName != null && !this.newProjectDialogName.isEmpty()) {
            if (!projectController.fetchProject().isEmpty()) {
                for(Project project : this.projectController.fetchProject())
                {
                    if(project.getName().equals(newProjectDialogName)){
                        newProjectDialogForm.recordError(messages.get("name-in-use"));
                        return;
                    }
                }
                //TODO Validate Unique Name depending on the user
            }
        }
        else {
            newProjectDialogForm.recordError(messages.get("invalid-name"));
        }
    }

    public void onFailureFromNewProjectDialogForm() {
        for (String str : newProjectDialogForm.getDefaultTracker().getErrors()) {
            alertManager.alert(Duration.TRANSIENT, Severity.ERROR, str);
        }
    }

    public void onSuccessFromNewProjectDialogForm() {

        this.newProject = this.projectController.createProject(newProjectDialogName);
        this.newProject.setcreated(new Date());
        this.newProject.setedited(new Date());

        alertManager.alert(Duration.TRANSIENT, Severity.INFO,
                messages.format("successfully-created", newProjectDialogName));
    }

    public Object onSubmitFromNewProjectDialogForm() {
        return this.projectsPage;

    }
}
	
	'''
	
	def openProjectDialog()
	'''
	package de.mtf.dywa.components.modals.project;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import de.mtf.dywa.pages.Projects;
import org.apache.tapestry5.alerts.AlertManager;
import org.apache.tapestry5.alerts.Duration;
import org.apache.tapestry5.alerts.Severity;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Parameter;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class OpenProjectDialog {

    @Inject
    private ProjectController projectController;

    @Property
    private List<Project> projects;

    @Property
    private Project iteratedProject;

    @Property
    @Parameter
    private String linkCss;

    @Property
    private int index;

    public void setupRender() {
        this.projects = new ArrayList<Project>(projectController.fetchProject());
    }
}
	
	'''
	
	def removeProjectDialog()
	'''
	package de.mtf.dywa.components.modals.project;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import de.mtf.dywa.pages.Projects;
import org.apache.tapestry5.alerts.AlertManager;
import org.apache.tapestry5.alerts.Duration;
import org.apache.tapestry5.alerts.Severity;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Parameter;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;

public class RemoveProjectDialog {

    @Inject
    private ProjectController projectController;

    @Parameter
    @Property
    private Project projectToRemove;

    @Inject
    private AlertManager alertManager;

    @Inject
    private Messages messages;

    @InjectPage
    private Projects projectsPage;

    @Property
    @Parameter
    private String linkCss;

    @Component
    private Form removeProjectDialogForm;

    public void onValidateFromRemoveProjectDialogForm() {

    }

    public void onFailureFromremoveProjectDialogForm() {
    }

    public void onSuccessFromremoveProjectDialogForm() {

        String projectName = projectToRemove.getName();
        this.projectController.deleteProject(projectToRemove);
        this.projectsPage.setupRender();

        alertManager.alert(Duration.TRANSIENT, Severity.INFO,
                messages.format("successfully-removed", projectName));

    }

    public Object onSubmitFromremoveProjectDialogForm() {
        return this.projectsPage;
    }

    public void onPrepare(long projectId) {
        this.projectToRemove = projectController.readProject(projectId);
    }
}
	
	'''
	
	def infoDialog()
	'''
	package de.mtf.dywa.components.modals;

/**
 * Created by zweihoff on 03.06.15.
 */
public class InfoDialog {
}
	
	'''
	
	def settingsDialog()
	'''
	package de.mtf.dywa.components.modals;

/**
 * Created by zweihoff on 03.06.15.
 */
public class SettingsDialog {
}
	
	'''
	
	def shareGraphDialog()
	'''
	package de.mtf.dywa.components.modals;

/**
 * Created by zweihoff on 03.06.15.
 */
public class ShareGraphDialog {
}
	
	'''
	
	def layout()
	'''
	package de.mtf.dywa.components;

import org.apache.tapestry5.*;
import org.apache.tapestry5.annotations.*;
import org.apache.tapestry5.ioc.annotations.*;
import org.apache.tapestry5.BindingConstants;
import org.apache.tapestry5.SymbolConstants;

/**
 * Layout component for pages of application testapp-presentation.
 */
@Import(
        library = {
            "context:js/jquery-1.11.3.min.js",
            "context:js/themes/bootstrap.min.js"
        }
    )
public class Layout
{
    /**
     * The page title, for the <title> element and the <h1> element.
     */
    @Property
    @Parameter(required = true, defaultPrefix = BindingConstants.LITERAL)
    private String title;

    @Property
    private String pageName;

    @Property
    @Parameter(defaultPrefix = BindingConstants.LITERAL)
    private String sidebarTitle;

    @Property
    @Parameter(defaultPrefix = BindingConstants.LITERAL)
    private Block sidebar;

    @Inject
    private ComponentResources resources;

    @Property
    @Inject
    @Symbol(SymbolConstants.APPLICATION_VERSION)
    private String appVersion;


    public String getClassForPageName()
    {
        return resources.getPageName().equalsIgnoreCase(pageName)
                ? "current_page_item"
                : null;
    }

    public String[] getPageNames()
    {
        return new String[]{"Index", "About", "Contact"};
    }
}
	
	'''
	
	def pyroLayout()
	'''
	package de.mtf.dywa.components;

import org.apache.tapestry5.*;
import org.apache.tapestry5.annotations.*;
import org.apache.tapestry5.ioc.annotations.*;
import org.apache.tapestry5.BindingConstants;
import org.apache.tapestry5.SymbolConstants;

/**
 * Layout component for pages of application testapp-presentation.
 */
@Import(stylesheet = {
        "context:css/joint/joint.css",
        "context:css/pyro/pyro.core.css",
        "context:css/pyro/pyro.nodes.css",
        "context:css/plugins/jquery.contextMenu.css",
        "context:css/themes/bootstrap.min.css",
        "context:css/themes/bootstrap-theme.min.css"

},
        library = {
                "context:js/joint/joint.js",
                "context:js/plugins/base64.js",
                "context:js/plugins/jquery.ui.position.js",
                "context:js/plugins/FileSaver.min.js",
                "context:js/plugins/jquery.contextMenu.js",
                "context:js/plugins/jquery.event.drag-2.2.js",
                "context:js/plugins/jquery.event.drag.live-2.2.js",
                "context:js/plugins/jquery.event.drag-2.2.js",
                "context:js/plugins/jquery.event.drop.live-2.2.js",
                "context:js/plugins/jquery.numeric.min.js",

                "context:js/themes/bootstrap.min.js",
                "context:js/themes/bootswatch.js"
        }
)
public class PyroLayout
{
    /**
     * The page title, for the <title> element and the <h1> element.
     */
    @Property
    @Parameter(required = true, defaultPrefix = BindingConstants.LITERAL)
    private String title;

    @Property
    private String pageName;

    @Property
    @Parameter(defaultPrefix = BindingConstants.LITERAL)
    private String sidebarTitle;

    @Property
    @Parameter(defaultPrefix = BindingConstants.LITERAL)
    private Block sidebar;

    @Inject
    private ComponentResources resources;

    @Property
    @Inject
    @Symbol(SymbolConstants.APPLICATION_VERSION)
    private String appVersion;


    public String getClassForPageName()
    {
        return resources.getPageName().equalsIgnoreCase(pageName)
                ? "current_page_item"
                : null;
    }

    public String[] getPageNames()
    {
        return new String[]{"Index", "About", "Contact"};
    }
}
	
	'''
	
	def about()
	'''
	package de.mtf.dywa.pages;

public class About
{

}
	
	'''
	
	def contact()
	'''
	package de.mtf.dywa.pages;

public class Contact
{

}
	
	'''
	
	def index()
	'''
	package de.mtf.dywa.pages;

import de.mtf.dywa.ExampleController;
import org.apache.tapestry5.ComponentResources;
import org.apache.tapestry5.SymbolConstants;
import org.apache.tapestry5.annotations.Import;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.ioc.annotations.Symbol;
import de.ls5.cinco.deployment.CincoDBController;
import org.apache.tapestry5.services.Request;
import org.apache.tapestry5.util.TextStreamResponse;

/**
 * Start page of application testapp-presentation.
 */
public class Index {

	@Property
	@Inject
	@Symbol(SymbolConstants.TAPESTRY_VERSION)
	private String tapestryVersion;

    @Inject
    private CincoDBController cincoDBController;

    @Inject
    private ComponentResources componentResources;

    @Inject
    private Request request;

    public void onActionFromCreateCincoSchema()
    {
        this.cincoDBController.createGraphModelDBTypes();
    }
    public void onActionFromDeleteCincoSchema()
    {
        this.cincoDBController.removeGraphModelDBTypes();
    }

}
	
	'''
	
	def projects()
	'''
	package de.mtf.dywa.pages;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.beaneditor.BeanModel;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.services.BeanModelSource;

import java.util.ArrayList;
import java.util.List;

public class Projects {

    @Inject
    private ProjectController projectController;

    @Property
    private int index;

    @Inject
    private Messages messages;

    @Property
    private Project iteratedProject;

    @Property
    private List<Project> projects;

    @Property
    private int rowIndex;

    @Inject
    private BeanModelSource beanModelSource;

    public BeanModel<Project> getModel(){
        BeanModel<Project> projectBeanModel = beanModelSource.createDisplayModel(Project.class, messages);
        projectBeanModel.addEmpty("actions");
        projectBeanModel.addEmpty("counter");
        projectBeanModel.include("counter","name","edited","created","actions");
        return projectBeanModel;
    }


    public void setupRender() {

        this.projects = new ArrayList<Project>(this.projectController.fetchProject());
    }

    public String getNewBtnCss() {
        return "btn btn-success";
    }

    public String getRemoveBtnCss() {
        return "btn btn-danger";
    }

    public String getEditBtnCss() {
        return "btn btn-primary";
    }

}
	
	'''
	
	def resMenuProp()
	'''
	newProjectButtonText=New
openProjectButtonText=Open
removeButtonText=Remove
projectExplorerButtonText=Explorer
cancel=Cancel
	'''
	
	def resMenu()
	'''
	<t:container xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
             xmlns:p="tapestry:parameter">
    <div id="menuPanel" class="panel panel-default">
        <div class="panel-body">
            <div class="btn-toolbar" role="toolbar">
                <!-- Model Menu -->
                <div class="btn-group btn-group-sm" role="group" aria-label="rgrrg">
                    <button type="button" class="btn btn-default dropdown-toggle btn-sm" data-toggle="dropdown" aria-expanded="false"><span class="glyphicon glyphicon-file"></span> Project <span class="caret"></span></button>
                    <ul class="dropdown-menu" role="menu">
                        <li>
                            <a
                                data-toggle="modal"
                                href="#newProjectDialog"
                                class="${newBtnCss}"><span class="glyphicon glyphicon-plus"></span> ${message:newProjectButtonText}
                            </a>
                        </li>
                        <li>
                            <a
                                data-toggle="modal"
                                href="#openProjectDialog"
                                class="${openBtnCss}"><span class="glyphicon glyphicon-folder-open"></span> ${message:openProjectButtonText}
                            </a>
                        </li>
                        <li>
                            <a
                                data-toggle="modal"
                                href="#removeProjectDialog${openedProject.id}"
                                class="${removeBtnCss}"><span class="glyphicon glyphicon-trash"></span> ${message:removeButtonText}
                            </a>
                        </li>
                        <li><t:pagelink page="projects"><span class="glyphicon glyphicon-th-list"></span> ${message:projectExplorerButtonText}</t:pagelink></li>
                    </ul>
                </div>
                <!-- Action Menu -->
                <div class="btn-group btn-group-sm" role="group" aria-label="...">
                    <button id="moveMode" type="button" class="btn btn-default active"><span class="glyphicon glyphicon-move"></span> Move</button>
                    <button id="markMode" type="button" class="btn btn-default" disabled="disabled"><span class="glyphicon glyphicon-screenshot"></span> Select</button>
                </div>
                <!-- Edge Menu Menu -->
                <div class="btn-group btn-group-sm" role="group" aria-label="...">
                    <button class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><span class="glyphicon glyphicon-transfer"></span> Edge Mode <span class="caret"></span></button>
                    <ul class="dropdown-menu" role="menu">
                        <li role="presentation" class="dropdown-header">Simple Modes</li>
                        <li id="normal"><a class="edgeType" data-connector="normal">Normal</a></li>
                        <li id="smooth"><a class="edgeType" data-connector="smooth">Smooth</a></li>
                        <li id="rounded"><a class="edgeType" data-connector="rounded">Rounded</a></li>
                        <li role="presentation" class="dropdown-header">Normal Routing Modes</li>
                        <li id="orthogonalnormal"><a class="edgeType" data-router="orthogonal" data-connector="normal">Orthogonal Normal</a></li>
                        <li id="manhattannormal"><a class="edgeType" data-router="manhattan" data-connector="normal">Manhattan Normal</a></li>
                        <li id="metronormal"><a class="edgeType" data-router="metro" data-connector="normal">Metro Normal</a></li>
                        <li role="presentation" class="dropdown-header">Rounded Routing Modes</li>
                        <li id="orthogonalrounded"><a class="edgeType" data-router="orthogonal" data-connector="rounded">Orthogonal Rounded</a></li>
                        <li id="manhattanrounded"><a class="edgeType" data-router="manhattan" data-connector="rounded">Manhattan Rounded</a></li>
                        <li id="metronormalrounded"><a class="edgeType" data-router="metro" data-connector="rounded">Metro Rounded</a></li>
                    </ul>
                </div>
                <!-- Undo redo Menu -->
                <div class="btn-group btn-group-sm" role="group" aria-label="...">
                    <button id="undoAction" type="button" class="btn btn-default" disabled="disabled"><span class="glyphicon glyphicon-share-alt"></span> Undo</button>
                    <button id="redoAction" type="button" class="btn btn-default" disabled="disabled"><span class="glyphicon glyphicon-share-alt"></span> Redo</button>
                </div>
                <!-- Zoom Menu -->
                <div class="btn-group btn-group-sm" role="group" aria-label="...">
                    <button id="zoomInAction" type="button" class="btn btn-default"><span class="glyphicon glyphicon-zoom-in"></span> Zoom In</button>
                    <button id="zoomOutAction" type="button" class="btn btn-default"><span class="glyphicon glyphicon-zoom-out"></span> Zoom Out</button>
                </div>
                <!-- Export Menu -->
                <div class="btn-group btn-group-sm" role="group" aria-label="...">
                    <button id="saveAsSVGAction" type="button" class="btn btn-default"><span class="glyphicon glyphicon-picture"></span> Save as SVG</button>
                </div>
                <!-- Settings -->
                <div class="btn-group btn-group-sm" role="group" aria-label="...">
                    <button id="settingsAction" type="button" class="btn btn-default" data-toggle="modal" data-target="#settingsModal"><span class="glyphicon glyphicon-cog"></span> Settings</button>
                    <button id="infoMenu" type="button" class="btn btn-default" data-toggle="modal" data-target="#infoModal"><span class="glyphicon glyphicon-info-sign"></span></button>
                </div>
                <!-- Minimize Menu -->
                <div class="btn-group btn-group-xs" role="group" aria-label="...">
                    <button id="minimizeMenu" type="button" class="btn btn-default btn-xs scaling-btn"><span class="glyphicon glyphicon-minus"></span></button>
                </div>
            </div>
        </div>
        <ol class="breadcrumb">
            <li><strong>Philip</strong></li>
            <t:if test="projectLoaded">
                <li class="dropdown">
                    <button class="btn btn-link dropdown-toggle" type="button" id="dropdownMenuProject" data-toggle="dropdown" aria-expanded="true">
                        ${openedProject.name}
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenuProject">
                        <t:loop source="projectList" value="iteratedProject">
                            <li role="presentation"><t:pagelink t:context="[iteratedProject.id]" page="pyro" tabindex="-1" role="menuitem">${iteratedProject.name}</t:pagelink></li>
                        </t:loop>
                    </ul>
                </li>
            </t:if>
            <t:if test="graphContained">
                <li class="dropdown">
                    <button class="btn btn-link dropdown-toggle" type="button" id="dropdownMenuGraph" data-toggle="dropdown" aria-expanded="true">
                        ${openedGraphModel.name}
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenuGraph">
                        <t:loop source="openedProject.getgraphModels_GraphModel()" value="iteratedGraphModel">
                            <li role="presentation"><t:pagelink t:context="[openedProject.id,iteratedGraphModel.id]" page="pyro" tabindex="-1" role="menuitem">${iteratedGraphModel.name}</t:pagelink></li>
                        </t:loop>
                    </ul>
                </li>
            </t:if>

        </ol>
    </div>
    <t:modals.project.newProjectDialog t:isExplorerPage="false" t:linkCss="${newBtnCss}"/>
    <t:modals.project.openProjectDialog t:linkCss="${openBtnCss}" />
    <t:modals.project.removeProjectDialog t:linkCss="${removeBtnCss}" t:projectToRemove="openedProject"/>
</t:container>'''

def resNewGraph()
'''
<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">
    <a
            data-toggle="modal"
            href="#newGraphDialog"
            class="${linkCss}"><span class="glyphicon glyphicon-plus"></span> ${message:buttonText}</a>

    <div
            class="modal fade"
            id="newGraphDialog"
            tabindex="-1"
            role="dialog"
            aria-labelledby="newGraphDialogLabel"
            aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <t:form
                        t:id="newGraphDialogForm"
                        t:context="project.id"
                        class="form-horizontal">
                    <div class="modal-header">
                        <button
                                type="button"
                                class="close"
                                data-dismiss="modal"
                                aria-hidden="true">×
                        </button>
                        <h4 class="modal-title"><span class="glyphicon glyphicon-plus"></span> ${message:modalTitle}</h4>
                    </div>
                    <div class="modal-body">

                        <div class="form-group">
                            <t:label
                                    t:for="newGraphDialogName"
                                    class="col-sm-3 control-label">${message:NameLabel}
                            </t:label>
                            <div class="col-sm-9">
                                <t:textfield
                                        t:id="newGraphDialogName"
                                        t:value="newGraphDialogName"
                                        class="form-control" />
                            </div>
                        </div>
                        <div class="form-group">
                            <t:label
                                    t:for="newGraphDialogGraph"
                                    class="col-sm-3 control-label">${message:GraphLabel}
                            </t:label>
                            <div class="col-sm-9">
                                <t:select
                                        t:id="newGraphDialogGraph"
                                        t:value="selectedGraphModel"
                                        t:encoder="typeEncoder"
                                        t:model="selectModel"
                                        t:blankOption="NEVER"
                                        class="form-control"/>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button
                                type="button"
                                class="btn btn-default"
                                data-dismiss="modal">${message:cancel}</button>
                        <t:submit
                                value="${message:create}"
                                class="btn btn-success" />
                    </div>
                </t:form>
            </div>
        </div>
    </div>
</t:container>

'''

def resRemoveGraphProp()
'''
modalTitle=Remove Graph %s
modalMessage=Are you sure you want to remove the Graph %s?
cancel=Cancel
remove=Remove
successfully-removed= %s successfully removed
'''

def resRemoveGraph()
'''
<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">

    <a
            data-toggle="modal"
            href="#removeGraphDialog${graphToRemove.id}"
            class="btn btn-sm btn-danger"><span class="glyphicon glyphicon-trash"></span></a>
    <div
            class="modal fade"
            id="removeGraphDialog${graphToRemove.id}"
            tabindex="-1"
            role="dialog"
            aria-labelledby="removeGraphDialogLabel"
            aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <t:form
                        t:context="[project.id,graphToRemove.id]"
                        t:id="removeGraphDialogForm"
                        class="form-horizontal">
                    <div class="modal-header">
                        <button
                                type="button"
                                class="close"
                                data-dismiss="modal"
                                aria-hidden="true">×
                        </button>
                        <h4 class="modal-title"><span class="glyphicon glyphicon-remove"></span> ${modalTitle}</h4>
                    </div>
                    <div class="modal-body">
                        ${modalMessage}
                    </div>
                    <div class="modal-footer">
                        <button
                                type="button"
                                class="btn btn-default"
                                data-dismiss="modal">${message:cancel}</button>
                        <t:submit
                                value="${message:remove}"
                                class="btn btn-danger" />
                    </div>
                </t:form>
            </div>
        </div>
    </div>
</t:container>

'''

def resShareGraph()
'''
<t:container xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
             xmlns:p="tapestry:parameter">
    <div class="modal fade" id="shareFileModal" tabindex="-1" role="dialog" aria-labelledby="newFileModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="shareFileModalTitle"><span class="glyphicon glyphicon-share"></span> Share Project</h4>
                </div>
                <div class="modal-body">
                    <div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
                        <div class="panel panel-primary">
                            <div class="panel-heading" role="tab" id="collapseShareHead0">
                                <h4 class="panel-title">
                                    <a data-toggle="collapse" data-parent="#accordion" href="#collapseShare0" aria-expanded="true" aria-controls="collapseShare0">
                                        MyFirstProject
                                    </a>
                                </h4>
                            </div>
                            <div id="collapseShare0" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="collapseShare0">
                                <div class="panel-body">
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user1" data-share-type="global" type="checkbox" value=""/>
                                            User 1
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user2" data-share-type="global" type="checkbox" value=""/>
                                            User 2
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user3" data-share-type="global" type="checkbox" value=""/>
                                            User 3
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel panel-default">
                            <div class="panel-heading" role="tab" id="collapseShareHead1">
                                <h4 class="panel-title">
                                    <a data-toggle="collapse" data-parent="#accordion" href="#collapseShare1" aria-expanded="true" aria-controls="collapseShare1">
                                        FlowGraph
                                    </a>
                                </h4>
                            </div>
                            <div id="collapseShare1" class="panel-collapse collapse" role="tabpanel" aria-labelledby="collapseShare1">
                                <div class="panel-body">
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user1" data-share-type="local" type="checkbox" value=""/>
                                            User 1
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user2" data-share-type="local" type="checkbox" value=""/>
                                            User 2
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user3" data-share-type="local" type="checkbox" value=""/>
                                            User 3
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel panel-default">
                            <div class="panel-heading" role="tab" id="collapseShareHead2">
                                <h4 class="panel-title">
                                    <a class="collapsed" data-toggle="collapse" data-parent="#accordion" href="#collapseShare2" aria-expanded="false" aria-controls="collapseShare2">
                                        OtherGraph
                                    </a>
                                </h4>
                            </div>
                            <div id="collapseShare2" class="panel-collapse collapse" role="tabpanel" aria-labelledby="collapseShare2">
                                <div class="panel-body">
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user1" data-share-type="local" type="checkbox" value=""/>
                                            User 1
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user2" data-share-type="local" type="checkbox" value=""/>
                                            User 2
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user3" data-share-type="local" type="checkbox" value=""/>
                                            User 3
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel panel-default">
                            <div class="panel-heading" role="tab" id="collapseShareHead3">
                                <h4 class="panel-title">
                                    <a class="collapsed" data-toggle="collapse" data-parent="#accordion" href="#collapseShare3" aria-expanded="false" aria-controls="collapseShare3">
                                        SharedGraph
                                    </a>
                                </h4>
                            </div>
                            <div id="collapseShare3" class="panel-collapse collapse" role="tabpanel" aria-labelledby="collapseShare3">
                                <div class="panel-body">
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user1" data-share-type="local" type="checkbox" value=""/>
                                            User 1
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user2" data-share-type="local" type="checkbox" value=""/>
                                            User 2
                                        </label>
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input class="share-input" data-share-user="user3" data-share-type="local" type="checkbox" value=""/>
                                            User 3
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary" data-dismiss="modal"><span class="glyphicon glyphicon-share"></span> Share</button>
                </div>
            </div>
        </div>
    </div>
</t:container>
'''

def resEditProjectProp()
'''
buttonText=Edit
modalTitle=Edit a project
nameLabel=Name

newTypeDialogName-regexp=^[a-zA-Z0-9_ ]+$
newTypeDialogName-regexp-message=The name does not fit the naming conventions.


name-in-use=The name is already in use.
successfully-edited=Project '%s' successfully edited.
invalid-name=You provided an invalid name.

cancel=Cancel
create=Save
'''

def resEditProject()
'''
<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">
    <div
            class="modal fade"
            id="editProjectDialog${projectToEdit.id}"
            tabindex="-1"
            role="dialog"
            aria-labelledby="editProjectDialogLabel"
            aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <t:form
                        t:context="projectToEdit.id"
                        t:id="editProjectDialogForm"
                        class="form-horizontal">
                    <div class="modal-header">
                        <button
                                type="button"
                                class="close"
                                data-dismiss="modal"
                                aria-hidden="true">×
                        </button>
                        <h4 class="modal-title"><span class="glyphicon glyphicon-pencil"></span> ${message:modalTitle}</h4>
                    </div>
                    <div class="modal-body">

                        <div class="form-group">
                            <label
                                    for="editProjectDialogName"
                                    class="col-sm-3 control-label">${message:NameLabel}</label>
                            <div class="col-sm-9">
                                <t:textfield
                                        t:id="editProjectDialogName"
                                        t:value="editProjectDialogName"
                                        class="form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button
                                type="button"
                                class="btn btn-default"
                                data-dismiss="modal">${message:cancel}</button>
                        <t:submit
                                value="${message:create}"
                                class="btn btn-success" />
                    </div>
                </t:form>
            </div>
        </div>
    </div>
</t:container>

'''

def resNewProjectProp()
'''
buttonText=Create a new project
modalTitle=Create a new project
nameLabel=Name

newTypeDialogName-regexp=^[a-zA-Z0-9_ ]+$
newTypeDialogName-regexp-message=The name does not fit the naming conventions.


name-in-use=The name is already in use.
successfully-created=Project '%s' successfully created.
invalid-name=You provided an invalid name.

cancel=Cancel
create=Create
'''

def resNewProject()
'''
<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">
    <div
            class="modal fade"
            id="newProjectDialog"
            tabindex="-1"
            role="dialog"
            aria-labelledby="newProjectDialogLabel"
            aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <t:form
                        t:id="newProjectDialogForm"
                        class="form-horizontal">
                    <div class="modal-header">
                        <button
                                type="button"
                                class="close"
                                data-dismiss="modal"
                                aria-hidden="true">×
                        </button>
                        <h4 class="modal-title"><span class="glyphicon glyphicon-plus"></span> ${message:modalTitle}</h4>
                    </div>
                    <div class="modal-body">

                        <div class="form-group">
                            <label
                                    for="newProjectDialogName"
                                    class="col-sm-3 control-label">${message:NameLabel}</label>
                            <div class="col-sm-9">
                                <t:textfield
                                        t:id="newProjectDialogName"
                                        t:value="newProjectDialogName"
                                        class="form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button
                                type="button"
                                class="btn btn-default"
                                data-dismiss="modal">${message:cancel}</button>
                        <t:submit
                                value="${message:create}"
                                class="btn btn-success" />
                    </div>
                </t:form>
            </div>
        </div>
    </div>
</t:container>

'''

def resOpenProjectProp()
'''
buttonText=Open
colNumber=#
colName=Projectname
colActions=Action
openButtonText=Open Project
modalTitle=Open a Project

'''

def resOpenProject()
'''
<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">
    <div
            class="modal fade"
            id="openProjectDialog"
            tabindex="-1"
            role="dialog"
            aria-labelledby="openProjectDialogLabel"
            aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button
                            type="button"
                            class="close"
                            data-dismiss="modal"
                            aria-hidden="true">×
                    </button>
                    <h4 class="modal-title"><span class="glyphicon glyphicon-folder-open"></span> ${message:modalTitle}</h4>
                </div>
                <div class="modal-body">
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th>${message:colNumber}</th>
                            <th>${message:colName}</th>
                            <th>${message:colActions}</th>
                        </tr>
                        </thead>
                        <tbody>
                        <t:if test="projects.empty">
                            <p:else>
                                <t:loop
                                        t:source="projects"
                                        t:value="iteratedProject"
                                        t:index="index">
                                    <tr>
                                        <td>${index}</td>
                                        <td>${iteratedProject.name}</td>
                                        <td>
                                            <div class="btn-group" role="group" aria-label="...">
                                                <t:pagelink t:context="[iteratedProject.id,0]" page="pyro" class="btn btn-primary">${message:openButtonText}</t:pagelink>
                                            </div>
                                        </td>
                                    </tr>
                                </t:loop>
                            </p:else>
                        </t:if>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button
                            type="button"
                            class="btn btn-default"
                            data-dismiss="modal">${message:cancel}</button>
                </div>
            </div>
        </div>
    </div>
</t:container>

'''

def removeProjectProp()
'''
buttonText=Remove
modalTitle=Remove a project

successfully-removed=Project '%s' successfully removed.

cancel=Cancel
remove=Remove
'''


def removeProject()
'''
<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">
    <div
            class="modal fade"
            id="removeProjectDialog${projectToRemove.id}"
            tabindex="-1"
            role="dialog"
            aria-labelledby="removeProjectDialogLabel"
            aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <t:form
                        t:context="projectToRemove.id"
                        t:id="removeProjectDialogForm"
                        class="form-horizontal">
                    <div class="modal-header">
                        <button
                                type="button"
                                class="close"
                                data-dismiss="modal"
                                aria-hidden="true">×
                        </button>
                        <h4 class="modal-title"><span class="glyphicon glyphicon-remove"></span> ${message:modalTitle}</h4>
                    </div>
                    <div class="modal-body">
                        Are you sure you want to remove the project?
                    </div>
                    <div class="modal-footer">
                        <button
                                type="button"
                                class="btn btn-default"
                                data-dismiss="modal">${message:cancel}</button>
                        <t:submit
                                value="${message:remove}"
                                class="btn btn-danger" />
                    </div>
                </t:form>
            </div>
        </div>
    </div>
</t:container>

'''

def resInfoDialog()
'''
<t:container xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
             xmlns:p="tapestry:parameter">
    <div class="modal fade" id="infoModal" tabindex="-1" role="dialog" aria-labelledby="infoModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="infoModalTitle"><span class="glyphicon glyphicon-info-sign"></span> Info</h4>
                </div>
                <div class="modal-body">
                    Have you tried F5?
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</t:container>
'''

def resSettingsDialog()
'''
<t:container xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
             xmlns:p="tapestry:parameter">
    <div class="modal fade" id="settingsModal" tabindex="-1" role="dialog" aria-labelledby="settingsModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="settingsModalLabel">Editor Settings</h4>
                </div>
                <div class="modal-body">
                    <div id="settingsSaveMessage" class="alert alert-success" role="alert">Changes successfully saved</div>
                    <form class="form-horizontal">
                        <div class="form-group">
                            <label for="scaleFactor" class="col-sm-6 control-label">Scale Factor</label>
                            <div class="col-sm-6">
                                <input type="text" class="form-control positive decimal-2-places" id="scaleFactor" placeholder="1.00" value="1.00"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edgeTriggerWidth" class="col-sm-6 control-label">Edge creation border width</label>
                            <div class="col-sm-6">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="edgeTriggerWidth" placeholder="10" value="10"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="snapRadius" class="col-sm-6 control-label">Edge snapping circle radius</label>
                            <div class="col-sm-6">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="snapRadius" placeholder="80" value="80"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="gridSize" class="col-sm-6 control-label">Grid size</label>
                            <div class="col-sm-6">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="gridSize" placeholder="1" value="1"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="paperWidth" class="col-sm-3 control-label">Paper width</label>
                            <div class="col-sm-3">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="paperWidth" placeholder="1000" value="1000"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                            <label for="paperHeight" class="col-sm-3 control-label">Paper height</label>
                            <div class="col-sm-3">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="paperHeight" placeholder="1000" value="1000"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="resizeStep" class="col-sm-3 control-label">Resize stepping</label>
                            <div class="col-sm-3">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="resizeStep" placeholder="10" value="10"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                            <label for="rotateStep" class="col-sm-3 control-label">Rotate stepping</label>
                            <div class="col-sm-3">
                                <div class="input-group">
                                    <input type="text" class="form-control positive numeric" id="rotateStep" placeholder="5" value="5"/>
                                    <div class="input-group-addon">px</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="editorTheme" class="col-sm-6 control-label">Editor Theme</label>
                            <div class="col-sm-6">
                                <div class="input-group">
                                    <select id="editorTheme" class="form-control">
                                        <option value="slate">Slate</option>
                                        <option value="simplex">Simplex</option>
                                        <option value="dark">Dark</option>
                                        <option value="flatly">Flatly</option>
                                        <option value="default">Default</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button id="settingsSave" type="button" class="btn btn-primary">Save changes</button>
                </div>
            </div>
        </div>
    </div>
</t:container>
'''

def resLayoutProp()
'''
cancel=Cancel
create=Create
createdBy=Philip Zweihoff
pyro=Pyro
signin=Signed in as
'''

def resLayout()
'''
<!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
      xmlns:p="tapestry:parameter">
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
        <link rel="stylesheet" type="text/css" href="${context:css/themes/default/bootstrap.default.css}" id="theme"/>
        <link rel="stylesheet" type="text/css" href="${context:css/themes/bootstrap.min.css}" id="helperTheme"/>
        <link rel="stylesheet" type="text/css" href="${context:css/themes/bootstrap-theme.min.css}"/>
        <title>${title}</title>
    </head>
    <body>
        <nav class="navbar navbar-default navbar-static-top">
            <div class="container-fluid">
                <div class="navbar-header">
                <a class="navbar-brand" href="#">
			        <img alt="pyro" src="${context:img/pyro.png}" width="20" />
			      </a>
                    <p class="navbar-text">${message:pyro}</p>
                </div>
                <div class="collapse navbar-collapse">
                    <ul class="nav navbar-nav navbar-right">
                        <li>${message:signin} User</li>
                    </ul>
                </div>
            </div>
        </nav>
        <div class="container">
            <t:body/>
        </div>
        <footer class="footer">
            <div class="container" style="position: absolute; width: 100%; bottom: 0; background-color:#EEEEEE ">
                <p class="text-muted">
                    ${message:pyro} by ${message:createdBy}
                </p>
            </div>
        </footer>
    </body>
</html>

'''
def resPyroLayout()
'''
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
      xmlns:p="tapestry:parameter">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" href="${context:css/themes/default/bootstrap.default.css}" id="theme" />
    <link rel="stylesheet" href="${context:css/themes/bootswatch.min.css}" id="helperTheme" />
    <title>${title}</title>
</head>
    <body>
        <div class="pyro-container">
            <t:body/>
        </div>
    </body>
</html>

'''

def resIndexProp()
'''
greeting=Welcome to Tapestry 5!  We hope that this project template will get you going in style.

'''

def resIndex()
'''
<html t:type="layout" title="Index testapp-presentation"
      xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
      xmlns:p="tapestry:parameter">
<div class="row">
    <div class="jumbotron">
        <div class="row">
            <div class="col-sm-4">
                <img src="${context:img/pyro.png}" />
            </div>
            <div class="col-sm-6">
                <h1>Pyro</h1>
                <p class="lead">Modeling environment</p>
                <p><t:pagelink page="projects" class="btn btn-lg btn-success">Project Explorer</t:pagelink></p>
                <div class="row">
                    <div class="col-md-6">
                        <t:actionlink t:id="createCincoSchema" class="btn btn-success">Create Cinco Schema</t:actionlink>
                    </div>
                    <div class="col-md-6">
                        <t:actionlink t:id="deleteCincoSchema" class="btn btn-warning">Delete Cinco Schema</t:actionlink>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


</html>
'''

def resProjectsProp()
'''
title=Projects
availableProjects=Available Projects
markedForDeletion=Marked for deletion
usedAs=Used as
usedIn=Used in
description=Description

filter=Filter
inUse=In Use
as=As

counter-label=#
name-label=Project Name
edited-label=Last edited
created-label=Created
actions-label=Actions
panelTitle=Project Explorer

editProjectButtonText=Edit
removeButtonText=Remove
newProjectButtonText=Create a new Project
'''

def resProjects()
'''
<t:layout
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter"
        t:title="${message:title}"
        t:menuCategory="menuCategory">

    <t:alerts fwtype="alert"/>

    <div class="row">
        <div class="panel panel-default">
            <div class="panel-heading">
                <div class="row">
                    <div class="col-md-10">
                        <h4>${message:panelTitle}</h4>
                    </div>
                    <div class="col-md-2">
                        <div class="btn-toolbar" role="toolbar" aria-label="...">
                            <a
                                    data-toggle="modal"
                                    href="#newProjectDialog"
                                    class="${newBtnCss}"><span class="glyphicon glyphicon-plus"></span> ${message:newProjectButtonText}
                            </a>
                            <t:modals.project.newProjectDialog t:isExplorerPage="true" t:linkCss="${newBtnCss}"/>
                        </div>
                    </div>
                </div>
            </div>
            <div class="panel-body">
                <t:grid source="projects" rowIndex="rowIndex" row="iteratedProject" class="table table-striped" model="model">
                    <p:counterCell>
                        ${rowIndex}
                    </p:counterCell>
                    <p:nameCell>
                        <t:pagelink page="pyro" t:context="[iteratedProject.id]">${iteratedProject.name}</t:pagelink>
                    </p:nameCell>
                    <p:actionsCell>
                        <div class="btn-group" role="group" aria-label="...">
                            <t:pagelink t:context="[iteratedProject.id]" page="pyro" class="btn btn-default">Open</t:pagelink>

                            <a
                                    data-toggle="modal"
                                    href="#editProjectDialog${iteratedProject.id}"
                                    class="${getEditBtnCss()}"><span class="glyphicon glyphicon-folder-open"></span> ${message:editProjectButtonText}
                            </a>
                            <t:modals.project.editProjectDialog t:linkCss="${getEditBtnCss()}" t:projectToEdit="iteratedProject"/>
                            <a
                                    data-toggle="modal"
                                    href="#removeProjectDialog${iteratedProject.id}"
                                    class="${getRemoveBtnCss()}"><span class="glyphicon glyphicon-remove"></span> ${message:removeButtonText}
                            </a>
                            <t:modals.project.removeprojectdialog t:linkCss="${getEditBtnCss()}" t:projectToRemove="iteratedProject"/>
                        </div>
                    </p:actionsCell>
                </t:grid>
            </div>
        </div>
    </div>
</t:layout>
'''

def resPyroProp()
'''

'''

def resPyro()
'''
<html t:type="pyroLayout" title="testapp-presentation Index"
      t:sidebarTitle="Framework Version"
      xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
      xmlns:p="tapestry:parameter">
      <t:alerts fwtype="alert"/>
      <!-- Context Menu elements -->
      <div id="imagecontainer"></div>
      <div id="edgeContextMenu"></div>
      <div id="elementChange"></div>
      <!-- Menu View -->
      <div class="row">
            <div class="col-lg-12">
                  <t:menubar.Menu t:openedProject="openedProject" t:openedGraphModel="openedGraphModel"/>
            </div>
      </div>
      <div class="row">
            <t:if test="openedGraphModel">
            <div id="miniMenu" class="col-sm-2">
                  <button id="maximizeMenu" type="button" class="btn btn-default btn-sm">
                        <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span> Menu
                  </button>
            </div>
            </t:if>
            <div class="col-sm-2">
                  <div class="btn-group" role="group">
                  <t:modals.graph.newgraphdialog t:linkCss="graphCreateCss" t:project="openedProject"/>
                  <t:unless test="projectEmpty">
                        <t:modals.graph.removegraphdialog t:project="openedProject" t:graphToRemove="openedGraphModel"/>
                  </t:unless>
                  </div>
            </div>
            <div id="graphTabs" class="col-sm-10">
                  <ul class="nav nav-tabs">
                        <t:unless test="projectEmpty">
                              <t:loop source="graphs" t:value="iteratedGraph">
                                    <li role="presentation" class="${activeGraphLiCss}">
                                          <t:pagelink t:context="[openedProject.id,iteratedGraph.id]" class="${activeGraphACss}" page="pyro">
                                                ${iteratedGraph.name}
                                          </t:pagelink>

                                    </li>
                              </t:loop>
                        </t:unless>
                  </ul>
            </div>
      </div>
      <t:if test="openedGraphModel">
          <t:canvas.modelingcanvas t:openProject="openedProject" t:openGraph="openedGraphModel"/>
      </t:if>
</html>

'''
}