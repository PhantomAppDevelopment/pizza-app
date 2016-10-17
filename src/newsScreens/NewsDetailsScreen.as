package newsScreens
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.PanelScreen;
	import feathers.controls.WebView;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import starling.display.DisplayObject;
	import starling.events.Event;

	import utils.NavigatorData;
	import utils.RoundedRect;

	public class NewsDetailsScreen extends PanelScreen
	{

		private var mainGroup:LayoutGroup;
		private var webView:WebView;

		protected var _data:NavigatorData;

		public function get data():NavigatorData
		{
			return this._data;
		}

		public function set data(value:NavigatorData):void
		{
			this._data = value;
		}

		override protected function initialize():void
		{
			super.initialize();

			this.title = "News Details";
			this.layout = new AnchorLayout();

			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			mainGroup = new LayoutGroup();
			mainGroup.layoutData = new AnchorLayoutData(10, 10, 10, 10, NaN, NaN);
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0xFFFFFF);
			this.addChild(mainGroup);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			webView = new WebView();
			webView.layoutData = new AnchorLayoutData(20, 20, 20, 20, NaN, NaN);
			this.addChild(webView);
			webView.loadString(_data.selectedNews.description);
		}

		private function goBack():void
		{
			this.dispatchEventWith(Event.COMPLETE);
		}

		override public function dispose():void
		{
			this.removeChild(webView, true);
			super.dispose();
		}

	}
}