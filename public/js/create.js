$( document ).ready( function() {
	$( "button[data-role=submit]" ).click( function() {
		$( "#spinner" ).show(200);
		$( this ).attr("disabled", "true");
		$( "p#response" ).addClass( "text-info" ).text( "Doin' work...");
		$.post( "create", {}, function( response, bla, blub ) {
			console.log( response, bla, blub );
		})
		.success( function() {
			var $paragraph = $( "p#response" );
			$paragraph.addClass( "text-success" );
			$paragraph.text( "Yay! Everything went alright.");
		})
		.error( function() {
			var $paragraph = $( "p#response" );
			$paragraph.addClass( "text-error" );
			$paragraph.text( "Oh no! Something went wrong... Sorry!");
		})
		.complete( function() {
			$( "p#response").removeClass( "text-info" );
			$( "#spinner" ).hide( 200 );
		});
	});
});