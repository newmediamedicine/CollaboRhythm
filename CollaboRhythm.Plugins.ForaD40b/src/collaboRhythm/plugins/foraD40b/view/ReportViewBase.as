package collaboRhythm.plugins.foraD40b.view
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bHealthActionInputController;
	import collaboRhythm.plugins.foraD40b.model.ForaD40bHealthActionInputModelBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import mx.binding.utils.BindingUtils;
	import mx.styles.CSSStyleDeclaration;

	import spark.components.HGroup;

	public class ReportViewBase extends HGroup
	{
		public static const SINGLE_VALUE_FONT_SIZE:Number = 110;
		public static const MULTIPLE_VALUES_FONT_SIZE:Number = 60;

		protected static const TEXT_INPUT_WIDTH:Number = 190;
		protected static const TEXT_INPUT_HEIGHT:Number = 130;

		protected var _dataInputController:ForaD40bHealthActionInputController;

		[Bindable]
		protected var _valueSizeScale:Number = 1;

		private var _propertiesChanged:Boolean;

		public function ReportViewBase()
		{
			super();
		}

		protected function reportForaD40bItemDataCollection_length_setterHandler(length:Number):void
		{
			var valueFontSize:Number = length > 1 ? MULTIPLE_VALUES_FONT_SIZE : SINGLE_VALUE_FONT_SIZE;
			var style:CSSStyleDeclaration = this.styleManager.getStyleDeclaration(".textInputText");
			if (style.getStyle("fontSize") != valueFontSize)
			{
				style.setStyle("fontSize", valueFontSize);
				this.styleManager.setStyleDeclaration(".textInputText", style, true);
			}

			_valueSizeScale = valueFontSize / SINGLE_VALUE_FONT_SIZE;
		}

		protected function dataInputModel_isFromDevice_setterHandler(value:Boolean):void
		{
			propertiesChanged = true;
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			if (propertiesChanged)
			{
				updateChildren();
				propertiesChanged = false;
			}
		}

		private function updateState():void
		{
			if (dataInputModelBase)
			{
				if (dataInputModelBase.scheduleItemOccurrence &&
						dataInputModelBase.scheduleItemOccurrence.adherenceItem &&
						dataInputModelBase.currentView == ForaD40bHealthActionInputView)
				{
					currentState = "review";
				}
				else
				{
					if (dataInputModelBase.isFromDevice)
						currentState = "reportDevice";
					else
						currentState = "reportManual";
				}
			}
		}

		public function get propertiesChanged():Boolean
		{
			return _propertiesChanged;
		}

		public function set propertiesChanged(value:Boolean):void
		{
			_propertiesChanged = value;
			if (propertiesChanged)
			{
				updateState();
				invalidateProperties();
			}
		}

		protected function initializeListeners():void
		{
			BindingUtils.bindSetter(reportForaD40bItemDataCollection_length_setterHandler,
					dataInputModelBase.foraD40bHealthActionInputModelCollection.reportForaD40bItemDataCollection,
					"length", false, true);
			BindingUtils.bindSetter(dataInputModel_isFromDevice_setterHandler,
					dataInputModelBase,
					"isFromDevice", false, true);
			propertiesChanged = true;
		}

		public function get dataInputModelBase():ForaD40bHealthActionInputModelBase
		{
			return null;
		}

		public function updateChildren():void
		{
		}
	}
}
