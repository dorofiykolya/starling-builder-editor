package starlingbuilder.editor.ui 
{
	import feathers.controls.LayoutGroup;
	import starling.animation.IAnimatable;
	import starling.extensions.ImageParticleSystem;
	import starling.extensions.PDParticleSystem;
	import starlingbuilder.editor.UIEditorApp;
    import starlingbuilder.editor.controller.DocumentManager;
    import starlingbuilder.util.feathers.FeathersUIUtil;

    import feathers.controls.Button;
    import feathers.controls.LayoutGroup;

    import starling.core.Starling;

    import starling.display.MovieClip;
    import starling.events.Event;
	/**
	 * ...
	 * @author dorofiy.com
	 */
	public class ParticleSystemTool extends LayoutGroup 
	{
		private var _movieClipTool:LayoutGroup;
        private var _playButton:Button;
        private var _stopButton:Button;

        private var _documentManager:DocumentManager;

		public function ParticleSystemTool() 
		{
			_documentManager = UIEditorApp.instance.documentManager;
            initMovieClipTool();
		}
		
        private function initMovieClipTool():void
        {
            _movieClipTool = FeathersUIUtil.layoutGroupWithHorizontalLayout();

            _playButton = FeathersUIUtil.buttonWithLabel("play", onPlayButton);
            _stopButton = FeathersUIUtil.buttonWithLabel("stop", onStopButton);

            _movieClipTool.addChild(FeathersUIUtil.labelWithText("Particle: "))
            _movieClipTool.addChild(_playButton);
            _movieClipTool.addChild(_stopButton);

            addChild(_movieClipTool);
        }

        public function updateTool():void
        {
            _movieClipTool.visible = isParticleSystem(_documentManager.selectedObject);
        }

        private function onPlayButton(event:Event):void
        {
            var mv:Object = asParticleSystem(_documentManager.selectedObject);

            if (mv)
            {
                Starling.current.juggler.add(IAnimatable(mv));
                mv.start();
                _documentManager.setChanged();
            }
        }

        private function onStopButton(event:Event):void
        {
            var mv:Object = asParticleSystem(_documentManager.selectedObject);

            if (mv)
            {
                mv.stop();
                Starling.current.juggler.remove(IAnimatable(mv));
                _documentManager.setChanged();
            }
        }
		
		private function asParticleSystem(value:Object):Object
		{
			if (isParticleSystem(value))
			{
				return value;
			}
			return null;
		}
		
		private function isParticleSystem(value:Object):Boolean
		{
			return value is PDParticleSystem || value is ImageParticleSystem;
		}
	}

}