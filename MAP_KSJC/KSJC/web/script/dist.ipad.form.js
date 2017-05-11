
var formListService = "GetData.ashx?t=JsonHome&methodName=formList";
var formDetailService = "GetData.ashx?t=JsonHome&methodName=formDetail";
var formSaveService = "GetData.ashx?t=JsonHome&methodName=save";
var formSendListService = "GetData.ashx?t=JsonHome&methodName=sendList";
var formSendService = "GetData.ashx?t=JsonHome&methodName=send";

formListService = "http://58.246.138.178:8040/ZZZFServices/ServiceProvider.ashx?t=JsonHome&methodName=formList";
formDetailService = "http://58.246.138.178:8040/ZZZFServices/ServiceProvider.ashx?t=JsonHome&methodName=formDetail";
formSaveService = "http://58.246.138.178:8040/ZZZFServices/ServiceProvider.ashx?t=JsonHome&methodName=save";
formSendListService = "http://58.246.138.178:8040/ZZZFServices/ServiceProvider.ashx?t=JsonHome&methodName=sendList";
formSendService = "http://58.246.138.178:8040/ZZZFServices/ServiceProvider.ashx?t=JsonHome&methodName=send";


dist.form = function(container, options) {
    
    formListService = serviceUrl + '?type=smartplan&action=formList';
    formDetailService = serviceUrl + "?type=smartplan&action=formDetail";
    formSaveService = serviceUrl + "?type=smartplan&action=save";
    formSendListService = serviceUrl + "?type=smartplan&action=sendList";
    formSendService = serviceUrl + "?type=smartplan&action=send";
    this.eleFlag = Math.random();
    this.ele = dist.$g(container);
    this.showToolbar = true;
    this.editable = true;
    if (options) {
        if (undefined != options.sendCompleted)
            this.sendCompleted = options.sendCompleted;
        if (undefined != options.showToolbar)
            this.showToolbar = !!options.showToolbar;
        if (undefined != options.editable)
            this.editable = !!options.editable;
    }

    this.ele.innerHTML = '<div>' +
                                '<div class="form-selector-box" id="form-selector-box-' + this.eleFlag + '">' +
                                    '<select id="form-selector-' + this.eleFlag + '"></select>' +
                                '</div>' +
                                '<div id="form-detail-box-' + this.eleFlag + '" class="form-detail-box">' +
                                    '<div id="form-detail-scroller-' + this.eleFlag + '"></div>' +
                                    '<ul id="form-send-list-' + this.eleFlag + '" style="display:none"></ul>' +
                                    '<ul id="form-sendback-list-' + this.eleFlag + '" style="display:none"></ul>' +
                                    '<div id="form-waiting-' + this.eleFlag + '" style="display:none"></div>' +
                                '</div>' +
                                '<div id="form-toolbar-' + this.eleFlag + '" class="form-toolbar">' +
                                    '<div id="form-button-save-' + this.eleFlag + '" class="form-toolbar-save" ></div>' +
                                    '<div id="form-button-send-' + this.eleFlag + '" class="form-toolbar-send" ></div>' +
                                    '<div id="form-button-sendback-' + this.eleFlag + '" class="form-toolbar-sendback" ></div>' +
                                    '<div id="form-button-goback-' + this.eleFlag + '" class="form-toolbar-goback"></div>' +
                                '</div>' +
                          '</div><div></div>';

    this.formSelectorBox = dist.$g('form-selector-box-' + this.eleFlag);
    this.formSelector = dist.$g('form-selector-' + this.eleFlag);
    this.formDetail = dist.$g('form-detail-scroller-' + this.eleFlag);
    this.sendListControl = dist.$g('form-send-list-' + this.eleFlag);
    this.sendBackListControl = dist.$g('form-sendback-list-' + this.eleFlag);
    this.toolbar = dist.$g('form-toolbar-' + this.eleFlag);
    this.btnSend = $(dist.$g('form-button-send-' + this.eleFlag));
    this.btnSendback = $(dist.$g('form-button-sendback-' + this.eleFlag));
    this.btnSave = $(dist.$g('form-button-save-' + this.eleFlag));
    this.btnGoback = $(dist.$g('form-button-goback-' + this.eleFlag)).hide();
    this.formBox = dist.$g('form-detail-box-' + this.eleFlag);
    this.waitingContainer = dist.$g('form-waiting-' + this.eleFlag);
    this.projectId = null;
    this.formContainer = this.ele.childNodes[0];
    this.errorMessageContainer = this.ele.childNodes[1];

    this.loadingHtml = '<div class="waiting"><img src="loading.gif" /><br /><br />请稍候</div>';
    this.waitingContainer.innerHTML = this.loadingHtml;

    if (!this.showToolbar)
        this.toolbar.style.display = 'none';

    //局部form对象，用于子作用域的事件回调中
    var $s = this;

    //存储表单列表，由formListService返回
    this.forms = null;

    //当前打开的表单
    this.currentFormData = null;

    this.currentSendListData = null;
    this.currentSendBackListData = null;

    //表单控件树
    this.controls = {};

    this.sendListInitialized = false;
    this.sendBackListInitialzie = false;

    this.detailScroller = null;

    new iScroll('form-send-list-' + this.eleFlag);
    new iScroll('form-sendback-list-' + this.eleFlag);

    this.btnSave.touchlink().bind('touchend click', function() {
        $s.save();
    });

    this.btnSend.touchlink().bind('touchend click', function() {
        $s.showSendList();
    });

    this.btnSendback.touchlink().bind('touchend click', function() {
        $s.showSendBackList();
    });

    this.btnGoback.touchlink().bind('touchend click', function() {
        $s.dispayForm();
    });

    $(this.formSelector).bind('change', function() {
        $s.changeForm();
    });

    $(this.sendListControl).dragList({ itemClick: function(sender) { $s.doSend(sender); } });

    $(this.sendBackListControl).dragList({ itemClick: function(sender) { $s.doSend(sender, true); } });

    this.showErrorMesssage = function(msg) {
        this.errorMessageContainer.innerText = msg;
    };

    this.showFormItemErrorMessage = function() {
        this.formDetail.innerHTML = '表单加载失败';
    }

    this.displayWating = function() {
        this.formDetail.style.display = 'none';
        this.sendListControl.style.display = 'none';
        this.sendBackListControl.style.display = 'none';
        this.waitingContainer.style.display = 'block';
    };

    this.dispayForm = function() {
        this.formDetail.style.display = 'block';
        this.sendListControl.style.display = 'none';
        this.sendBackListControl.style.display = 'none';
        this.waitingContainer.style.display = 'none';
        this.btnGoback.hide();
        this.btnSave.show();
        this.btnSend.show();
        this.btnSendback.show();
    };

    this.dispaySendList = function() {
        this.formDetail.style.display = 'none';
        this.sendListControl.style.display = 'block';
        this.sendBackListControl.style.display = 'none';
        this.waitingContainer.style.display = 'none';
        this.btnGoback.show();
        this.btnSave.hide();
        this.btnSendback.hide();
        this.btnSend.hide();
    };

    this.displaySendBackList = function() {
        this.dispaySendList();
        this.sendListControl.style.display = 'none';
        this.sendBackListControl.style.display = 'block';
    };

    this.checkSize = function() {
        var h = $(this.ele).height() - $(this.formSelectorBox).height() - (this.showToolbar ? $(this.toolbar).height() : 0) - 2;
        this.formBox.style.height = h + 'px';
    };
    this.clear = function(projectId) {
        this.controls = {};
        this.projectId = projectId;
        this.checkSize();
        this.formSelector.innerHTML = '';
        this.formDetail.innerHTML = '';
        this.currentSendBackListData = this.currentSendListData = null;
        this.sendBackListInitialzie = this.sendListInitialized = false;
    };

    this.load = function(projectId) {
        this.clear(projectId);
        $.ajax({
            url: formListService,
            data: { project: projectId },
            dataType: 'json',
            success: function(data) {
                $s.createFormSelector(data);
            },
            error: function() {
                $s.showErrorMesssage('表单加载失败');
            }
        });
    };

    this.createFormSelector = function(forms) {
        this.formSelector.innerHTML = '';
        this.forms = forms.result;
        for (var i = 0; i < this.forms.length; i++) {
            var formItem = this.forms[i];
            var option = new Option(formItem.name, i);
            this.formSelector.options[i] = option;
        }
        if (this.forms.length > 0)
            this.showFormItem(this.forms[0].id, this.forms[0].busiFormId);
    };

    this.changeForm = function() {
        var formItem = this.forms[parseInt(this.formSelector.value)];
        if (formItem)
            this.showFormItem(formItem.id, formItem.busiFormId);
    };

    this.showFormItem = function(formId, busiFormId) {
        this.displayWating();
        $.ajax({
            url: formDetailService,
            data: { form: formId, user: dist.userid, project: this.projectId, busiFormId: busiFormId },
            dataType: 'json',
            success: function(data) {
                $s.createFormPanel(data);
            },
            error: function() {
                $s.showFormItemErrorMessage();
            }
        });
    };

    this.createFormPanel = function(data) {
        this.currentFormData = data.result;
        this.formDetail.innerHTML = '';
        var df = document.createDocumentFragment();
        for (var i = 0; i < this.currentFormData.length; i++) {
            var control = this.createFormControl(this.currentFormData[i]);
            if (control)
                df.appendChild(control);
        }
        this.formDetail.appendChild(df);
        this.dispayForm();
        if (this.detailScroller)
            this.detailScroller.destroy();
        this.detailScroller = new iScroll('form-detail-scroller-' + this.eleFlag);
    };

    this.createFormControl = function(item) {
        var div = document.createElement('DIV');
        div.className = 'form-item';
        var nameDiv = document.createElement('DIV');
        nameDiv.className = 'form-item-name';
        nameDiv.innerText = item.text;
        var valDiv = document.createElement('DIV');
        valDiv.className = 'form-item-input';


        var input = null;
        var input2 = null;

        if (this.editable) {

            if (item.extensionType == '文本框') {
                input = document.createElement('INPUT');
            } else if (item.extensionType == '意见按钮' || item.extensionType == '签阅意见按钮') {
                input = document.createElement('INPUT');
                input.setAttribute('placeHoler', '输入意见');
                input.setAttribute('notsubmit', true);
                nameDiv.innerText = '';
                input2 = document.createElement('DIV');
                input2.className = 'button';
                input2.innerText = '提交意见';
                input2.setAttribute('to', item.to);
                input2.setAttribute('for', 'form-' + item.field);
                nameDiv.className = 'form-item-name form-none';
                $(input2).touchlink().bind('touchend', function() {
                    $s.onBtnSignClick(this);
                });
            } else if (item.extensionType == '签字口令框') {
                input = document.createElement('INPUT');
                if (item.readonly == "false") {
                    input2 = document.createElement('DIV');
                    input2.className = 'button';
                    input2.innerText = '签名';
                    input2.setAttribute('to', item.to);
                    input2.setAttribute('for', 'form-' + item.field);
                    $(input2).touchlink().bind('touchend', function() {//click
                        $s.onBtnSignClick2(this);
                    });
                }
            } else if (item.extensionType == '多行文本框') {
                input = document.createElement('TEXTAREA');
                div.className = 'form-item form-textarea-row';
            } else if (item.extensionType == '日期框') {
                input = document.createElement('INPUT');
                //input.style.paddingRight = "80px";
                //                input.style.background = "如:2013-01-01";
                //                input.style.backgroundPosition = "center right";
                input.setAttribute('placeHolder', '如:2013-01-01');

            } else if (item.extensionType == '下拉框') {
                input = document.createElement('SELECT');
                for (var i = 0; i < item.dataSource.length; i++) {
                    var d = item.dataSource[i];
                    var option = new Option(d.name, d.value);
                    input.options[i] = option;
                }
            } else
                return null;
            if (item.value != undefined)
                input.value = item.value;
            
            input.setAttribute('old', item.value);
            input.setAttribute('field', item.field);
            input.setAttribute('table', item.table);
            input.id = 'form-' + item.field;
            if (!this.controls[item.table])
                this.controls[item.table] = {};
            this.controls[item.table][item.id] = input;

            valDiv.appendChild(input);
            if (input2)
                valDiv.appendChild(input2);
            //input.disabled = item.readonly == "true";
            if (item.readonly == "true" || item.extensionType == '签字口令框') {
                input.disabled = true;
            } else {
                input.disabled = false;
            }
            if (input.disabled)
                input.className += ' disabled';
        } else {
            valDiv.innerText = item.value;
        }
        div.appendChild(nameDiv);
        div.appendChild(valDiv);
        return div;
    };

    //签字
    this.onBtnSignClick = function(sender) {
        var forInput = dist.$g(sender.getAttribute('for'));
        var val = forInput.value;
        if (val == '') {
            return;
        }
        //根据控件引用关系获得目标对象
        var to = sender.getAttribute('to');
        var target = null;
        for (var t in this.controls) {
            var f = this.controls[t];
            target = f[to];
            if (target)
                break;
        }
        if (!target)
            return;
        var today = new Date();
        target.value += '\n' + val + '\t填写人：' + dist.un + '\t日期：' + today.getFullYear() + '年' + (today.getMonth() + 1) + '月' + today.getDate() + '日';
        sender.parentNode.parentNode.style.display = 'none';
    };

    //签字2
    this.onBtnSignClick2 = function(sender) {
        sender.style.display = "none";
        var forInput = dist.$g(sender.getAttribute('for'));
        forInput.value = dist.uname;
        //根据控件引用关系获得目标对象
        var to = sender.getAttribute('to');
        var target = null;
        for (var t in this.controls) {
            var f = this.controls[t];
            target = f[to];
            if (target)
                break;
        }
        if (!target)
            return;
        var today = new Date();
        target.value = today.getFullYear() + '/' + (today.getMonth() + 1) + '/' + today.getDate();
    };

    //获取保存表单的xml
    this.createSaveXml = function() {
        var changed = false;
        var formXml = '<root>';
        for (var t in this.controls) {
            var items = this.controls[t];
            formXml += '<' + t + '>';
            for (var f in items) {
                var input = items[f];
                if (input.getAttribute('notsubmit')) {
                    continue;
                }
                var nowVal = input.value;
                var oldVal = input.getAttribute('old');
                if (nowVal != oldVal) {
                    changed = true;
                    var field = input.getAttribute('field');
                    formXml += '<' + field + '><![CDATA[' + nowVal + ']]></' + field + '>';
                }
            }
            formXml += '</' + t + '>';
        }
        formXml += '</root>';
        if (!changed)
            return null;
        return formXml;
    };

    this.save = function() {
        var xml = this.createSaveXml();
        if (null == xml)
            return;
        $.ajax({
            url: formSaveService,
            type: 'post',
            data: { user: dist.userid, project: this.projectId, data: xml },
            success: function(data) {
                alert(data == '1' ? '表单已保存' : '保存失败');
            },
            error: function() {
                alert('保存失败');
            }
        });
    };

    this.showSendList = function() {
        this.dispaySendList();
        if (!this.sendListInitialized) {
            this.getSendList();
        }
    };

    this.getSendList = function() {
        this.currentSendListData = null;
        this.sendListControl.innerHTML = '';
        this.displayWating();
        $.ajax({
            url: formSendListService,
            dataType: 'json',
            data: { project: this.projectId, user: dist.userid, sendType: 'send' },
            success: function(data) {
                $s.fillSendList(data);
            },
            error: function() {
                $s.dispayForm();
            }
        });
    };

    this.fillSendList = function(data) {
        this.currentSendListData = data.result;
        this.sendListInitialized = true;
        var df = document.createDocumentFragment();
        for (var i = 0; i < this.currentSendListData.length; i++) {
            var li = document.createElement('LI');
            li.setAttribute('i', i);
            li.innerText = this.currentSendListData[i].userName;
            df.appendChild(li);
        }
        this.sendListControl.appendChild(df);
        this.dispaySendList();
    };

    this.showSendBackList = function() {
        this.displaySendBackList();
        if (!this.sendBackListInitialzie) {
            this.getSendBackList();
        }
    };

    this.getSendBackList = function() {
        this.currentSendBackListData = null;
        this.sendBackListControl.innerHTML = '';
        this.displayWating();
        $.ajax({
            url: formSendListService,
            dataType: 'json',
            data: { project: this.projectId, user: dist.userid, sendType: 'sendback' },
            success: function(data) {
                $s.fillSendBackList(data);
            },
            error: function() {
                $s.dispayForm();
            }
        });
    };

    this.fillSendBackList = function(data) {
        this.currentSendBackListData = data.result;
        this.sendBackListInitialzie = true;
        var df = document.createDocumentFragment();
        for (var i = 0; i < this.currentSendBackListData.length; i++) {
            var li = document.createElement('LI');
            li.setAttribute('i', i);
            li.innerText = this.currentSendBackListData[i].userName;
            df.appendChild(li);
        }
        this.sendBackListControl.appendChild(df);
        this.displaySendBackList();
    };

    this.doSend = function(sender, sendBack) {
        if (!confirm('确认发送?'))
            return;
        var sendInfo = null;
        if (sendBack)
            sendInfo = this.currentSendBackListData[parseInt(sender[0].getAttribute('i'))];
        else
            sendInfo = this.currentSendListData[parseInt(sender[0].getAttribute('i'))];
        this.displayWating();
        $.ajax({
            url: formSendService,
            data: {
                project: this.projectId,
                fromUser: dist.userid,
                toUser: sendInfo.userId,
                activityID: sendInfo.activityID,
                type: sendBack ? 'sendback' : 'send'
            },
            success: function(data) {
                if ("1" == data) {
                    alert("发送成功");
                    $s.onSendCompleted();
                }
                else
                    $s.onSendFail();
            },
            error: function() {
                $s.onSendFail();
            }
        });
    };

    this.onSendCompleted = function() {
        if (this.sendCompleted)
            this.sendCompleted();
        else
            this.load(this.projectId);
    };

    this.onSendFail = function() {
        this.dispaySendList();
        alert('发送失败');
    };
};
