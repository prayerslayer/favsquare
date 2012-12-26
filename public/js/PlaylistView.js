PlaylistView = Backbone.View.extend({

	initialize: function() {
		this.model.bind( "add", this.addTrack, this );
		//this.model.bind( "reset", this.reset, this );
		this.render();
	},

	render: function( ) {
		$( this.el ).append("<ol id='playlist-list'></ol>");
		return this;
	},

	events: {
		"click [data-role = prev]": "previousTrack",
		"click [data-role = play]": "togglePlay",
		"click [data-role = next]": "nextTrack"
	},

	currentTrack: 0,

	addTrack: function( track ) {
		var trackview = new TrackView({
			model: track,
			parent: this
		});
		$( this.el ).find( "#playlist-list" ).append( trackview.el );
	},

	previousTrack: function(  ) {
		if ( this.currentTrack - 1 >= 0 ) {
			this.togglePlay();
			this.currentTrack = this.currentTrack - 1;
			this.togglePlay();
		}
	},
	setPlayingIndicator: function() {
		var trackheight = $( ".track" ).first().outerHeight( false );
		var newpos = ( this.currentTrack * trackheight ) + trackheight / 2;
		$("#playing-indicator").animate({"top": newpos + "px"}, 200);
	},
	play: function( track ) {
		track.set( "playing", true );
		track.trigger( "play" );
		$( ".play-button i").removeClass( "icon-play" );
		$( ".play-button i").addClass( "icon-pause" );
		this.setPlayingTrack( track );
		this.setPlayingIndicator();	
	},
	pause: function( track ) {
		if ( track == null ) {
			//use current track
			track = this.model.at( this.currentTrack );
		}
		track.set( "playing", false );
		track.trigger( "pause" );
		$( ".play-button i").addClass( "icon-play" );
		$( ".play-button i").removeClass( "icon-pause" );
		this.setPlayingTrack( track );
		this.setPlayingIndicator();
	},
	togglePlay: function( ) {
		var track = this.model.at( this.currentTrack );
		if ( !track.get( "playing" ) ) {
			this.play( track );
		}
		else {
			this.pause( track );
		}
	},

	setPlayingTrack: function( track ) {
		var id = track.get( "id" );
		var index = _.indexOf( this.model.pluck( "id" ), id );
		console.log( index, id );
		this.currentTrack = index;
		$( "#current-track" ).attr( "href", "#track-" + id );
		var text = track.get( "creator" ) + " - " + track.get( "title" );
		$( "#current-track" ).text( text );	
	},

	fetchThenPlay: function( ) {
		var that = this;
		this.model.fetch({
			add: true,
			success: function( ) {
				that.playNext();
			},
			error: function( resp ) {
				console.log( resp );
				alert("nooo");
			}
		});
	},

	playNext: function( ) {
		this.currentTrack = this.currentTrack + 1;

		this.togglePlay();
	},
	
	nextTrack: function(  ) {
		var track = this.model.at( this.currentTrack );

		if ( track == null ) {
			this.fetchThenPlay();
			return;
		}

		this.pause();

		if ( this.currentTrack + 1 >= this.model.length ) {
			this.fetchThenPlay();
		}
		else
			this.playNext();
	}
});