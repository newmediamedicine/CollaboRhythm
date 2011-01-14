package org.indivo.client
{

	public class DocumentBuilder
	{
		public function DocumentBuilder()
		{
		}
		
		public function parse(inputString:String):XML
		{
			var doc:XML = new XML(inputString);
			return doc;
		}
	}
}