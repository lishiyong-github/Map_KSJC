

var imgs = [];
var currentIndex = 1;
var sp, ep, moveing;
var player = null;
var imgLeft;
var moving = false;
function onImgTouchstart(e) {
    sp = e.touches[0].pageX;
    imgLeft = $(imgs[currentIndex]).position().left;
}

function onImgTouchmove(e) {
    var p = e.touches[0].pageX;
    var offsetX = p - sp;
    if (Math.abs(offsetX) > 20)
        moving = true;
    imgs[currentIndex].style.left = (imgLeft + offsetX) + 'px';
}

function onImgTouchend(e) {
    ep = e.changedTouches[0].pageX;
    if (Math.abs(ep - sp) > 50) {
        if (sp > ep)
            nextImg();
        else
            previousImg();
    }
}

function nextImg(isAuto) {
    if (currentIndex < imgs.length - 1) {
        currentIndex++;
    } else if (isAuto) {
        currentIndex = 0;
    }
    //        if (isAuto)
    //            dist.desktop.main.autoplay();
    updateImgPlayer();
}

function previousImg() {
    if (currentIndex > 0) {
        currentIndex--;
    }
    updateImgPlayer();
}

function updateImgPlayer() {
    var i = currentIndex;
    for (j = i - 2; j >= 0; j--) {
        imgs[j].className = 'p0';
        imgs[j].style.left = '-300px';
    }
    if (imgs[i - 2]) {
        imgs[i - 2].className = 'p0';
        imgs[i - 2].style.left = '-300px';
    }
    if (imgs[i - 1]) {
        imgs[i - 1].className = 'p1';
        imgs[i - 1].style.left = '-2px';
    }
    if (imgs[i]) {
        imgs[i].className = 'current';
        imgs[i].style.left = '270px';
    }
    if (imgs[i + 1]) {
        imgs[i + 1].className = 'p2';
        imgs[i + 1].style.left = '730px';
    }
    if (imgs[i + 2]) {
        imgs[i + 2].className = 'p3';
        imgs[i + 2].style.left = '1214px';
    }
    for (var j = i + 2; j < imgs.length; j++) {
        imgs[j].className = 'p3';
        imgs[j].style.left = '1214px';
    }
}