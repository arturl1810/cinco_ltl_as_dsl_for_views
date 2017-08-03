package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class PyroProject extends info.scce.pyro.rest.RESTBaseImpl implements info.scce.pyro.rest.RESTBaseType
{

    private PyroUser owner = new PyroUser();

    @com.fasterxml.jackson.annotation.JsonProperty("owner")
    public PyroUser geowner() {
        return this.owner;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("owner")
    public void setowner(final PyroUser owner) {
        this.owner = owner;
    }

    private java.util.List<PyroUser> shared = new java.util.LinkedList<>();

    @com.fasterxml.jackson.annotation.JsonProperty("shared")
    public java.util.List<PyroUser> getshared() {
        return this.shared;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("shared")
    public void setshared(final java.util.List<PyroUser> shared) {
        this.shared = shared;
    }


    private java.lang.String name;

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public java.lang.String getname() {
        return this.name;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public void setname(final java.lang.String name) {
        this.name = name;
    }

    private java.lang.String description;

    @com.fasterxml.jackson.annotation.JsonProperty("description")
    public java.lang.String getdescription() {
        return this.description;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("description")
    public void setdescription(final java.lang.String description) {
        this.description = description;
    }





    public static PyroProject fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject entity, info.scce.pyro.rest.ObjectCache objectCache) {

        if(objectCache.containsRestTo(entity)){
            return objectCache.getRestTo(entity);
        }
        final PyroProject result;
        result = new PyroProject();
        result.setDywaId(entity.getDywaId());
        result.setDywaName(entity.getDywaName());
        result.setDywaVersion(entity.getDywaVersion());

        result.setname(entity.getname());
        result.setdescription(entity.getdescription());

        objectCache.putRestTo(entity, result);

        result.setowner(PyroUser.fromDywaEntity(entity.getowner(),objectCache));

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser p:entity.getshared_PyroUser()){
            result.getshared().add(PyroUser.fromDywaEntity(p,objectCache));
        }



        return result;
    }
}
