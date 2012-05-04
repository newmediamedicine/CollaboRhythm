	

package qs.charts.dataShapes
{
	import flash.utils.getQualifiedClassName;

	import mx.charts.chartClasses.ChartElement;
	import mx.graphics.SolidColor;
	import mx.charts.chartClasses.IAxis;
	import mx.charts.chartClasses.CartesianTransform;
	import mx.graphics.IFill;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import mx.charts.chartClasses.DataDescription;
	import mx.charts.chartClasses.BoundedValue;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import mx.core.UIComponent;
	import mx.core.IFlexDisplayObject;
	import flash.display.DisplayObject;
	import mx.core.IUIComponent;
	import flash.events.Event;
	import mx.graphics.IStroke;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	import qs.utils.DebugUtils;

	[DefaultProperty("dataChildren")]
	public class DataDrawingCanvas extends ChartElement
	{
		// a cache of the values and their corresponding pixel values
		private var _xCache:Array;
		private var _yCache:Array;
		
		private var _xMap:Dictionary;
		private var _yMap:Dictionary;
		private var _hDataDesc:DataDescription;
		private var _vDataDesc:DataDescription;
		
		private var _dataCache:DataCache;
		private var _opCodes:Array = [];
		private var _dataCacheDirty:Boolean = true;
		private var _mappingDirty:Boolean = true;
		private var _transformDirty:Boolean = true;
		private var _oldUW:Number;
		private var _oldUH:Number;
		private var _includeInRanges:Boolean = false;
		private var _dataChildren:Array = [];
		private var borderWidth:Number = 0;

		
		private var _childMap:Dictionary;
		private var _logger:ILogger;
		private var _traceEventHandlers:Boolean = false;
				
		public function DataDrawingCanvas()
		{
		    super();
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_hDataDesc = new DataDescription();
			_vDataDesc = new DataDescription();
			_childMap = new Dictionary(true);
		}

		public function set dataChildren(value:Array):void
		{
			for(var aChild:* in _childMap)
			{
				removeChild(_childMap[aChild].child);
			}
			_childMap = new Dictionary(true);
			_dataChildren = value;
			for(var i:int =0;i<value.length;i++)
			{
				var dc:DataChild;

				if(value[i] is DataChild)				
					dc = value[i];
				else
					dc = new DataChild(value[i]);
					
				_childMap[dc.child] = dc;
				dc.addEventListener("change",dataChildChangeHandler,false,0,true);
				super.addChild(dc.child);			
			}
			invalidateOpCodes();
		}

		public function get dataChildren():Array
		{
			return _dataChildren;
		}
		public function dataChildChangeHandler(e:Event):void
		{
			dataChildren = dataChildren;
		}

		public function addDataChild(child:DisplayObject,left:* = undefined, top:* = undefined, right:* = undefined, bottom:* = undefined):void
		{
			var dc:DataChild = new DataChild(child,left,top,right,bottom);
			_childMap[child] = dc;
			_dataChildren.push(dc);
			dc.addEventListener("change",dataChildChangeHandler,false,0,true);
			addChild(child);
			invalidateOpCodes();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var dc:DataChild = new DataChild(child);
			_childMap[child] = dc;			
			dc.addEventListener("change",dataChildChangeHandler,false,0,true);
			invalidateOpCodes();
			return super.addChild(child);
		}
		override public function addChildAt(child:DisplayObject,index:int):DisplayObject
		{
			var dc:DataChild = new DataChild(child);
			_childMap[child] = dc;			
			dc.addEventListener("change",dataChildChangeHandler,false,0,true);
			invalidateOpCodes();
			return super.addChildAt(child,index);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);
			if(child in _childMap)
				delete _childMap[child];
			return child;
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			var child:DisplayObject = super.removeChildAt(index);
			if(child in _childMap)
				delete _childMap[child];
			return child;
		}



		public function updateDataChild(child:DisplayObject,values:Object):void
		{
			var dc:DataChild = _childMap[child];
			dc.left = values.left;
			dc.top = values.top;
			dc.right = values.right;
			dc.bottom = values.bottom;
			dc.horizontalCenter = values.horizontalCenter;
			dc.verticalCenter = values.verticalCenter;
			invalidateOpCodes();
		}

		[ArrayElementType("qs.charts.dataShapes.OpCode")]
		public function set opCodes(value:Array):void
		{		
			_opCodes = value;
			invalidateOpCodes();
		}
		public function get opCodes():Array
		{
			return _opCodes;
		}
		
		public function set includeInRanges(value:Boolean):void
		{
			if(_includeInRanges == value)
				return;
			_includeInRanges = value;
			dataChanged();
		}
		public function get includeInRanges():Boolean
		{
			return _includeInRanges;
		}

		public function clear():void
		{
			_opCodes = [];
			invalidateOpCodes();
		}




		public function beginFill(color:uint, alpha:Number = 1):void
		{
			pushOp(OpCode.BEGIN_FILL,{ color: color, alpha: alpha} );
		}
		public function beginBitmapFill(bitmap:BitmapData,x:* = undefined,y:* = undefined,matrix:Matrix = null,repeat:Boolean=true,smooth:Boolean=true):void
		{
			pushOp(OpCode.BEGIN_BITMAP_FILL,{ bitmap:bitmap, x:x, y:y, repeat:repeat, smooth:smooth, matrix:matrix});
		}
		public function lineStyle(thickness:Number, color:uint = 0, alpha:Number = 1.0, 
									pixelHinting:Boolean = false, scaleMode:String = "normal", 
									caps:String = null, joints:String = null, 
									miterLimit:Number = 3):void
		{
			borderWidth = thickness;
			pushOp(OpCode.LINE_STYLE,{ thickness: thickness, color: color, alpha: alpha, pixelHinting: pixelHinting, scaleMode: scaleMode,
										caps: caps, joints: joints, miterLimit: miterLimit} );
		}
		public function endFill():void
		{
			pushOp(OpCode.END_FILL);
		}
		public function moveTo(x:*,y:*):void
		{
			pushOp(OpCode.MOVE_TO,{ x: x, y:y, borderWidth: borderWidth});
		}
		public function lineTo(x:*,y:*):void
		{
			pushOp(OpCode.LINE_TO,{ x: x, y:y, borderWidth: borderWidth});
		}
		public function dashedLine(xFrom:*,yFrom:*,xTo:*,yTo:*,stroke:IStroke,pattern:Array):void
		{
			pushOp(OpCode.DASHED_LINE,{ xFrom: xFrom, yFrom: yFrom, xTo: xTo, yTo: yTo, stroke: stroke, pattern: pattern});
		}
		public function curveTo(controlX:*,controlY:*,anchorX:*, anchorY:*):void
		{
			pushOp(OpCode.CURVE_TO,{ controlX: controlX, controlY:controlY, anchorX:anchorX, anchorY:anchorY, borderWidth: borderWidth} );
		}
		public function drawRect(left:*,top:*,right:*,bottom:*):void
		{
			pushOp(OpCode.DRAW_RECT,{ left: left, top: top, right: right, bottom: bottom, borderWidth: borderWidth});
		}

		public function drawEllipse(left:*,top:*,right:*,bottom:*):void
		{
			pushOp(OpCode.DRAW_ELLIPSE,{ left: left, top: top, right: right, bottom: bottom, borderWidth: borderWidth});
		}

		public function drawRoundedRect(left:*,top:*,right:*,bottom:*,cornerRadius:Number):void
		{
			pushOp(OpCode.DRAW_ROUNDRECT,{ left: left, top: top, right: right, bottom: bottom, 
										borderWidth: borderWidth,
										cornerRadius: cornerRadius});
		}

		private function invalidateOpCodes():void
		{
			_dataCacheDirty = true;
			dataChanged();
			invalidateDisplayList();
		}
		private function pushOp(code:int, params:Object = null):OpCode
		{
			var op:OpCode = new OpCode(this,code,params);
			_opCodes.push(op);
			invalidateOpCodes();
			return op;
		}

		// our main drawing routine.
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			var i:int;
			
			// first, make sure we have valid pixel values.

			updateMapping();
			var updated:Boolean = updateTransform();
			
			if(updated)
			{
				var g:Graphics = graphics;
				
				g.clear();
				for(i = 0;i<_opCodes.length;i++)
				{
					_opCodes[i].render(this,_dataCache);
				}
				positionChildren();
			}
		}

		public function mapChildren():void
		{
			var width:Number;
			var height:Number;
			for(var aChild:* in _childMap)
			{
				var dc:DataChild = _childMap[aChild];
				if(dc.horizontalCenter != undefined)
				{
					width = widthFor(dc.child);
					split(dc.horizontalCenter)
					_dataCache.storeX(_data,width/2 - _offset,width/2 + _offset);
				}
				else if(dc.right == undefined)
				{
					split(dc.left);
					_dataCache.storeX(_data,- _offset,widthFor(dc.child) + _offset);
				}
				else if (dc.left == undefined)				
				{
					split(dc.right);
					_dataCache.storeX(_data,widthFor(dc.child) - _offset,_offset);
				}	
				else
				{
					split(dc.left);
					_dataCache.storeX(_data,-_offset,_offset);
					split(dc.right);
					_dataCache.storeX(_data,-_offset,_offset);
				}

				if(dc.verticalCenter != undefined)
				{
					height = heightFor(dc.child);
					split(dc.verticalCenter);
					_dataCache.storeY(_data,height/2 - _offset,height/2 + _offset);
				}
				else if(dc.bottom== undefined)
				{
					split(dc.top);
					_dataCache.storeY(_data,- _offset,heightFor(dc.child) + _offset);
				}
				else if (dc.top == undefined)				
				{
					split(dc.bottom);
					_dataCache.storeY(_data,heightFor(dc.child) - _offset,_offset);
				}
				else
				{
					split(dc.top);
					_dataCache.storeY(_data,-_offset,_offset);
					split(dc.bottom);
					_dataCache.storeY(_data,-_offset,_offset);
				}
			}
		}
		private function widthFor(child:DisplayObject):Number
		{
			return 	(child is IUIComponent)? IUIComponent(child).getExplicitOrMeasuredWidth() + 2:
					(child is IFlexDisplayObject)? IFlexDisplayObject(child).measuredWidth + 2:
					child.width; 
		}

		private function heightFor(child:DisplayObject):Number
		{
			return 	(child is IUIComponent)? IUIComponent(child).getExplicitOrMeasuredHeight() + 2:
					(child is IFlexDisplayObject)? IFlexDisplayObject(child).measuredHeight + 2:
					child.height; 
		}
		
		public function positionChildren():void
		{
			for(var aChild:* in _childMap)
			{
				var dc:DataChild = _childMap[aChild];
				var left:Number;
				var right:Number;
				var top:Number;
				var bottom:Number;
				var hCenter:Number;
				var vCenter:Number;
				var width:Number;
				var height:Number;
				
				if(dc.horizontalCenter != undefined)
				{
					hCenter = _dataCache.x(data(dc.horizontalCenter)) + offset(dc.horizontalCenter);
					width = widthFor(dc.child);
					left = hCenter - width/2;
					right = hCenter + width/2;		
				}
				else if(dc.right == undefined)
				{
					left = _dataCache.x(data(dc.left)) + offset(dc.left);
					right = left + widthFor(dc.child);
				}
				else if (dc.left == undefined)				
				{
					right = _dataCache.x(data(dc.right) ) + offset(dc.right);
					left = right - widthFor(dc.child);
				}
				else
				{
					left = _dataCache.x(data(dc.left)) + offset(dc.left);
					right = _dataCache.x(data(dc.right)) + offset(dc.right);
				}
				
				if(dc.verticalCenter != undefined)
				{
					vCenter = _dataCache.y(data(dc.verticalCenter)) + offset(dc.verticalCenter);
					height = heightFor(dc.child);
					top = vCenter - height/2;
					bottom= vCenter + height/2;		
				}
				else if(dc.bottom == undefined)
				{
					top = _dataCache.y(data(dc.top)) + offset(dc.top);
					bottom = top + heightFor(dc.child);
				}
				else if (dc.top == undefined)				
				{
					bottom = _dataCache.y(data(dc.bottom)) + offset(dc.bottom);
					top = bottom - heightFor(dc.child);
				}
				else
				{
					top = _dataCache.y(data(dc.top)) + offset(dc.top);
					bottom = _dataCache.y(data(dc.bottom)) + offset(dc.bottom);
				}
				if(dc.child is IFlexDisplayObject)
				{
					IFlexDisplayObject(dc.child).setActualSize(right-left,bottom-top);
					IFlexDisplayObject(dc.child).move(left, top);
				}
				else
				{
					dc.child.width = right - left;
					dc.child.height = bottom - top;
					dc.child.x = left ;
					dc.child.y = top;
				}
			}
		}

		// takes our data values and converts them into pixel values. Note that this routine could be a little bit
		// optimizied.
		private function updateMapping():void
		{
			if(_dataCacheDirty)
			{
				if (_traceEventHandlers)
					_logger.debug("updateMapping resetting _dataCache of " + this.id + "(" + DebugUtils.getObjectMemoryHash(this) + ")");

				_dataCache = new DataCache();
				var i:int;
				var key:*;
				var record:*;
				var value:*;
				var boundedValue:BoundedValue;

				for(i=0;i<_opCodes.length;i++)
				{
					_opCodes[i].collectValues(_dataCache);
				}

				mapChildren();
				
				_dataCache.xCache = [];
				_dataCache.yCache = [];
				_hDataDesc.min = Number.MAX_VALUE;
				_hDataDesc.max = Number.MIN_VALUE;
				_vDataDesc.min = Number.MAX_VALUE;
				_vDataDesc.max = Number.MIN_VALUE;
				
				for(key in _dataCache.xMap)
				{
					value = _dataCache.xMap[key];
					_dataCache.xCache.push( { value: value } );
					_hDataDesc.min = Math.min(_hDataDesc.min,value);
					_hDataDesc.max = Math.max(_hDataDesc.max,value);
				}
				for(key in _dataCache.yMap)
				{
					value = _dataCache.yMap[key];
					_dataCache.yCache.push( { value: value } );
					_vDataDesc.min = Math.min(_vDataDesc.min,value);
					_vDataDesc.max = Math.max(_vDataDesc.max,value);
				}
				_mappingDirty = true;
				_dataCacheDirty = false;
			}
			if(_mappingDirty)
			{
				dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).mapCache(_dataCache.yCache,"value","mappedValue",true);
				dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).mapCache(_dataCache.xCache,"value","mappedValue",true);
				_transformDirty = true;

				var boundedValues:Array = [];

				for(i = 0;i<_dataCache.xCache.length;i++)
				{
					value = _dataCache.xCache[i];
					boundedValue = _dataCache.xBoundedValues[value.value];
					if (boundedValue != null)
					{
						boundedValue.value = value.mappedValue;
						boundedValues.push(boundedValue);
					}
				}
				if(boundedValues.length > 0)
				{
					_hDataDesc.boundedValues = boundedValues;
					boundedValues = [];
				}
				for(i=0;i<_dataCache.yCache.length;i++)
				{
					value = _dataCache.yCache[i];
					boundedValue = _dataCache.yBoundedValues[value.value];
					if (boundedValue != null)
					{
						boundedValue.value = value.mappedValue;
						boundedValues.push(boundedValue);
					}
				}
				if(boundedValues.length > 0)
				{
					_vDataDesc.boundedValues = boundedValues;
				}

				_mappingDirty = false;
			}
		}
		
		private function updateTransform():Boolean
		{
			var i:int;
			var record:Object;
			var updated:Boolean = false;
			if(_transformDirty == false)
			{
				if(unscaledHeight != _oldUW || unscaledWidth != _oldUW)
				{
					_transformDirty = true;
					_oldUW = unscaledWidth;
					_oldUH = unscaledHeight;
				}
			}

			if(_transformDirty)
			{
				updated = true;
				if (_traceEventHandlers)
					_logger.debug("updateTransform " + describeCache("xCache"));

				var repeatCount:int = 0;
				var dataCacheChanged:Boolean;
				do {
					var oldDataCache:DataCache = _dataCache;
					dataTransform.transformCache(_dataCache.xCache, "mappedValue", "pixelValue", null, null);
					dataTransform.transformCache(_dataCache.yCache, null, null, "mappedValue", "pixelValue");
					dataCacheChanged = (_dataCache != oldDataCache);
				} while (dataCacheChanged && repeatCount < 2);

				if (dataCacheChanged)
				{
					_logger.warn("updateTransform will fail because _dataCache changed more than once " + describeCache("xCache"));
				}

				for (i = 0; i < _dataCache.xCache.length; i++)
				{
					record = _dataCache.xCache[i];
					if (record.hasOwnProperty("pixelValue"))
					{
						_dataCache.xMap[record.value] = record.pixelValue;
					}
					else
					{
						_logger.warn("updateTransform warning: transformCache failed " + describeCache("xCache"));
						updated = false;
						break;
					}
				}
				for (i = 0; i < _dataCache.yCache.length; i++)
				{
					record = _dataCache.yCache[i];
					if (record.hasOwnProperty("pixelValue"))
					{
						_dataCache.yMap[record.value] = record.pixelValue;
					}
					else
					{
						_logger.warn("updateTransform warning: transformCache failed " + describeCache("yCache"));
						updated = false;
						break;
					}
				}

				_dataCache.xMap[Edge.LEFT] = 0;
				_dataCache.xMap[Edge.RIGHT] = unscaledWidth;
				_dataCache.yMap[Edge.TOP] = 0;
				_dataCache.yMap[Edge.BOTTOM] = unscaledHeight;

				if (updated)
				{
					_transformDirty = false;
					if (_traceEventHandlers)
						_logger.debug("updateTransform transformCache succeeded " + describeCache("xCache"));
				}
			}
			return updated;
		}

		private function describeCache(cacheProperty:String):String
		{
			var ancestor:UIComponent = getAncestor(5);
			var cacheItem:Object = _dataCache[cacheProperty][0];
			//  + " " + ObjectUtil.toString(cacheItem)
			return "for _dataCache(" + DebugUtils.getObjectMemoryHash(_dataCache) + ")." + cacheProperty + "(" + DebugUtils.getObjectMemoryHash(_dataCache[cacheProperty]) + ") of " + this.id + "(" + DebugUtils.getObjectMemoryHash(this) + ") of " + (ancestor ? ancestor.id : "(unknown)") + " with " + _dataCache[cacheProperty].length + " " + cacheProperty + " item(s)" + (cacheItem ? " _dataCache." + cacheProperty + "[0] " + DebugUtils.getObjectMemoryHash(cacheItem) : "");
		}

		private function getAncestor(levels:int):UIComponent
		{
			var ancestor:DisplayObject = this;
			for (var i:int; i < levels && ancestor != null; i++)
			{
				ancestor = ancestor.parent;
			}
			return ancestor as UIComponent;
		}

		override public function describeData(dimension:String,
											  requiredFields:uint):Array
		{
			updateMapping();
			var result:Array = [];
	
			if(_includeInRanges)
			{
				if (dimension == CartesianTransform.VERTICAL_AXIS)
				{
					if(_dataCache.xCache.length)
						result.push(_vDataDesc);
				}
				else if (dimension == CartesianTransform.HORIZONTAL_AXIS)
				{
					if(_dataCache.yCache.length)
						result.push(_hDataDesc);
				}
			}
	
			return result;	
		}
		
		// this function is called by the charting package when the axes that affect this element change their mapping some how.
		// that means we need to call the mapCache function again to get new mappings.	
		override public function mappingChanged():void
		{
			_mappingDirty = true;
			invalidateDisplayList();
		}		  

		private var _data:*;
		private var _offset:Number;
		private function split(v:*):void
		{
			if(v is Array)
			{
				_data = v[0];
				_offset = v[1];
				if(isNaN(_offset))
					_offset = 0;
			}
			else
			{
				_data = v;
				_offset = 0;
			}
		}
		private function data(v:*):*
		{
			if(v is Array)
				return v[0];
			else
				return v;
		}
		private function offset(v:*):Number
		{
			if(v is Array)
				return v[1];
			else
				return 0;
		}
	}		
}
