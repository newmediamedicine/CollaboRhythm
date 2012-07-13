package collaboRhythm.shared.model
{
	public class DebugUtils
	{
		public static function getObjectMemoryHash(obj:*):String
		{
			var memoryHash:String;

			try
			{
				FakeClass(obj);
			}
			catch (e:Error)
			{
				memoryHash = String(e).replace(/.*([@|\$].*?) to .*$/gi, '$1');
			}

			return memoryHash;
		}
	}
}

internal final class FakeClass
{
}
