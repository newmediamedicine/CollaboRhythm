/*
* Copyright (c) 2009 Adam Newgas http://www.boristhebrave.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package{

import Box2D.Common.b2Settings;
import Box2D.Dynamics.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.Joints.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Common.Math.*;
import flash.events.Event;
import flash.display.*;
import flash.system.Capabilities;
import flash.system.System;
import flash.text.*;
import flash.utils.getTimer;
import General.*
import Benchmarks.*;

import flash.display.MovieClip;
	[SWF(width='640', height='360', backgroundColor='#414647', frameRate='30')]
	public class Benchmark extends MovieClip {
		
		// Parameters of the test ///////////////
		public var broadphase:String = 
			"DynamicTree";
			//"SAP";
			
		public var test:IBenchmark = 
			//new PyramidBenchmark();
			//new RagdollBenchmark();
			new LotteryBenchmark();
			//new NullBenchmark();
			
		public var doSleep:Boolean = false;
		public var steps:int = 300;
		public var frequency:int = 60;
		public var velocityIterations:int = 10;
		public var positionIterations:int = 10;
		public var warmStarting:Boolean = true;
		public var continuousPhysics:Boolean = false;
		public var preview:Boolean = false;
		
		
		// Private variables //////////////////
		private var world:b2World;
		private var result:XML;
		private var timeStep:Number = 1.0 / frequency;
		private var totalRuns:int = 10;
		private var runCount:int;
		private var data:Vector.<Number> = new Vector.<Number>();
		
		public function Benchmark()
		{
			// Gather the specifics of the test
			var isDebug:Boolean = Capabilities.isDebugger;
			var revision:String = "$Rev: 92 $ $Date: 2009-12-26 17:08:24 +0000 (Sat, 26 Dec 2009) $"
			var version:String = b2Settings.VERSION;
			var playerVersion:String = Capabilities.version;
			var os:String = Capabilities.os;
			
			result = 
				<benchmark>
					<setup>
						<isDebug>{isDebug}</isDebug>
						<revision>{revision}</revision>
						<version>{version}</version>
						<playerVersion>{playerVersion}</playerVersion>
						<os>{os}</os>
					</setup>
					<parameters>
						<test>{test.Name()}</test>
						<broadphase>{broadphase}</broadphase>
						<doSleep>{doSleep}</doSleep>
						<steps>{steps}</steps>
						<frequency>{frequency}</frequency>
						<velocityIterations>{velocityIterations}</velocityIterations>
						<positionIterations>{positionIterations}</positionIterations>
						<warmStarting>{warmStarting}</warmStarting>
						<continuousPhysics>{continuousPhysics}</continuousPhysics>
					</parameters>
					{test.Details()}
				</benchmark>;
			
			this.addEventListener(Event.ENTER_FRAME, RunTest);
		
			if (preview)
			{
				totalRuns = steps;
				steps = 1;
				InitWorld();
			}
		}
		
		private function InitWorld():void
		{
			world = new b2World(new b2Vec2(), doSleep);
			world.SetWarmStarting(warmStarting);
			world.SetContinuousPhysics(continuousPhysics);
			this[broadphase + "Broadphase"]();
			test.Init(world);
		}
		
		private function RunTest(event:Event = null):void
		{
			if (runCount < totalRuns)
			{
				if(!preview)
					InitWorld();
				data.push(DoRun());
				runCount++;
				if (preview)
					DisplayScene();
			}else {
				removeEventListener(Event.ENTER_FRAME, RunTest);
				SummarizeResults();
				ReportResults();
			}
		}
		
		private function SummarizeResults():void
		{
			var n:int = data.length;
			var sum:Number = 0;
			var sum2:Number = 0;
			var t:Number;
			for each(t in data)
			{
				sum += t;
				sum2 += t * t;
			}
			var average:Number = sum / n;
			var sd:Number = Math.sqrt(sum2 / n - average * average);
			var results:XML = <results>
				<average>{average}</average>
				<sd>{sd}</sd>
				<totalMemory>{System.totalMemory}</totalMemory>
			</results>;
			for each(t in data)
			{
				results.appendChild(<run>{t}</run>);
			}
			result.appendChild(results);
		}
		
		private function DoRun():int
		{
			var start:int = getTimer();
			for (var n:int = 0; n < steps; n++)
			{
				world.Step(timeStep, velocityIterations, positionIterations);
				world.ClearForces();
			}
			var end:int = getTimer();
			return end - start;
		}
		
		private function DisplayScene():void
		{
			// Show a snapshot of the world in the background.
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(this);
			debugDraw.SetDrawScale(30.0);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(debugDraw);
			this.graphics.clear();
			world.DrawDebugData();
		}
		
		private function ReportResults():void
		{
			DisplayScene();
			
			// Show the text
			var tf:TextField = new TextField();
			addChild(tf);
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
			tf.text = result;
			
			// Copy to clipboard
			System.setClipboard(result);
		}
		
		private function DynamicTreeBroadphase():void
		{
			world.SetBroadPhase(new b2DynamicTreeBroadPhase());
		}
		
		private function SAPBroadphase():void
		{
			var aabb:b2AABB  = new b2AABB();
			aabb.lowerBound.x = -100000;
			aabb.lowerBound.y = -100000;
			aabb.upperBound.x = 100000;
			aabb.upperBound.y = 100000;
			world.SetBroadPhase(new b2BroadPhase(aabb));
		}
		
	}
}
