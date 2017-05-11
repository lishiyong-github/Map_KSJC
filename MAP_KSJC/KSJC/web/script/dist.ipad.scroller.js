//dist 2012-04-17

(function($) {
    $.fn.scroller = function(options) {
        if (!this)
            return false;

        var sender = $(this);
        var callback = null;
        if (options && options.onscroller)
            callback = options.onscroller;
        var touchdown = false;
        var startY = 0;
        var startX = 0;
        var startTop = 0;
        var startLeft = 0;
        var mTimeout = 0;
        function ontouchsart(e) {
            clearTimeout(mTimeout);
            if (e.touches) {
                startY = e.touches[0].pageY;
                startX = e.touches[0].pageX;
            } else {
                startY = e.pageY;
                startX = e.pageX;
            }
            var p = sender.position();
            startTop = p.top;
            startLeft = p.left;
            touchdown = true;
        }

        function ontouchmove(e) {
            if (!touchdown)
                return;
            var fullHeight = sender.height();
            var fullWidth = sender.width();
            var parentNode = $(sender[0].parentNode);
            var vh = parentNode.height();
            var vw = parentNode.width();

            var canLeft = false;
            var canRight = false;

            if (fullHeight > vh) {
                var ey = 0;
                if (e.touches)
                    ey = e.touches[0].pageY;
                else
                    ey = e.pageY;
                var offsetY = ey - startY;
                var toTop = startTop + offsetY;
                if (toTop > 0)
                    toTop = 0;
                else if (toTop < vh - fullHeight - 40) {
                    toTop = vh - fullHeight - 40;
                }
                sender.css({ top: toTop });
                canLeft = toTop < 0;
                canRight = toTop > vh - fullHeight;
                sender[0].setAttribute('moved', Math.abs(offsetY) > 10 ? '1' : '0');

            }
            if (fullWidth > vw) {
                var ex = 0;
                if (e.touches)
                    ex = e.touches[0].pageX;
                else
                    ex = e.pageX;
                var offsetX = ex - startX;
                var toLeft = startLeft + offsetX;
                if (toLeft > 0)
                    toLeft = 0;
                else if (toLeft < vw - fullWidth - 40)
                    toLeft = vw - fullWidth - 40;
                sender.css({ left: toLeft });
                canLeft = toLeft < 0;
                canRight = toLeft > vw - fullWidth;
                sender[0].setAttribute('moved', Math.abs(offsetX) > 10 ? '1' : '0');
            }
            if (callback)
                callback(canLeft, canRight);
        }

        function ontouchend(e) {
            touchdown = false;
            mTimeout = setTimeout(function() {
                sender[0].setAttribute('moved', '0');
            }, 500);
        }

        return this.each(function() {
            var $this = $(this);
            var defaultBackgroundColor = $this[0].style.backgroundColor;
            $this[0].style.position = 'relative';
            $this[0].addEventListener('touchstart', ontouchsart, false);
            $this[0].addEventListener('touchmove', ontouchmove, false);
            $this[0].addEventListener('touchend', ontouchend, false);

            $this[0].addEventListener('mousedown', ontouchsart, false);
            $this[0].addEventListener('mousemove', ontouchmove, false);
            $this[0].addEventListener('mouseup', ontouchend, false);
            $this[0].addEventListener('mouseout', ontouchend, false);
            //$this.bind('touchend click', mouseupHandler);
        });
    }
})(jQuery);