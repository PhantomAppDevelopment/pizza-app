package newsScreens
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import renderers.NewsRenderer;

	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	import utils.NavigatorData;

	public class HomeScreen extends PanelScreen
	{
		public static const GO_NEWS_DETAILS:String = "goNewsDetails";

		private var mainGroup:LayoutGroup;
		private var pizzaNewsLabel:Label;
		private var newsList:List;

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

			this.title = "Local Pizza News";
			this.layout = new AnchorLayout();

			var menuButton:Button = new Button();
			menuButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(Main.OPEN_MENU);
			});
			menuButton.styleNameList.add("menu-button");
			this.headerProperties.leftItems = new <DisplayObject>[menuButton];

			mainGroup = new LayoutGroup();
			mainGroup.alpha = 0;
			mainGroup.layoutData = new AnchorLayoutData(100, NaN, 10, NaN, 0, 0);
			mainGroup.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			this.addChild(mainGroup);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			pizzaNewsLabel = new Label();
			pizzaNewsLabel.alpha = 0;
			pizzaNewsLabel.styleNameList.add("big-label");
			pizzaNewsLabel.text = "Pizza News";
			pizzaNewsLabel.layoutData = new AnchorLayoutData(10, NaN, NaN, NaN, -50, NaN);
			this.addChild(pizzaNewsLabel);

			var pizzaNewsLabelFade:Tween = new Tween(pizzaNewsLabel, 0.5);
			pizzaNewsLabelFade.animate("alpha", 1);
			Starling.juggler.add(pizzaNewsLabelFade);

			var pizzaNewsLabelSlide:Tween = new Tween(pizzaNewsLabel.layoutData, 0.5);
			pizzaNewsLabelSlide.animate("horizontalCenter", 0);
			Starling.juggler.add(pizzaNewsLabelSlide);

			newsList = new List();
			newsList.addEventListener(starling.events.Event.CHANGE, changeHandler);
			newsList.itemRendererType = NewsRenderer;
			newsList.layoutData = new AnchorLayoutData(90, 10, 10, 10, 0, NaN);

			var listTween:Tween = new Tween(mainGroup, 0.3);
			listTween.animate("alpha", 1.0);
			listTween.animate("width", stage.stageWidth - 20);
			listTween.onComplete = function ():void
			{
				Starling.juggler.remove(listTween);
				addChild(newsList);
				loadNews();
			};
			Starling.juggler.add(listTween);
		}

		private function loadNews():void
		{
			var request:URLRequest = new URLRequest("https://news.google.com/news/feeds?q=pizza");

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, newsLoaded);
			loader.load(request);
		}

		private function newsLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, newsLoaded);

			removeChild(mainGroup, true);

			var myXMLList:XMLList = new XMLList(event.currentTarget.data);
			newsList.dataProvider = new ListCollection(myXMLList.channel.item);
		}

		private function changeHandler(event:starling.events.Event):void
		{
			_data.selectedNews = newsList.selectedItem;
			this.dispatchEventWith(GO_NEWS_DETAILS);
		}

		override public function dispose():void
		{
			super.dispose();
		}

	}
}