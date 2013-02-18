package collaboRhythm.shared.deviceSimulator.model
{
	import collaboRhythm.shared.deviceSimulator.view.DeviceSimulatorPopup;
	import collaboRhythm.shared.model.services.IViewModifier;

	import flash.events.MouseEvent;

	import mx.core.FlexGlobals;
	import mx.events.FlexMouseEvent;
	import mx.managers.PopUpManager;

	import spark.components.Application;
	import spark.components.View;
	import spark.components.ViewMenuItem;

	/**
	 * Adds the Device Simulator menu item to any view.
	 */
	public class DeviceSimulatorViewModifier implements IViewModifier
	{
		private var _deviceSimulator:DeviceSimulator;

		public function DeviceSimulatorViewModifier()
		{
		}

		public function modify(view:View):void
		{
			var deviceSimulatorMenuItem:ViewMenuItem = new ViewMenuItem();
			deviceSimulatorMenuItem.id = "deviceSimulatorMenuItem";

			for each (var item:ViewMenuItem in view.viewMenuItems)
			{
				if (item.id == deviceSimulatorMenuItem.id)
				{
					return;
				}
			}

			deviceSimulatorMenuItem.label = "Device Simulator";
			deviceSimulatorMenuItem.addEventListener(MouseEvent.CLICK, deviceSimulatorMenuItem_clickHandler);
			view.viewMenuItems.push(deviceSimulatorMenuItem)
		}

		private function deviceSimulatorMenuItem_clickHandler(event:MouseEvent):void
		{
			if (_deviceSimulator == null)
			{
				_deviceSimulator = new DeviceSimulator();
			}

			var deviceSimulatorPopup:DeviceSimulatorPopup = new DeviceSimulatorPopup();
			deviceSimulatorPopup.deviceSimulator = _deviceSimulator;

			var owner:Application = FlexGlobals.topLevelApplication as Application;
//			owner.addElement(deviceSimulatorPopup);
			deviceSimulatorPopup.width = owner.width;
			deviceSimulatorPopup.height = owner.height;
			deviceSimulatorPopup.open(owner, true);

			PopUpManager.centerPopUp(deviceSimulatorPopup);
			deviceSimulatorPopup.visible = true;
		}
	}
}
