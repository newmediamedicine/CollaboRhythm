package resources.physics
{
	import spark.effects.easing.IEaser;
	
	public class AccelerationEaser implements IEaser
	{
		public static const dpi:Number = 72; // approximate
		private static const metersToPixels:Number = 100 / 2.54 * dpi;
		private static const secondsToMilliseconds:Number = 1000 * 1000;
		public static const gravity:Number = 9.8 * metersToPixels / secondsToMilliseconds;
		
		private var _delta:Number;
		private var _acceleration:Number;
		private var _v0:Number;
		private var _duration:Number;
		
		public function AccelerationEaser(delta:Number, acceleration:Number, v0:Number=0)
		{
			_delta = delta;
			_acceleration = acceleration;
			_v0 = v0;
			
			var discriminant:Number = v0 * v0 + 2 * acceleration * delta;
			_duration = (-v0 + Math.sqrt(discriminant)) / acceleration; 
		}
		
		public function get duration():Number
		{
			return _duration;
		}
		
		public function ease(fraction:Number):Number
		{
			var t:Number = _duration * fraction;
			var x:Number = _v0 * t + 0.5 * _acceleration * t * t;
			return x / _delta;
		}
	}
}