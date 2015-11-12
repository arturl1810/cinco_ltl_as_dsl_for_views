package de.jabc.cinco.meta.plugin.gratext.util;

import java.util.List;
import java.util.Map;

public interface IRegistry<K,T> {
	
	T lookup(K key);
	
	<U extends T> Map<K, U> lookupByType(Class<U> type);
	
	<U extends T> Map<K, U> lookupByType(Class<U> type, boolean includeSubTypes);
	
	List<K> keys();
	
	List<T> values();
}
