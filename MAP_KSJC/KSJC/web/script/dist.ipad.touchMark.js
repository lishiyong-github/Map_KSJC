/*
*   build on jquery-1.7.1
*
*   $.mark 在屏幕显示触碰标记
*   $(*).mark 封装某一元素的触碰标记功能
*   2011-12-21 by dist
*/

//  $.mark jQuery类方法，非标准方式
(function($) {

    var insSequence = 1;

    //缓存对象的池，防止频繁DOM操作
    var markCache = [];

    $.mark = function(options) {
        if (markCache.length > 0) {
            var rv = markCache[0];
            markCache.splice(0, 1);
            rv.move(options.x, options.y);
            rv.active();
            return rv;
        }
        return new mk(options.x, options.y);
    };

    var mk = function(x, y) {
        //当前作用域对自身的引用，在timeout事件中访问
        var instance = this;
        var baseStyle = "touch-mark";
        var styleSequence = ["touch-mark-s3", "touch-mark-s2", "touch-mark-s1"];
        var step = 1;
        //样式渐变速度
        this.duration = 50;
        this.stateIndex = -1;
        this.timeOutVal = -100;

        this.id = "mark" + insSequence;
        insSequence++;

        this.createElement = function() {
            var ele = document.createElement("DIV");
            ele.setAttribute("ismark", true);
            document.body.appendChild(ele);
            return ele;
        };

        //ontimeout Handler
        this.changeState = function() {
            instance.stateIndex += 1 * step;

            if (instance.stateIndex < styleSequence.length && instance.stateIndex >= 0) {
                instance.element.className = baseStyle + " " + styleSequence[instance.stateIndex];
                instance.timeOutVal = setTimeout(instance.changeState, instance.duration);
            } else {
                instance.timeOutVal = -100;
                if (step == -1) {
                    instance.element.style.display = 'none';
                    //未被使用的标记放回到缓存池中
                    markCache.push(instance);
                    //document.body.removeChild(instance.element);
                }
            }
        };

        this.move = function(x, y) {
            this.element.style.left = (x - 47) + "px";
            this.element.style.top = (y - 50) + "px";
            this.x = x;
            this.y = y;
        }

        this.active = function() {
            clearTimeout(this.timeOutVal);
            step = 1;
            this.element.style.display = '';
            this.stateIndex = -1;
            this.timeOutVal = setTimeout(this.changeState, this.duration);
        };

        this.remove = function() {
            if (this.timeOutVal != -100)
                clearTimeout(this.timeOutVal);
            step = -1;
            this.stateIndex = styleSequence.length - 1;
            this.timeOutVal = setTimeout(this.changeState, this.duration);
        };

        this.element = this.createElement();
        this.move(x, y);
        markCache.push(this);
        timeOutVal = setTimeout(this.changeState, this.duration);
    };

})(jQuery);


//  $(*).mark
(function($) {

    var nomarksequence = 0;

    $.extend($.fn, {
        //<summary>
        //应用触摸标记
        //</summary>
        mark: function(setting) {
            var ps = $.extend({
                //触发标记的手指数，0表示任何点的触摸都将显示标记
                minTouch: 0,
                //handler(type,data),type=centerChanged|startMark|endMark,data=事件源的数据
                eventHandler: null
            }, setting);
            var sender = $(this);
            if (ps.eventHandler)
                sender.eh = ps.eventHandler;
            sender.currentSequence = nomarksequence;
            nomarksequence++;
            if (!sender[0] || !sender[0].addEventListener)
                return sender;
            //ontouchstart 这时添加标记
            sender[0].addEventListener("touchstart", function(e) {

                var nms = "nomark" + sender.currentSequence;
                var tn = e.target.tagName;
                //alert(e.target + "  " + e.target[nms]);
                if (tn == "SELECT" || tn == "INPUT" || tn=="A")
                    return;
                if ((e.target.getAttribute && (e.target.getAttribute("ismark") || e.target.getAttribute('nomark'))) || e.target[nms] || e.target['nomark']) {
                    return;
                }


                var mcount = sender.marks.length;
                sender.clear();
                if (ps.minTouch != 0 && e.touches.length != ps.minTouch) {
                    if (mcount > 0)
                        sender.dispetchEndEvent();
                    return;
                }

                for (var i = 0; i < e.touches.length; i++) {
                    var touch = e.touches[i];
                    sender.marks.push($.mark({ x: touch.pageX, y: touch.pageY }));
                }

                var startC = sender.calcCenter(e.touches);
                if (sender.eh)
                    sender.eh("startMark", startC);
                sender.updateCenter(startC);
                return true;
            });

            //ontouchmove 标记跟随手指移动
            sender[0].addEventListener("touchmove", function(e) {
                for (var i = 0; i < e.changedTouches.length; i++) {
                    var touch = e.changedTouches[i];
                    //找到最近的标记
                    var markIndex = sender.findNearMaker(touch.pageX, touch.pageY);

                    if (-1 == markIndex)
                        continue;
                    sender.marks[markIndex].move(touch.pageX, touch.pageY);
                }
                if (sender.marks.length > 0) {
                    var cen = sender.calcCenter(e.touches);
                    sender.updateCenter(cen);
                }
            });

            //ontouchend
            sender[0].addEventListener("touchend", function(e) {
                //如果触摸点数量不等于minTouch，则移除所有标记
                if (ps.minTouch != 0 && e.touches.length != ps.minTouch) {
                    if (sender.marks.length > 0) {
                        sender.clear();
                        sender.dispetchEndEvent();
                    }
                } else {
                    for (var i = 0; i < e.changedTouches.length; i++) {
                        var touche = e.changedTouches[i];
                        //找到最近的标记进行删除
                        var theMarkIndex = sender.findNearMaker(touche.pageX, touche.pageY);
                        if (-1 == theMarkIndex) {
                            continue;
                        }
                        var theMark = sender.marks[theMarkIndex];
                        theMark.remove();
                        sender.marks.splice(theMarkIndex, 1);
                    }
                    if (e.touches.length == 0) {
                        sender.clear();
                        sender.dispetchEndEvent();
                    }
                }
            });

            sender[0].addEventListener("ongesturechange", function(e) {

            });

            return sender;
        },
        //当前显示的标记列表
        marks: [],
        cp: { x: -1, y: -1 },
        eh: null,
        //清除所有标记
        clear: function() {
            for (var i = this.marks.length - 1; i >= 0; i--) {
                this.marks[i].remove();
            }
            this.marks = [];
        },
        currentSequence: 0,
        //提供相对于页面左上角的坐标，找到距该坐标最近的标记
        findNearMaker: function(x, y) {
            if (this.marks.length == 0)
                return -1;
            var index = -1, lx = 0, ly = 0;
            for (var i = 0; i < this.marks.length; i++) {
                var theMark = this.marks[i];
                var xn = Math.abs(x - theMark.x);
                var xy = Math.abs(y - theMark.y);
                if (index == -1 || xn < lx || xy < ly) {
                    index = i;
                    lx = xn;
                    ly = xy;
                }
            }
            return index;
        },

        updateCenter: function(newC) {
            if (this.cp.x == -1 && this.cp.y == -1) {
                this.cp.x = newC.x;
                this.cp.y = newC.y;
            }
            var oldC = this.cp;
            this.cp = newC;
            if (this.eh) {
                this.eh("centerChanged", { x: newC.x, y: newC.y, oldX: oldC.x, oldY: oldC.y });
            }
        },
        //计算中心位置
        calcCenter: function(touches) {
            var maxX = 0, maxY = 0, minX, minY;
            for (var i = 0; i < touches.length; i++) {
                var touch = touches[i];
                if (touch.pageX > maxX)
                    maxX = touch.pageX;
                if (touch.pageY > maxY)
                    maxY = touch.pageY;
                if ((!minX) || touch.pageX < minX)
                    minX = touch.pageX;
                if ((!minY) || touch.pageY < minY)
                    minY = touch.pageY;
            }
            return { x: minX + (maxX - minX) / 2, y: minY + (maxY - minY) / 2 };
        },
        dispetchEndEvent: function() {
            if (this.eh)
                this.eh("endMark", null);
        },
        //设置例外，某些子控件可能不需要显示标记
        setExceptions: function(vas) {
            for (var i = 0; i < vas.length; i++) {
                var theEx = dist.$g(vas[i]);
                this.setChildExceptions(theEx);
            }
        },
        setChildExceptions: function(ele) {
            var nms = 'nomark' + this.currentSequence;
            var cs = ele.childNodes;
            if (ele.setAttribute)
                ele.setAttribute(nms, '1');
            ele[nms] = 1;
            for (var i = 0; i < cs.length; i++) {
                var child = cs[i];
                if (child.setAttribute) {
                    child.setAttribute(nms, '1');
                    this.setChildExceptions(child);
                }
                child[nms] = 1;
            }
        }
    });

})(jQuery);