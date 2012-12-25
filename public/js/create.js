$( document ).ready( function() {
	var $response = $( "div#response" );
	$( "button[data-role=submit]" ).click( function() {
		$( this ).attr("disabled", "true");
		$response.fadeIn( 200 );
		$response.addClass( "alert-info" );
		$response.find("p").text( "Doin' work...")
		$.post( "create", {}, function( response, bla, blub ) {
			console.log( response, bla, blub );
		})
		.success( function() {
			$response.addClass( "alert-success" );
			$response.find( "strong" ).text( "Yay!" );
			$response.find( "p" ).text( "Everything went alright." );
		})
		.error( function() {
			$response.addClass( "alert-error" );
			$response.find( "strong" ).text( "Damn!" );
			$response.find( "p" ).text( "Something went wrong... Sorry!");
		})
		.complete( function() {
			$( "div#response").removeClass( "alert-info" );
			$( "#spinner" ).fadeOut( 200 );
		});
	});
});