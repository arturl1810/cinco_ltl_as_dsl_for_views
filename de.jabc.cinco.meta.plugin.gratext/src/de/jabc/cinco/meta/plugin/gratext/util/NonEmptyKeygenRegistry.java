package de.jabc.cinco.meta.plugin.gratext.util;

import java.util.function.Function;
import java.util.function.Supplier;

public class NonEmptyKeygenRegistry<K,V> extends KeygenRegistry<K,V> {
	
	// generated
	private static final long serialVersionUID = -7398768765765415345L;

	private Supplier<V> valueSupplier;
	
	public NonEmptyKeygenRegistry(Function<V,K> keySupplier, Supplier<V> valueSupplier) {
		super(keySupplier);
		this.valueSupplier = valueSupplier;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public V get(Object key) {
		V val = super.get(key);
		if (val == null) {
			val = valueSupplier.get();
			put((K) key, val);
		}
		return val;
	}
	
	public Supplier<V> getValueSupplier() {
		return valueSupplier;
	}
	
	public void setValueSupplier(Supplier<V> valueSupplier) {
		this.valueSupplier = valueSupplier;
	}
}
