/*
 * Copyright 1992,2009 Universität Dortmund
 *
 * For license details contact nagel@jabc.de
 * 
 */
package de.metaframe.jabc.framework.sib.parameter.foundation;

/**
 * Foundation class for ContextExpression
 * 
 * @author <a href="mailto:nagel@jabc.de">Ralf Nagel</a>
 * @version $Revision: 6564 $ $Date: 2009-06-12 13:41:56 +0200 (Fri, 12 Jun 2009) $
 * 
 */
public class ContextExpressionFoundation implements FoundationParameter {

	/**
	 * for serialization 
	 */
	private static final long serialVersionUID = -1323686892579683841L;
	
	private String expression = "${2 + 2}";
	private Class<?> clazz;
	private boolean classMutable;

	/**
	 * @param expression
	 * @param clazz
	 * @param classMutable
	 */
	public ContextExpressionFoundation(String expression, Class<?> clazz, boolean classMutable) {
		super();
		this.expression = expression;
		this.clazz = clazz;
		this.classMutable = classMutable;
	}

	/**
	 * @see de.metaframe.jabc.framework.sib.parameter.foundation.FoundationParameter#toConstructorArray()
	 */
	public Object[] toConstructorArray() {
		return new Object[] {this.expression, this.clazz, Boolean.valueOf(this.classMutable)};
	}

	/**
	 * @return the classMutable
	 */
	public boolean isClassMutable() {
		return this.classMutable;
	}

	/**
	 * @return the clazz
	 */
	public Class<?> getClazz() {
		return this.clazz;
	}

	/**
	 * @return the expression
	 */
	public String getExpression() {
		return this.expression;
	}
}
