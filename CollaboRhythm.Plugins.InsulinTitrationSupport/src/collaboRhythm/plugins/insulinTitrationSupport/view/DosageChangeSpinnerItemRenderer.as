package collaboRhythm.plugins.insulinTitrationSupport.view
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.DosageChangeValueProxy;

	import flash.events.Event;

	import mx.core.IVisualElement;
	import mx.events.FlexEvent;

	import spark.components.SpinnerListItemRenderer;
	import spark.core.SpriteVisualElement;
	import spark.filters.GlowFilter;

	public class DosageChangeSpinnerItemRenderer extends SpinnerListItemRenderer
	{
		public static const PATIENT_LATEST_DECISION_HIGHLIGHT_COLOR:int = 0x33B5E5;
		public static const CLINICIAN_LATEST_DECISION_HIGHLIGHT_COLOR:int = 0x9C69AD;
		private var _decisionClinicianNew:DecisionClinicianNew;
		private var _decisionClinicianAgree:DecisionClinicianAgree;
		private var _decisionPatientNew:DecisionPatientNew;
		private var _decisionPatientAgree:DecisionPatientAgree;
		private var pendingUpdateIcons:Boolean;
//		public static const CLINICIAN_LATEST_DECISION_HIGHLIGHT_COLOR:int = 0xBB81D3;

		public function DosageChangeSpinnerItemRenderer()
		{
		}

		override protected function createChildren():void
		{
			super.createChildren();

			_decisionClinicianNew = new DecisionClinicianNew();
			initializeIcon(_decisionClinicianNew);
			_decisionClinicianAgree = new DecisionClinicianAgree();
			initializeIcon(_decisionClinicianAgree);
			_decisionPatientNew = new DecisionPatientNew();
			initializeIcon(_decisionPatientNew);
			_decisionPatientAgree = new DecisionPatientAgree();
			initializeIcon(_decisionPatientAgree);

			addEventListener(Event.RESIZE, resizeHandler)
		}

		public function initializeIcon(icon:SpriteVisualElement):void
		{
			icon.width = icon.height = 26;
//			icon.verticalCenter = 0;
			updateIcon(icon);
			icon.visible = false;
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.color = 0xFFFFFF;
			glowFilter.alpha = 0.7;
			glowFilter.blurX = icon.width / 8;
			glowFilter.blurY = icon.width / 8;
			glowFilter.strength = icon.width / 8;

			icon.filters = [glowFilter];
			addChildAt(icon, 0);
		}

		[Bindable(style="true")]
		override public function getStyle(styleProp:String):*
		{
			if (styleProp == "fontSize" && label == InsulinTitrationDecisionPanel.NO_CHANGE_LABEL)
				return super.getStyle(styleProp) - 3;
			return super.getStyle(styleProp);
		}

		override public function set label(value:String):void
		{
			super.label = value;
			if (labelDisplay)
				labelDisplay.setStyle("fontSize", getStyle("fontSize"));

			if (label == InsulinTitrationDecisionPanel.NO_CHANGE_LABEL)
			{
				setStyle("paddingLeft", 8);
			}
			else
			{
				setStyle("paddingLeft", 16);
			}
			setStyle("paddingRight", 2);
			setStyle("textAlign", "right");
		}

		override public function set data(value:Object):void
		{
			super.data = value;
			data.addEventListener(FlexEvent.UPDATE_COMPLETE, data_updateCompleteHandler);
			updateIcons();
		}

		public function updateIcons():void
		{
			_decisionClinicianAgree.visible = false;
			_decisionPatientAgree.visible = false;
			_decisionClinicianNew.visible = false;
			_decisionPatientNew.visible = false;

			if (valueProxy.isLatestAgreementDosageChange)
			{
				_decisionPatientAgree.visible = valueProxy.isLatestDecisionByPatient;
				_decisionClinicianAgree.visible = !_decisionPatientAgree.visible;
			}
			else if (valueProxy.isPatientLatestDosageChange)
			{
				_decisionPatientNew.visible = true;
			}
			else if (valueProxy.isClinicianLatestDosageChange)
			{
				_decisionClinicianNew.visible = true;
			}

			drawBackground(unscaledWidth, unscaledHeight);
		}

		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			graphics.clear();
			if (valueProxy.isLatestAgreementDosageChange)
			{
				highlight(unscaledWidth, unscaledHeight, valueProxy.isLatestDecisionByPatient ? PATIENT_LATEST_DECISION_HIGHLIGHT_COLOR : CLINICIAN_LATEST_DECISION_HIGHLIGHT_COLOR);
			}
			else if (valueProxy.isPatientLatestDosageChange)
			{
				highlight(unscaledWidth, unscaledHeight, PATIENT_LATEST_DECISION_HIGHLIGHT_COLOR);
			}
			else if (valueProxy.isClinicianLatestDosageChange)
			{
				highlight(unscaledWidth, unscaledHeight, CLINICIAN_LATEST_DECISION_HIGHLIGHT_COLOR);
			}
			else
			{
				super.drawBackground(unscaledWidth, unscaledHeight);
			}
		}

		public function highlight(unscaledWidth:Number, unscaledHeight:Number, color:int):void
		{
			// draw a highlighted background
			graphics.beginFill(color, 0.5);
			graphics.lineStyle();
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
		}

		private function get valueProxy():DosageChangeValueProxy
		{
			return data as DosageChangeValueProxy;
		}

		private function resizeHandler(event:Event):void
		{
			updateIcon(_decisionClinicianNew);
			updateIcon(_decisionClinicianAgree);
			updateIcon(_decisionPatientNew);
			updateIcon(_decisionPatientAgree);
		}

		private function updateIcon(icon:SpriteVisualElement):void
		{
			icon.y = (this.height - icon.height) / 2;
		}

		private function data_updateCompleteHandler(event:FlexEvent):void
		{
			pendingUpdateIcons = true;
			invalidateProperties();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if (pendingUpdateIcons)
			{
				updateIcons();
				pendingUpdateIcons = false;
			}
		}
	}
}
