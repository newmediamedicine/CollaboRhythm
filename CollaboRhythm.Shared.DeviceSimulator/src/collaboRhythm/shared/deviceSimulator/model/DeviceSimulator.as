package collaboRhythm.shared.deviceSimulator.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.DeviceGatewayConstants;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	import flash.system.Capabilities;

	import spark.components.ViewMenuItem;

	[Bindable]
	public class DeviceSimulator
	{
		private static const FIVE_MINUTES:int = 1000 * 60 * 5;

//		protected var _dataInputModel:ForaD40bHealthActionInputModelCollection;
		private var _currentDateSource:ICurrentDateSource;
		private var _viewMenuItems:Array;
		private var _previousInputDateValue:Number;
		private var _nextInputDateValue:Number;

		public function DeviceSimulator()
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			updatePreviousNextDates(_currentDateSource.now());
		}

		private function simulateDevice3MenuItem_clickHandler(event:MouseEvent):void
		{
			simulateDeviceBatchTransferBegin();
			NativeApplication.nativeApplication.dispatchEvent(new InvokeEvent(InvokeEvent.INVOKE, false, false, null,
					["collaborhythm://collaborhythm?deviceMeasuredDate=2012-10-19T23%3A15%3A00-04%3A00&bloodGlucose=181&equipmentName=FORA%20D40b&correctedMeasuredDate=2012-10-19T22%3A16%3A40-04%3A00&healthActionName=Blood%20Glucose&localTransmittedDate=2012-11-19T18%3A12%3A40-05%3A00&deviceTransmittedDate=2012-11-19T19%3A11%3A00-05%3A00&debug=0%20of%20181&healthActionType=Equipment&success=true&batchTransfer=data"]));
			simulateDeviceBatchTransferEnd();
		}

		private function simulateDeviceMenuItem_clickHandler(event:MouseEvent):void
		{

			var index:Number;
			index = 0;
			var numToSimulate:Number = 3;

			simulateDeviceBatchTransferBegin();
			for (var i:int = 0; i < numToSimulate; i++)
			{
				simulateDeviceOffsetFromNow(index / numToSimulate + i * (1.0 / numToSimulate), 1.0 / numToSimulate);
			}
			simulateDeviceBatchTransferEnd();
		}

		private function simulateDeviceHighMenuItem_clickHandler(event:MouseEvent):void
		{
			simulateSingleBloodGlucoseFromDevice(150);
		}

		private function simulateDeviceBloodPressureMenuItem_clickHandler(event:MouseEvent):void
		{
			simulateSingleBloodPressureFromDevice(193, 86, 68);
		}

		private function simulateDeviceLowMenuItem_clickHandler(event:MouseEvent):void
		{
			simulateSingleBloodGlucoseFromDevice(60);
		}

		private function simulateDeviceOffsetFromNow(daysBeforeNow:Number, maximumRandomDaysFraction:Number):void
		{
			var correctedMeasuredDate:Date = new Date(_currentDateSource.now().valueOf() -
					DateUtil.MILLISECONDS_IN_DAY * daysBeforeNow -
					(DateUtil.MILLISECONDS_IN_DAY * maximumRandomDaysFraction * Math.random()));
			var bloodGlucose:int = Math.round(70 + Math.random() * 200);
			simulateDeviceBloodGlucose(bloodGlucose, correctedMeasuredDate);
		}

		private function addMenuItem(label:String, listener:Function):void
		{
			var menuItem:ViewMenuItem = new ViewMenuItem();
			menuItem.label = label;
			menuItem.addEventListener(MouseEvent.CLICK, listener);
			viewMenuItems.push(menuItem)
		}

		private function simulateDeviceBloodGlucose(bloodGlucose:int, correctedMeasuredDate:Date):void
		{
			var urlVariables:URLVariables = new URLVariables();
			urlVariables[DeviceGatewayConstants.BLOOD_GLUCOSE_KEY] = bloodGlucose.toString();
			simulateDevice(urlVariables, correctedMeasuredDate, "Blood Glucose");
		}

		private function simulateDeviceBloodPressure(systolic:int, diastolic:int, heartRate:int,
													 correctedMeasuredDate:Date):void
		{
			var urlVariables:URLVariables = new URLVariables();
			urlVariables[DeviceGatewayConstants.SYSTOLIC_KEY] = systolic.toString();
			urlVariables[DeviceGatewayConstants.DIASTOLIC_KEY] = diastolic.toString();
			urlVariables[DeviceGatewayConstants.HEARTRATE_KEY] = heartRate.toString();
			simulateDevice(urlVariables, correctedMeasuredDate, "Blood Pressure");
		}

		private function simulateDeviceBatchTransferBegin():void
		{
			simulateDeviceBatchTransfer(HealthActionInputControllerBase.BATCH_TRANSFER_ACTION_BEGIN, "Blood Glucose");
			simulateDeviceBatchTransfer(HealthActionInputControllerBase.BATCH_TRANSFER_ACTION_BEGIN, "Blood Pressure");
		}

		private function simulateDeviceBatchTransferEnd():void
		{
			simulateDeviceBatchTransfer(HealthActionInputControllerBase.BATCH_TRANSFER_ACTION_END, "Blood Glucose");
			simulateDeviceBatchTransfer(HealthActionInputControllerBase.BATCH_TRANSFER_ACTION_END, "Blood Pressure");
		}

		private function simulateDeviceBatchTransfer(batchTransfer:String, healthActionName:String):void
		{
			NativeApplication.nativeApplication.dispatchEvent(new InvokeEvent(InvokeEvent.INVOKE, false, false, null,
					["collaborhythm://healthActionType=Equipment&healthActionName=" + healthActionName +
							"&equipmentName=FORA D40b&success=true&" +
							HealthActionInputControllerBase.BATCH_TRANSFER_URL_VARIABLE +
							"=" +
							batchTransfer]));
		}

		public function simulateSingleBloodGlucoseFromDevice(bloodGlucose:int):void
		{
			var dateValue:Number = previousInputDateValue;
			if (!isNaN(dateValue))
			{
				simulateDeviceBatchTransferBegin();
				simulateDeviceBloodGlucose(bloodGlucose, nextInputDate);
				simulateDeviceBatchTransferEnd();
			}
		}

		public function get nextInputDate():Date
		{
			return new Date(_nextInputDateValue);
		}

		public function simulateSingleBloodPressureFromDevice(systolic:int, diastolic:int, heartRate:int):void
		{
			var dateValue:Number = previousInputDateValue;
			if (!isNaN(dateValue))
			{
				simulateDeviceBatchTransferBegin();
				simulateDeviceBloodPressure(systolic, diastolic, heartRate, nextInputDate);
				simulateDeviceBatchTransferEnd();
			}
		}

		private function simulateDevice(urlVariables:URLVariables, correctedMeasuredDate:Date,
										healthActionName:String):void
		{
			urlVariables[DeviceGatewayConstants.HEALTH_ACTION_TYPE_KEY] = DeviceGatewayConstants.EQUIPMENT_HEALTH_ACTION_TYPE;
			urlVariables[DeviceGatewayConstants.HEALTH_ACTION_NAME_KEY] = healthActionName;
			urlVariables[DeviceGatewayConstants.EQUIPMENT_NAME_KEY] = "FORA D40b";
			urlVariables[DeviceGatewayConstants.SUCCESS_KEY] = "true";
			urlVariables[DeviceGatewayConstants.CORRECTED_MEASURED_DATE_KEY] = DateUtil.format(correctedMeasuredDate,
					false);
			urlVariables[DeviceGatewayConstants.DEVICE_MEASURED_DATE_KEY] = DateUtil.format(correctedMeasuredDate,
					false);
			urlVariables[DeviceGatewayConstants.LOCAL_TRANSMITTED_DATE_KEY] = DateUtil.format(_currentDateSource.now(),
					false);
			urlVariables[DeviceGatewayConstants.DEVICE_TRANSMITTED_DATE_KEY] = DateUtil.format(_currentDateSource.now(),
					false);
			urlVariables[DeviceGatewayConstants.BATCH_TRANSFER_KEY] = "data";

			var uriString:String = "collaborhythm://loadData?" + urlVariables.toString();
			NativeApplication.nativeApplication.dispatchEvent(new InvokeEvent(InvokeEvent.INVOKE, false, false, null,
					[uriString]));
			updatePreviousNextDates(correctedMeasuredDate);
		}

		private function updatePreviousNextDates(correctedMeasuredDate:Date):void
		{
			_previousInputDateValue = correctedMeasuredDate.valueOf();
			_nextInputDateValue = _previousInputDateValue - FIVE_MINUTES;
		}

		public function get previousInputDateValue():Number
		{
			return _previousInputDateValue;
		}

		private function addMenuItems():void
		{

			if (viewMenuItems)
			{
				// TODO: perhaps we should also include these menu items when debug tools is enabled or allow independent control via a new setting
				var isDebugger:Boolean = Capabilities.isDebugger;
				var playerType:String = Capabilities.playerType;

				if (playerType == "Desktop" && isDebugger)
				{
					addMenuItem("Sim 3 Random Glucose Measurements", simulateDeviceMenuItem_clickHandler);
					addMenuItem("Sim high glucose measurement", simulateDeviceHighMenuItem_clickHandler);
					addMenuItem("Sim low glucose measurement", simulateDeviceLowMenuItem_clickHandler);
					addMenuItem("Sim duplicate glucose measurement", simulateDevice3MenuItem_clickHandler);
					addMenuItem("Sim BP measurement", simulateDeviceBloodPressureMenuItem_clickHandler);
				}
			}
		}

		public function get viewMenuItems():Array
		{
			return _viewMenuItems;
		}

		public function get defaultBloodGlucose():int
		{
			return Math.round(80 + Math.random() * 200);
		}

		public function get defaultSystolic():int
		{
			return Math.round(90 + Math.random() * 60);
		}

		public function get defaultDiastolic():int
		{
			return Math.round(60 + Math.random() * 30);
		}

		public function get defaultHeartRate():int
		{
			return Math.round(50 + Math.random() * 100);
		}

		public function set nextInputDate(nextInputDate:Date):void
		{
			_nextInputDateValue = nextInputDate.valueOf();
		}

		public function resetNextInputDate():void
		{
			nextInputDate = _currentDateSource.now();
		}
	}
}
