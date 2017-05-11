
(function() {

    function fi(fm, fk) {
        if (!gIsTouch) {
            return
        } var fn = this;
        fn.element = typeof fm == "object" ? fm : document.getElementById(fm);
        fn.wrapper = fn.element.parentNode;
        fn.options = {
            bounce: fc, momentum: fc, checkDOMChanges: true, topOnDOMChanges: false, hScrollbar: fc, vScrollbar: fc, fadeScrollbar: e9 || fa || !e7, shrinkScrollbar: e9 || fa, desktopCompatibility: false, overflow: "auto", scrollbarColor: "0,0,0,0.5"
        };

        if (typeof fk == "object") {
            for (var fl in fk) {
                fn.options[fl] = fk[fl]
            }
        } if (fn.options.desktopCompatibility) {
            fn.options.overflow = "hidden"
        } fn.wrapper.style.overflow = fn.options.overflow;
        fn.refresh();

        window.addEventListener("onorientationchange" in window ? "orientationchange" : "resize", fn, false);
        if (e7 || fn.options.desktopCompatibility) {
            fn.element.addEventListener(fe, fn, false);
            fn.element.addEventListener(fh, fn, false);
            fn.element.addEventListener(fd, fn, false);
        } if (fn.options.checkDOMChanges) {
            fn.element.addEventListener("DOMSubtreeModified", fn, false)
        } if (!e7) {
            fn.element.addEventListener("click", fn, true)
        }
    }
    fi.prototype = {
        x: 0, y: 0, dist: 0, handleEvent: function(fl) {
            var fk = this;
            switch (fl.type) {
                case "click": if (!fl._fake) {
                        fl.stopPropagation()
                    } break;
                case fe: fk.touchStart(fl);
                    break;
                case fh: fk.touchMove(fl);
                    break;
                case fd: fk.touchEnd(fl);
                    break;
                case "webkitTransitionEnd": fk.transitionEnd(fl);
                    break;
                case "orientationchange": case "resize": fk.refresh();
                    break;
                case "DOMSubtreeModified": fk.onDOMModified(fl);
                    break
            }
        }, onDOMModified: function(fl) {
            var fk = this;
            fk.refresh();
            if (fk.options.topOnDOMChanges && (fk.x != 0 || fk.y != 0)) {
                fk.scrollTo(0, 0, "0")
            }
        }, refresh: function() {
            var fk = this, fm = this.x, fl = this.y;
            fk.scrollWidth = fk.wrapper.clientWidth;
            fk.scrollHeight = fk.wrapper.clientHeight;
            fk.scrollerWidth = fk.element.offsetWidth;
            fk.scrollerHeight = fk.element.offsetHeight;
            fk.maxScrollX = fk.scrollWidth - fk.scrollerWidth;
            fk.maxScrollY = fk.scrollHeight - fk.scrollerHeight;
            if (fk.scrollX) {
                if (fk.maxScrollX >= 0) {
                    fm = 0
                } else {
                    if (fk.x < fk.maxScrollX) {
                        fm = fk.maxScrollX
                    }
                }
            } if (fk.scrollY) {
                if (fk.maxScrollY >= 0) {
                    fl = 0
                } else {
                    if (fk.y < fk.maxScrollY) {
                        fl = fk.maxScrollY
                    }
                }
            } if (fm != fk.x || fl != fk.y) {
                fk.setTransitionTime("0");
                fk.setPosition(fm, fl, true)
            } fk.scrollX = fk.scrollerWidth > fk.scrollWidth;
            fk.scrollY = !fk.scrollX || fk.scrollerHeight > fk.scrollHeight;
            if (fk.options.hScrollbar && fk.scrollX) {
                fk.scrollBarX = fk.scrollBarX || new fj("horizontal", fk.wrapper, fk.options.fadeScrollbar, fk.options.shrinkScrollbar, fk.options.scrollbarColor);
                fk.scrollBarX.init(fk.scrollWidth, fk.scrollerWidth)
            } else {
                if (fk.scrollBarX) {
                    fk.scrollBarX = fk.scrollBarX.remove()
                }
            } if (fk.options.vScrollbar && fk.scrollY && fk.scrollerHeight > fk.scrollHeight) {
                fk.scrollBarY = fk.scrollBarY || new fj("vertical", fk.wrapper, fk.options.fadeScrollbar, fk.options.shrinkScrollbar, fk.options.scrollbarColor);
                fk.scrollBarY.init(fk.scrollHeight, fk.scrollerHeight)
            } else {
                if (fk.scrollBarY) {
                    fk.scrollBarY = fk.scrollBarY.remove()
                }
            }
        }, setPosition: function(fk, fn, fm) {
            var fl = this;
            fl.x = fk;
            fl.y = fn;
            fl.element.style.webkitTransform = fg + fl.x + "px," + fl.y + "px" + e8;
            if (!fm) {
                if (fl.scrollBarX) {
                    fl.scrollBarX.setPosition(fl.x)
                } if (fl.scrollBarY) {
                    if (fl.options.onscroll)
                        fl.options.onscroll(fl.y);
                    fl.scrollBarY.setPosition(fl.y)
                }
            }
        }, setTransitionTime: function(fl) {
            var fk = this;
            fl = fl || "0";
            fk.element.style.webkitTransitionDuration = fl;
            if (fk.scrollBarX) {
                fk.scrollBarX.bar.style.webkitTransitionDuration = fl;
                fk.scrollBarX.wrapper.style.webkitTransitionDuration = fc && fk.options.fadeScrollbar ? "300ms" : "0"
            } if (fk.scrollBarY) {
                fk.scrollBarY.bar.style.webkitTransitionDuration = fl;
                fk.scrollBarY.wrapper.style.webkitTransitionDuration = fc && fk.options.fadeScrollbar ? "300ms" : "0"
            }
        }, touchStart: function(fm) {
            try {
                if (fm && fm.target && fm.target.getAttribute("noTouch")) {
                    return
                }
            } catch (fm) {
            } var fl = this, fk;
            fl.scrolling = true;
            //fm.preventDefault();
            //fm.stopPropagation();
            fl.moved = false;
            fl.dist = 0;
            fl.setTransitionTime("0");
            if (fl.options.momentum) {
                fk = new WebKitCSSMatrix(window.getComputedStyle(fl.element).webkitTransform);
                if (fk.e != fl.x || fk.f != fl.y) {
                    fl.element.removeEventListener("webkitTransitionEnd", fl, false);
                    fl.moved = true
                }
            } fl.touchStartX = e7 ? fm.changedTouches[0].pageX : fm.pageX;
            fl.scrollStartX = fl.x;
            fl.touchStartY = e7 ? fm.changedTouches[0].pageY : fm.pageY;
            fl.scrollStartY = fl.y;
            fl.scrollStartTime = fm.timeStamp
        }, touchMove: function(fq) {

            if ("1" == this.element.getAttribute("draging"))
                return;
            if (fq.target) {
                var tagName = fq.target.tagName;
                if ("INPUT" == tagName || "TEXTAREA" == tagName || "SELECT" == tagName) {
                    fq.stopPropagation();
                    fq.preventDefault();
                    return false;
                }
            }
            var fo = this, fn = e7 ? fq.changedTouches[0].pageX : fq.pageX, fm = e7 ? fq.changedTouches[0].pageY : fq.pageY, fl = fo.scrollX ? fn - fo.touchStartX : 0, fk = fo.scrollY ? fm - fo.touchStartY : 0, fr = fo.x + fl, fp = fo.y + fk;
            if (!fo.scrolling) {
                return
            } fo.dist += Math.abs(fo.touchStartX - fn) + Math.abs(fo.touchStartY - fm);
            fo.touchStartX = fn;
            fo.touchStartY = fm;
            if (fr > 0 || fr < fo.maxScrollX) {
                fr = fo.options.bounce ? Math.round(fo.x + fl / 3) : fr >= 0 ? 0 : fo.maxScrollX
            } if (fp > 0 || fp < fo.maxScrollY) {
                fp = fo.options.bounce ? Math.round(fo.y + fk / 3) : fp >= 0 ? 0 : fo.maxScrollY
            } if (fo.dist > 5) {
                fo.setPosition(fr, fp);
                fo.moved = true
            }
        }, touchEnd: function(fr) {
            var fq = this, fn = fr.timeStamp - fq.scrollStartTime, fs, ft, fl, fk, fm, fp, fo;
            if (!fq.scrolling) {
                return
            } fq.scrolling = false;
            if (!fq.moved) {
                fq.resetPosition();
                fs = e7 ? fr.changedTouches[0].target : fr.target;
                while (fs.nodeType != 1) {
                    fs = fs.parentNode
                } ft = document.createEvent("Event");
                ft.initEvent("focus", true, true);
                fs.dispatchEvent(ft);
                ft = document.createEvent("MouseEvents");
                ft.initMouseEvent("click", true, true, fr.view, 1, fs.screenX, fs.screenY, fs.clientX, fs.clientY, fr.ctrlKey, fr.altKey, fr.shiftKey, fr.metaKey, 0, null);
                ft._fake = true;
                fs.dispatchEvent(ft);
                return
            } if (!fq.options.momentum || fn > 250) {
                fq.resetPosition();
                return
            } fl = fq.scrollX === true ? fq.momentum(fq.x - fq.scrollStartX, fn, fq.options.bounce ? -fq.x + fq.scrollWidth / 5 : -fq.x, fq.options.bounce ? fq.x + fq.scrollerWidth - fq.scrollWidth + fq.scrollWidth / 5 : fq.x + fq.scrollerWidth - fq.scrollWidth) : {
                dist: 0, time: 0
            };
            fk = fq.scrollY === true ? fq.momentum(fq.y - fq.scrollStartY, fn, fq.options.bounce ? -fq.y + fq.scrollHeight / 5 : -fq.y, fq.options.bounce ? (fq.maxScrollY < 0 ? fq.y + fq.scrollerHeight - fq.scrollHeight : 0) + fq.scrollHeight / 5 : fq.y + fq.scrollerHeight - fq.scrollHeight) : {
                dist: 0, time: 0
            };
            if (!fl.dist && !fk.dist) {
                fq.resetPosition();
                return
            } fm = Math.max(Math.max(fl.time, fk.time), 1);
            fp = fq.x + fl.dist;
            fo = fq.y + fk.dist;
            fq.scrollTo(fp, fo, fm + "ms")
        }, transitionEnd: function() {
            this.element.removeEventListener("webkitTransitionEnd", this, false);
            this.resetPosition()
        }, resetPosition: function(fm) {
            var fk = this, fn = fk.x, fl = fk.y, fk = fk, fm = fm || "500ms";
            if (fk.x >= 0) {
                fn = 0
            } else {
                if (fk.x < fk.maxScrollX) {
                    fn = fk.maxScrollX
                }
            } if (fk.y >= 0 || fk.maxScrollY > 0) {
                fl = 0
            } else {
                if (fk.y < fk.maxScrollY) {
                    fl = fk.maxScrollY
                }
            } if (fn != fk.x || fl != fk.y) {
                fk.scrollTo(fn, fl, fm)
            } else {
                if (fk.scrollBarX || fk.scrollBarY) {
                    if (fk.scrollBarX) {
                        fk.scrollBarX.hide()
                    } if (fk.scrollBarY) {
                        fk.scrollBarY.hide()
                    }
                }
            }
        }, scrollTo: function(fl, fk, fn) {
            var fm = this;
            fm.setTransitionTime(fn || "450ms");
            fm.setPosition(fl, fk);
            if (fn === "0" || fn == "0s" || fn == "0ms") {
                fm.resetPosition()
            } else {
                fm.element.addEventListener("webkitTransitionEnd", fm, false)
            }
        }, scrollToElement: function(fl, fn) {
            fl = typeof fl == "object" ? fl : this.element.querySelector(fl);
            if (!fl) {
                return
            } var fm = this, fk = fm.scrollX ? -fl.offsetLeft : 0, fo = fm.scrollY ? -fl.offsetTop : 0;
            if (fk >= 0) {
                fk = 0
            } else {
                if (fk < fm.maxScrollX) {
                    fk = fm.maxScrollX
                }
            } if (fo >= 0) {
                fo = 0
            } else {
                if (fo < fm.maxScrollY) {
                    fo = fm.maxScrollY
                }
            } fm.scrollTo(fk, fo, fn)
        }, momentum: function(fr, fl, fp, fk) {
            var fo = 2.5, fq = 1.2, fm = Math.abs(fr) / fl * 1000, fn = fm * fm / fo / 1000, fs = 0;
            if (fr > 0 && fn > fp) {
                fm = fm * fp / fn / fo;
                fn = fp
            } else {
                if (fr < 0 && fn > fk) {
                    fm = fm * fk / fn / fo;
                    fn = fk
                }
            } fn = fn * (fr < 0 ? -1 : 1);
            fs = fm / fq;
            return {
                dist: Math.round(fn), time: Math.round(fs)
            }
        }, destroy: function(fk) {
            var fl = this;
            window.removeEventListener("orientationchange", fl, false);
            window.removeEventListener("resize", fl, false);
            fl.element.removeEventListener(fe, fl, false);
            fl.element.removeEventListener(fh, fl, false);
            fl.element.removeEventListener(fd, fl, false);
            fl.element.removeEventListener("DOMSubtreeModified", fl, false);
            fl.element.removeEventListener("click", fl, true);
            fl.element.removeEventListener("webkitTransitionEnd", fl, false);
            if (fl.scrollBarX) {
                fl.scrollBarX = fl.scrollBarX.remove()
            } if (fl.scrollBarY) {
                fl.scrollBarY = fl.scrollBarY.remove()
            } if (fk) {
                fl.wrapper.parentNode.removeChild(fl.wrapper)
            } return null
        }
    };
    var fj = function(fl, fr, fq, fn, cl) {
        var fp = this;
        fp.dir = fl;
        fp.fade = fq;
        fp.shrink = fn;
        fp.uid = ++fb;
        fp.bar = document.createElement("div");
        var fo = "position:absolute;top:0;left:0;-webkit-transition-timing-function:cubic-bezier(0,0,0.25,1);pointer-events:none;-webkit-transition-duration:0;-webkit-transition-delay:0;-webkit-transition-property:-webkit-transform;z-index:10;background:rgba(" + cl + ");-webkit-transform:" + fg + "0,0" + e8 + ";" + (fl == "horizontal" ? "-webkit-border-radius:3px 2px;min-width:6px;min-height:5px" : "-webkit-border-radius:2px 3px;min-width:5px;min-height:6px"), fm, fk;
        fp.bar.setAttribute("style", fo);
        fp.wrapper = document.createElement("div");
        fo = "-webkit-mask:-webkit-canvas(scrollbar" + fp.uid + fp.dir + ");position:absolute;z-index:10;pointer-events:none;overflow:hidden;opacity:0;-webkit-transition-duration:" + (fq ? "300ms" : "0") + ";-webkit-transition-delay:0;-webkit-transition-property:opacity;" + (fp.dir == "horizontal" ? "bottom:2px;left:1px;right:7px;height:5px" : "top:1px;right:2px;bottom:7px;width:5px;");
        fp.wrapper.setAttribute("style", fo);
        fp.wrapper.appendChild(fp.bar);
        fr.appendChild(fp.wrapper)
    };
    fj.prototype = {
        init: function(fk, fn) {
            var fo = this, fl, fm;
            if (fo.dir == "horizontal") {
                fm = fo.wrapper.offsetWidth;
                fl = document.getCSSCanvasContext("2d", "scrollbar" + fo.uid + fo.dir, fm, 5);
                fl.fillStyle = "rgb(0,0,0)";
                fl.beginPath();
                fl.arc(2.5, 2.5, 2.5, Math.PI / 2, -Math.PI / 2, false);
                fl.lineTo(fm - 2.5, 0);
                fl.arc(fm - 2.5, 2.5, 2.5, -Math.PI / 2, Math.PI / 2, false);
                fl.closePath();
                fl.fill()
            } else {
                fm = fo.wrapper.offsetHeight;
                fl = document.getCSSCanvasContext("2d", "scrollbar" + fo.uid + fo.dir, 5, fm);
                fl.fillStyle = "rgb(0,0,0)";
                fl.beginPath();
                fl.arc(2.5, 2.5, 2.5, Math.PI, 0, false);
                fl.lineTo(5, fm - 2.5);
                fl.arc(2.5, fm - 2.5, 2.5, 0, Math.PI, false);
                fl.closePath();
                fl.fill()
            } fo.maxSize = fo.dir == "horizontal" ? fo.wrapper.clientWidth : fo.wrapper.clientHeight;
            fo.size = Math.round(fo.maxSize * fo.maxSize / fn);
            fo.maxScroll = fo.maxSize - fo.size;
            fo.toWrapperProp = fo.maxScroll / (fk - fn);
            fo.bar.style[fo.dir == "horizontal" ? "width" : "height"] = fo.size + "px"
        }, setPosition: function(fm, fl) {
            var fk = this;
            if (!fl && fk.wrapper.style.opacity != "1") {
                fk.show()
            } fm = fk.toWrapperProp * fm;

            if (fm < 0) {
                fm = fk.shrink ? fm + fm * 3 : 0;
                if (fk.size + fm < 5) {
                    fm = -fk.size + 5
                }
            } else {
                if (fm > fk.maxScroll) {
                    fm = fk.shrink ? fm + (fm - fk.maxScroll) * 3 : fk.maxScroll;
                    if (fk.size + fk.maxScroll - fm < 5) {
                        fm = fk.size + fk.maxScroll - 5
                    }
                }
            } fm = fk.dir == "horizontal" ? fg + Math.round(fm) + "px,0" + e8 : fg + "0," + Math.round(fm) + "px" + e8;
            fk.bar.style.webkitTransform = fm
        }, show: function() {
            if (fc) {
                this.wrapper.style.webkitTransitionDelay = "0"
            } this.wrapper.style.opacity = "1"
        }, hide: function() {
            if (fc) {
                this.wrapper.style.webkitTransitionDelay = "200ms"
            } this.wrapper.style.opacity = "0"
        }, remove: function() {
            this.wrapper.parentNode.removeChild(this.wrapper);
            return null
        }
    };
    var fc = ("WebKitCSSMatrix" in window && "m11" in new WebKitCSSMatrix()), e9 = (/iphone/gi).test(navigator.appVersion), fa = (/ipad/gi).test(navigator.appVersion), ff = (/android/gi).test(navigator.appVersion), e7 = e9 || fa || ff, e6 = (/mobilesafari/gi).test(navigator.appVersion), fe = e7 ? "touchstart" : "mousedown", fh = e7 ? "touchmove" : "mousemove", fd = e7 ? "touchend" : "mouseup", fg = "translate" + (fc ? "3d(" : "("), e8 = fc ? ",0)" : ")", fb = 0;
    window.gIsTouch = true;
    window.gIsCell = e6 || e9;
    window.iScroll = fi;
})();
