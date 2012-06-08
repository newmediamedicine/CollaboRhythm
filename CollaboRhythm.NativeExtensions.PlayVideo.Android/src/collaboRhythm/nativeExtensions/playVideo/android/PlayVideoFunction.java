/**
 * Copyright 2012 John Moore, Scott Gilroy
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
package collaboRhythm.nativeExtensions.playVideo.android;

import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class PlayVideoFunction implements FREFunction {

	public FREObject call(FREContext freContext, FREObject[] freObjects) {

		String movieurl = Environment.getExternalStorageDirectory() + "/Movies/Joslin_Insulin_Pen_demo.mp4";

					Intent intentToPlayVideo = new Intent(Intent.ACTION_VIEW);
					intentToPlayVideo.setDataAndType(Uri.parse(movieurl), "video/*");
					freContext.getActivity().startActivity(intentToPlayVideo);

//		String videoName = "";
//
//		try {
//			videoName = freObjects[0].getAsString();
//		} catch (FRETypeMismatchException e) {
//			e.printStackTrace();
//		} catch (FREInvalidObjectException e) {
//			e.printStackTrace();
//		} catch (FREWrongThreadException e) {
//			e.printStackTrace();
//		}
//
//		String videoUrl = Environment.getExternalStorageDirectory() + "/Movies/" + videoName;
//
//		Intent intentToPlayVideo = new Intent(Intent.ACTION_VIEW);
//		intentToPlayVideo.setDataAndType(Uri.parse(videoUrl), "video/*");
//		freContext.getActivity().startActivity(intentToPlayVideo);

		return null;
	}

}
