package collaboRhythm.plugins.bloodPressure.model.titration
{
	/**
	 * Code indicating dose strength or level, where 0 means none, 1 means half of max, and 2 means max or full.
	 */
	public class DoseStrengthCode
	{
		public static const NONE:int = 0;
		public static const HALF:int = 1;
		public static const FULL:int = 2;

		public function DoseStrengthCode()
		{
		}

		public static function describe(doseSelected:int):String
		{
			switch (doseSelected)
			{
				case NONE:
					return "none";
				case HALF:
					return "half strength";
				case FULL:
					return "full strength";
			}
			return null;
		}
	}
}
