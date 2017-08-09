package info.scce.pyro.core;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.ser.impl.SimpleFilterProvider;
import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroProjectController;
import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.*;
import de.ls5.dywa.generated.util.Identifiable;
import info.scce.pyro.core.rest.types.*;
import info.scce.pyro.core.rest.types.PyroProject;
import info.scce.pyro.core.rest.types.PyroUser;
import info.scce.pyro.rest.PyroSelectiveRestFilter;
import info.scce.pyro.sync.ProjectWebSocket;
import info.scce.pyro.sync.UserWebSocket;
import info.scce.pyro.sync.WebSocketMessage;

import javax.ws.rs.core.Response;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

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
    private ProjectWebSocket projectWebSocket;

    @javax.inject.Inject
    private UserWebSocket userWebSocket;

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


        //update shared user
        pp.getshared_PyroUser().forEach(n->userWebSocket.send(n.getDywaId(), WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroUser.fromDywaEntity(n,objectCache))));

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
        
        graphModelController.checkPermission(pp);
        
        Set<de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser> updateUsers = new HashSet<>(pp.getshared_PyroUser());
        //updateUsers.add(subject);
        if(pp.getowner().equals(subject)){
            pp.setdescription(ownedProject.getdescription());
            pp.setname(ownedProject.getname());
            //remove previous shared
            pp.getshared_PyroUser().forEach(n->n.getsharedProjects_PyroProject().remove(pp));
            pp.getshared_PyroUser().clear();
            pp.setshared_PyroUser(ownedProject.getshared().stream().map(n->subjectController.read(n.getDywaId())).collect(Collectors.toList()));
            pp.getshared_PyroUser().forEach(n->n.getsharedProjects_PyroProject().add(pp));
            updateUsers.addAll(pp.getshared_PyroUser());
        } else {
            return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();
        }


        //update shared user
        updateUsers.forEach(n->userWebSocket.send(n.getDywaId(), WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroUser.fromDywaEntity(n,objectCache))));

        return javax.ws.rs.core.Response.ok(PyroProject.fromDywaEntity(pp,objectCache)).build();


    }

    @javax.ws.rs.GET
    @javax.ws.rs.Path("structure/{id}/private")
    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  loadProjectStructure(@javax.ws.rs.PathParam("id")  final long id) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());
    

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(id);

        graphModelController.checkPermission(pp);
        
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

        graphModelController.checkPermission(pp);
        
        if(pp.getowner().equals(subject)){
            final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser sharedUser = subjectController.read(updatePyroProject.getuserId());
           pp.getshared_PyroUser().add(sharedUser);
            sharedUser.getsharedProjects_PyroProject().add(pp);
        } else {
            return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();
        }

        //update shared user
        pp.getshared_PyroUser().forEach(n->userWebSocket.send(n.getDywaId(), WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroUser.fromDywaEntity(n,objectCache))));

        //update shared user
        projectWebSocket.send(pp.getDywaId(), WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroProject.fromDywaEntity(pp,objectCache)));

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

        graphModelController.checkPermission(pp);
        
        if(pp.getowner().equals(subject)){
            de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser removedUser = subjectController.read(updatePyroProject.getuserId());
            pp.getshared_PyroUser().remove(removedUser);
            removedUser.getsharedProjects_PyroProject().remove(pp);
            projectWebSocket.updateUserList(pp.getDywaId(), Stream.concat(Stream.of(pp.getowner().getDywaId()),pp.getshared_PyroUser().stream().map(Identifiable::getDywaId)).collect(Collectors.toList()));
            //update removed shared user
            userWebSocket.send(removedUser.getDywaId(),WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroUser.fromDywaEntity(removedUser,objectCache)));

        } else {
            return javax.ws.rs.core.Response.status(Response.Status.FORBIDDEN).build();
        }
        //update other users
        pp.getshared_PyroUser().forEach(n->userWebSocket.send(n.getDywaId(),WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroUser.fromDywaEntity(n,objectCache))));

        //update shared user
        projectWebSocket.send(pp.getDywaId(), WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroProject.fromDywaEntity(pp,objectCache)));


        return javax.ws.rs.core.Response.ok(PyroProject.fromDywaEntity(pp,objectCache)).build();


    }

    @javax.ws.rs.GET
    @javax.ws.rs.Path("remove/{id}/private")
    @org.jboss.resteasy.annotations.GZIP
    public javax.ws.rs.core.Response  removeProject(@javax.ws.rs.PathParam("id")  final long id) {

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject pp = projectController.read(id);

        graphModelController.checkPermission(pp);
        
        List<de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser> sharedUser = new LinkedList<>(pp.getshared_PyroUser());
        sharedUser.add(pp.getowner());
        if(pp.getowner().equals(subject)){
            pp.getowner().getownedProjects_PyroProject().remove(pp);
            pp.setowner(null);
            pp.getshared_PyroUser().forEach(n->n.getsharedProjects_PyroProject().remove(pp));
            pp.getshared_PyroUser().clear();
            graphModelController.removeFolder(pp,null);
            projectWebSocket.updateUserList(pp.getDywaId(), Collections.emptyList());

        } else {
            pp.getshared_PyroUser().remove(subject);
            subject.getsharedProjects_PyroProject().remove(pp);
            projectWebSocket.updateUserList(pp.getDywaId(), Stream.concat(Stream.of(pp.getowner().getDywaId()),pp.getshared_PyroUser().stream().map(Identifiable::getDywaId)).collect(Collectors.toList()));

        }
        sharedUser.forEach(n->userWebSocket.send(n.getDywaId(),WebSocketMessage.fromDywaEntity(subject.getDywaId(),PyroUser.fromDywaEntity(n,objectCache))));
        return javax.ws.rs.core.Response.ok("Removed").build();


    }


}
