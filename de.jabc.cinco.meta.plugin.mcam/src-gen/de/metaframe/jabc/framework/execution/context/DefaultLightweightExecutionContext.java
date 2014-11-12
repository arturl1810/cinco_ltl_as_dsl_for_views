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
package de.metaframe.jabc.framework.execution.context;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

import de.metaframe.jabc.framework.sib.parameter.foundation.ContextElementFoundation;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextKeyFoundation;

/**
 * This class supports the execution of SIB graph models outside the JavaABC. It
 * was generated by the Genesys plugin of the jABC and must not be modified.
 * 
 * @author Benjamin Bentmann
 */
public class DefaultLightweightExecutionContext implements
		LightweightExecutionContext {

	/**
	 * The parent of this context.
	 */
	private final LightweightExecutionContext parent;

	/**
	 * The entries of this context.
	 */
	private final Map<String, Object> entries = new HashMap<String, Object>();

	/**
	 * Creates a new execution context with the specified parent.
	 * 
	 * @param parent
	 *            The parent for this context, may be {@code null}.
	 */
	public DefaultLightweightExecutionContext(
			final LightweightExecutionContext parent) {
		this.parent = parent;
	}

	/**
	 * {@inheritDoc}
	 */
	public LightweightExecutionContext createNewChildContext() {
		return new DefaultLightweightExecutionContext(this);
	}

	/**
	 * {@inheritDoc}
	 */
	public LightweightExecutionContext getParent() {
		return this.parent;
	}

	/**
	 * {@inheritDoc}
	 */
	public LightweightExecutionContext getGlobalContext() {
		LightweightExecutionContext global;
		LightweightExecutionContext parent = this;
		do {
			global = parent;
			parent = global.getParent();
		} while (parent != null);
		return global;
	}

	/**
	 * {@inheritDoc}
	 */
	public LightweightExecutionContext findContextContainingKey(final String key) {
		return getDeclaringContext(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public LightweightExecutionContext getDeclaringContext(final Object key) {
		LightweightExecutionContext context = this;
		do {
			if (context.containsKey(key)) {
				return context;
			}
			context = context.getParent();
		} while (context != null);
		return null;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object get(final Object key) {
		final LightweightExecutionContext context = getDeclaringContext(key);
		return (context == null) ? null : context.getLocal(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object put(final String key, final Object value) {
		LightweightExecutionContext context = getDeclaringContext(key);
		if (context == null) {
			context = this;
		}
		return context.putLocal(key, value);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object remove(final Object key) {
		final LightweightExecutionContext context = getDeclaringContext(key);
		return (context == null) ? null : context.removeLocal(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object getLocal(final Object key) {
		if (key == null) {
			throw new NullPointerException("key missing");
		}
		return this.entries.get(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object putLocal(final String key, final Object value) {
		if (key == null) {
			throw new NullPointerException("key missing");
		}
		return this.entries.put(key, value);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object removeLocal(final Object key) {
		if (key == null) {
			throw new NullPointerException("key missing");
		}
		return this.entries.remove(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object getFromParent(final Object key) {
		final LightweightExecutionContext parent = getParent();
		return (parent != null) ? parent.getLocal(key) : null;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object putIntoParent(final String key, final Object value) {
		final LightweightExecutionContext parent = getParent();
		return (parent != null) ? parent.putLocal(key, value) : null;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object removeFromParent(final Object key) {
		final LightweightExecutionContext parent = getParent();
		return (parent != null) ? parent.removeLocal(key) : null;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object getGlobally(final Object key) {
		return getGlobalContext().getLocal(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object putGlobally(final String key, final Object value) {
		return getGlobalContext().putLocal(key, value);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object removeGlobally(final Object key) {
		return getGlobalContext().removeLocal(key);
	}

	private static void checkType(final ContextElementFoundation element,
			final Object value) {
		if (value != null) {
			final String className = element.getClassName();
			if (className.length() > 0 && !className.equals("java.lang.Object")
					&& !isCompatible(value.getClass(), className)) {
				throw new ClassCastException("value for element "
						+ element.getScope() + ":" + element.getName()
						+ " is not compatible with " + className + ": " + value);
			}
		}
	}

	private static boolean isCompatible(final Class<?> type, final String name) {
		if (type == null) {
			return false;
		}
		if (type.getName().equals(name)) {
			return true;
		}
		if (isCompatible(type.getSuperclass(), name)) {
			return true;
		}
		for (final Class<?> iface : type.getInterfaces()) {
			if (isCompatible(iface, name)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object get(final ContextKeyFoundation element) {
		final String key = element.getKey();
		final String scope = element.getScope();
		final Object value;
		if ("DECLARED".equals(scope)) {
			value = get(key);
		} else if ("LOCAL".equals(scope)) {
			value = getLocal(key);
		} else if ("GLOBAL".equals(scope)) {
			value = getGlobally(key);
		} else if ("PARENT".equals(scope)) {
			value = getFromParent(key);
		} else {
			throw new IllegalArgumentException("unknown context scope: "
					+ scope);
		}
		return value;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object put(final ContextKeyFoundation element, final Object value) {
		final String key = element.getKey();
		final String scope = element.getScope();
		if ("DECLARED".equals(scope)) {
			return put(key, value);
		} else if ("LOCAL".equals(scope)) {
			return putLocal(key, value);
		} else if ("GLOBAL".equals(scope)) {
			return putGlobally(key, value);
		} else if ("PARENT".equals(scope)) {
			return putIntoParent(key, value);
		}
		throw new IllegalArgumentException("unknown context scope: " + scope);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object remove(final ContextKeyFoundation element) {
		final String key = element.getKey();
		final String scope = element.getScope();
		if ("DECLARED".equals(scope)) {
			return remove(key);
		} else if ("LOCAL".equals(scope)) {
			return removeLocal(key);
		} else if ("GLOBAL".equals(scope)) {
			return removeGlobally(key);
		} else if ("PARENT".equals(scope)) {
			return removeFromParent(key);
		}
		throw new IllegalArgumentException("unknown context scope: " + scope);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object get(final ContextElementFoundation element) {
		final String key = element.getName();
		final String scope = element.getScope();
		final Object value;
		if ("DECLARED".equals(scope)) {
			value = get(key);
		} else if ("LOCAL".equals(scope)) {
			value = getLocal(key);
		} else if ("GLOBAL".equals(scope)) {
			value = getGlobally(key);
		} else if ("PARENT".equals(scope)) {
			value = getFromParent(key);
		} else {
			throw new IllegalArgumentException("unknown context scope: "
					+ scope);
		}
		checkType(element, value);
		return value;
	}

	/**
	 * {@inheritDoc}
	 */
	public Object put(final ContextElementFoundation element, final Object value) {
		checkType(element, value);
		final String key = element.getName();
		final String scope = element.getScope();
		if ("DECLARED".equals(scope)) {
			return put(key, value);
		} else if ("LOCAL".equals(scope)) {
			return putLocal(key, value);
		} else if ("GLOBAL".equals(scope)) {
			return putGlobally(key, value);
		} else if ("PARENT".equals(scope)) {
			return putIntoParent(key, value);
		}
		throw new IllegalArgumentException("unknown context scope: " + scope);
	}

	/**
	 * {@inheritDoc}
	 */
	public Object remove(final ContextElementFoundation element) {
		final String key = element.getName();
		final String scope = element.getScope();
		if ("DECLARED".equals(scope)) {
			return remove(key);
		} else if ("LOCAL".equals(scope)) {
			return removeLocal(key);
		} else if ("GLOBAL".equals(scope)) {
			return removeGlobally(key);
		} else if ("PARENT".equals(scope)) {
			return removeFromParent(key);
		}
		throw new IllegalArgumentException("unknown context scope: " + scope);
	}

	/**
	 * {@inheritDoc}
	 */
	public void clear() {
		this.entries.clear();
	}

	/**
	 * {@inheritDoc}
	 */
	public boolean containsKey(final Object key) {
		if (key == null) {
			throw new NullPointerException("key missing");
		}
		return this.entries.containsKey(key);
	}

	/**
	 * {@inheritDoc}
	 */
	public boolean containsValue(final Object value) {
		return this.entries.containsValue(value);
	}

	/**
	 * {@inheritDoc}
	 */
	public Set<Map.Entry<String, Object>> entrySet() {
		return this.entries.entrySet();
	}

	/**
	 * {@inheritDoc}
	 */
	public boolean isEmpty() {
		return this.entries.isEmpty();
	}

	/**
	 * {@inheritDoc}
	 */
	public Set<String> keySet() {
		return this.entries.keySet();
	}

	/**
	 * {@inheritDoc}
	 */
	public void putAll(final Map<? extends String, ? extends Object> map) {
		for (Map.Entry<? extends String, ? extends Object> entry : map.entrySet()) {
			this.put(entry.getKey(), entry.getValue());
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public int size() {
		return this.entries.size();
	}

	/**
	 * {@inheritDoc}
	 */
	public Collection<Object> values() {
		return this.entries.values();
	}

	@Override
	public String toString() {
		return String.valueOf(this.entries);
	}

}
