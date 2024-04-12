const express = require('express');
const app = express();

app.use(express.static(__dirname));

app.get("/", (req, res) => {		// abc.com/ 으로 들어온다면..
	res.sendFile(__dirname + "/index.html") //해당 폴더에 있는 index.html을 표시
})

app.listen(81	, () => {		//80포트를 사용중이면 포트번호 수정하길..
	console.log("80 homepage run");
})