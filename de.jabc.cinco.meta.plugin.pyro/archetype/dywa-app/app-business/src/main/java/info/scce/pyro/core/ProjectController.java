package info.scce.pyro.core;

import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroProjectController;
import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;
import info.scce.pyro.core.rest.types.*;

import javax.ws.rs.core.Response;
import java.util.stream.Collectors;

@javax.transaction.Transactional
@javax.ws.rs.Path("/project")
public class ProjectController {

	@javax.inject.Inject
	private PyroUserController subjectController;

    @javax.inject.Inject
    private GraphModelController graphModelController;

	@javax.inject.Inject
	private PyroProjectController projectController;

	@javax.inject.Inject
	private info.scce.pyro.rest.ObjectCache objectCache;


	@javax.ws.rs.POST
	@javax.ws.rs.Path("create/private")
	@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@org.jboss.resteasy.annotations.GZIP
	public javax.ws.rs.core.Response  createProject(PyroProject newProject) {

		final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


		final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.create("Project_"+newProject.getname());
		pp.setowner(subject);
		pp.setname(newProject.getname());
		pp.setdescription(newProject.getdescription());
        subject.getownedProjects_PyroProject().add(pp);
		pp.setshared_PyroUser(newProject.getshared().stream().map(n->subjectController.read(n.getDywaId())).collect(Collectors.toList()));
        newProject.getshared().forEach(n->subjectController.read(n.getDywaId()).getsharedProjects_PyroProject().add(pp));

		return javax.ws.rs.core.Response.ok(PyroProject.fromDywaEntity(pp,objectCache)).build();


	}

    @javax.ws.rs.POST
    @javax.ws.rs.Path("update/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  updateProject(PyroProject ownedProject) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(ownedProject.getDywaId());
        if(pp.getowner().equals(subject)){
            pp.setdescription(ownedProject.getdescription());
            pp.setname(ownedProject.getname());
            pp.getshared_PyroUser().clear();
            pp.setshared_PyroUser(ownedProject.getshared().stream().map(n->subjectController.read(n.getDywaId())).collect(Collectors.toList()));
        } else {
            return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();
        }

        return javax.ws.rs.core.Response.ok(PyroProject.fromDywaEntity(pp,objectCache)).build();


    }

    @javax.ws.rs.GET
    @javax.ws.rs.Path("structure/{id}/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  loadProjectStructure(@javax.ws.rs.PathParam("id")  final long id) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(id);
        if(pp.getowner().equals(subject)||pp.getshared_PyroUser().contains(subject)){
            return javax.ws.rs.core.Response.ok(PyroProjectStructure.fromDywaEntity(pp,objectCache)).build();
        }
        return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();

    }

    @javax.ws.rs.POST
    @javax.ws.rs.Path("update/addsharing/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  addProjectSharing(UpdatePyroProject updatePyroProject) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(updatePyroProject.getprojectId());
        if(pp.getowner().equals(subject)){
            final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser sharedUser = subjectController.read(updatePyroProject.getuserId());
           pp.getshared_PyroUser().add(sharedUser);
            sharedUser.getsharedProjects_PyroProject().add(pp);
        } else {
            return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();
        }

        return javax.ws.rs.core.Response.ok(PyroProject.fromDywaEntity(pp,objectCache)).build();


    }

    @javax.ws.rs.POST
    @javax.ws.rs.Path("update/removesharing/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  removeProjectSharing(UpdatePyroProject updatePyroProject) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(updatePyroProject.getprojectId());
        if(pp.getowner().equals(subject)){
            pp.getshared_PyroUser().remove(subjectController.read(updatePyroProject.getuserId()));
        } else {
            return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();
        }

        return javax.ws.rs.core.Response.ok(PyroProject.fromDywaEntity(pp,objectCache)).build();


    }

    @javax.ws.rs.GET
    @javax.ws.rs.Path("remove/{id}/private")
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  removeProject(@javax.ws.rs.PathParam("id")  final long id) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(id);
        if(pp.getowner().equals(subject)){
            pp.getowner().getownedProjects_PyroProject().remove(pp);
            pp.setowner(null);
            graphModelController.removeFolder(pp,null);
        } else {
            pp.getshared_PyroUser().remove(subject);
            subject.getsharedProjects_PyroProject().remove(pp);
        }

        return javax.ws.rs.core.Response.ok("Removed").build();


    }


}
