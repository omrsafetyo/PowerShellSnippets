[CmdletBinding()]
param (
	[Parameter(Mandatory=$False)]
	$RequestBody,

	[Parameter(Mandatory=$True)]
	$ApiKey,

	[Parameter(Mandatory=$True)]
	$AppId,

	[Parameter(Mandatory=$False)]
	$RequestMethod = "GET",

	[Parameter(Mandatory=$True)]
	$RequestUri,

	[Parameter(Mandatory=$True)]
	$HeaderName = "HMAC"
)
	
BEGIN {
	Add-Type -AssemblyName System.Web
}
	
PROCESS {
	# http://bitoftech.net/2014/12/15/secure-asp-net-web-api-using-api-key-authentication-hmac-authentication/
		
	# [DateTime]$epochStart = Get-Date -Date "1970-01-01 00:00:00Z"
	$epochStart = [datetime]::new(1970,01,01,00,00,00,00, ([DateTimeKind]::Utc) )
	$timeSpan = New-TimeSpan -End ([datetime]::UtcNow) -Start $epochStart;
	$requestTimeStamp = [System.Convert]::ToUInt64($timeSpan.TotalSeconds).ToString();
	$nonce = [Guid]::NewGuid().ToString("N");
		
	# Default - no content (GET) empty base64 string for request
	[string]$requestContentBase64String = ""
		
	# If content was provided in the request, create an MD5 hash, and convert to base64 to add to the signature
	if ($null -ne $RequestBody) {
		[byte[]]$content = [Text.Encoding]::UTF8.GetBytes($RequestBody)
		$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
			
		# Hashing the request body, any change in request body will result in different hash, we'll ensure message integrity
		[byte[]]$requestContentHash = $md5.ComputeHash($content);
		$requestContentBase64String = [System.Convert]::ToBase64String($requestContentHash);
	}
		
	# Signature includes the AppID, the method (POST/GET), the Url to the Api service - encoded, timestamp of the request, the nonce, and a base64 of the md5 hash of the content)
	$signatureRawData = "{0}{1}{2}{3}{4}{5}" -f $AppId, $RequestMethod, [System.Web.HttpUtility]::UrlEncode($RequestUri).ToLower(), $requestTimeStamp, $nonce, $requestContentBase64String;
		
	[byte[]]$secretKeyByteArray = [System.Convert]::FromBase64String($ApiKey);
	[byte[]]$signature = [Text.Encoding]::UTF8.GetBytes($signatureRawData)
		
	$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
	$hmacsha.key = $secretKeyByteArray
		
	[byte[]]$signatureBytes = $hmacsha.ComputeHash($signature);
	$requestSignatureBase64String = [Convert]::ToBase64String($signatureBytes)
		
	# Setting the values in the Authorization header using custom scheme (amx)               
	$HeaderValue = "{4} {0}:{1}:{2}:{3}" -f $AppId, $requestSignatureBase64String, $nonce, $requestTimeStamp, $HeaderName
	$Auth = [PSCustomObject]@{Authorization = $HeaderValue }
		
	$Auth
} # PROCESS
	
END{}
