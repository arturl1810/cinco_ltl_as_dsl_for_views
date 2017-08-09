package info.scce.pyro.core;

import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;
import info.scce.pyro.core.rest.types.FindPyroUser;
import info.scce.pyro.core.rest.types.PyroUser;

import java.util.stream.Collectors;

@javax.transaction.Transactional
@javax.ws.rs.Path("/user/current")
public class CurrentUserController {
	
	@javax.inject.Inject
	private de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController subjectController;

	@javax.inject.Inject
	private info.scce.pyro.rest.ObjectCache objectCache;
	
	@javax.ws.rs.GET
	@javax.ws.rs.Path("private")
	@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@org.jboss.resteasy.annotations.GZIP
	public javax.ws.rs.core.Response  getCurrentUser() {

		final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());

		if(subject!=null) {
			PyroUser result = objectCache.getRestTo(subject);
			if(result==null){
				result = PyroUser.fromDywaEntity(subject, objectCache);
			}
			return javax.ws.rs.core.Response.ok(result).build();
		}


		return javax.ws.rs.core.Response.status(
				javax.ws.rs.core.Response.Status.FORBIDDEN).build();
	}

	@javax.ws.rs.POST
	@javax.ws.rs.Path("addknown/private")
	@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
	@org.jboss.resteasy.annotations.GZIP
	public javax.ws.rs.core.Response  addKnownUser(FindPyroUser findPyroUser) {

		final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());


		final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser searchObject = subjectController.createSearchObject(null);
		searchObject.setusername(findPyroUser.getusername());
		searchObject.setemail(findPyroUser.getemail());

		final java.util.List<de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser> users = subjectController.findByProperties(searchObject);
		if(users.isEmpty()){
			return javax.ws.rs.core.Response.ok("None found").build();
		}
		if(subject.getknownUsers_PyroUser().contains(users.get(0)) || users.get(0).equals(subject)){
			return javax.ws.rs.core.Response.ok("Already known").build();
		}
		subject.getknownUsers_PyroUser().add(users.get(0));
		return javax.ws.rs.core.Response.ok(PyroUser.fromDywaEntity(users.get(0),objectCache)).build();


	}


}
