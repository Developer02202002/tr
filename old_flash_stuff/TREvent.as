package {
	import flash.events.Event;
	public class TREvent extends Event {
		public static const START:String = "TRStart";
		public static const LOAD_PROP_TEXTURE:String = "Load_Prop_Texture";
		public static const LOAD_PROP:String = "Load_Prop";
		public var file:String;
		public var name:String;
		public function TREvent($type:String, $file:String = "", $name:String = "", $bubbles:Boolean = false, $cancelable:Boolean = false) {
			file = $file;
			name = $name;
			super($type, $bubbles, $cancelable);
		}
	}
}