package collaboRhythm.core.pluginsManagement
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	public class DefaultComponentContainer implements IComponentContainer
	{
		private var componentArraysByType:Dictionary = new Dictionary();
		
		public function DefaultComponentContainer()
		{
		}
		
		public function registerComponentInstance(componentKey:String, serviceType:Class, componentInstance:Object):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(serviceType).name;
			var comonentsArray:Array;
			if (!componentArraysByType.hasOwnProperty(typeName))
			{
				componentArraysByType[typeName] = new Array();
			}
			
			comonentsArray = componentArraysByType[typeName];
			comonentsArray.push(componentInstance);
		}
		
		public function resolveAll(serviceType:Class):Array
		{
			var typeName:String = ReflectionUtils.getClassInfo(serviceType).name;
			return componentArraysByType[typeName];
		}
	}
}