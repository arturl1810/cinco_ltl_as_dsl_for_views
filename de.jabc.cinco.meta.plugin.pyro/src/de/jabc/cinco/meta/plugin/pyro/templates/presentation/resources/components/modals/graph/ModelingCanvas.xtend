package de.jabc.cinco.meta.plugin.pyro.templates.presentation.resources.components.modals.graph

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage

class ModelingCanvas implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
	<t:container
        xmlns:t="http://tapestry.apache.org/schema/tapestry_5_3.xsd"
        xmlns:p="tapestry:parameter">
    <!-- Center -->
    <div class="row">
        <!-- Palette View -->
        <div id="palette" class="col-md-3"></div>
        <div id="graphModel" class="col-md-9">
            <!-- NewGraphDialog Model View -->
            <div class="panel panel-default">
                <div class="panel-heading">
                    <strong><span class="glyphicon glyphicon-pencil"></span> ${message:graphView}</strong>
                    <button id="maximizeGraph" type="button" class="btn btn-default btn-xs scaling-btn"><span class="glyphicon glyphicon-fullscreen"></span></button>
                    <button id="minimizeGraph" type="button" class="btn btn-default btn-xs scaling-btn"><span class="glyphicon glyphicon-minus"></span></button>
                </div>
                <div id="muiCanvas" class="panel-body">
                    <div id="paper" class="paper mui-border scroll-auto"></div><br />
                </div>
            </div>
        </div>
    </div>
    <!-- South -->
    <div class="row">
        <div id="graphMapCol" class="col-md-3">
            <!--Map View-->
            <div id="graphMapPanel" class="panel panel-primary">
                <div class="panel-heading">
                    <strong><span class="glyphicon glyphicon-picture"></span> ${message:map}</strong>
                    <button id="minimizeMap" type="button" class="btn btn-default btn-xs scaling-btn"><span class="glyphicon glyphicon-minus"></span></button>
                </div>
                <div class="panel-body">
                    <div id="myholder-small" class="paper mui-border"></div>
                </div>
            </div>
        </div>
        <div id="propertiesCol" class="col-md-9">
            <!--Properties View-->
            <div id="properties" class="panel panel-primary">
                <div class="panel-heading">
                    <strong><span class="glyphicon glyphicon-info-sign"></span> ${message:propertiesView} </strong> <span id="model-name" class="badge"></span>
                    <button id="minimizeProperties" type="button" class="btn btn-default btn-xs scaling-btn"><span class="glyphicon glyphicon-minus"></span></button>
                    <button id="maximizeProperties" type="button" class="btn btn-default btn-xs scaling-btn"><span class="glyphicon glyphicon-fullscreen"></span></button>
                </div>
                <div class="panel-body properties-panel">
                    <form class="form-horizontal properties-form">
                        <div id="paper-link-out"></div>
                    </form>
                    <button id="removeModelElement" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-remove"></span> ${message:buttonRemove}</button>
                    <div id="resizeProperties" class="btn-group" role="group" aria-label="...">
                        <button id="resizePlusModelElement" class="btn btn-default btn-sm"><span class="glyphicon glyphicon-plus"></span> ${message:buttonResize}</button>
                        <button id="resizeMinusModelElement" class="btn btn-default btn-sm"><span class="glyphicon glyphicon-minus"></span> ${message:buttonResize}</button>
                    </div>
                    <div id="rotateProperties" class="btn-group" role="group" aria-label="...">
                        <button id="rotatePlusModelElement" class="btn btn-default btn-sm"><span class="glyphicon glyphicon-plus"></span> ${message:buttonRotate}</button>
                        <button id="rotateMinusModelElement" class="btn btn-default btn-sm"><span class="glyphicon glyphicon-minus"></span> ${message:buttonRotate}</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <t:modals.infodialog/>
    <t:modals.settingsdialog/>
    <script type="text/javascript">
        function getCreateElementURL() {
            return "${createElement}";
        }
        function getEditElementURL() {
            return "${editElement}";
        }
        function getRemoveElementURL() {
            return "${removeElement}";
        }
        function getChangeSettingsURL() {
            return "${changeSettings}";
        }
        function getCustomFeatureURL() {
            return "${customFeature}";
        }
        function getAssetRootPath() {
            return "${context:css}";
        }
        function getPrimeReferences() {
            return  ${primeReferences};

        }
    </script>

    <script src="${context:js/pyro/pyro.core.js}"></script>
    <script type="text/javascript">
        /**
         *
         * @returns {{edge: Array, node: string[], container: Array, graphmodel: Array}}
         */
        function getCustomeActions()
        {
            return{
                ${customActions}
            };
        }
    </script>
    <script src="${context:js/pyro}/${graphModelTypeName}/pyro.constraints.js"></script>
    <script src="${context:js/pyro}/${graphModelTypeName}/pyro.model.js"></script>
    <script src="${context:js/pyro/pyro.events.js}"></script>
    <script src="${context:js/pyro}/${graphModelTypeName}/pyro.communicator.js"></script>
    <script type="text/javascript">
        theme = '${openGraph.theme}';
        projectId  = ${openProject.id};
        graphModelId = ${openGraph.id};
        scaleFactor = ${openGraph.scaleFactor};
        edgeTriggerWidth = ${openGraph.edgeTriggerWidth};
        edgeStyleMode = {connector: '${openGraph.edgeStyleModeConnector}',router: '${edgeStyleModeRouter}'};
        snapRadius = ${openGraph.snapRadius};
        paperWidth = ${openGraph.paperWidth};
        paperHeight = ${openGraph.paperHeight};
        gridSize = ${openGraph.gridSize};
        resizeStep = ${openGraph.resizeStep};
        rotateStep = ${openGraph.rotateStep};
        graphName = '${openGraph.name}';
        projectName = '${openProject.name}';
        <t:if test="isGraphMinimized">
        $( "#minimizeGraph" ).trigger( "click" );
        <p:else>
        $( "#maximizeGraph" ).trigger( "click" );
        </p:else>
        </t:if>
        <t:if test="isMapMinimized">
                $( "#maximizeProperties" ).trigger( "click" );
        <p:else>
        $( "#minimizeProperties" ).trigger( "click" );
        </p:else>
        </t:if>
        <t:if test="isMenuMinimized">
                $( "#minimizeMenu" ).trigger( "click" );
        <p:else>
        $( "#maximizeMenu" ).trigger( "click" );
        </p:else>
        </t:if>
        ${initialJSModel}
    </script>
    <script src="${context:js/pyro/pyro.init.js}"></script>
</t:container>


	'''
	
}