package utils
{
	import feathers.controls.Label;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import starling.display.Image;
	import starling.text.TextFormat;

	public class ChatMessageItemRenderer extends LayoutGroupListItemRenderer
	{
		protected var bubble:Image;
		protected var side:String;
		protected var _messageLabel:Label;

		public function ChatMessageItemRenderer()
		{
			super();
		}

		override protected function initialize():void
		{
			this.layout = new AnchorLayout();

			bubble = RoundedRect.createRoundedRect();

			_messageLabel = new Label();
			_messageLabel.minWidth = 5;
			_messageLabel.minHeight = 5;
			_messageLabel.maxWidth = 250;
			_messageLabel.wordWrap = true;
			_messageLabel.padding = 10;
			_messageLabel.backgroundSkin = bubble;
			this.addChild(_messageLabel);
		}

		override protected function commitData():void
		{
			if (this._data && this._owner) {

				var tempData:Date = new Date(Number(this._data.timestamp));
				var hours:String = String(tempData.hours);

				if (hours.length == 1) {
					hours = "0" + hours;
				}

				var minutes:String = String(tempData.minutes);

				if (minutes.length == 1) {
					minutes = "0" + minutes;
				}

				_messageLabel.text = this._data.message +
						"<font size='10'> " + hours + ":" + minutes + " </font>";

				if (this._data.senderId == Main.profile.localId) {
					side = "right";
				} else {
					side = "left";
				}

			}
		}

		override protected function preLayout():void
		{
			if (side == "left") {
				_messageLabel.fontStyles = new TextFormat("-sans", 14, 0xFFFFFF, "left");
				_messageLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, 10, NaN, 0);
				bubble.color = 0xD50000;
			} else {

				_messageLabel.fontStyles = new TextFormat("_sans", 14, 0xFFFFFF, "left");
				_messageLabel.layoutData = new AnchorLayoutData(NaN, 10, NaN, NaN, NaN, 0);
				bubble.color = 0x2979FF;
			}

			bubble.width = _messageLabel.width;
			bubble.height = _messageLabel.height;

		}

	}
}