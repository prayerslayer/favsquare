TrackView = Backbone.View.extend( {
	
	initialize: function() {
		this.render();
	},

	template: _.template( $( "#track_template" ).html() ),

	render: function() {
		var track = this.model.toJSON();
		var html = this.template( track );
		$( this.el ).append( html );
		return this;
	},
	events: {
		"click [data-role = play-track]": "play",
		"click [data-role = pause-track]": "pause"
	},
	play: function( evt ) {
		var $me = $( evt.target );
		//transform to pause button
		$me.attr("data-role", "pause");
		//TODO omre

		//start playing and stuff

		//trigger/delegate event for playlist
	},
	pause: function( evt ) {
		var $me = $( evt.target );
		//transform to play button
		$me.attr("data-role", "play");
	}
});