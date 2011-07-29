package collaboRhythm.plugins.bloodPressure.view.simulation.levels.circulatorySystem
{

	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.IFocusManagerComponent;

	public class HypertensionCirculatorySystemSimulationView extends UIComponent implements IFocusManagerComponent
	{
		private static const CIRCULATORY_SYSTEM_SIMULATION_SWF:String = "http://www.mit.edu/~jom/temp/simulations/circulatorySystemSimulation.swf";

		private var _circulatorySystemSimulationLoader:Loader = new Loader();
		private var _circulatorySystemSimulationMovieClip:MovieClip;
		protected var _logger:ILogger;

		public function HypertensionCirculatorySystemSimulationView()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		override protected function createChildren():void
		{
			super.createChildren();

			this.addChild(_circulatorySystemSimulationLoader);
			_circulatorySystemSimulationLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, circulatorySystemSimulationLoader_completeHandler);
			_circulatorySystemSimulationLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, circulatorySystemSimulationLoader_ioErrorHandler)
			var urlRequest:URLRequest = new URLRequest(CIRCULATORY_SYSTEM_SIMULATION_SWF);
			_circulatorySystemSimulationLoader.load(urlRequest);
		}

		private function circulatorySystemSimulationLoader_completeHandler(event:Event):void
		{
			_circulatorySystemSimulationMovieClip = MovieClip(_circulatorySystemSimulationLoader.content);
		}

		private function circulatorySystemSimulationLoader_ioErrorHandler(event:Event):void
		{
			_logger.warn("circulatorySystemSimulator load FAILED");
		}

		public function set concentration(concentration:Number):void
		{
			if (_circulatorySystemSimulationMovieClip)
			{
				if (concentration < SimulationModel.HYDROCHLOROTHIAZIDE_GOAL)
				{
					_circulatorySystemSimulationMovieClip.current_preload = 3;
					_circulatorySystemSimulationMovieClip.current_damage = 2;
					_circulatorySystemSimulationMovieClip.update();
				}
				else
				{
					_circulatorySystemSimulationMovieClip.current_preload = 1;
					_circulatorySystemSimulationMovieClip.current_damage = 0;
					_circulatorySystemSimulationMovieClip.update();
				}
			}
		}

		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			// TODO: this event handler is currently not working; figure out why so that we can handle key events
			super.keyDownHandler(event);
			if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.P)
			{
				if (_circulatorySystemSimulationMovieClip)
				{
					_logger.info("Stopping simulation MovieClip");
					stopAll(_circulatorySystemSimulationMovieClip);
				}
			}
		}

		private function stopAll(displayObjectContainer:DisplayObjectContainer):void
		{
			var movieClip:MovieClip = displayObjectContainer as MovieClip;
			if (movieClip)
				movieClip.stop();

			for (var i:int = 0; i < displayObjectContainer.numChildren; i++)
			{
				var child:DisplayObject = displayObjectContainer.getChildAt(i);
				if (child is DisplayObjectContainer)
					stopAll(child as DisplayObjectContainer);
			}
		}

	}
}
