package starling.extensions
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.SpriteBox;
	import starling.events.Event;
	import starling.extensions.Particle;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author ...
	 */
	
	/** Dispatched when emission of particles is finished. */
	[Event(name="complete",type="starling.events.Event")]
	
	public class ImageParticleSystem extends SpriteBox implements IAnimatable
	{
		protected var mTexture:Texture;
		protected var mImages:Vector.<Image>;
		protected var mParticles:Vector.<Particle>;
		protected var mFrameTime:Number;
		
		protected var mNumParticles:int;
		protected var mMaxCapacity:int;
		protected var mEmissionRate:Number; // emitted particles per second
		protected var mEmissionTime:Number;
		
		protected static var sHelperMatrix:Matrix = new Matrix();
		protected static var sHelperPoint:Point = new Point();
		
		protected var mEmitterX:Number;
		protected var mEmitterY:Number;
		protected var mPremultipliedAlpha:Boolean;
		
		public function ImageParticleSystem(texture:Texture, emissionRate:Number, initialCapacity:int = 128, maxCapacity:int = 8192)
		{
			mTexture = texture;
			mParticles = new Vector.<Particle>(0, false);
			mImages = new Vector.<Image>(0, false);
			mEmissionRate = emissionRate;
			mEmissionTime = 0.0;
			mFrameTime = 0.0;
			mEmitterX = mEmitterY = 0;
			mMaxCapacity = Math.min(8192, maxCapacity);
			
			raiseCapacity(initialCapacity);
		}
		
		protected function raiseCapacity(byAmount:int):void
		{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(mMaxCapacity, capacity + byAmount);
			
			mParticles.fixed = false;
			mImages.fixed = false;
			
			var image:Image;
			var particle:Particle;
			for (var i:int = oldCapacity; i < newCapacity && i >= mImages.length; ++i)
			{
				
				particle = createParticle();
				image = createImage(mTexture);
				advanceImage(particle, image);
				
				insert(image);
				
				mParticles[i] = particle;
				mImages[i] = image;
			}
			
			mParticles.fixed = true;
			mImages.fixed = true;
		}
		
		protected function createParticle():Particle
		{
			return new Particle();
		}
		
		protected function createImage(texture:Texture):Image
		{
			var result:Image = new Image(texture);
			result.alignPivot();
			return result;
		}
		
		protected function initParticle(particle:Particle):void
		{
			particle.x = mEmitterX;
			particle.y = mEmitterY;
			particle.currentTime = 0;
			particle.totalTime = 1;
			particle.color = Math.random() * 0xffffff;
		}
		
		protected function advanceImage(particle:Particle, image:Image):void
		{
			image.x = particle.x;
			image.y = particle.y;
			image.scaleX = particle.scale;
			image.scaleY = particle.scale;
			image.rotation = particle.rotation;
			image.alpha = particle.alpha;
			image.color = particle.color;
			image.visible = particle.currentTime < particle.totalTime && particle.currentTime != 0.0;
		}
		
		protected function advanceParticle(particle:Particle, passedTime:Number):void
		{
			particle.y += passedTime * 250;
			particle.alpha = 1.0 - particle.currentTime / particle.totalTime;
			particle.scale = 1.0 - particle.alpha;
			particle.currentTime += passedTime;
		}
		
		public function start(duration:Number = Number.MAX_VALUE):void
		{
			if (mEmissionRate != 0)
				mEmissionTime = duration;
		}
		
		public function stop():void
		{
			mEmissionTime = 0.0;
			mNumParticles = 0;
		}
		
		public function pause():void
		{
			mEmissionTime = 0.0;
		}
		
		public function advanceTime(passedTime:Number):void
		{
			var particleIndex:int = 0;
			var particle:Particle;
			var image:Image;
			
			// advance existing particles
			
			while (particleIndex < mNumParticles)
			{
				particle = mParticles[particleIndex] as Particle;
				image = mImages[particleIndex] as Image;
				
				if (particle.currentTime < particle.totalTime)
				{
					advanceParticle(particle, passedTime);
					advanceImage(particle, image);
					++particleIndex;
				}
				else
				{
					advanceImage(particle, image);
					if (particleIndex != mNumParticles - 1)
					{
						var nextParticle:Particle = mParticles[int(mNumParticles - 1)] as Particle;
						mParticles[int(mNumParticles - 1)] = particle;
						mParticles[particleIndex] = nextParticle;
						
						var nextImage:Image = mImages[int(mNumParticles - 1)] as Image;
						mImages[int(mNumParticles - 1)] = image;
						mImages[particleIndex] = nextImage;
						
						//advanceImage(nextParticle, nextImage);
					}
					
					--mNumParticles;
					
					if (mNumParticles == 0)
					{
						dispatchEventWith(Event.COMPLETE);
					}
				}
			}
			
			// create and advance new particles
			
			if (mEmissionTime > 0)
			{
				var timeBetweenParticles:Number = 1.0 / mEmissionRate;
				mFrameTime += passedTime;
				
				while (mFrameTime > 0)
				{
					if (mNumParticles < mMaxCapacity)
					{
						if (mNumParticles == capacity)
							raiseCapacity(capacity);
						
						particle = mParticles[int(mNumParticles)] as Particle;
						image = mImages[int(mNumParticles)] as Image;
						mNumParticles++;
						initParticle(particle);
						advanceParticle(particle, mFrameTime);
						advanceImage(particle, image);
					}
					
					mFrameTime -= timeBetweenParticles;
				}
				
				if (mEmissionTime != Number.MAX_VALUE)
				{
					mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
				}
			}
		}
		
		public function get capacity():int { return mNumParticles; }
        public function get numParticles():int { return mNumParticles; }
        
        public function get maxCapacity():int { return mMaxCapacity; }
        public function set maxCapacity(value:int):void { mMaxCapacity = Math.min(8192, value); }
        
        public function get emissionRate():Number { return mEmissionRate; }
        public function set emissionRate(value:Number):void { mEmissionRate = value; }
        
        public function get emitterX():Number { return mEmitterX; }
        public function set emitterX(value:Number):void { mEmitterX = value; }
        
        public function get emitterY():Number { return mEmitterY; }
        public function set emitterY(value:Number):void { mEmitterY = value; }
        
        public function get texture():Texture { return mTexture; }
        public function set texture(value:Texture):void 
		{ 
			if (value != mTexture)
			{
				mTexture = value;
				for each (var item:Image in mImages) 
				{
					item.texture = mTexture;
					item.readjustSize();
				}
			}
		}
	}
}