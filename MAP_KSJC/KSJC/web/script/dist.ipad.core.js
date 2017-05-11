/*
*   dist.ipad.core 数慧基本于Ipad的脚本库
*   2011-12-21 by dist
*/

(function() {

    dist = window.dist =
    {
        //版本
        version: "v1.0000",

        //配置选项
        options: {
            entry: "Handler/Entry.ashx",
            defaultResponseFormat: "xml"
        },

        //响应数据
        responseObject: function() {
            this.time = null,
            this.data = null,
            this.args = null
        },

        send: function(callback, mothed, args) {

        },

        parseXml: function(xml) {
            return new dist.responseObject();
        },

        //获取屏幕的方向,0:横向，1:竖向
        windowDirection: function() {
            if ($(window).height() > 800)
                return 1;
            return 0;
        },

        //当屏幕方向改变时
        onWindowDirectionChanged: function(callback) {

        },

        writeProperty: function(object) {
            for (var i in object) {
                document.write(i + ":" + object[i] + "<br/>");
            }
        },
        $g: function(ele) {
            return document.getElementById(ele);
        },
        format: function(formatStr, data) {
            var val = '';
            var keying = false;
            var key = '';
            for (var i = 0; i < formatStr.length; i++) {
                var c = formatStr.charAt(i);
                if (c == "{") {
                    keying = true;
                    continue;
                }
                if (keying && c == "}") {
                    keying = false;
                    val += data[key];
                    key = '';
                    continue;
                }
                if (keying) {
                    key += c;
                } else {
                    val += c;
                }
            }
            return val;
        }
    };

})();

