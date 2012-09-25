
/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 */

package
{
    import flash.display.Sprite;
    
    /**
     * The basic framework Library to be included in the SWC.
     * <p>
     * <b>Note:</b> This class is not a component, it is just
     * a shim that allow to declare the SWC manifest and associate an icon file.
     * </p>
     */
    [ExcludeClass]
    [IconFile("gaforflash.png")]
    public class Library extends Sprite
    {
        public function Library()
        {
        }

    }
}