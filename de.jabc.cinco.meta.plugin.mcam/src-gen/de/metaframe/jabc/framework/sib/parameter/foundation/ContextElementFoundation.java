/*
 * Copyright 1992,2009 Universität Dortmund
 *
 * For license details contact nagel@jabc.de
 * 
 */
package de.metaframe.jabc.framework.sib.parameter.foundation;

/**
 * This is the basic representation of a ContextElement used for pure
 * generators.
 * 
 * @author <a href="mailto:nagel@jabc.de">Ralf Nagel</a>
 * @version $Revision: 6564 $ $Date: 2009-06-12 13:41:56 +0200 (Fri, 12 Jun 2009) $
 * 
 */
public class ContextElementFoundation implements FoundationParameter {

	/**
	 * for serialization
	 */
	private static final long serialVersionUID = 1545482835424035856L;

	/** The key which identifies the object in the execution context. */
	private String name;

	/** The scope for this context element. */
	private String scope;

	/** The type of the object that is identifed by this context element. */
	private String className;

	/** The pre- and postconditions for this context element. */
	private String conditions;

	/**
	 * The (simple) operation for this context element.
	 */
	private String operation;

	private Boolean isScopeMutable;
	
	private Boolean isClassNameMutable;

	/**
	 * @param name
	 *            the name of the ContextElement
	 * @param className
	 *            the className of the ContextElement
	 * @param scope
	 *            the scope of the ContextElement
	 * @param conditions
	 *            the conditions of the ContextElement
	 * @param operation
	 *            the operation of the ContextElement
	 * @deprecated Use {@link #ContextElementFoundation(String,String,String,String,String,boolean,boolean)} instead
	 */
	@Deprecated
	public ContextElementFoundation(String name, String className, String scope, String conditions, String operation) {
		this(name, scope, className, operation, conditions, true, true);
	}

	/**
	 * @param name
	 *            the name of the ContextElement
	 * @param scope
	 *            the scope of the ContextElement
	 * @param className
	 *            the className of the ContextElement
	 * @param operation
	 *            the operation of the ContextElement
	 * @param conditions
	 *            the conditions of the ContextElement
	 * @param isScopeMutable 
	 * 			  true if the user is allowed to change the scope 
	 * @param isClassNameMutable 
	 *            true if the user is allowed to change the class name 
	 */
	public ContextElementFoundation(String name, String scope, String className, String operation, String conditions, boolean isScopeMutable, boolean isClassNameMutable) {
		super();
		this.name = name;
		this.scope = scope;
		this.className = className;
		this.conditions = conditions;
		this.operation = operation;
		this.isScopeMutable = Boolean.valueOf(isScopeMutable);
		this.isClassNameMutable = Boolean.valueOf(isClassNameMutable);
	}

	/**
	 * @see de.metaframe.jabc.framework.sib.parameter.foundation.FoundationParameter#toConstructorArray()
	 */
	public Object[] toConstructorArray() {
		return new Object[] { this.name, this.scope, this.className, this.operation , this.conditions, this.isScopeMutable, this.isClassNameMutable};
	}

	/**
	 * @return the className
	 */
	public String getClassName() {
		return this.className;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return this.name;
	}

	/**
	 * @return the scope
	 */
	public String getScope() {
		return this.scope;
	}

	/**
	 * @return the conditions
	 */
	public String getConditions() {
		return this.conditions;
	}

	/**
	 * @return the operation
	 */
	public String getOperation() {
		return this.operation;
	}

	public boolean getScopeMutable() {
		if (this.isScopeMutable==null) {
			return true;
		} else {
			return this.isScopeMutable.booleanValue();
		}
	}

	
	public boolean getClassNameMutable() {
		if (this.isClassNameMutable == null) {
			return true;
		} else {
			return this.isClassNameMutable.booleanValue();
		}
	}
}
