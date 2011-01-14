package qs.charts.dataShapes
{
	import flash.display.Graphics;
	import qs.utils.GraphicsUtils;
	import flash.geom.Matrix;
	
	public class OpCode
	{
		public var canvas:DataDrawingCanvas;
		public var code:int;
		public var params:Object;
		
		public function OpCode(canvas:DataDrawingCanvas,code:int, params:Object = null ):void
		{
			this.canvas = canvas;
			this.code = code;
			this.params = (params == null)? {}:params;
		}
		
		public static const MOVE_TO:int = 		0;
		public static const LINE_TO:int = 		1;
		public static const BEGIN_FILL:int = 	2;
		public static const LINE_STYLE:int = 	3;
		public static const DRAW_ELLIPSE:int =	5;
		public static const DRAW_RECT:int = 	6;
		public static const DRAW_ROUNDRECT:int = 7;	
		public static const END_FILL:int = 		8;
		public static const CURVE_TO:int = 		9;
		public static const DRAW:int = 			10;
		public static const LINE_DASH:int = 	11;
		public static const BEGIN_BITMAP_FILL:int = 	12;
		public static const DASHED_LINE:int = 	13;

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
		
		public function collectValues(cache:DataCache):void
		{
			switch(code)
			{
				case BEGIN_BITMAP_FILL:
					split(params.x);
					if(_data != undefined)
						cache.storeX(_data,-_offset,_offset);
					split(params.y);
					if(_data != undefined)
						cache.storeY(_data,-_offset,_offset);
					break;
				case CURVE_TO:
					split(params.anchorX);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.anchorY);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.controlX);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.controlY);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					break;
				case DASHED_LINE:
					split(params.xFrom);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.yFrom);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.xTo);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.yTo);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					break;
				case MOVE_TO:
				case LINE_TO:
					split(params.x);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.y);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					break;
				case CURVE_TO:
					cache.storeX(params.x,Math.max(0,-params.xOffset+ params.borderWidth/2),
										  Math.max(0,params.xOffset + params.borderWidth/2));
					cache.storeY(params.y,Math.max(0,-params.yOffset+ params.borderWidth/2),
										  Math.max(0,params.yOffset + params.borderWidth/2));
					break;
				case DRAW_ELLIPSE:
					split(params.left);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.top);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.right);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.bottom);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					break;
				case DRAW_RECT:
					split(params.left);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.top);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.right);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.bottom);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					break;
				case DRAW_ROUNDRECT:
					split(params.left);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.top);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.right);
					cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					split(params.bottom);
					cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
					break;
			}
		}
		public function render(target:DataDrawingCanvas,cache:DataCache):void
		{
			var left:Number;
			var top:Number;
			var right:Number;
			var bottom:Number;
			
			var g:Graphics = target.graphics;

			switch(code)
			{
				case BEGIN_FILL:
					g.beginFill(params.color,params.alpha);
					break;
				case BEGIN_BITMAP_FILL:
					var m:Matrix;
					if(params.matrix == null)
						m = new Matrix();
					else
						m = params.matrix.clone();
						
					var d:* = data(params.x);
					if(d != undefined)
						m.tx = cache.x(d);
					m.tx  += offset(params.x);
					d = data(params.y);
					if(d != undefined)
						m.ty = cache.y(d);
					m.ty += offset(params.y);
					g.beginBitmapFill(params.bitmap,m,params.repeat,params.smooth);
					break;
				case END_FILL:
					g.endFill();
					break;
				case LINE_STYLE:
					g.lineStyle(params.thickness,params.color,params.alpha,params.pixleHinting,params.scaleMode,params.caps,params.joints,params.miterLimit);
					break;
				case MOVE_TO:
					g.moveTo(cache.x(data(params.x)) + offset(params.x), cache.y(data(params.y)) + offset(params.y));
					break;
				case LINE_TO:
					g.lineTo(cache.x(data(params.x)) + offset(params.x), cache.y(data(params.y)) + offset(params.y));
					break;
				case DASHED_LINE:
					GraphicsUtils.drawDashedLine(g,params.stroke,params.pattern,
						cache.x(data(params.xFrom)) + offset(params.xFrom),
						cache.y(data(params.yFrom)) + offset(params.yFrom),
						cache.x(data(params.xTo)) + offset(params.xTo),
						cache.y(data(params.yTo)) + offset(params.yTo));
					break;
				case CURVE_TO:
					g.curveTo(	cache.x(data(params.controlX)) + offset(params.controlX),
								cache.y(data(params.controlY)) + offset(params.controlY),
								cache.x(data(params.anchorX)) + offset(params.anchorX),
								cache.y(data(params.anchorY)) + offset(params.anchorY));
					break;
				case DRAW_ELLIPSE:
					left = cache.x(data(params.left)) + offset(params.left);
					top = cache.y(data(params.top)) + offset(params.top);
					right = cache.x(data(params.right)) + offset(params.right);
					bottom = cache.y(data(params.bottom)) + offset(params.bottom);

					g.drawEllipse(left, top, 
								right - left,bottom - top);
					break;
				case DRAW_RECT:
					left = cache.x(data(params.left)) + offset(params.left);
					top = cache.y(data(params.top)) + offset(params.top);
					right = cache.x(data(params.right)) + offset(params.right);
					bottom = cache.y(data(params.bottom)) + offset(params.bottom);
					g.drawRect(left, top, 
								right - left,bottom - top);
					break;
				case DRAW_ROUNDRECT:
					left = cache.x(data(params.left)) + offset(params.left);
					top = cache.y(data(params.top)) + offset(params.top);
					right = cache.x(data(params.right)) + offset(params.right);
					bottom = cache.y(data(params.bottom)) + offset(params.bottom);
					g.drawRoundRect(left, top, 
								right - left,bottom - top,params.cornerRadius,params.cornerRadius);
					break;
				
			}
		}
	}
}