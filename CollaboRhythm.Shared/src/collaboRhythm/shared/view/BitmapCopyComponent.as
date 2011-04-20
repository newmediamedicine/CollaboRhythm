/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.view
{
	import flash.display.BitmapData;

	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;

	public class BitmapCopyComponent extends UIComponent
	{
		private var _sourceComponent:UIComponent;

		public function BitmapCopyComponent()
		{
		}

		public function get sourceComponent():UIComponent
		{
			return _sourceComponent;
		}

		public function set sourceComponent(value:UIComponent):void
		{
			_sourceComponent = value;
		}

		public function copyComponent(component:UIComponent):void
		{
//			component.validateNow();
			var bitmapData:BitmapData = ImageSnapshot.captureBitmapData(component);
			fillWithBitmap(bitmapData, component);
		}

		public function fillWithBitmap(bitmapData:BitmapData, component:UIComponent):void
		{
			sourceComponent = component;
			this.graphics.lineStyle(0,0,0);
			if (bitmapData)
			{
				this.graphics.beginBitmapFill(bitmapData, null, false, true);
				this.graphics.drawRect(0, 0, bitmapData.width, bitmapData.height);
			}
		}

		public static function createFromBitmap(bitmapData:BitmapData, component:UIComponent):BitmapCopyComponent
		{
			var c:BitmapCopyComponent = new BitmapCopyComponent();
			c.fillWithBitmap(bitmapData, component);
			return c;
		}

		public static function createFromComponent(component:UIComponent):BitmapCopyComponent
		{
			var c:BitmapCopyComponent = new BitmapCopyComponent();
			c.copyComponent(component);
			return c;
		}

		public function finish():void
		{
			this.sourceComponent.visible = this.visible;
			if (sourceVisualElementContainer)
				sourceVisualElementContainer.removeElement(this);
			else
				sourceComponent.parent.removeChild(this);
			this.sourceComponent = null;
		}

		public function replaceSource():void
		{
			this.visible = sourceComponent.visible;
			if (sourceVisualElementContainer)
				sourceVisualElementContainer.addElement(this);
			else
				sourceComponent.parent.addChild(this);
			sourceComponent.visible = false;
		}

		private function get sourceVisualElementContainer():IVisualElementContainer
		{
			return sourceComponent.parent as IVisualElementContainer;
		}
	}
}
