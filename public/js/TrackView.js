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
	className: "track",

	render: function() {
		var track = this.model.toJSON();
		track.title = track.title.substring( 0, 80 ); //cramp title length
		var html = this.template( track );
		$( this.el ).append( html );
		return this;
	},
	events: {
		"click canvas": "seek",
		"click .title": "directPlay"
	},

	seek: function( evt ) {
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
	},

	directPlay: function() {
		var that = this;
		that.parent.pauseCurrent();
		that.parent.setPlayingTrack( this.model );	
		that.parent.setPlayingIndicator();
		that.play();
	},

	play: function( ) {
		var that = this,
			$me = $( this.el );

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
					if ( that.sound == null ) {
					  	that.sound = sound;
					}
					that.sound.play({
						onfinish: function() {
							that.parent.nextTrack();
						}
					});	
					window.exampleStream = that.sound;
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