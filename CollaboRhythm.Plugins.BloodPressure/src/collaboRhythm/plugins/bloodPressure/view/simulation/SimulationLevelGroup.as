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
package collaboRhythm.plugins.bloodPressure.view.simulation
{

	import collaboRhythm.plugins.bloodPressure.view.simulation.buttons.SimulationDetail;
	import collaboRhythm.plugins.bloodPressure.view.simulation.buttons.SimulationDetailButton;
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;

	import com.dncompute.graphics.GraphicsUtil;

	import flash.geom.Point;

	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	import spark.components.Group;

	[Event(name="backUpLevel",type="collaboRhythm.plugins.bloodPressure.view.simulation.SimulationLevelEvent")]
	[Event(name="drillDownLevel",type="collaboRhythm.plugins.bloodPressure.view.simulation.SimulationLevelEvent")]
	public class SimulationLevelGroup extends Group
	{
		private var _simulationModel:SimulationModel;
		private var _title:String;
		private var _breadcrumbContent:UIComponent;
		private var _details:Vector.<SimulationDetail>;
		public var arrowsGroup:Group;

		[Bindable]
		public function get simulationModel():SimulationModel
		{
			return _simulationModel;
		}

		public function set simulationModel(value:SimulationModel):void
		{
			_simulationModel = value;
		}

		public function initializeModel(simulationModel:SimulationModel):void
		{
			_simulationModel = simulationModel;
		}

		[Bindable]
		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		[Bindable]
		public function get breadcrumbContent():UIComponent
		{
			return _breadcrumbContent;
		}

		public function set breadcrumbContent(value:UIComponent):void
		{
			_breadcrumbContent = value;
		}

		public function get details():Vector.<SimulationDetail>
		{
			return _details;
		}

		public function set details(value:Vector.<SimulationDetail>):void
		{
			_details = value;
		}

		public function SimulationLevelGroup()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler)
		}

		protected function creationCompleteHandler(event:FlexEvent):void
		{
			drawArrows();
		}

		protected function drawArrows():void
		{
			arrowsGroup.graphics.clear();
			arrowsGroup.graphics.lineStyle(0, 0x000000);
			arrowsGroup.graphics.beginFill(0x000000);

			for each (var detail:SimulationDetail in details)
			{
				drawDetailArrow(detail.detailButton, detail.indicatedPoint);
			}
		}

		private function drawDetailArrow(button:SimulationDetailButton, endPoint:Point):void
		{
			GraphicsUtil.drawArrow(
					arrowsGroup.graphics,
					new Point(button.x, button.arrowTailY),
					endPoint,
					{shaftThickness:3, headWidth:30,headLength:26,
						shaftPosition:0, edgeControlPosition:0.5}
			);
		}

		private static const BUTTON_GAP:int = 20;

		protected function layoutDetailButtons(... rest):Number
		{
			var currentY:Number = this.height;

			for (var i:int = details.length - 1; i >= 0; i--)
			{
				var detail:SimulationDetail = details[i];
				var button:SimulationDetailButton = detail.detailButton;
				currentY -= button.height / 2 + button.bottomExpansion;
				currentY = Math.min(currentY, detail.indicatedPoint.y);
				button.arrowTailY = currentY;
				currentY -= button.height / 2 + BUTTON_GAP;
			}

			// If necessary, move buttons down so that first button is not off the top edge
			currentY = 0;
			for each (detail in details)
			{
				button = detail.detailButton;
				currentY += button.height / 2;
				currentY = Math.max(currentY, button.arrowTailY);
				button.arrowTailY = currentY;
				currentY += button.height / 2 + button.bottomExpansion + BUTTON_GAP;
			}
			
			var firstArrowTailY:Number = details[0].detailButton.arrowTailY;
			return firstArrowTailY;
		}
	}
}
