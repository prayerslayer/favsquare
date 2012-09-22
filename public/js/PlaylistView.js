PlaylistView = Backbone.View.extend({

	initialize: function() {
	},

	render: function( ) {
		var that = this;
		_.each( this.model.models, function( track ) {
			if ( !track.get( "rendered" ) ) {
				var view = track.get( "view" ).render();
				track.set( "rendered", true );
				$(that.$el.selector).append( view.el.innerHTML );
			}
		});
	},
	events: {
		
	},
});