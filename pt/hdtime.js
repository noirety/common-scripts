let urlList = [
    "https://hdtime.org/details.php?id=83274",
    "https://hdtime.org/details.php?id=98050",
    "https://hdtime.org/details.php?id=7438",
    "https://hdtime.org/details.php?id=7817",
    "https://hdtime.org/details.php?id=98776",
    "https://hdtime.org/details.php?id=86876",
    "https://hdtime.org/details.php?id=93190",
    "https://hdtime.org/details.php?id=82100",
    "https://hdtime.org/details.php?id=93425",
    "https://hdtime.org/details.php?id=85186",
    "https://hdtime.org/details.php?id=85499",
    "https://hdtime.org/details.php?id=85034",
    "https://hdtime.org/details.php?id=88052",
    "https://hdtime.org/details.php?id=15906",
    "https://hdtime.org/details.php?id=92454",
    "https://hdtime.org/details.php?id=97255",
    "https://hdtime.org/details.php?id=98598",
    "https://hdtime.org/details.php?id=87448",
    "https://hdtime.org/details.php?id=87231",
    "https://hdtime.org/details.php?id=84656",
    "https://hdtime.org/details.php?id=89597",
    "https://hdtime.org/details.php?id=62940",
    "https://hdtime.org/details.php?id=9868",
    "https://hdtime.org/details.php?id=82191",
    "https://hdtime.org/details.php?id=13444",
    "https://hdtime.org/details.php?id=81378",
    "https://hdtime.org/details.php?id=79296",
    "https://hdtime.org/details.php?id=97964",
    "https://hdtime.org/details.php?id=97257",
    "https://hdtime.org/details.php?id=90857"
]

function getUrlParameter(url, paramName) {
    const urlObject = new URL(url);
    const urlParams = new URLSearchParams(urlObject.search);
    return urlParams.get(paramName);
}

function loadIframeContent(iframe) {
    return new Promise((resolve, reject) => {
        iframe.onload = function () {
            let iframeWindow = iframe.contentWindow;
            let iframeDocument = iframeWindow.document;
            let title = iframeDocument.title;
            let content = iframeDocument.body.innerHTML;
            let regex = /https:\/\/hdtime\.org\/download\.php\?downhash=[^\s'"]+/g;
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

    let downHashSet = new Set();
    let i = 0;

    for (let url of urlList) {

        console.log(`正在获取第${i + 1}个种子链接`)
        try {
            iframe.src = url;
            document.body.appendChild(iframe);
            let startTime = new Date();
            let tempUrl = await loadIframeContent(iframe);
            downHashSet.add(tempUrl);
            let endTime = new Date();
            let elapsedTime = endTime - startTime;
            console.log(`耗时: ${elapsedTime}毫秒`);
        } catch (error) {
            console.error('Error:', error);
        }
        i++;
    }

    document.body.removeChild(iframe);
    let downHashStr = Array.from(downHashSet).join('\n');
    console.log("获取种子链接执行完成");
    console.log(downHashStr);
}

await main();
