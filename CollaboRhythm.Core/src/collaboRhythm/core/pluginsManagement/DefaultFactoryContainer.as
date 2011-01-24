package collaboRhythm.core.pluginsManagement
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.pluginsSupport.IFactoryContainer;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IFactory;
	
	public class DefaultFactoryContainer implements IFactoryContainer
	{
		private var factoryVectorsByType:Dictionary = new Dictionary();
		
		public function DefaultFactoryContainer()
		{
		}
		
		public function addFactory(factory:IFactory, type:Class):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(type).name;
			var factories:Vector.<IFactory>;
			if (!factoryVectorsByType.hasOwnProperty(typeName))
			{
				factoryVectorsByType[typeName] = new Vector.<IFactory>();
			}
			
			factories = factoryVectorsByType[typeName];
			factories.push(factory);
		}
		
		public function getFactories(type:Class):Vector.<IFactory>
		{
			var typeName:String = ReflectionUtils.getClassInfo(type).name;
			return factoryVectorsByType[typeName];
		}
	}
}