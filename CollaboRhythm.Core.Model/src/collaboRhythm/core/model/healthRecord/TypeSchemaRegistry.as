package collaboRhythm.core.model.healthRecord
{
	import flash.utils.getQualifiedClassName;

	public class TypeSchemaRegistry
	{
		private var schemaMap:Object = {};

		public function TypeSchemaRegistry()
		{
		}

		public function registerSchema(definition:Object, qName:QName):void
		{
			var definitionName:String;
			if (definition is String)
				definitionName = definition as String;
			else
				definitionName = getQualifiedClassName(definition);

			schemaMap[definitionName] = qName;
		}

		public function getSchema(instance:Object):QName
		{
			var qName:QName;
			if (instance != null)
			{
				var definitionName:String = getQualifiedClassName(instance);

				qName = schemaMap[definitionName] as QName;
			}
			return qName;
		}
	}
}
