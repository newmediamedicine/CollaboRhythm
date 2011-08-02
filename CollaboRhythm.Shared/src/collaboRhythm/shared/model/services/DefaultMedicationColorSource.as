package collaboRhythm.shared.model.services
{

	import flash.utils.Dictionary;

	public class DefaultMedicationColorSource implements IMedicationColorSource
	{
		private var _medicationColorsArray:Array = [
			{key: "atacand", value: 0xf0dbc9},
			{key: "658620064", value: 0x9cb7cc},
			{key: "658620062", value: 0x9cb7cc},
			{key: "605050049", value: 0xa49887},
			{key: "498840027", value: 0xb96f4b},
			{key: "007811506", value: 0x969da7},
			{key: "006033856", value: 0xa38580},
			{key: "006033740", value: 0x979fa9},
			{key: "005271413", value: 0xba9e93},
			{key: "003782075", value: 0xaeb7a6},
			{key: "003782072", value: 0x99afca},
			{key: "003780216", value: 0x9ca1ab},
			{key: "003780018", value: 0xb0b6c0},
			{key: "001723760", value: 0xabb2bf},
			{key: "001723760", value: 0xa5adb9},
			{key: "001723757", value: 0x99a1aa},
			{key: "001722907", value: 0xa36a6a},
			{key: "001431268", value: 0x779cb7},
			{key: "000930734", value: 0x9e7389},
			{key: "000930733", value: 0xa8aab1},
			{key: "000798", value: 0xebe8e0},
			{key: "000779", value: 0xd2d1cf},
			{key: "000777", value: 0xd1d0cc},
			{key: "000771", value: 0x84a7a8},
			{key: "000544299", value: 0xadafb5},
			{key: "000319", value: 0xd5d5d5},
			{key: "000279", value: 0xfdac81}
		];

		private var _medicationColorsDictionary:Dictionary = new Dictionary();

		public function DefaultMedicationColorSource()
		{
			for each (var keyValuePair:Object in _medicationColorsArray)
			{
				_medicationColorsDictionary[keyValuePair.key] = keyValuePair.value;
			}
		}

		public function getMedicationColor(ndc:String):uint
		{
			return _medicationColorsDictionary[ndc];
		}
	}
}
