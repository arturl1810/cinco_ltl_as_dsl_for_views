package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class PyroProjectStructure extends PyroProject implements info.scce.pyro.rest.RESTBaseType
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



    private java.util.List<PyroFolder> innerFolders = new java.util.LinkedList<>();

    @com.fasterxml.jackson.annotation.JsonProperty("innerFolders")
    public java.util.List<PyroFolder> getinnerFolders() {
        return this.innerFolders;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("innerFolders")
    public void setinnerFolders(final java.util.List<PyroFolder> innerFolders) {
        this.innerFolders = innerFolders;
    }

    private java.util.List<GraphModel> graphModels = new java.util.LinkedList<>();

    @com.fasterxml.jackson.annotation.JsonProperty("graphModels")
    public java.util.List<GraphModel> getgraphModels() {
        return this.graphModels;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("graphModels")
    public void setgraphModels(final java.util.List<GraphModel> graphModels) {
        this.graphModels = graphModels;
    }


    private String name;

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public String getname() {
        return this.name;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public void setname(final String name) {
        this.name = name;
    }

    private String description;

    @com.fasterxml.jackson.annotation.JsonProperty("description")
    public String getdescription() {
        return this.description;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("description")
    public void setdescription(final String description) {
        this.description = description;
    }





    public static PyroProjectStructure fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroProject entity, info.scce.pyro.rest.ObjectCache objectCache) {

        if(objectCache.containsRestTo(entity)){
            return objectCache.getRestTo(entity);
        }
        final PyroProjectStructure result;
        result = new PyroProjectStructure();
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

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.GraphModel p:entity.getgraphModels_GraphModel()){
            result.getgraphModels().add(GraphModel.fromDywaEntity(p,objectCache));
        }

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroFolder p:entity.getinnerFolders_PyroFolder()){
            result.getinnerFolders().add(PyroFolder.fromDywaEntity(p,objectCache));
        }



        return result;
    }
}
