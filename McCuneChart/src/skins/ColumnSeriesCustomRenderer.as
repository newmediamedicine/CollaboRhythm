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
/*
Copyright (c) 2007 Brendan Meutzner

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package skins
{
	import mx.charts.ChartItem;
	import mx.charts.renderers.BoxItemRenderer;
	
	public class ColumnSeriesCustomRenderer extends BoxItemRenderer
	{
	    public var _chartItem:ChartItem;
	    
	    override public function get data():Object
	    {
	        return _chartItem;
	    }
	
	    override public function set data(value:Object):void
	    {
	        _chartItem = ChartItem(value);
	        this.alpha = 0.5;

	    }

/**
 *  Constructor
 */
 		public function ColumnSeriesCustomRenderer():void
	    {
	        super();
	    }
	    
	    public function showRenderer(value:Boolean):void
	    {
	    	//if we show this renderer instance, set it's alpha to full, if not, set it's alpha to half and refresh display
	    	(value) ? this.alpha = 1 : this.alpha = 0.5;
	    }
	    	    
	
	    
	}

}
