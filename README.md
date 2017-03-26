# HTTP.au3
WinHTTP-based library for AutoIt3 that allows GET, POST and upload.

## Functions

### string _HTTP_Get ( string $sURL )

Executes a HTTP Get request to $sURL.

**Return value:**

Success: the page content

Error: 0 and set @error to non-zero (see remarks).

Example:

```
MsgBox(0, "Google.com homepage content", _HTTP_Get("http://google.com") )
MsgBox(0, "Google.com search for ""AutoIt 3"" page content", _HTTP_Get("http://google.com/search?q=" & URLEncode("AutoIt 3")) )
```

### string _HTTP_Post ( string $sURL , string $sPostData )

Executes a HTTP Post request to $sURL, sending $sPostData as parameters.

**Return value:**

Success: the page content

Error: 0 and set @error to non-zero (see remarks).

Example:

```
MsgBox(0, "Post test", _HTTP_Post("http://posttestserver.com/post.php", "foo=bar&test=" & URLEncode("Testing 123")) )
```

### string _HTTP_Upload ( string $sURL , string $sFilePath , string $sFileField , string $sPostData = '' , string $sFilename = Default)

Executes a HTTP Post request to $sURL.

At the moment, it's only possible to upload 1 file per request. However it's planned to add multiple file upload support soon.

* **$sURL**: the URL to post to
* **$sFilePath**: the file path to upload (on your machine - it can be whether relative to the working dir or the system root)
* **$sFileField**: the name of the file input (get it on the form's HTML code: `<input type="file" name="..." >`
* **$sPostData**: additional data to send as POST (optional). Default is none.
* **$sFilename**: spoofs the filename (optional). If you do not provide any, then the original filename will be used.

**Return value:**

Success: the page content

Error: 0 and set @error to non-zero (see remarks).

Example

```
_HTTP_Upload("http://test/upload", @HomeDrive & "\Picture.jpg")
```

## Remarks

### URL encoding and decoding

When going to send form data through GET or POST in any of these functions (even if you are using $sPostData on _HTTP_Upload), you must put all the variables on only one line and URLEncode() the values, just as you see as query string on GET requests with variables on the URL.

**This library supplies two additional functions for URL encoding/decoding**. These are: URLEncode($sStr) and URLDecode($sStr).

```
ConsoleWrite(URLEncode("Code: AutoIt3")) ; Code%3A+AutoIt3
ConsoleWrite(URLDecode("Code%3A+AutoIt3")) ; Code: AutoIt3
```

Therefore, when sending data, here's what you must do. Notice that only VALUES, and not KEYS are encoded.

```
_HTTP_Get("http://test/script?str=" & URLEncode("Code: AutoIt3") )
_HTTP_Post("http://test/postscript", "str=" & URLEncode("Code: AutoIt3") )
_HTTP_Upload("http://test/postscript", "myPicture.jpg", "uploadinput", "str=" & URLEncode("Code: AutoIt3") )
```

Of course you can also supply the already-encoded text manually:

```
_HTTP_Get("http://test/script?str=Code%3A+AutoIt3")
```

### Error handling

All these 3 main functions, in case of error, will return 0 and set @error to non-zero. Here's what @error means:

* 1: Could not instantiate WinHTTP and open a POST request.
* 2: Could not send request.
* 3: Other HTTP error (in this case @extended will return the HTTP status from the server)

### Attributions

HTTP_Upload is based on a VB version by Eric Phelps accessible [here](http://www.ericphelps.com/scripting/samples/reference/web/http_post.txt). Note that ADODB.Recordset need has been removed on this port.

URLEncode has been taken from AutoIt Forums, but the author is unknown. The source can be accessed [here](https://www.autoitscript.com/forum/topic/95850-url-encoding/?do=findComment&comment=689045).
