package info.scce.pyro.core;

import de.ls5.dywa.generated.controller.info.scce.pyro.core.*;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.*;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.GraphModel;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroFolder;
import info.scce.pyro.core.command.types.ProjectMessage;
import info.scce.pyro.core.rest.types.*;
import info.scce.pyro.core.rest.types.PyroProject;

import javax.ws.rs.core.Response;
import java.util.Collections;
import java.util.LinkedList;
import java.util.stream.Collectors;

@javax.transaction.Transactional
@javax.ws.rs.Path("/graph")
public class GraphModelController {

    @javax.inject.Inject
    private IdentifiableElementController identifiableElementController;

    @javax.inject.Inject
    private de.ls5.dywa.generated.controller.info.scce.pyro.core.GraphModelController graphModelController;

	@javax.inject.Inject
	private PyroUserController subjectController;

    @javax.inject.Inject
    private PyroFolderController folderController;

	@javax.inject.Inject
	private PyroProjectController projectController;

	@javax.inject.Inject
	private info.scce.pyro.rest.ObjectCache objectCache;


	@javax.ws.rs.POST
	@javax.ws.rs.Path("create/folder/private")
	@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@org.jboss.resteasy.annotations.GZIP
	public Response createFolder(CreatePyroFolder newFolder) {

		//find parent
        final PyroFolder pf = folderController.read(newFolder.getparentId());
        if(pf==null){
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        final PyroFolder newPF = folderController.create("PyroFolder_"+newFolder.getname());
        newPF.setname(newFolder.getname());
        pf.getinnerFolders_PyroFolder().add(newPF);

		return Response.ok(info.scce.pyro.core.rest.types.PyroFolder.fromDywaEntity(newPF,objectCache)).build();


	}

    @javax.ws.rs.POST
    @javax.ws.rs.Path("update/folder/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public Response updateFolder(UpdatePyroFolder folder) {

        //find folder
        final PyroFolder pf = folderController.read(folder.getdywaId());
        if(pf==null){
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        pf.setname(folder.getname());
        return Response.ok(info.scce.pyro.core.rest.types.PyroFolder.fromDywaEntity(pf,objectCache)).build();
    }

    @javax.ws.rs.POST
    @javax.ws.rs.Path("update/graphmodel/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public Response updateGraphModel(info.scce.pyro.core.graphmodel.GraphModel graphModel) {

        //find folder
        final GraphModel gm = graphModelController.read(graphModel.getDywaId());
        if(gm==null){
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        gm.setfilename(graphModel.getfilename());
        gm.setscale(graphModel.getscale());
        gm.setheight(graphModel.getheight());
        gm.setwidth(graphModel.getwidth());
        gm.setconnector(graphModel.getconnector());
        gm.setrouter(graphModel.getrouter());
        return Response.ok(info.scce.pyro.core.rest.types.GraphModel.fromDywaEntity(gm,objectCache)).build();
    }

    @javax.ws.rs.GET
    @javax.ws.rs.Path("remove/folder/{id}/{parentId}/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public Response removeFolder(@javax.ws.rs.PathParam("id") final long id,@javax.ws.rs.PathParam("parentId") final long parentId) {

        //find parent
        final PyroFolder pf = folderController.read(id);
        final PyroFolder parent = folderController.read(parentId);
        if(pf==null||parent==null){
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        //cascade remove
        if(parent.getinnerFolders_PyroFolder().contains(pf)){
            removeFolder(pf,parent);
            return Response.ok("OK").build();
        }
        return Response.status(Response.Status.BAD_REQUEST).build();
    }


    void removeFolder(PyroFolder folder,PyroFolder parent) {

            java.util.List<PyroFolder> innerFolder = new LinkedList<>(folder.getinnerFolders_PyroFolder());
            innerFolder.forEach(n->removeFolder(n,folder));

            java.util.List<GraphModel> graphmodels = new LinkedList<>(folder.getgraphModels_GraphModel());
            folder.getgraphModels_GraphModel().clear();
            graphmodels.forEach(this::removeContainer);
            if(parent!=null){
                parent.getinnerFolders_PyroFolder().remove(folder);
            }
            folderController.delete(folder);
    }

    private void removeContainer(ModelElementContainer container) {
        container.getmodelElements_ModelElement().forEach((n)->{
            if(n instanceof Container){
                removeContainer((Container) n);
                removeNode((Container)n);
            }
            if(n instanceof Node){
                removeNode((Node) n);
            }
        });
        container.getmodelElements_ModelElement().forEach((n)->{
            if(n instanceof Edge){
                removeEdge((Edge) n);
            }
        });
        identifiableElementController.delete(container);
    }


    private void removeNode(Node node){
        node.getincoming_Edge().forEach(e->e.settargetElement(null));
        node.getincoming_Edge().clear();
        node.getoutgoing_Edge().forEach(e->e.setsourceElement(null));
        node.getoutgoing_Edge().clear();
        node.getcontainer().getmodelElements_ModelElement().remove(node);
        node.setcontainer(null);
        identifiableElementController.delete(node);

    }

    private void removeEdge(Edge edge){
        identifiableElementController.delete(edge);
    }



}
