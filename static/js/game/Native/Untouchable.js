var domCache = {}

var _hackerexperience$heborn$Native_Untouchable = function() {

    function node(node, id) {
        function render(vNode, eventNode) {
            if(!(id in domCache)) {
                const d = document.createElement(node);
                d.setAttribute("id", id);
                domCache[id] = d;
            }
            return domCache[id];
        }

        function diff(a, b) {
            return [];
        }

        var impl = {
            render: render,
            diff: diff
        };

        return _elm_lang$virtual_dom$Native_VirtualDom.custom(
            { ctor: "[]" },
            {},
            impl
        );
    }

    return {
        node: F2(node)
    };

}();
