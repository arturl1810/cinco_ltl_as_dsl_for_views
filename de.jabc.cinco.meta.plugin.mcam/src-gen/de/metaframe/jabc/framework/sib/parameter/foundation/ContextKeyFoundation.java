/*
 * Copyright 1992,2009 METAFrame Technologies GmbH, Universität Dortmund
 *    _    _    ____   ____     _____                                            _    
 *   (_)  / \  | __ ) / ___|   |  ___| __ __ _ _ __ ___   _____      _____  _ __| | __
 *   | | / _ \ |  _ \| |       | |_ | '__/ _` | '_ ` _ \ / _ \ \ /\ / / _ \| '__| |/ /
 *   | |/ ___ \| |_) | |___    |  _|| | | (_| | | | | | |  __/\ V  V / (_) | |  |   < 
 *  _/ /_/   \_\____/ \____|   |_|  |_|  \__,_|_| |_| |_|\___| \_/\_/ \___/|_|  |_|\_\
 * |__/                                                                             
 *
 * For license details contact: nagel@jabc.de
 * 
 */
package de.metaframe.jabc.framework.sib.parameter.foundation;

/**
 * 
 * @author <a href="mailto:nagel@jabc.de">Ralf Nagel</a>
 * @version $Revision: 6564 $ $Date: 2009-06-12 13:41:56 +0200 (Fri, 12 Jun 2009) $
 *
 */
public class ContextKeyFoundation implements FoundationParameter {

	/**
	 * for serialization
	 */
	private static final long serialVersionUID = -7094549370043215048L;
	
	private String key;
	private String scope;
	private boolean scopeMutable;

	
	/**
	 * @param key
	 * @param scope
	 * @param scopeMutable
	 */
	public ContextKeyFoundation(String key, String scope, boolean scopeMutable) {
		this.key = key;
		this.scope = scope;
		this.scopeMutable = scopeMutable;
	}


	public Object[] toConstructorArray() {
		return new Object[]{this.key, this.scope, Boolean.valueOf(this.scopeMutable)};
	}


	/**
	 * @return the key
	 */
	public String getKey() {
		return this.key;
	}


	/**
	 * @return the scope
	 */
	public String getScope() {
		return this.scope;
	}


	/**
	 * @return the scopeMutable
	 */
	public boolean isScopeMutable() {
		return this.scopeMutable;
	}

}
