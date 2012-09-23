TrackView = Backbone.View.extend( {
	
	initialize: function() {
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
		return {
			"click [data-role = play-track]": "play",
			"click [data-role = pause-track]": "pause"
		};
	},
	play: function( evt ) {
		var $me = $( evt.target );
		var that = this;

		console.log( "play at ", that);

		//transform to pause button
		$me.attr("data-role", "pause-track");
		$me.attr("src", "img/pause.png");
		//TODO bild austauschen etc

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
	pause: function( evt ) {
		var $me = $( evt.target );
		var that = this;

		console.log( "pause at ", that);

		//transform to play button
		$me.attr("data-role", "play-track");
		$me.attr("src", "img/play.png");
		//pause playing
		that.sound.pause();

		//trigger/delegate event for playlist
	}
});