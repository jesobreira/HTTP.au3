#include-once

#cs
	HTTP.au3

	made by @Jefrey
	Repo: http://github.com/jesobreira/HTTP.au3
#ce

Func _HTTP_Get($url)
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("GET", $url, False)
	If (@error) Then Return SetError(1, 0, 0)
	$oHTTP.Send()
	If (@error) Then Return SetError(2, 0, 0)
	$sReceived = $oHTTP.ResponseText
	$iStatus = $oHTTP.Status
	If $iStatus = 200 Then
		Return $sReceived
	Else
		Return SetError(3, $iStatus, $sReceived)
	EndIf
EndFunc   ;==>_HTTP_Get

Func _HTTP_Post($url, $postdata = '')
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("POST", $url, False)
	If (@error) Then Return SetError(1, 0, 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oHTTP.Send($postdata)
	If (@error) Then Return SetError(2, 0, 0)
	$sReceived = $oHTTP.ResponseText
	$iStatus = $oHTTP.Status
	If $iStatus = 200 Then
		Return $sReceived
	Else
		Return SetError(3, $iStatus, $sReceived)
	EndIf
EndFunc   ;==>_HTTP_Post

Func _HTTP_Upload($strUploadUrl, $strFilePath, $strFileField, $strDataPairs = '', $strFilename = Default)
	If $strFilename = Default Then $strFilename = StringMid($strFilePath, StringInStr($strFilePath, "\", 0, -1) + 1)
	Local $MULTIPART_BOUNDARY = "----WebKitFormBoundaryE3ljMozBTcgaOhpd"
	Local $bytFormData, $bytFormStart, $bytFile
	Local $strFormStart, $strFormEnd, $strDataPair
	$h = FileOpen($strFilePath, 16)
	$bytFile = FileRead($h)
	FileClose($h)
	; Create the multipart form data
	; Define the end of form
	$strFormEnd = @CRLF & "--" & $MULTIPART_BOUNDARY & "--" & @CRLF
	; First add any ordinary form data pairs
	Local $split = StringSplit($strDataPairs, "&")
	For $i = 1 To $split[0]
		$splitagain = StringSplit($split[$i], "=")
		$strFormStart &= "--" & $MULTIPART_BOUNDARY & @CRLF & _
				"Content-Disposition: form-data; " & _
				"name=""" & $splitagain[1] & """" & _
				@CRLF & @CRLF & _
				URLDecode($splitagain[2]) & @CRLF
	Next
	; Now add the header for the uploaded file
	$strFormStart &= "--" & $MULTIPART_BOUNDARY & @CRLF & _
			"Content-Disposition: form-data; " & _
			"name=""" & $strFileField & """; " & _
			"filename=""" & $strFilename & """" & @CRLF & _
			"Content-Type: application/upload" & _ ; bogus, but it works
			@CRLF & @CRLF

	; Now merge it all
	$bytFormData = StringToBinary($strFormStart) & $bytFile & StringToBinary($strFormEnd)

	; Upload it
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("POST", $strUploadUrl, False)
	If (@error) Then Return SetError(1, 0, 0)
	$oHTTP.SetRequestHeader("Content-Type", "multipart/form-data; boundary=" & $MULTIPART_BOUNDARY)
	$oHTTP.Send($bytFormData)
	If (@error) Then Return SetError(2, 0, 0)
	$sReceived = $oHTTP.ResponseText
	$iStatus = $oHTTP.Status
	If $iStatus = 200 Then
		Return $sReceived
	Else
		Return SetError(3, $iStatus, $sReceived)
	EndIf
EndFunc   ;==>_HTTP_Upload

Func URLEncode($urlText)
	$url = ""
	For $i = 1 To StringLen($urlText)
		$acode = Asc(StringMid($urlText, $i, 1))
		Select
			Case ($acode >= 48 And $acode <= 57) Or _
					($acode >= 65 And $acode <= 90) Or _
					($acode >= 97 And $acode <= 122)
				$url = $url & StringMid($urlText, $i, 1)
			Case $acode = 32
				$url = $url & "+"
			Case Else
				$url = $url & "%" & Hex($acode, 2)
		EndSelect
	Next
	Return $url
EndFunc   ;==>URLEncode

Func URLDecode($urlText)
	$urlText = StringReplace($urlText, "+", " ")
	Local $matches = StringRegExp($urlText, "\%([abcdefABCDEF0-9]{2})", 3)
	For $match In $matches
		$urlText = StringReplace($urlText, "%" & $match, BinaryToString('0x' & $match))
	Next
	Return $urlText
EndFunc   ;==>URLDecode
