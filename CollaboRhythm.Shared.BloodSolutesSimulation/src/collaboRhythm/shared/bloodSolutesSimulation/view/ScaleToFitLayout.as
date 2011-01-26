package collaboRhythm.shared.bloodSolutesSimulation.view
{
	import flash.geom.PerspectiveProjection;
	
	import mx.core.ILayoutElement;
	import mx.core.UIComponent;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class ScaleToFitLayout extends LayoutBase
	{
		private var _unscaledWidth:Number = 100;
		private var _aspectRatioMin:Number = 0.5;
		private var _aspectRatioMax:Number = 1.5;
		
		public function ScaleToFitLayout()
		{
			super();
		}
		
		public function get unscaledWidth():Number
		{
			return _unscaledWidth;
		}

		public function set unscaledWidth(value:Number):void
		{
			_unscaledWidth = value;
			invalidateIfInitialized();
		}
		
		private function invalidateIfInitialized():void
		{
			var layoutTarget:GroupBase = target;
			if (layoutTarget)
				layoutTarget.invalidateDisplayList();
		}

		public function get aspectRatioMin():Number
		{
			return _aspectRatioMin;
		}

		public function set aspectRatioMin(value:Number):void
		{
			_aspectRatioMin = value;
			invalidateIfInitialized();
		}

		public function get aspectRatioMax():Number
		{
			return _aspectRatioMax;
		}

		public function set aspectRatioMax(value:Number):void
		{
			_aspectRatioMax = value;
			invalidateIfInitialized();
		}

		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);

			var layoutTarget:GroupBase = target;
			if (layoutTarget)
			{
				trace("ScaleToFitLayout.updateDisplayList w, h", w, h, "width, height", layoutTarget.width, layoutTarget.height);
				var count:uint = target.numElements;
				
				for (var i:int = 0; i < count; i++)
				{
					var layoutElement : ILayoutElement =
						useVirtualLayout ? target.getVirtualElementAt( i ) :
						target.getElementAt( i );
					
					if (w > 0 && h > 0)
					{
						// constrain the aspect ratio by changing the percentWidth/percentHeight when appropriate
						var aspectRatio:Number = w / h;
						var percentWidth:Number;
						var percentHeight:Number;
						
						if (aspectRatio > aspectRatioMax)
						{
							percentHeight = 100;
							percentWidth = 100 * aspectRatioMax / aspectRatio;
						}
						else if (aspectRatio < aspectRatioMin)
						{
							percentHeight = 100 * aspectRatio / aspectRatioMin;
							percentWidth = 100;
						}
						else
						{
							percentHeight = 100;
							percentWidth = 100;
						}
						
						var component:UIComponent = layoutElement as UIComponent;
						if (component)
						{
							component.scaleX = percentWidth / 100 * w / unscaledWidth;
							component.scaleY = component.scaleX;
						}
						
						layoutElement.setLayoutBoundsSize(
							w * percentWidth / 100,
							h * percentHeight / 100); 
						
						// center the element horizontally and vertically
						layoutElement.setLayoutBoundsPosition(
							w * (100 - percentWidth) / 100 / 2,
							h * (100 - percentHeight) / 100 / 2);
					}
				}
			}
		}
	}
}