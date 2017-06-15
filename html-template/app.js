/**
 * Created by plter on 6/15/17.
 */


(function () {

    var flash = document.getElementById("flash");

    document.getElementById("btncapture").onclick = function () {
        if (flash.capture) {
            document.getElementById("output").innerHTML = flash.capture();
        } else {
            alert("flash.capture is not ready");
        }
    };

})();