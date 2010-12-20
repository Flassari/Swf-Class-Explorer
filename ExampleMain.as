/*
The MIT License

Copyright (c) 2008 Flassari.is

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package  {
	import com.flassari.swfclassexplorer.SwfClassExplorer;
	import com.flassari.swfclassexplorer.data.Traits;
	import fl.data.DataProvider;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	/**
	* @author Flassari.is
	*/
	public class ExampleMain extends MovieClip {
		private var _loader:Loader;
		private var _bytes:ByteArray;
		
		public function ExampleMain() {
			btnBrowse.addEventListener(MouseEvent.CLICK, onBrowseClick);
		}
		
		private function onBrowseClick(e:MouseEvent):void {
			previewer.clear();
			lstClasses.dataProvider = new DataProvider();
			if (_loader != null) {
				try {
					_loader.unload(); // Looking forward to unloadAndStop()
				} catch (e:Error) { }
				_loader = null;
			}
			
			txtError.text = "Loading...";
			btnBrowse.removeEventListener(MouseEvent.CLICK, onBrowseClick);
			txtPath.enabled = btnBrowse.enabled = false;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, onSwfLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			try {
				urlLoader.load(new URLRequest(txtPath.text));
			} catch (e:Error) {
				resetBrowseControls();
				txtError.text = "Error:\n" + e.toString();
				urlLoader.removeEventListener(Event.COMPLETE, onSwfLoaded);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
			
		}
		
		private function onSwfLoaded(e:Event):void {
			var urlLoader:URLLoader = URLLoader(e.currentTarget);
			urlLoader.removeEventListener(Event.COMPLETE, onSwfLoaded);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			_bytes= ByteArray(URLLoader(e.currentTarget).data);
			
			_loader = new Loader();
			var loaderContext:LoaderContext = new LoaderContext();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderInit);
			_loader.loadBytes(_bytes, loaderContext);
		}
		
		private function onLoaderInit(e:Event):void {
			resetBrowseControls();
			populateList(_bytes);
		}
		
		private function populateList(bytes:ByteArray):void{
			var classes:Array = SwfClassExplorer.getClassNames(bytes);
			
			lstClasses.dataProvider = new DataProvider(classes);
			lstClasses.addEventListener(Event.CHANGE, onListChange);
		}
		
		private function onListChange(e:Event):void {
			var className:String = e.currentTarget.selectedItem.data;
			var obj:Object;
			try {
				obj = new (_loader.contentLoaderInfo.applicationDomain.getDefinition(className));
			} catch (e:Error) {
				txtError.text = "Can't instantiate class:\n" + e.toString();
			}
			if (obj != null && obj is DisplayObject) {
				previewer.preview(DisplayObject(obj));
			}
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			resetBrowseControls();
			txtError.text = "A security error occurred:\n" + e.text;
		}
		
		private function onIoError(e:IOErrorEvent):void {
			resetBrowseControls();
			txtError.text = "An IO error occurred:\n" + e.text;
		}
		
		private function resetBrowseControls():void {
			txtError.text = "";
			btnBrowse.addEventListener(MouseEvent.CLICK, onBrowseClick);
			txtPath.enabled = btnBrowse.enabled = true;
		}
		
		
	}
	
}