let urlList = [
    'https://carpt.net/details.php?id=80237&hit=1',
    'https://carpt.net/details.php?id=37889&hit=1',
    'https://carpt.net/details.php?id=16591&hit=1',
    'https://carpt.net/details.php?id=59151&hit=1',
    'https://carpt.net/details.php?id=4005&hit=1',
    'https://carpt.net/details.php?id=348&hit=1',
    'https://carpt.net/details.php?id=37887&hit=1',
    'https://carpt.net/details.php?id=13391&hit=1',
    'https://carpt.net/details.php?id=27582&hit=1',
    'https://carpt.net/details.php?id=64913&hit=1',
    'https://carpt.net/details.php?id=4006&hit=1',
    'https://carpt.net/details.php?id=6863&hit=1',
    'https://carpt.net/details.php?id=4007&hit=1',
    'https://carpt.net/details.php?id=22448&hit=1',
    'https://carpt.net/details.php?id=62122&hit=1',
    'https://carpt.net/details.php?id=54676&hit=1',
    'https://carpt.net/details.php?id=47908&hit=1',
    'https://carpt.net/details.php?id=4008&hit=1',
    'https://carpt.net/details.php?id=467&hit=1',
    'https://carpt.net/details.php?id=4009&hit=1',
    'https://carpt.net/details.php?id=71906&hit=1',
    'https://carpt.net/details.php?id=71671&hit=1',
    'https://carpt.net/details.php?id=4010&hit=1',
    'https://carpt.net/details.php?id=4011&hit=1',
    'https://carpt.net/details.php?id=71614&hit=1',
    'https://carpt.net/details.php?id=28740&hit=1',
    'https://carpt.net/details.php?id=24979&hit=1',
    'https://carpt.net/details.php?id=1033&hit=1',
    'https://carpt.net/details.php?id=13393&hit=1',
    'https://carpt.net/details.php?id=56961&hit=1',
    'https://carpt.net/details.php?id=54542&hit=1',
    'https://carpt.net/details.php?id=4012&hit=1',
    'https://carpt.net/details.php?id=71560&hit=1',
    'https://carpt.net/details.php?id=4013&hit=1',
    'https://carpt.net/details.php?id=24901&hit=1',
    'https://carpt.net/details.php?id=4014&hit=1',
    'https://carpt.net/details.php?id=22449&hit=1',
    'https://carpt.net/details.php?id=22450&hit=1',
    'https://carpt.net/details.php?id=57121&hit=1',
    'https://carpt.net/details.php?id=24957&hit=1',
    'https://carpt.net/details.php?id=4015&hit=1',
    'https://carpt.net/details.php?id=4016&hit=1',
    'https://carpt.net/details.php?id=71692&hit=1',
    'https://carpt.net/details.php?id=31824&hit=1',
    'https://carpt.net/details.php?id=30050&hit=1',
    'https://carpt.net/details.php?id=4017&hit=1',
    'https://carpt.net/details.php?id=4018&hit=1',
    'https://carpt.net/details.php?id=8252&hit=1',
    'https://carpt.net/details.php?id=333&hit=1',
    'https://carpt.net/details.php?id=53350&hit=1',
    'https://carpt.net/details.php?id=4019&hit=1',
    'https://carpt.net/details.php?id=2701&hit=1',
    'https://carpt.net/details.php?id=4020&hit=1',
    'https://carpt.net/details.php?id=51176&hit=1',
    'https://carpt.net/details.php?id=71678&hit=1',
    'https://carpt.net/details.php?id=15839&hit=1',
    'https://carpt.net/details.php?id=22451&hit=1',
    'https://carpt.net/details.php?id=48784&hit=1',
    'https://carpt.net/details.php?id=70213&hit=1',
    'https://carpt.net/details.php?id=65859&hit=1',
    'https://carpt.net/details.php?id=51168&hit=1',
    'https://carpt.net/details.php?id=24899&hit=1',
    'https://carpt.net/details.php?id=54288&hit=1',
    'https://carpt.net/details.php?id=54880&hit=1',
    'https://carpt.net/details.php?id=54225&hit=1',
    'https://carpt.net/details.php?id=4021&hit=1',
    'https://carpt.net/details.php?id=51225&hit=1',
    'https://carpt.net/details.php?id=22452&hit=1',
    'https://carpt.net/details.php?id=22453&hit=1',
    'https://carpt.net/details.php?id=55084&hit=1',
    'https://carpt.net/details.php?id=56410&hit=1',
    'https://carpt.net/details.php?id=14062&hit=1',
    'https://carpt.net/details.php?id=71563&hit=1',
    'https://carpt.net/details.php?id=4022&hit=1',
    'https://carpt.net/details.php?id=63040&hit=1',
    'https://carpt.net/details.php?id=22454&hit=1',
    'https://carpt.net/details.php?id=53533&hit=1',
    'https://carpt.net/details.php?id=71688&hit=1',
    'https://carpt.net/details.php?id=63034&hit=1',
    'https://carpt.net/details.php?id=4025&hit=1',
    'https://carpt.net/details.php?id=37888&hit=1',
    'https://carpt.net/details.php?id=69018&hit=1',
    'https://carpt.net/details.php?id=4026&hit=1',
    'https://carpt.net/details.php?id=28739&hit=1',
    'https://carpt.net/details.php?id=22455&hit=1',
    'https://carpt.net/details.php?id=22456&hit=1',
    'https://carpt.net/details.php?id=16161&hit=1',
    'https://carpt.net/details.php?id=22457&hit=1',
    'https://carpt.net/details.php?id=4027&hit=1',
    'https://carpt.net/details.php?id=47910&hit=1',
    'https://carpt.net/details.php?id=70284&hit=1',
    'https://carpt.net/details.php?id=71687&hit=1',
    'https://carpt.net/details.php?id=4028&hit=1',
    'https://carpt.net/details.php?id=7909&hit=1',
    'https://carpt.net/details.php?id=4029&hit=1',
    'https://carpt.net/details.php?id=55710&hit=1',
    'https://carpt.net/details.php?id=47911&hit=1',
    'https://carpt.net/details.php?id=61166&hit=1',
    'https://carpt.net/details.php?id=61570&hit=1',
    'https://carpt.net/details.php?id=4030&hit=1'
]

function loadIframeContent(iframe) {
    return new Promise((resolve, reject) => {
        iframe.onload = function () {
            let iframeWindow = iframe.contentWindow;
            let iframeDocument = iframeWindow.document;
            let title = iframeDocument.title;
            let content = iframeDocument.body.innerHTML;
            let regex = /https:\/\/carpt\.net\/download\.php\?downhash=[^\s'"]+/g;
            let matches = content.match(regex);
            if (matches) {
                resolve(matches);
            } else {
                reject('No matches found');
            }
        };
    });
}

async function main() {
    let iframe = document.createElement("iframe");
    iframe.style.display = "none";

    let downhashSet = new Set();
    for (let i = 0; i < urlList.length; i++) {
        console.log(`正在获取第${i + 1}个种子链接`)
        try {
            iframe.src = urlList[i];
            document.body.appendChild(iframe);
            let startTime = new Date();
            let tempUrl = await loadIframeContent(iframe);
            downhashSet.add(tempUrl);
            let endTime = new Date();
            let elapsedTime = endTime - startTime;
            console.log(`耗时: ${elapsedTime}毫秒`);
        } catch (error) {
            console.error('Error:', error);
        }
    }
    document.body.removeChild(iframe);
    let downHashStr = Array.from(downhashSet).join('\n');
    console.log("获取种子链接执行完成");
    console.log(downHashStr);
}

main();
