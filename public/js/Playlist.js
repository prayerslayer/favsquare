Playlist = Backbone.Collection.extend({
	model: Track,
	initialize: function( opts ) {
		if ( opts.host && opts.resource) {
			this.url = opts.host + "/" + opts.resource;
		}		
	},
	events: {
	}
});