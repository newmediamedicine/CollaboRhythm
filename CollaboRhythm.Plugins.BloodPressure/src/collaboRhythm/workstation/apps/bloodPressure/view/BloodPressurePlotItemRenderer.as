/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.workstation.apps.bloodPressure.view
{
import flash.display.Graphics;
import flash.geom.Rectangle;
import mx.charts.chartClasses.GraphicsUtilities;
import mx.graphics.IFill;
import mx.graphics.IStroke;
import mx.skins.ProgrammaticSkin;
import mx.core.IDataRenderer;
import mx.graphics.SolidColor;
import mx.utils.ColorUtil;
import mx.charts.ChartItem;

/**
 *  A simple chart itemRenderer implementation
 *  that draws an arrow head (up or down).
 *  This class can be used as an itemRenderer for ColumnSeries, BarSeries, AreaSeries, LineSeries,
 *  PlotSeries, and BubbleSeries objects.
 *  It renders its area on screen using the <code>stroke</code> styles
 *  of its associated series.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class BloodPressurePlotItemRenderer extends ProgrammaticSkin implements IDataRenderer
{
//	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	private static var rcFill:Rectangle = new Rectangle();
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Constructor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function BloodPressurePlotItemRenderer() 
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  data
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the data property.
	 */
	private var _data:Object;
	
	[Inspectable(environment="none")]
	
	/**
	 *  The chartItem that this itemRenderer is displaying.
	 *  This value is assigned by the owning series
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get data():Object
	{
		return _data;
	}
	
	/**
	 *  @private
	 */
	public function set data(value:Object):void
	{
		if (_data == value)
			return;
		_data = value;
		
	}
	
	
	//----------------------------------
	//  thickness
	//----------------------------------
	
	[Inspectable]
	
	/**
	 *  The thickness of the cross rendered, in pixels.
	 *  To create cross renderers of other widths, developers should extend
	 *  this class and change this value in the derived class' constructor.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var thickness:Number = 3;

	[Inspectable]
	
	/**
	 *  The delta in the Y direction for the arrow.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var deltaY:Number = 8;
	
	[Inspectable]
	
	/**
	 *  The delta in the X direction for the arrow.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var deltaX:Number = 8;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var stroke:IStroke = getStyle("stroke");
		
		// center
		var cx:Number = unscaledWidth / 2;
		var cy:Number = unscaledHeight / 2;
		
		var g:Graphics = graphics;
		g.clear();		
		if (stroke)
			stroke.apply(g,null,null);

		const DELTA:Number = 8;
		
		// left top corner
		g.moveTo(cx - deltaX, cy + deltaY);
		
		// center
		g.lineTo(cx, cy);
		
		// right top corner
		g.lineTo(cx + deltaX, cy + deltaY);
	}
}
}
