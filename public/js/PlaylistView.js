PlaylistView = Backbone.View.extend({

	initialize: function() {
		this.el = this.$el.selector;	//don't know why I have to do this, should be done automatically, right?
	},

	render: function( ) {
		var that = this,
			buffer = [];

		_.each( this.model.models, function( track ) {
			if ( !track.get( "view" ).isRendered ) {
				var view = track.get( "view" ).render();
				view.isRendered = true;
				buffer.push( view.$el.html() );
			}
		});

		//insert all new tracks at once
		$( this.el ).append( buffer.join("") );
	},
	events: {
		
	},
});