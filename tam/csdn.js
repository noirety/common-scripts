// ==UserScript==
// @name         CSDN去广告
// @namespace    http://tampermonkey.net/
// @version      2024-10-24
// @description  try to take over the world!
// @author       You
// @match        https://blog.csdn.net/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=csdn.net
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    window.addEventListener('load', function() {
        // 延时 3 秒执行自定义脚本
        setTimeout(function() {
            // 左边
            document.getElementById('remuneration').remove();
            document.getElementById('asideWriteGuide').remove();
            // 右边
            let divs = document.getElementsByClassName('toolbar-advert');
            for (let i = divs.length - 1; i >= 0; i--) {
                let div = divs[i];
                div.remove();
            }

            let divs1 = document.getElementsByClassName('csdn-common-logo-advert');
            for (let i = divs1.length - 1; i >= 0; i--) {
                let div = divs1[i];
                div.remove();
            }

        }, 2200); // 3000 毫秒 = 3 秒
    });
})();