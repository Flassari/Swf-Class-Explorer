package  {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	public class Previewer extends MovieClip {
		private var _child:DisplayObject;
		
		public function preview(dsp:DisplayObject):void {
			clear();
			
			_child = dsp;
			var scale:Number = 1;
			
			if (_child.width > 185) scale = 185 / _child.width;
			if (_child.height * scale > 185) scale = 185 / _child.height;
			
			if (scale != 1) {
				_child.scaleX = _child.scaleY = scale;
			} 
			
			var bounds:Rectangle = _child.getBounds(_child);
			_child.x = -bounds.x * scale + (185 - _child.width) / 2;
			_child.y = -bounds.y * scale + (185 - _child.height) / 2;
			addChild(_child);
		}
		
		public function clear():void {
			if (_child != null && contains(_child)) removeChild(_child);
			_child = null;
		}
		
	}
	
}