//do nothing
$( document ).ready( function() {
	if ( window.location.pathname !== "/playlist" )
		$( "#playlist-controls" ).hide();

	$( "ul.nav a").tooltip({
		"placement": "bottom"
	});
});