/*
*   build on jQuery-1.7.2
*   $(*).dragList(...) 可拖拽列表
*   2011-12-27 by dist
*/

(function($) {
    $.fn.dragList = function(options) {
        if (!this) return false;

        this.addClass("draglist");

        var listItems = [];

        var $target = this;

        //点击回调函数
        var ic = null;

        //拖着移开1/2宽度后的回调函数
        var mc = null;

        var itemIndexChange = null;

        var enableDrag = false;

        var dragingHandle = null;

        var dragEndHandle = null;

        var startPoint = null;

        var currentItem = null;

        //是否可以选中
        var se = false;

        if (options) {

            if (options.itemClick)
                ic = options.itemClick;
            if (options.onItemMoved)
                mc = options.onItemMoved;
            if (options.indexChange)
                itemIndexChange = options.indexChange;
            if (options.dragingHandle)
                dragingHandle = options.dragingHandle;
            if (options.dragEndHandle)
                dragEndHandle = options.dragEndHandle;
            if (options.selectEnable)
                se = options.selectEnable;

            if (undefined != options.enableDrag) {
                enableDrag = options.enableDrag;
            }
            if (options.showNextIcon) {
                var child = $target[0].childNodes;
                for (var i = 0; i < child.length; i++) {
                    var li = child[i];

                    if (li.tagName != "LI")
                        continue;
                    else {
                        li.className = "nextIcon";
                    }
                }
            }
        }

        //在拖拽完成后，更新列表
        this.updateList = function() {
            var cs = $target[0].childNodes;
            listItems = [];
            for (var i = 0; i < cs.length; i++) {
                var child = cs[i];
                if (child.tagName == "LI") {
                    child.setAttribute("index", i);
                    listItems.push($(child));
                }
            }
        };

        this.getItemCount = function() {
            return listItems.length;
        }

        this.removeCurrentItem = function(item) {
            var cs = $target[0].childNodes;
            for (var i = 0; i < cs.length; i++) {
                var child = cs[i];
                if (child.tagName == "LI") {
                    if (child == item) {
                        $target[0].removeChild(child);
                    }
                }
            }
            for (var i = 0; i < listItems.length; i++) {
                listItems[i][0].style.top = "0px";
            }
            $target.updateList();

        }

        this.getSelectedItem = function() {
            return currentItem;
        }

        return this.each(function() {
            var $this = $(this);
            //当前正在实施拖拽的对象
            var moveSource = null;

            var dragTimeout = 0;
            //指示是否正在拖拽
            var dragging = false;

            //手指的起始位置
            var startPosition;

            //拖拽对象的起始位置(相对于父容器)
            var moverPosition;

            //指示当实施拖拽后其后列表是否已经移动
            var nextMoved = false;

            //拖拽目标的原始位置
            var oldIndex = 0;

            var moved = false;

            var lastPosition = null;

            function touchStart(e) {
                moved = false;
                startPoint = e;
                if (e.touches.length == 1) {
                    var t = e.target;

                    while (t && t.tagName != "LI") {
                        t = t.parentNode;
                    }

                    var listItem = t;

                    if ((!listItem) || listItem.tagName != "LI")
                        return;

                    moveSource = $(listItem);
                    moveSource.addClass("touchActive");

                    if (enableDrag) {

                        var touch = e.touches[0];
                        startPosition = { x: touch.pageX, y: touch.pageY };

                        //手指悬停半秒后激活拖拽
                        dragTimeout = setTimeout(startDrag, 500);
                    }
                } else
                    clearTimeout(dragTimeout);
            };

            function touchMove(e) {
                moved = true;
                if (e.touches.length > 1) {
                    clearTimeout(dragTimeout);
                    return;
                }
                if (dragging) {
                    var touch = e.touches[0];
                    var offsetX = touch.pageX - startPosition.x;
                    var offsetY = touch.pageY - startPosition.y;
                    moveSource[0].style.left = offsetX + "px";
                    moveSource[0].style.top = offsetY + "px";
                    if (!nextMoved) {
                        nextMoved = true;
                        var oy = moveSource.height();
                        oldIndex = getItemIndex(moveSource[0]);
                        for (var i = oldIndex + 1; i < listItems.length; i++) {
                            var nextMover = listItems[i];
                            nextMover.animate({ top: -oy }, 100);
                        }
                    }
                    if (dragingHandle) {
                        eval(dragingHandle)(e);
                    }
                    lastPosition = { x: touch.pageX, y: offsetY };
                }
                else {
                    clearTimeout(dragTimeout);
                }
            };

            function touchEnd(e) {
                clearTimeout(dragTimeout);
                $target[0].setAttribute("draging", "0");

                if (se) {
                    if (currentItem)
                        currentItem.removeClass("touchActive");
                    moveSource.addClass('touchActive');
                } else if (moveSource) {
                    moveSource.removeClass("touchActive");
                }
                currentItem = moveSource;

                //if (dragging) {
                if (dragging && nextMoved) {
                    //dragging = false;
                    var iscontinue = true;
                    if (dragEndHandle)
                        iscontinue = eval(dragEndHandle)(moveSource[0]);
                    if (iscontinue) {
                        var moveX = Math.abs(startPosition.x - lastPosition.x);
                        if (moveX > moveSource.width() / 2) {
                            if (mc) {
                                //如果回调函数返回true，则不执行下面的更新操作
                                if (mc(moveSource, startPoint))
                                    return;
                            }
                        }

                        var appendIndex = -1;
                        var mp = moveSource.position();
                        var oy = moveSource.height();

                        //把其下的列表项向下滑动
                        for (var i = 0; i < listItems.length; i++) {
                            if (i == oldIndex)
                                continue;
                            var theItem = listItems[i];
                            var lp = theItem.position();
                            if (mp.top > lp.top) {
                                appendIndex = i;
                            }
                            else {
                                theItem.animate({ top: oy }, 100);
                            }
                        }

                        //得到当前拖拽项要停留的位置
                        /* var direction = 1;
                        var iend = Math.abs(oldIndex - appendIndex);
                        if (oldIndex > appendIndex) {
                        iend--;
                        direction = -1;
                        }
                        var toY = 0;

                         for (var i = 0; i < iend; i++) {
                        toY += listItems[oldIndex + direction].height() * direction;
                        }*/
                        var toY = 0;
                        if (appendIndex != -1) {
                            for (var i = 0; i <= appendIndex; i++) {
                                if (i == oldIndex)
                                    continue;
                                toY += listItems[i].height();
                            }
                        }

                        //当前项滑动到目标位置后，重置所有列表的top，并更新子控件顺序
                        moveSource.animate({ left: 0, top: toY }, 100, null, function() {
                            if (oldIndex != appendIndex) {
                                moveSource[0].parentNode.removeChild(moveSource[0]);
                                for (var i = 0; i < listItems.length; i++) {
                                    listItems[i][0].style.top = "0px";
                                }
                                if (appendIndex == listItems.length - 1) {
                                    $this[0].appendChild(moveSource[0]);
                                } else {
                                    var nextChild = null;
                                    if (appendIndex == -1)
                                        nextChild = $this[0].childNodes[0];
                                    else
                                        nextChild = getNextChild(listItems[appendIndex][0]);
                                    $this[0].insertBefore(moveSource[0], nextChild);
                                }
                                //moveSource.removeClass("dragflag");
                                $target.updateList();
                                if (null != itemIndexChange) {
                                    itemIndexChange();
                                }
                            }
                        });
                    }

                }
                else if (ic && !moved) {
                    //ic(moveSource);

                    ic(moveSource, startPoint);
                }
                dragging = false;
                moveSource.removeClass("dragflag");
            };

            function mousedownHanlder(evt) {
                $(evt.srcElement).addClass("touchActive");
            }

            function mouseupHandler(evt) {
                var sender = $(evt.srcElement);
                sender.removeClass("touchActive");
                var cp = { targetTouches: [{ pageX: evt.pageX, pageY: evt.pageY}] };
                if (ic) {
                    ic(sender, cp);
                }
                if (se) {
                    if (currentItem)
                        currentItem.removeClass("touchActive");
                    sender.addClass('touchActive');
                } else if (moveSource) {
                    sender.removeClass("touchActive");
                }
                currentItem = sender;
            };

            function startDrag() {
                dragging = true;
                nextMoved = false;
                moveSource.removeClass("touchActive");
                moveSource.addClass("dragflag");
                moverPosition = moveSource.position();
                $target[0].setAttribute("draging", "1");
            };

            function getItemIndex(item) {
                for (var i = 0; i < listItems.length; i++) {
                    var theChild = listItems[i][0];
                    if (theChild == item)
                        return i;
                }
                return -1;
            };

            //根据提供的子项获取该项的后一子节点
            function getNextChild(child) {
                var cs = $this[0].childNodes;
                for (var i = 0; i < cs.length; i++) {
                    if (cs[i] == child)
                        return cs[i + 1];
                }
                return null;
            }


            function updateList() {

            };

            try {
                this.addEventListener("touchstart", touchStart, false);
                this.addEventListener("touchmove", touchMove, false);
                this.addEventListener("touchend", touchEnd, false);

                this.addEventListener("mousedown", mousedownHanlder, false);
                this.addEventListener("mouseup", mouseupHandler, false);
            }
            catch (e) {
            }


            $target.updateList();
        });




    }
})(jQuery);