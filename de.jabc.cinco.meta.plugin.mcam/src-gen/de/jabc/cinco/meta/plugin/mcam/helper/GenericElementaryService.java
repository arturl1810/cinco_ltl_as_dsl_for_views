package de.jabc.cinco.meta.plugin.mcam.helper;

/**
 * Represents an elementary service that dynamically executes the corresponding
 * service functionality via reflection. Thus this type of service can be reused
 * for different service implementations.
 *
 * @author Java Class Generator (2014-11-12 15:36:16.989)
 */
public class GenericElementaryService extends de.jabc.cinco.meta.plugin.mcam.helper.AbstractService {
	/** The (absolute) name of the class containing the service's functionality. */
	private java.lang.String serviceAdapterClassName;
	/** The name of the method containing the service's functionality. */
	private java.lang.String methodName;
	/** The types of the method's arguments. */
	private java.lang.Class<?>[] parameterTypes;
	/** The values of the method's arguments. */
	private java.lang.Object[] parameterValues;
	/** User-defined results of the service. */
	private java.util.List<java.lang.String> userDefinedResults;

	/**
	 * Creates a new generic elementary service for the functionality described
	 * by the given data.
	 * 
	 * @param serviceAdapterClassName
	 *            Name of the class that contains the service functionality.
	 * @param methodName
	 *            Name of the method that implements the service functionality.
	 * @param parameterTypes
	 *            Types of the method's parameters.
	 * @param parameterValues
	 *            Argument values for the method.
	 */
	public GenericElementaryService(java.lang.String serviceAdapterClassName, java.lang.String methodName, java.lang.Class<?>[] parameterTypes, java.lang.Object[] parameterValues) {
		super();
		this.serviceAdapterClassName = serviceAdapterClassName;
		this.methodName = methodName;
		this.parameterTypes = parameterTypes;
		this.parameterValues = parameterValues;
		this.userDefinedResults = null;
	}

	/**
	 * Creates a new generic elementary service for the functionality described
	 * by the given data.
	 * 
	 * @param serviceAdapterClassName
	 *            Name of the class that contains the service functionality.
	 * @param methodName
	 *            Name of the method that implements the service functionality.
	 * @param parameterTypes
	 *            Types of the method's parameters.
	 * @param userDefinedResults
	 *            User-defined results of the service.
	 * @param parameterValues
	 *            Argument values for the method.
	 */
	public GenericElementaryService(java.lang.String serviceAdapterClassName, java.lang.String methodName, java.lang.Class<?>[] parameterTypes, java.lang.Object[] parameterValues, java.util.List<java.lang.String> userDefinedResults) {
		super();
		this.serviceAdapterClassName = serviceAdapterClassName;
		this.methodName = methodName;
		this.parameterTypes = parameterTypes;
		this.parameterValues = parameterValues;
		this.userDefinedResults = userDefinedResults;
	}

	/**
	 * Executes the service.
	 * 
	 * @param executionEnvironment
	 *            The execution environment that will be passed to the service
	 *            functionality.
	 * @return The result of the service execution, i.e. the name of the branch
	 *         leading to the successor that should be executed next.
	 * @throws ServiceException
	 *             if the execution of the service failed.
	 */
	public java.lang.String execute(de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment executionEnvironment) throws de.jabc.cinco.meta.plugin.mcam.helper.ServiceException {
		java.lang.Object result;
		try {
			java.lang.Class<?> serviceAdapter = java.lang.Class.forName(this.serviceAdapterClassName);
			java.lang.Class<?>[] parameterTypes = buildFullParameterList();
			java.lang.Object[] arguments = buildFullArgumentList(executionEnvironment);
			java.lang.reflect.Method method = serviceAdapter.getMethod(this.methodName, parameterTypes);
			result = method.invoke(null, arguments);
		} catch (java.lang.SecurityException e) {
			throw new de.jabc.cinco.meta.plugin.mcam.helper.ServiceException(e);
		} catch (java.lang.IllegalArgumentException e) {
			throw new de.jabc.cinco.meta.plugin.mcam.helper.ServiceException(e);
		} catch (java.lang.ClassNotFoundException e) {
			throw new de.jabc.cinco.meta.plugin.mcam.helper.ServiceException(e);
		} catch (java.lang.NoSuchMethodException e) {
			throw new de.jabc.cinco.meta.plugin.mcam.helper.ServiceException(e);
		} catch (java.lang.IllegalAccessException e) {
			throw new de.jabc.cinco.meta.plugin.mcam.helper.ServiceException(e);
		} catch (java.lang.reflect.InvocationTargetException e) {
			throw new de.jabc.cinco.meta.plugin.mcam.helper.ServiceException(e);
		}
		
		if (result == null) {
			return null;
		}
		return result.toString();
	}

	/**
	 * Builds the complete parameter list for the service call.
	 * 
	 * @return The parameter argument list for the service call.
	 */
	private java.lang.Class<?>[] buildFullParameterList() {
		java.util.List<java.lang.Class<?>> parameters = new java.util.ArrayList<java.lang.Class<?>>();
		parameters.add(de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment.class);
		if (this.userDefinedResults != null) {
			parameters.add(java.lang.String[].class);
		}
		parameters.addAll(java.util.Arrays.asList(this.parameterTypes));
		return parameters.toArray(new java.lang.Class<?>[parameters.size()]);
	}

	/**
	 * Builds the complete argument list for the service call.
	 * 
	 * @param executionEnvironment
	 *            The execution environment that will be passed to the service
	 *            functionality.
	 * @return The complete argument list for the service call.
	 */
	private java.lang.Object[] buildFullArgumentList(de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment executionEnvironment) {
		java.util.List<java.lang.Object> arguments = new java.util.ArrayList<java.lang.Object>();
		arguments.add(executionEnvironment);
		if (this.userDefinedResults != null) {
			arguments.add(this.userDefinedResults.toArray(new java.lang.String[this.userDefinedResults.size()]));
		}
		arguments.addAll(java.util.Arrays.asList(this.parameterValues));
		return arguments.toArray();
	}
}