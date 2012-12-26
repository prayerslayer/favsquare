TrackView = Backbone.View.extend( {
	
	initialize: function( opts ) {
		this.model.bind( "play", this.play, this );
		this.model.bind( "pause", this.pause, this );
		this.parent = opts.parent;
		this.render();
	},

	sound: null,
	template: _.template( $( "#track_template" ).html() ),
	tagName: "li",

	render: function() {
		var track = this.model.toJSON();
		track.title = track.title.substring( 0, 80 ); //cramp title length
		var html = this.template( track );
		$( this.el ).append( html );
		return this;
	},
	events: {
		"click .title": "directPlay"
	},

	seek: function( evt ) {
		if ( this.sound) {
			var x = 0;
			if ( evt.pageX ) {
				// defined in chrome
				x = ( evt.pageX - $( evt.target ).offset().left );
			}
			else {
				// undefined in firefox
				x = evt.offsetX;
			}
			var total = $( evt.target ).width();
			var rel_pos = x / total;
			var abs_pos = Math.floor( this.model.get( "duration" ) * rel_pos );
			this.sound.setPosition( abs_pos );
		}
	},

	directPlay: function() {
		var that = this;
		if ( !this.model.get( "playing" ) ) {
			that.parent.pause();
			that.parent.setPlayingTrack( this.model );	
			that.parent.play( this.model );
		}
	},
	play: function( ) {
		var that = this,
			$me = $( this.el ),
			$ava = $( this.el ).find( ".avatar img" );

		console.log( "play at ", that);
		
		//start playing and stuff
		if ( !that.waveform ) {
			var waveform = new Waveform({
				container: that.el.querySelector( ".waveform" ),
				innerColor: "#333"
			});
			waveform.dataFromSoundCloudTrack( that.model.attributes );
			that.waveform = waveform;
		}
		if ( !that.sound )
		{
			var streamOptions = that.waveform.optionsForSyncedStream();
			SC.stream( "/tracks/" + this.model.get("track_id"), streamOptions, function( sound ){
				var seekhandler = jQuery.proxy( that.seek, that );
				var firstload = false;

				if ( that.sound == null ) {
				  	that.sound = sound;
				}
				if ( that.sound.readyState === 0 ) {
					//uninitialized
					firstload = true;
					$ava.attr("src", "img/spinner.gif");
				}

				that.sound.play({
					onfinish: function() {
						$ava.attr("src", "img/spinner.gif");
						//free some stuff
						delete that.sound;
						delete that.waveform;
						$me.find( "canvas" ).off( "click", seekhandler );
						$me.find( ".waveform" ).children().fadeOut( 200, function() {
							$(this).remove();
						});
						//play next
						that.parent.nextTrack();
						$ava.attr("src", that.model.get("creator_avatar") );
					},
					onplay: function() {
						$me.find( "canvas" ).off( "click", seekhandler ).on( "click", seekhandler );		
					},
					onbufferchange: function() {
						if ( firstload && this.bytesLoaded > 0 ) {
							$ava.attr( "src", that.model.get( "creator_avatar" ) );
							firstload = false;
						}
					}
				});

				//TODO hier sowas wie spinner	
			});
		}
		else {
			that.sound.play();
		}
	},
	pause: function() {
		var that = this;

		if ( that.sound )
			that.sound.pause();
	}
});