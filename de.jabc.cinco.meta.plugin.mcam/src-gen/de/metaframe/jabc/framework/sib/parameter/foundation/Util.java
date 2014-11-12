/*
 * Copyright 1992,2009 METAFrame Technologies GmbH, UniversitÃ¤t Dortmund
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

package de.metaframe.jabc.framework.sib.parameter.foundation;

import java.util.Collection;
import java.util.Map;

/**
 * UtilityClass for Codegenerator
 * 
 * @author <a href="mailto:nagel@metaframe.de">Ralf Nagel</a>
 * @version $Revision: 6564 $ $Date: 2009-06-12 13:41:56 +0200 (Fri, 12 Jun 2009) $
 * 
 */
public class Util {

	/**
	 * Fill a Collection in a single line
	 * 
	 * @param collection
	 *            the list to fill
	 * @param elements
	 *            the elements
	 * @return the same collection
	 */
	public static <E, C extends Collection<? super E>> C add(C collection,
			E[] elements) {

		assert collection != null : "add() AssertError: collection != null";

		if (elements != null)
			for (int i = 0; i < elements.length; i++)
				collection.add(elements[i]);

		return collection;
	}

	/**
	 * Fill a map in a single line
	 * 
	 * @param map
	 *            the map to fill
	 * @param keys
	 *            the key elements
	 * @param values
	 *            the value elements
	 * @return the same map
	 */
	public static <K, V, M extends Map<? super K, ? super V>> M put(M map,
			K[] keys, V[] values) {

		assert map != null : "put() AssertError: map != null";

		if ((keys != null) && (values != null))
			for (int i = 0; i < keys.length; i++)
				map.put(keys[i], values[i]);

		return map;
	}

}
