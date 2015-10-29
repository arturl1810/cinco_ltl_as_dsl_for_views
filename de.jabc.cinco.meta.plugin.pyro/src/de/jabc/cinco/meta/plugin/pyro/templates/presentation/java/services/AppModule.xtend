package de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.services

import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import org.eclipse.emf.ecore.EClass
import mgl.ReferencedType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import mgl.NodeContainer

class AppModule implements Templateable {
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
package de.mtf.dywa.services;

import de.ls5.cinco.deployment.CincoDBController;
«FOR GraphModel g:graphModels»
import de.ls5.cinco.transformation.api.«g.name.toFirstLower».*;
«ENDFOR»
import de.ls5.dywa.api.security.DyWARealm;
import de.ls5.dywa.generated.controller.*;
import de.mtf.dywa.ExampleController;
import de.mtf.dywa.util.filter.CERFImpl;
import de.mtf.dywa.util.filter.PRRFImpl;
import org.apache.shiro.realm.Realm;
import org.apache.shiro.web.mgt.WebSecurityManager;
import org.apache.tapestry5.SymbolConstants;
import org.apache.tapestry5.ioc.*;
import org.apache.tapestry5.ioc.annotations.Contribute;
import org.apache.tapestry5.ioc.annotations.Local;
import org.apache.tapestry5.ioc.annotations.Scope;
import org.apache.tapestry5.ioc.services.ClasspathURLConverter;
import org.apache.tapestry5.services.*;
import org.slf4j.Logger;

import javax.enterprise.context.spi.CreationalContext;
import javax.enterprise.inject.spi.Bean;
import javax.enterprise.inject.spi.BeanManager;
import javax.naming.InitialContext;
import java.io.IOException;
import java.util.Set;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public class AppModule
{
    public static void bind(ServiceBinder binder)
    {
        // binder.bind(MyServiceInterface.class, MyServiceImpl.class);

        // Make bind() calls on the binder object to define most IoC services.
        // Use service builder methods (example below) when the implementation
        // is provided inline, or requires more initialization than simply
        // invoking the constructor.
    }

    public static void contributeFactoryDefaults(
            MappedConfiguration<String, Object> configuration)
    {
        // The application version number is incorprated into URLs for some
        // assets. Web browsers will cache assets because of the far future expires
        // header. If existing assets are changed, the version number should also
        // change, to force the browser to download new versions. This overrides Tapesty's default
        // (a random hexadecimal number), but may be further overriden by DevelopmentModule or
        // QaModule.
        configuration.override(SymbolConstants.APPLICATION_VERSION, "0.1-SNAPSHOT");
    }

    public static void contributeApplicationDefaults(
            MappedConfiguration<String, Object> configuration)
    {
        // Contributions to ApplicationDefaults will override any contributions to
        // FactoryDefaults (with the same key). Here we're restricting the supported
        // locales to just "en" (English). As you add localised message catalogs and other assets,
        // you can extend this list of locales (it's a comma separated series of locale names;
        // the first locale name is the default when there's no reasonable match).
        configuration.add(SymbolConstants.SUPPORTED_LOCALES, "en");
        configuration.add(SymbolConstants.PRODUCTION_MODE,false);
        configuration.add(SymbolConstants.HMAC_PASSPHRASE, "9g96ktm4Gp4j8uYzYGoBlbqi5R6tEM");
    }


    /**
     * This is a service definition, the service will be named "TimingFilter". The interface,
     * RequestFilter, is used within the RequestHandler service pipeline, which is built from the
     * RequestHandler service configuration. Tapestry IoC is responsible for passing in an
     * appropriate Logger instance. Requests for static resources are handled at a higher level, so
     * this filter will only be invoked for Tapestry related requests.
     * <p/>
     * <p/>
     * Service builder methods are useful when the implementation is inline as an inner class
     * (as here) or require some other kind of special initialization. In most cases,
     * use the static bind() method instead.
     * <p/>
     * <p/>
     * If this method was named "build", then the service id would be taken from the
     * service interface and would be "RequestFilter".  Since Tapestry already defines
     * a service named "RequestFilter" we use an explicit service id that we can reference
     * inside the contribution method.
     */
    public RequestFilter buildTimingFilter(final Logger log)
    {
        return new RequestFilter()
        {
            public boolean service(Request request, Response response, RequestHandler handler)
                    throws IOException
            {
                long startTime = System.currentTimeMillis();

                try
                {
                    // The responsibility of a filter is to invoke the corresponding method
                    // in the handler. When you chain multiple filters together, each filter
                    // received a handler that is a bridge to the next filter.

                    return handler.service(request, response);
                } finally
                {
                    long elapsed = System.currentTimeMillis() - startTime;

                    log.info(String.format("Request time: %d ms", elapsed));
                }
            }
        };
    }

    /**
     * This is a contribution to the RequestHandler service configuration. This is how we extend
     * Tapestry using the timing filter. A common use for this kind of filter is transaction
     * management or security. The @Local annotation selects the desired service by type, but only
     * from the same module.  Without @Local, there would be an error due to the other service(s)
     * that implement RequestFilter (defined in other modules).
     */
    public void contributeRequestHandler(OrderedConfiguration<RequestFilter> configuration,
                                         @Local
                                         RequestFilter filter)
    {
        // Each contribution to an ordered configuration has a name, When necessary, you may
        // set constraints to precisely control the invocation order of the contributed filter
        // within the pipeline.

//        configuration.add("Timing", filter);
    }
    
	public static void contributeServiceOverride(MappedConfiguration<Class<?>, Object> configuration) {
		configuration.add(ClasspathURLConverter.class, new JBoss7ClasspathURLConverterImpl());
	}

	public void contributePageRenderRequestHandler(OrderedConfiguration<PageRenderRequestFilter> configuration) {
		configuration.add("pageTransactionFilter", new PRRFImpl());
	}

	public void contributeComponentEventRequestHandler(OrderedConfiguration<ComponentEventRequestFilter> configuration) {
		configuration.add("componentTransactionFilter", new CERFImpl());
	}

	public void contributeAjaxComponentEventRequestHandler(
			OrderedConfiguration<ComponentEventRequestFilter> configuration) {
		configuration.add("ajaxComponentTransactionFilter", new CERFImpl());
	}

	@SuppressWarnings("unchecked")
	private <T> T buildControllerOrNull(Class<T> clazz, String beanname) {
		try {
			InitialContext ctx = new InitialContext();

			BeanManager bmgr = (BeanManager) ctx.lookup("java:comp/BeanManager");
			Set<Bean<?>> beans = bmgr.getBeans(clazz);
			Bean<T> bean = null;

			for (final Bean<?> b : beans) {
				if (b.getName() != null && b.getName().equals(beanname)) {
					bean = (Bean<T>) b;
					break;
				}
			}

			if (bean == null) {
				throw new IllegalStateException("Bean with name '" + beanname + "' of type '" + clazz.getName()
						+ "' not found");
			}

			CreationalContext<T> cctx = bmgr.createCreationalContext(bean);
			T o = (T) bmgr.getReference(bean, clazz, cctx);

			return o;
		}
		catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	@Scope(ScopeConstants.PERTHREAD)
	public ExampleController buildExampleController() {
		return buildControllerOrNull(ExampleController.class, "exampleController");
	}


	@Contribute(WebSecurityManager.class)
	public void configureDyWARealm(Configuration<Realm> configuration) {
		configuration.add(buildControllerOrNull(DyWARealm.class, "dywaRealm"));
	}

    @Scope(ScopeConstants.PERTHREAD)
    public CincoDBController buildCincoDBController() {
        return buildControllerOrNull(CincoDBController.class, "cincoDBController");
    }

    @Scope(ScopeConstants.PERTHREAD)
    public ProjectController buildProjectController() {
        return buildControllerOrNull(ProjectController.class, "projectControllerImpl");
    }

    @Scope(ScopeConstants.PERTHREAD)
    public GraphModelController buildGraphModelController() {
        return buildControllerOrNull(GraphModelController.class, "graphModelControllerImpl");
    }
    //Commmands
    @Scope(ScopeConstants.PERTHREAD)
    public PyroCommandController buildPyroCommandController() {
        return buildControllerOrNull(PyroCommandController.class, "pyroCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroCreateNodeCommandController buildPyroCreateNodeCommandController() {
        return buildControllerOrNull(PyroCreateNodeCommandController.class, "pyroCreateNodeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroRemoveNodeCommandController buildPyroRemoveNodeCommandController() {
        return buildControllerOrNull(PyroRemoveNodeCommandController.class, "pyroRemoveNodeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroMoveNodeCommandController buildPyroMoveNodeCommandController() {
        return buildControllerOrNull(PyroMoveNodeCommandController.class, "pyroMoveNodeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroResizeNodeCommandController buildPyroResizeNodeCommandController() {
        return buildControllerOrNull(PyroResizeNodeCommandController.class, "pyroResizeNodeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroRotateNodeCommandController buildPyroRotateNodeCommandController() {
        return buildControllerOrNull(PyroRotateNodeCommandController.class, "pyroRotateNodeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroCreateEdgeCommandController buildPyroCreateEdgeCommandController() {
        return buildControllerOrNull(PyroCreateEdgeCommandController.class, "pyroCreateEdgeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroRemoveEdgeCommandController buildPyroRemoveEdgeCommandController() {
        return buildControllerOrNull(PyroRemoveEdgeCommandController.class, "pyroRemoveEdgeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroReconnectEdgeCommandController buildPyroReconnectEdgeCommandController() {
        return buildControllerOrNull(PyroReconnectEdgeCommandController.class, "pyroReconnectEdgeCommandControllerImpl");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public PyroVertexEdgeCommandController buildPyroVertexEdgeCommandController() {
        return buildControllerOrNull(PyroVertexEdgeCommandController.class, "pyroVertexEdgeCommandControllerImpl");
    }
    «FOR GraphModel g:graphModels»
    «IF !g.attributes.isEmpty»
    @Scope(ScopeConstants.PERTHREAD)
    public Pyro«g.name.toFirstUpper»AttributeCommandController buildPyro«g.name.toFirstUpper»AttributeCommandController() {
        return buildControllerOrNull(Pyro«g.name.toFirstUpper»AttributeCommandController.class, "pyro«g.name.toFirstUpper»AttributeCommandControllerImpl");
    }
    «ENDIF»
    
    «FOR mgl.Node sn:g.nodes»
    @Scope(ScopeConstants.PERTHREAD)
    public «sn.name.toFirstUpper»Controller build«sn.name.toFirstUpper»Controller() {
        return buildControllerOrNull(«sn.name.toFirstUpper»Controller.class, "«sn.name.toFirstLower»ControllerImpl");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public C«sn.name.toFirstUpper» buildC«sn.name.toFirstUpper»() {
        return buildControllerOrNull(C«sn.name.toFirstUpper».class, "c«sn.name.toFirstUpper»");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public Pyro«sn.name.toFirstUpper»AttributeCommandController buildPyro«sn.name.toFirstUpper»AttributeCommandController() {
        return buildControllerOrNull(Pyro«sn.name.toFirstUpper»AttributeCommandController.class, "pyro«sn.name.toFirstUpper»AttributeCommandControllerImpl");
    }
    «ENDFOR»
    
    «FOR NodeContainer sn:g.nodes.filter[n | (n instanceof NodeContainer)].map[nc | nc as NodeContainer]»
    @Scope(ScopeConstants.PERTHREAD)
    public «sn.name.toFirstUpper»Controller build«sn.name.toFirstUpper»Controller() {
        return buildControllerOrNull(«sn.name.toFirstUpper»Controller.class, "«sn.name.toFirstLower»ControllerImpl");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public C«sn.name.toFirstUpper» buildC«sn.name.toFirstUpper»() {
        return buildControllerOrNull(C«sn.name.toFirstUpper».class, "c«sn.name.toFirstUpper»");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public Pyro«sn.name.toFirstUpper»AttributeCommandController buildPyro«sn.name.toFirstUpper»AttributeCommandController() {
        return buildControllerOrNull(Pyro«sn.name.toFirstUpper»AttributeCommandController.class, "pyro«sn.name.toFirstUpper»AttributeCommandControllerImpl");
    }
    «ENDFOR»
    
    «FOR mgl.Edge sn:g.edges»
    @Scope(ScopeConstants.PERTHREAD)
    public «sn.name.toFirstUpper»Controller build«sn.name.toFirstUpper»Controller() {
        return buildControllerOrNull(«sn.name.toFirstUpper»Controller.class, "«sn.name.toFirstLower»ControllerImpl");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public C«sn.name.toFirstUpper» buildC«sn.name.toFirstUpper»() {
        return buildControllerOrNull(C«sn.name.toFirstUpper».class, "c«sn.name.toFirstUpper»");
    }
    @Scope(ScopeConstants.PERTHREAD)
    public Pyro«sn.name.toFirstUpper»AttributeCommandController buildPyro«sn.name.toFirstUpper»AttributeCommandController() {
        return buildControllerOrNull(Pyro«sn.name.toFirstUpper»AttributeCommandController.class, "pyro«sn.name.toFirstUpper»AttributeCommandControllerImpl");
    }
    «ENDFOR»
    
     @Scope(ScopeConstants.PERTHREAD)
    public «g.name.toFirstUpper»Controller build«g.name.toFirstUpper»Controller() {
        return buildControllerOrNull(«g.name.toFirstUpper»Controller.class, "«g.name.toFirstLower»ControllerImpl");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public C«g.name.toFirstUpper»Wrapper buildC«g.name.toFirstUpper»Wrapper() {
        return buildControllerOrNull(C«g.name.toFirstUpper»Wrapper.class, "c«g.name.toFirstUpper»Wrapper");
    }
    
    @Scope(ScopeConstants.PERTHREAD)
    public C«g.name.toFirstUpper» buildC«g.name.toFirstUpper»() {
        return buildControllerOrNull(C«g.name.toFirstUpper».class, "c«g.name.toFirstUpper»");
    }
    
    «ENDFOR»

   
    
    


}

	'''
}