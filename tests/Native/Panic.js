var _hackerexperience$heborn$Native_Panic = function() {

    function crash(code, message) {
        throw new Error(code + ">> " + message);
    }

    return {
        crash: F2(crash)
    };

}();
