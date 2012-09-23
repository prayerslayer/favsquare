PlaylistView = Backbone.View.extend({

	initialize: function() {
		this.el = this.$el.selector;	//don't know why I have to do this, should be done automatically, right?

		this.model.bind( "add", this.addTrack, this );

		this.render();
	},

	render: function( ) {
		// var that = this,
		// 	buffer = [];

		// // if there are any tracks in the collection
		// if ( _.size( this.model.models ) > 0 ) {
		// 		// check if they are already rendered and render if not
		// 		_.each( this.model.models, function( track ) {
		// 			if ( !track.view.isRendered ) {
		// 				var view = track.view.render();
		// 				view.isRendered = true;
		// 				buffer.push( view.$el.html() );
		// 			}
		// 		});
		
		// 		//insert all new tracks at once
		// 		$( this.el ).append( buffer.join("") );
		// 	}

		return this;
	},

	events: {
		
	},

	addTrack: function( track ) {
		var trackview = new TrackView({
			model: track
		});
		$( this.el ).append( trackview.el );
	}
});