
if (navigator.appVersion.indexOf("MSIE")!=-1)
document.write("<script type='text/javascript' id='chillicontroller'></script>");

if (!window.queryObj) {
    window.queryObj = new Object();
    window.location.search.replace(new RegExp("([^?=&]+)(=([^&]*))?","g"), function($0,$1,$2,$3) { queryObj[$1] = $3; });
}

if (queryObj['uamip'] != null && queryObj['uamport'] != null) {
    var script = document.getElementById('chillicontroller');
    if (script == null) {
	script = document.createElement('script');
	script.id = 'chillicontroller';
	script.type = 'text/javascript';
    	script.src = 'http://'+queryObj['uamip']+':'+queryObj['uamport']+'/www/chillijs.chi';

    	var head = document.getElementsByTagName("head")[0];
    	if (head == null) head = document.body; 
	head.appendChild(script);
    }
    script.src = 'http://'+queryObj['uamip']+':'+queryObj['uamport']+'/www/chillijs.chi';
} else {
    var noLocation = document.getElementById("noLocation");
    if (noLocation != null && noLocation.style) {
       noLocation.style.display = 'inline';
    }
}
