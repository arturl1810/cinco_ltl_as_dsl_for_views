package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class PyroUser extends info.scce.pyro.rest.RESTBaseImpl implements info.scce.pyro.rest.RESTBaseType
{

    private java.util.List<PyroUser> knownUsers = new java.util.LinkedList<>();

    @com.fasterxml.jackson.annotation.JsonProperty("knownUsers")
    public java.util.List<PyroUser> getknownUsers() {
        return this.knownUsers;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("knownUsers")
    public void setknownUsers(final java.util.List<PyroUser> knownUsers) {
        this.knownUsers = knownUsers;
    }

    private java.util.List<PyroProject> ownedProjects = new java.util.LinkedList<>();

    @com.fasterxml.jackson.annotation.JsonProperty("ownedProjects")
    public java.util.List<PyroProject> getownedProjects() {
        return this.ownedProjects;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("ownedProjects")
    public void setownedProjects(final java.util.List<PyroProject> ownedProjects) {
        this.ownedProjects = ownedProjects;
    }

    private java.util.List<PyroProject> sharedProjects = new java.util.LinkedList<>();

    @com.fasterxml.jackson.annotation.JsonProperty("sharedProjects")
    public java.util.List<PyroProject> getsharedProjects() {
        return this.sharedProjects;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("sharedProjects")
    public void setsharedProjects(final java.util.List<PyroProject> sharedProjects) {
        this.sharedProjects = sharedProjects;
    }


    private java.lang.String username;

    @com.fasterxml.jackson.annotation.JsonProperty("username")
    public java.lang.String getusername() {
        return this.username;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("username")
    public void setusername(final java.lang.String username) {
        this.username = username;
    }

    private java.lang.String email;

    @com.fasterxml.jackson.annotation.JsonProperty("email")
    public java.lang.String getemail() {
        return this.email;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("email")
    public void setemail(final java.lang.String email) {
        this.email = email;
    }





    public static PyroUser fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser entity, info.scce.pyro.rest.ObjectCache objectCache) {

        if(objectCache.containsRestTo(entity)){
            return objectCache.getRestTo(entity);
        }
        final PyroUser result;
        result = new PyroUser();
        result.setDywaId(entity.getDywaId());
        result.setDywaName(entity.getDywaName());
        result.setDywaVersion(entity.getDywaVersion());

        result.setemail(entity.getemail());
        result.setusername(entity.getusername());

        objectCache.putRestTo(entity, result);

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser p:entity.getknownUsers_PyroUser()){
            result.getknownUsers().add(PyroUser.fromDywaEntity(p,objectCache));
        }

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject p:entity.getownedProjects_PyroProject()){
            result.getownedProjects().add(PyroProject.fromDywaEntity(p,objectCache));
        }

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject p:entity.getsharedProjects_PyroProject()){
            result.getsharedProjects().add(PyroProject.fromDywaEntity(p,objectCache));
        }



        return result;
    }
}
