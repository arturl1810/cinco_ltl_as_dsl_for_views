package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class PyroFolder extends info.scce.pyro.rest.RESTBaseImpl implements info.scce.pyro.rest.RESTBaseType
{


    private String name;

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public String getname() {
        return this.name;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public void setname(final String name) {
        this.name = name;
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






    public static PyroFolder fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroFolder entity, info.scce.pyro.rest.ObjectCache objectCache) {

        if(objectCache.containsRestTo(entity)){
            return objectCache.getRestTo(entity);
        }
        final PyroFolder result;
        result = new PyroFolder();
        result.setDywaId(entity.getDywaId());
        result.setDywaName(entity.getDywaName());
        result.setDywaVersion(entity.getDywaVersion());

        result.setname(entity.getname());

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroFolder p:entity.getinnerFolders_PyroFolder()){
            result.getinnerFolders().add(PyroFolder.fromDywaEntity(p,objectCache));
        }

        for(de.ls5.dywa.generated.entity.info.scce.pyro.core.GraphModel p:entity.getgraphModels_GraphModel()){
            result.getgraphModels().add(GraphModel.fromDywaEntity(p,objectCache));
        }

        objectCache.putRestTo(entity, result);

        return result;
    }
}
