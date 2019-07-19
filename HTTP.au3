#include-once
#include <FileConstants.au3>

#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#cs
	HTTP.au3

	made by @Jefrey
	Repo: http://github.com/jesobreira/HTTP.au3
	edited by @Tumio
	modified: mLipok
#ce

Global $__g_oHTTP_ErrorHandler = ObjEvent("AutoIt.Error", __HTTP_OnError) ; Install a custom error handler

; Custom error handler will set @error variable to 1 if a COM error is intercepted
; and will print out the error informations by the Console
Func __HTTP_OnError(ByRef $oMyError)
	Local $HexNumber = Hex($oMyError.number, 8)
	ConsoleWrite("We intercepted a COM Error !" & @LF & _
			"Number is: " & $HexNumber & @LF & _
			"Windescription is: " & $oMyError.windescription _
			)
	Return SetError(5, $HexNumber, 0)
EndFunc   ;==>__HTTP_OnError

Func _HTTP_Get($url)
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	Local $res = $oHTTP.Open("GET", $url, False)
	If @error Then Return SetError(1, 0, 0)
	#forceref $res

	$oHTTP.Send()
	If @error Then Return SetError(2, 0, 0)

	Local $sReceived = $oHTTP.ResponseText
	Local $iStatus = $oHTTP.Status
	If $iStatus = 200 Then Return $sReceived

	Return SetError(3, $iStatus, $sReceived)
EndFunc   ;==>_HTTP_Get

Func _HTTP_Post($url, $postdata = '')
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("POST", $url, False)
	If @error Then Return SetError(1, 0, 0)

	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oHTTP.Send($postdata)
	If @error Then Return SetError(2, 0, 0)

	Local $sReceived = $oHTTP.ResponseText
	Local $iStatus = $oHTTP.Status
	If $iStatus = 200 Then Return $sReceived

	Return SetError(3, $iStatus, $sReceived)
EndFunc   ;==>_HTTP_Post

Func _HTTP_Upload($strUploadUrl, $strFilePath, $strFileField, $strDataPairs = '', $strFilename = Default)
	If $strFilename = Default Then $strFilename = StringMid($strFilePath, StringInStr($strFilePath, "\", 0, -1) + 1)
;~ 	Local $pwd = ""
;~ 	#forceref $pwd

	Local $MULTIPART_BOUNDARY = "----WebKitFormBoundary"
	Local $aSpace[3]
	For $i = 1 To 16
		$aSpace[0] = Chr(Random(65, 90, 1)) ;A-Z
		$aSpace[1] = Chr(Random(97, 122, 1)) ;a-z
		$aSpace[2] = Chr(Random(48, 57, 1)) ;0-9
		$MULTIPART_BOUNDARY &= $aSpace[Random(0, 2, 1)]
	Next
;~ 	Local $bytFormStart, $strDataPair
;~ 	#forceref $bytFormStart, $strDataPair

	If Not FileExists($strFilePath) Then Return SetError(4, 0, 0)

	Local $h = FileOpen($strFilePath, $FO_BINARY)
	Local $bytFile = FileRead($h)
	FileClose($h)

	; Create the multipart form data - Define the end of form
	Local $strFormEnd = @CRLF & "--" & $MULTIPART_BOUNDARY & "--" & @CRLF
	Local $strFormStart

	; First add any ordinary form data pairs
	If $strDataPairs Then
		Local $split = StringSplit($strDataPairs, "&")
		Local $splitagain
		For $i = 1 To $split[0]
			$splitagain = StringSplit($split[$i], "=")
			$strFormStart &= "--" & $MULTIPART_BOUNDARY & @CRLF & _
					"Content-Disposition: form-data; " & _
					"name=""" & $splitagain[1] & """" & _
					@CRLF & @CRLF & _
					URLDecode($splitagain[2]) & @CRLF
		Next
	EndIf

	; Now add the header for the uploaded file
	$strFormStart &= "--" & $MULTIPART_BOUNDARY & @CRLF & _
			"Content-Disposition: form-data; " & _
			"name=""" & $strFileField & """; " & _
			"filename=""" & $strFilename & """" & @CRLF & _
			"Content-Type: application/upload" & _ ; bogus, but it works
			@CRLF & @CRLF

	; Now merge it all
	Local $bytFormData = StringToBinary($strFormStart) & $bytFile & StringToBinary($strFormEnd)

	; Upload it
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("POST", $strUploadUrl, False)
	If @error Then Return SetError(1, 0, 0)

	$oHTTP.SetRequestHeader("Content-Type", "multipart/form-data; boundary=" & $MULTIPART_BOUNDARY)
	$oHTTP.Send($bytFormData)
	If @error Then Return SetError(2, 0, 0)

	Local $sReceived = $oHTTP.ResponseText
	Local $iStatus = $oHTTP.Status
	If $iStatus = 200 Then Return $sReceived

	Return SetError(3, $iStatus, $sReceived)
EndFunc   ;==>_HTTP_Upload

Func URLEncode($urlText)
	Local $url = "", $acode
	For $i = 1 To StringLen($urlText)
		$acode = Asc(StringMid($urlText, $i, 1))
		Select
			Case ($acode >= 48 And $acode <= 57) Or _
					($acode >= 65 And $acode <= 90) Or _
					($acode >= 97 And $acode <= 122)
				$url &= StringMid($urlText, $i, 1)
			Case $acode = 32
				$url &= "+"
			Case Else
				$url &= "%" & Hex($acode, 2)
		EndSelect
	Next
	Return $url
EndFunc   ;==>URLEncode

Func URLDecode($urlText)
	$urlText = StringReplace($urlText, "+", " ")
	Local $matches = StringRegExp($urlText, "\%([abcdefABCDEF0-9]{2})", 3)
	If Not @error Then
		For $match In $matches
			$urlText = StringReplace($urlText, "%" & $match, BinaryToString('0x' & $match))
		Next
	EndIf
	Return $urlText
EndFunc   ;==>URLDecode
