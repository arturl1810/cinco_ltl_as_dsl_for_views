/*
 * Copyright 1992,2009 Universität Dortmund
 *
 * For license details contact nagel@jabc.de
 * 
 */
package de.metaframe.jabc.framework.sib.parameter.foundation;

import java.io.Serializable;

/**
 * Marker Interface for all foundation versions of SIB Parameters
 * 
 * @author <a href="mailto:nagel@jabc.de">Ralf Nagel</a>
 * @version $Revision: 6564 $ $Date: 2009-06-12 13:41:56 +0200 (Fri, 12 Jun 2009) $
 * 
 */
public interface FoundationParameter extends Serializable {

	/**
	 * delivers the current value of this Foundation Parameter in the correct sequence for the constructor. This function is needed
	 * by the Source Code Generator.
	 * 
	 * @return a sequence of objects for the constructor
	 */
	public Object[] toConstructorArray();

}
