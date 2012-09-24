TrackView = Backbone.View.extend( {
	
	initialize: function() {
		this.model.bind( "play", this.play, this );
		this.model.bind( "pause", this.pause, this );
		this.render();
	},

	sound: null,
	template: _.template( $( "#track_template" ).html() ),
	tagName: "li",

	render: function() {
		var track = this.model.toJSON();
		var html = this.template( track );
		$( this.el ).append( html );
		return this;
	},
	events: function() {

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
		var streamOptions = that.waveform.optionsForSyncedStream();
		SC.stream( "/tracks/" + this.model.id, streamOptions, function( sound ){
			if ( that.sound == null ) {
			  	that.sound = sound;
			}
			that.sound.play();	
			window.exampleStream = that.sound;
		});

		//trigger/delegate event for playlist
	},
	pause: function( ) {
		var that = this,
			$me = $( this.el );

		console.log( "pause at ", that);

		//pause playing
		if ( that.sound )
			that.sound.pause();

		//trigger/delegate event for playlist
	}
});