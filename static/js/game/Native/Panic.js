var _hackerexperience$heborn$Native_Panic = function() {

    function crash(code, message) {
        document.body.innerHTML =
            "<div style=\"background-color: rgb(0, 122, 255); color: rgb(255, 255, 255); text-align: center; width: 100%; min-height: 100%; display: flex; flex-direction: column; align-items: center;\"><div style=\"flex: 1 1 0%;\"></div><div style=\"max-width: 640px; text-align: left; flex: 0 1 0%;\"><h1 style=\"font-size: 72px; margin-top: 0px;\">(ノò_ó)ノ︵┻━━━┻</h1><h3>D'Lay'D OS ran into a problem that it couldn't (never)<br>handle and now it needs to restart.</h3><h5>You can ask on discord: " +
            code + "</h5><h5 style=\"-moz-user-select: text;\">" +
            message + "</h5><br><h4 onClick=\"javascript:location.reload();\" style=\"text-align: center; cursor: pointer;\">Click here to reboot!</h4><br><p style=\"font-size: 7px;\">70.111.100.97.45.83.69.33</p></div><div style=\"flex: 1 1 0%;\"></div></div>";
    }

    return {
        crash: F2(crash)
    };

}();
