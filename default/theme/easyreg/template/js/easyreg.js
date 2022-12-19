/* easyreg.js */

function EasyMember (t) {

	//alert('EasyMember()');

	var myFp;    // stores current user's fingerprint

//	if (t && t.value) {
//		t.value = 'Meditate...';
//		setTimeout('EasyMember', 100);
//		return false;
//	}
//
	myFp = getUserFp();
	if (!myFp) {
		var keySuccess = MakeKey(t, 'afterKeygen()');
		myFp = getUserFp();
	} else {
		afterKeygen();
	}

	return false;
}

function afterKeygen () {

	//alert('afterKeygen()');

	//alert('DEBUG: EasyMember: myFp = ' + myFp);

	var myFp = getUserFp();

	var solvedPuzzle = getSolvedPuzzle(myFp, '1337', 10, 1000000);

	var myMessage = 'New member registration, puzzle solved.' + "\n\n" + solvedPuzzle;

	//alert('DEBUG: EasyMember: solvedPuzzle = ' + solvedPuzzle);

	//alert('DEBUG: EasyMember: window.signMessageBasic= ' + window.signMessageBasic);

	sharePubKey();

	var signedPuzzle = signMessageBasic(myMessage, document.compose.comment, 'sendSignedMessage()');

	//alert('DEBUG: EasyMember: signedPuzzle = ' + signedPuzzle);

	//comment.value = signedPuzzle;

	//compose.submit();
}

function sendSignedMessage () {

	//alert('sendSignedMessage()');

	document.compose.submit();
}

/* / easyreg.js */