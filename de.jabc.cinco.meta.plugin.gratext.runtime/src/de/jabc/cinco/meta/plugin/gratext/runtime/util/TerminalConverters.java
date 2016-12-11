package de.jabc.cinco.meta.plugin.gratext.runtime.util;

import java.util.regex.Pattern;

import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.impl.AbstractDeclarativeValueConverterService;
import org.eclipse.xtext.conversion.impl.AbstractIDValueConverter;
import org.eclipse.xtext.conversion.impl.AbstractNullSafeConverter;
import org.eclipse.xtext.conversion.impl.INTValueConverter;
import org.eclipse.xtext.conversion.impl.STRINGValueConverter;
import org.eclipse.xtext.nodemodel.INode;

import com.google.inject.Inject;
import com.google.inject.Singleton;

/**
 * Default converters for Strings, Integers and IDs.
 */
@Singleton
public class TerminalConverters extends AbstractDeclarativeValueConverterService {
	
	private static final Pattern ID_PATTERN = Pattern.compile("\\p{Alpha}\\w*");
	
	@ValueConverter(rule = "_EString")
	public IValueConverter<String> EString() {
		return new AbstractNullSafeConverter<String>() {
			@Override
			protected String internalToValue(String string, INode node) {
				if((string.startsWith("'") && string.endsWith("'"))||(string.startsWith("\"") && string.endsWith("\""))) {
					return STRING().toValue(string, node);
				}
				return ID().toValue(string, node);
			}

			@Override
			protected String internalToString(String value) {
				if(ID_PATTERN.matcher(value).matches()) {
					return ID().toString(value);
				} else {
					return STRING().toString(value);
				}
			}
		};
	}
	
	@Inject
	private AbstractIDValueConverter idValueConverter;

	@ValueConverter(rule = "_ID")
	public IValueConverter<String> ID() {
		return idValueConverter;
	}
	
	@Inject
	private INTValueConverter intValueConverter;
	
	@ValueConverter(rule = "_INT")
	public IValueConverter<Integer> INT() {
		return intValueConverter;
	}

	@Inject
	private STRINGValueConverter stringValueConverter;
	
	@ValueConverter(rule = "_STRING")
	public IValueConverter<String> STRING() {
		return stringValueConverter;
	}
}
