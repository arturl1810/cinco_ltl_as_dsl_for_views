/*
 * Copyright 1992,2009 METAFrame Technologies GmbH, Universität Dortmund
 *    _    _    ____   ____     _____                                            _    
 *   (_)  / \  | __ ) / ___|   |  ___| __ __ _ _ __ ___   _____      _____  _ __| | __
 *   | | / _ \ |  _ \| |       | |_ | '__/ _` | '_ ` _ \ / _ \ \ /\ / / _ \| '__| |/ /
 *   | |/ ___ \| |_) | |___    |  _|| | | (_| | | | | | |  __/\ V  V / (_) | |  |   < 
 *  _/ /_/   \_\____/ \____|   |_|  |_|  \__,_|_| |_| |_|\___| \_/\_/ \___/|_|  |_|\_\
 * |__/                                                                             
 *
 * For license details contact nagel@jabc.de
 * 
 */
package de.metaframe.jabc.framework.execution.el;

import java.lang.reflect.Method;

/**
 * This interface defines the methods used to evaluate context expressions. Each evaluator implementation maintains a registry of functions that may
 * be used in context expressions. Variables will always be resolved against the local execution context of the execution environment hosting the
 * evaluator.
 * <p>
 * Initially, the following mathematical functions will be available for usage in context expressions, using either their simple name or by using the
 * prefix "Math":
 * <ul>
 * <li>{@link Math#random()}</li>
 * <li>{@link Math#abs(double)}</li>
 * <li>{@link Math#sin(double)}</li>
 * <li>{@link Math#cos(double)}</li>
 * <li>{@link Math#tan(double)}</li>
 * <li>{@link Math#asin(double)}</li>
 * <li>{@link Math#acos(double)}</li>
 * <li>{@link Math#atan(double)}</li>
 * <li>{@link Math#floor(double)}</li>
 * <li>{@link Math#ceil(double)}</li>
 * <li>{@link Math#exp(double)}</li>
 * <li>{@link Math#log(double)}</li>
 * <li>{@link Math#sqrt(double)}</li>
 * <li>{@link Math#max(double, double)}</li>
 * <li>{@link Math#min(double, double)}</li>
 * <li>{@link Math#pow(double, double)}</li>
 * </ul>
 * 
 * @author Benjamin Bentmann
 * @version $Revision: 6564 $ $Date: 2009-06-12 13:41:56 +0200 (Fri, 12 Jun 2009) $
 */
public interface ContextExpressionEvaluator {

	/**
	 * Evaluates the specified context expression.
	 * 
	 * @param expression
	 *            The context expression to evaluate, must not be {@code null}.
	 * @param type
	 *            The expected result type of the context expression, must not be {@code null}.
	 * @return The result of the expression evaluation, can be {@code null}.
	 * @throws NullPointerException
	 *             If the specified expression is {@code null}.
	 * @throws IllegalArgumentException
	 *             If the specified expression could not be evaluated due to unresolvable variables, unknown functions or otherwise bad syntax.
	 */
	public Object evaluate(String expression, Class<?> type);

	/**
	 * @deprecated As of jABC 3.7.x, use
	 *             {@link de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment#evaluate(de.metaframe.jabc.framework.sib.parameter.foundation.ContextExpressionFoundation)}
	 *             instead.
	 */
	@Deprecated
	public Object evaluate(de.metaframe.jabc.framework.sib.parameter.foundation.ContextExpressionFoundation expression);

	/**
	 * Gets the function registry employed by this evaluator.
	 * 
	 * @return The function registry employed by this evaluator, never {@code null}.
	 */
	public FunctionRegistry getFunctionRegistry();

	/**
	 * The registry of functions available to an evaluator.
	 */
	public interface FunctionRegistry {

		/**
		 * Gets the function with the specified namespace prefix and name (if any).
		 * 
		 * @param prefix
		 *            The namespace prefix for the function to add, may be empty but must not be {@code null}.
		 * @param name
		 *            The (simple) name for the function to add, must not be {@code null}.
		 * @return The requested function or {@code null} if no function was registered with the specified name.
		 */
		public Method get(String prefix, String name);

		/**
		 * Adds the specified method to this function registry. The method providing the implementation for the function must be public and static.
		 * 
		 * @param prefix
		 *            The namespace prefix for the function to add, may be empty but must not be {@code null}.
		 * @param name
		 *            The (simple) name for the function to add, must not be {@code null}.
		 * @param method
		 *            The method that provides the implementation for the function, must not be {@code null}.
		 * @param force
		 *            A flag to control behavior in case an equally named function is already registered. If {@code true}, the existing function is
		 *            replaced. If {@code false}, an exception will be thrown.
		 */
		public void add(String prefix, String name, Method method, boolean force);

		/**
		 * Removes the specified method from this function registry. Removing a non-existing function has no effect.
		 * 
		 * @param prefix
		 *            The namespace prefix of the function to remove, may be empty but must not be {@code null}.
		 * @param name
		 *            The (simple) name of the function to remove, must not be {@code null}.
		 */
		public void remove(String prefix, String name);

	}

}
