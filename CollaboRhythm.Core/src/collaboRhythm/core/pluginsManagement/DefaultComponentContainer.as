/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.core.pluginsManagement
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.model.services.IComponentContainer;
	
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

		public function unregisterServiceType(serviceType:Class):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(serviceType).name;
			if (componentArraysByType.hasOwnProperty(typeName))
			{
				delete componentArraysByType[typeName];
			}
		}
		
		public function resolveAll(serviceType:Class):Array
		{
			var typeName:String = ReflectionUtils.getClassInfo(serviceType).name;
			return componentArraysByType[typeName];
		}
		
		public function removeAllComponents():void
		{
			componentArraysByType = new Dictionary();
		}
	}
}