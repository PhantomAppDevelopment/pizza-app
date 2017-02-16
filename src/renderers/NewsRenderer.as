package renderers
{
	import feathers.controls.ButtonState;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	import feathers.utils.touch.TapToSelect;

	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextFormat;

	public class NewsRenderer extends LayoutGroupListItemRenderer
	{
		private var monthNames:Array = new Array("Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec");

		private var _newsLabel:Label;
		private var _dayLabel:Label;
		private var _monthLabel:Label;
		private var _select:TapToSelect;
		private var _currentState = ButtonState.UP;
		protected var touchID:int = -1;

		public function get currentState():String
		{
			return this._currentState;
		}

		public function set currentState(value:String):void
		{
			if (this._currentState == value) {
				return;
			}
			this._currentState = value;
			this.invalidate(INVALIDATION_FLAG_STATE);
		}

		public function NewsRenderer()
		{
			super();
			this._select = new TapToSelect(this); //This helper allows our ItemRenderer to dispatch the starling.events.Event.CHANGE event.
		}

		override protected function initialize():void
		{
			super.initialize();

			this.addEventListener(TouchEvent.TOUCH, touchHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);

			this.layout = new AnchorLayout();
			this.height = 80;
			this.isQuickHitAreaEnabled = true;
			this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			this.backgroundSelectedSkin = new Quad(3, 3, 0xD50000);

			var dateGroup:LayoutGroup = new LayoutGroup();
			dateGroup.layout = new VerticalLayout();
			dateGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, 10, NaN, 0);
			this.addChild(dateGroup);

			_monthLabel = new Label();
			_monthLabel.styleNameList.add("date-label");
			_monthLabel.backgroundSkin = new Quad(3, 3, 0x0277BD);
			dateGroup.addChild(_monthLabel);

			_dayLabel = new Label();
			_dayLabel.styleNameList.add("date-label");
			_dayLabel.paddingTop = -3;
			_dayLabel.backgroundSkin = new Quad(3, 3, 0x000000);
			dateGroup.addChild(_dayLabel);

			_newsLabel = new Label();
			_newsLabel.wordWrap = true;
			_newsLabel.layoutData = new AnchorLayoutData(5, 10, 5, 75);
			_newsLabel.fontStyles = new TextFormat("_sans", 14, 0x000000, "left");
			_newsLabel.fontStyles.leading = 5;
			this.addChild(_newsLabel);
		}

		override protected function commitData():void
		{
			if (this._data && this._owner) {

				this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);

				var itemDate:Date = new Date(String(_data.pubDate));
				_monthLabel.text = String(monthNames[itemDate.month]);
				_dayLabel.text = String(itemDate.date);

				_newsLabel.text = _data.title;

			} else {
				_newsLabel.text = "";
			}
		}

		private function touchHandler(event:TouchEvent):void
		{
			if (!this._isEnabled) {
				this.touchID = -1;
				this.currentState = ButtonState.UP;
				return;
			}

			if (this.touchID >= 0) {
				var touch:Touch = event.getTouch(this, null, this.touchID);

				if (!touch) {
					return;
				}

				if (touch.phase == TouchPhase.ENDED) {
					this.currentState = ButtonState.UP;
					this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
					this._newsLabel.fontStyles.color = 0x000000;

					this.touchID = -1;
				}
				return;
			}
			else {
				touch = event.getTouch(this, TouchPhase.BEGAN);

				if (!touch) {
					return;
				}

				this.currentState = ButtonState.DOWN;
				this.backgroundSkin = new Quad(3, 3, 0xD50000);
				this._newsLabel.fontStyles.color = 0xFFFFFF;

				this.touchID = touch.id;
			}
		}

		private function removedFromStageHandler(event:Event):void
		{
			this.touchID = -1;
		}

	}
}