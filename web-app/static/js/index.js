$(function(){
	$.get(wifiConnectEndpoint() + '/networks', function(data){
		if(data.length === 0){
			$('.before-submit').hide();
			$('#no-networks-message').removeClass('hidden');
		} else {
			$('#debug').html(data);
			$.each(JSON.parse(data), function(i, val){
				$("#ssid-select").append($('<option>').attr('val', val.ssid).text(val.ssid);
			});
		}
	});

	$('#connect-form').submit(function(ev){
		let serialized = $('#connect-form').serialize();
		$.post(wifiConnectEndpoint() + '/connect', serialized, function(data){
			$.post('/custom', serialized, function(data){
				$('.before-submit').hide();
				$('#submit-message').removeClass('hidden');
			});
		});
		ev.preventDefault();
	});
});

function wifiConnectEndpoint() {
	return window.location.protocol + '//' + window.location.hostname + ':45454';
}
