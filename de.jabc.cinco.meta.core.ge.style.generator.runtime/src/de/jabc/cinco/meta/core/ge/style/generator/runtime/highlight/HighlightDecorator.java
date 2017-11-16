package de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight;

import org.eclipse.graphiti.tb.AbstractDecorator;
import org.eclipse.graphiti.tb.IColorDecorator;
import org.eclipse.graphiti.util.ColorConstant;
import org.eclipse.graphiti.util.IColorConstant;

import static java.lang.Math.min;
import static java.lang.Math.max;

public class HighlightDecorator extends AbstractDecorator implements IColorDecorator {

	private IColorConstant foregroundColor;
	private IColorConstant backgroundColor;
	
	private String text = "";
	private String fontName = "Arial";
	private int fontSize = 10;
	private int y = 4;
	private int x = 4;
	
//	private IColorConstant borderColor;
//	private Integer lineWidth;
//	private Integer borderStyle;

	/**
	 * Creates a new decorator that can decorate a shape with foreground and
	 * background colors as well as with a border.
	 */
	public HighlightDecorator() {
		super();
	}
	

	/**
	 * Creates a new decorator that can decorate a shape with foreground and
	 * background colors as well as with a border.
	 */
	public HighlightDecorator(IColorConstant foregroundColor, IColorConstant backgroundColor) {
		this();
		setForegroundColor(foregroundColor);
		setBackgroundColor(backgroundColor);
	}
	
	public HighlightDecorator(HighlightDecorator archetype) {
		this(archetype.foregroundColor, archetype.backgroundColor);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.IColorDecorator#getForegroundColor()
	 */
	public IColorConstant getForegroundColor() {
		return foregroundColor;
	}
	
	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#setForegroundColor()
	 */
//	@Override
	public void setForegroundColor(IColorConstant color) {
		this.foregroundColor = new ColorConstant(
			max(0, min(255, color.getRed())),
			max(0, min(255, color.getGreen())),
			max(0, min(255, color.getBlue()))
		);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.IColorDecorator#getBackgroundColor()
	 */
	public IColorConstant getBackgroundColor() {
		return backgroundColor;
	}
	
	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#setBackgroundColor()
	 */
//	@Override
	public void setBackgroundColor(IColorConstant color) {
		this.backgroundColor = new ColorConstant(
			max(0, min(255, color.getRed())),
			max(0, min(255, color.getGreen())),
			max(0, min(255, color.getBlue()))
		);
	}


//	/*
//	 * (non-Javadoc)
//	 * 
//	 * @see org.eclipse.graphiti.tb.IBorderDecorator#getBorderColor()
//	 */
//	public IColorConstant getBorderColor() {
//		return borderColor;
//	}
//
//	/**
//	 * Sets the color to be used for the border line. By default (when
//	 * <code>null</code> is set) {@link IColorConstant#BLACK} is used.
//	 * 
//	 * @param borderColor
//	 */
//	public HighlightDecorator setBorderColor(IColorConstant borderColor) {
//		this.borderColor = borderColor;
//		return this;
//	}
//
//	/*
//	 * (non-Javadoc)
//	 * 
//	 * @see org.eclipse.graphiti.tb.IBorderDecorator#getBorderWidth()
//	 */
//	public Integer getBorderWidth() {
//		return lineWidth;
//	}
//
//	/**
//	 * Sets the width that will be used for the border line. By default (when
//	 * <code>null</code> or a value smaller than 1 is set) 1 is used.
//	 * 
//	 * @param lineWidth
//	 *            an Integer defining the width of the border line
//	 */
//	public HighlightDecorator setBorderWidth(Integer lineWidth) {
//		this.lineWidth = lineWidth;
//		return this;
//	}
//
//	/*
//	 * (non-Javadoc)
//	 * 
//	 * @see org.eclipse.graphiti.tb.IBorderDecorator#getBorderStyle()
//	 */
//	public Integer getBorderStyle() {
//		return borderStyle;
//	}
//
//	/**
//	 * Sets the style that will be used for the border line. Possible values
//	 * are:
//	 * <p>
//	 * <ul>
//	 * <li>{@link org.eclipse.draw2d.Graphics#LINE_SOLID}</li>
//	 * <li>{@link org.eclipse.draw2d.Graphics#LINE_DASH}</li>
//	 * <li>{@link org.eclipse.draw2d.Graphics#LINE_DASHDOT}</li>
//	 * <li>{@link org.eclipse.draw2d.Graphics#LINE_DASHDOTDOT}</li>
//	 * <li>{@link org.eclipse.draw2d.Graphics#LINE_DOT}</li>
//	 * </ul>
//	 * By default (when <code>null</code> or an invalid value is set)
//	 * {@link org.eclipse.draw2d.Graphics#LINE_SOLID} is used.
//	 * 
//	 * @param borderStyle
//	 *            an Integer defining the style of the border line
//	 */
//	public HighlightDecorator setBorderStyle(Integer borderStyle) {
//		this.borderStyle = borderStyle;
//		return this;
//	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.datatypes.ILocation#getX()
	 */
	public int getX() {
		return this.x;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.datatypes.ILocation#getY()
	 */
	public int getY() {
		return this.y;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.datatypes.ILocation#setX(int)
	 */
	public void setX(int x) {
		this.x = x;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.datatypes.ILocation#setY(int)
	 */
	public void setY(int y) {
		this.y = y;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#getText()
	 */
	public String getText() {
		return this.text;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#setText(java.lang.String)
	 */
	public void setText(String text) {
		this.text = text;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#getFontName()
	 */
	public String getFontName() {
		return fontName;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#setFontName(java.lang.String)
	 */
	public void setFontName(String fontName) {
		this.fontName = fontName;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#getFontSize()
	 */
	public int getFontSize() {
		return fontSize;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.graphiti.tb.ITextDecorator#setFontSize(int)
	 */
	public void setFontSize(int fontSize) {
		this.fontSize = fontSize;
	}
}
