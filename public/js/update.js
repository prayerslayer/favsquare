var Timer = (function() {
	return {
		id: 0,
		running: false,
		total_timeout: 30,

		start: function( ) {
			var that = this;
			that.running = true;
			that.id = setInterval( function() {
				that.total_timeout -= 1;
				if ( that.total_timeout === 0 ) {
					window.location.reload( false );
				}
				else {
					$( "#countdown" ).text( that.total_timeout > 1 ? that.total_timeout + " seconds" : "1 second" );
				}
			}, 1000 );
		},
		stop: function( ) {
			var that = this;
			if ( that.running ) {
				that.running = false;
				clearInterval( that.id );
			}
		},
		isRunning: function( ) {
			return this.running;
		}
	}
})();

$( document ).ready( function() {
	Timer.start();
});