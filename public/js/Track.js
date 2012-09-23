Track = Backbone.Model.extend({
	
	defaults: {
		id: 0,
		title: "Unnamed track",
		permalink: "http://who.car.es/notme"
	},

	initialize: function() {
		var that = this;

		//output error
		this.bind( "error", function( model, error ) {
			console.log( "ERROR: " + error );
		});
	}
});