////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.adobe.audio.effects
{
	import flash.utils.ByteArray;
	
/**
 * 	Encapsulating audio effect code.
 * 
 * 	Author: Renaun Erickson 
 */
public class EffectDriver
{
	private var samplesPosition:int = 0;
	private var lastSample:Number = 0;
	private var lastSampleUsageCount:int = 0;
	
	public var range:Number = 0;
	public var speed:Number = 0;
	public var volume:Number = 0;

	/**
	 * 
	 */
	public function effectInit():void
	{
		samplesPosition = 0;
		lastSample = 0;
		lastSampleUsageCount = 0;		
	}
	
	/**
	 * 	Process the effects with the sampleData provided.
	 */
	public function processEffect(sampleData:ByteArray):Number
	{
		var currentSampleValue:Number = 0;
		if (sampleData.bytesAvailable < 4)
		{
			return currentSampleValue;
		}
	
		// Speed is no 0, >0 fast <0 slow
		if (speed > 0)
		{
			currentSampleValue = sampleData.readFloat();
			if (samplesPosition % range <= speed)
			{
				if (sampleData.bytesAvailable > 4)
					sampleData.readFloat();
				
				if (sampleData.bytesAvailable > 4)
					sampleData.readFloat();
			}
		}
		else if (speed == 0)
		{
			currentSampleValue = sampleData.readFloat();
		}
		else
		{
			if (lastSampleUsageCount == 0)
			{
				currentSampleValue = sampleData.readFloat();
				lastSample = currentSampleValue;
			}
			currentSampleValue = lastSample;
			if (lastSampleUsageCount == Math.floor(-speed/6) || lastSampleUsageCount > range)
				lastSampleUsageCount = 0;
			else
				lastSampleUsageCount++;
		}
		samplesPosition++;
		return currentSampleValue * (volume/100);
	}

}
}