TrackView = Backbone.View.extend( {
	
	initialize: function() {
	},

	template: _.template( $( "#track_template" ).html() ),

	render: function() {
		var track = this.model.toJSON();
		var html = this.template( track );
		$( this.el ).append( html );
		return this;
	},
	events: {
		"click .play_button": "play"
	},
	play: function( evt ) {
		alert( "play track" );
	}
});