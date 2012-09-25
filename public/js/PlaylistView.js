PlaylistView = Backbone.View.extend({

	initialize: function() {
		this.model.bind( "add", this.addTrack, this );
		this.mediator = new Mediator();
		this.mediator.Subscribe( "trackview:next", this.nextTrack, {}, this );
		this.render();
	},

	render: function( ) {
		$( this.el ).append("<ol id='playlist-list'></ol>");
		return this;
	},

	events: {
		"click [data-role = prev]": "previousTrack",
		"click [data-role = play]": "playTrack",
		"click [data-role = next]": "nextTrack"
	},

	currentTrack: 0,

	addTrack: function( track ) {
		var trackview = new TrackView({
			model: track,
			mediator: this.mediator
		});
		$( this.el ).find( "#playlist-list" ).append( trackview.el );
	},

	previousTrack: function(  ) {
		if ( this.currentTrack - 1 >= 0 ) {
			var track = this.model.at( this.currentTrack );
			track.set( "playing", false );
			track.trigger( "pause" );

			this.currentTrack = this.currentTrack - 1;

			this.playTrack();
		}
	},
	playTrack: function( ) {
		var track = this.model.at( this.currentTrack );
		if ( !track.get( "playing" ) ) {
			track.set( "playing", true );
			track.trigger( "play" );	
		}
		else {
			track.set( "playing", false );
			track.trigger( "pause" );
		}

	},

	fetchThenPlay: function( ) {
		this.model.fetch({
			add: true,
			success: function( ) {
				alert("weee");
			},
			error: function( resp ) {
				alert("nooo");
				//TODO fetch error?
			}
		});
	},

	playNext: function( ) {
		this.currentTrack = this.currentTrack + 1;

		this.playTrack();
	},

	nextTrack: function(  ) {
		var track = this.model.at( this.currentTrack );
		if ( track == null ) {
			this.fetchThenPlay();
			return;
		}

		track.set( "playing", false );
		track.trigger( "pause" );

		if ( this.currentTrack + 1 >= this.model.length ) {
			this.fetchThenPlay();
		}
		else
			this.playNext();

		
		
	}
});