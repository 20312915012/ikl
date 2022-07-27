import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:b_dep/b_dep.dart';
import 'package:b_dep/src/utils/widgets/blupsheets.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart' as dio;
import 'package:b_dep/src/utils/variables.dart' as variables;

class BStorage {
  BSSOnSuccess bssOnSuccess;
  BSSOnFailure bssOnFailure;
  BSSOnUploading bssOnUploading;

  BSSOnSuccess getSuccess() {
    return bssOnSuccess;
  }

  void uploadFile(List<String> filePathList) {
    Timer(const Duration(milliseconds: 50), () {
      awsS3Backend.uploadTOS3(io.File(filePathList.first), bssOnUploading, bssOnSuccess, bssOnFailure);
    });
  }
}

_AWSS3Backend awsS3Backend = _AWSS3Backend();

class _AWSS3Backend {
  final String aws_cognito_user_pool_id = "ap-south-1_X83Vc9KRe";
  final String aws_cognito_identity_pool_id = "ap-south-1:e9c02197-3915-4a5b-b1b2-07c1e60b51df";
  final String aws_cognito_client_id = "3a4fhb45maaalphsesef3uhjh1";

  final String aws_region = "ap-south-1";
  final String aws_s3_endpoint = 'https://blup-client-bss-1.s3-ap-south-1.amazonaws.com';

  String getUploadToS3DownloadUrl(io.File file) {
    final String fileName = path.basename(file.path);
    final String bucketKey = 'bss/${variables.clientEmail}/$fileName';
    String downloadUrl = aws_s3_endpoint + "/" + bucketKey;
    return downloadUrl;
  }

  void uploadTOS3(
      io.File file, BSSOnUploading bssOnUploading, BSSOnSuccess bssOnSuccess, BSSOnFailure bssOnFailure) async {
    final userPool = CognitoUserPool(aws_cognito_user_pool_id, aws_cognito_client_id);
    dio.Dio dioObj = dio.Dio();
    final _credentials = CognitoCredentials(aws_cognito_identity_pool_id, userPool);
    await _credentials.getGuestAwsCredentialsId();

    final length = await file.length();

    final uri = Uri.parse(aws_s3_endpoint);

    final String fileName = path.basename(file.path);
    final String bucketKey = 'bss/${variables.clientEmail}/$fileName';

    final policy = Policy.fromS3PresignedPost(bucketKey, 'blup-client-bss-1', 15, _credentials.accessKeyId, length,
        _credentials.sessionToken, getFileContentTypeForPolicy(fileName),
        region: aws_region);
    final key = SigV4.calculateSigningKey(_credentials.secretAccessKey, policy.datetime, aws_region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());

    final dio.FormData formData = dio.FormData.fromMap({
      'key': policy.key,
      'X-Amz-Credential': policy.credential,
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Date': policy.datetime,
      'Policy': policy.encode(),
      'X-Amz-Signature': signature,
      'x-amz-security-token': _credentials.sessionToken,
      'Content-Type': '${getFileContentType(fileName) /*getContentType(enumS3FileType, fileName)*/}',
      'file': await dio.MultipartFile.fromFile(
        file.path,
        filename: fileName,
      )
    });

    try {
      await dioObj.postUri(
        uri,
        data: formData,
        onSendProgress: (int sentBytes, int totalBytes) {
          double progressPercent = sentBytes / totalBytes * 100;
          if (bssOnUploading != null) {
            bssOnUploading(progressPercent, 0);
          }
          print("$progressPercent %");
          if (progressPercent == 100) {
            if (bssOnSuccess != null) {
              bssOnSuccess(getUploadToS3DownloadUrl(file));
            }
          }
        },
      );
    } catch (e) {
      if (bssOnFailure != null) {
        bssOnFailure();
      }
      print("uploadS3 error> " + e.toString());
    }
  }

  String getFileContentType(String fileName) {
    return awsS3contentTypeMap[fileName.substring(fileName.lastIndexOf(".") + 1)];
  }

  String getFileContentTypeForPolicy(String fileName) {
    String contentType = awsS3contentTypeMap[fileName.substring(fileName.lastIndexOf(".") + 1)];
    return contentType.substring(0, contentType.lastIndexOf("/") + 1);
  }
}

class Policy {
  String expiration;
  String region;
  String bucket;
  String key;
  String credential;
  String datetime;
  String sessionToken;
  String fileContentType;
  int maxFileSize;

  Policy(this.key, this.bucket, this.datetime, this.expiration, this.credential, this.maxFileSize, this.sessionToken,
      this.fileContentType,
      {this.region = 'us-east-1'});

  factory Policy.fromS3PresignedPost(String key, String bucket, int expiryMinutes, String accessKeyId, int maxFileSize,
      String sessionToken, String fileContentType,
      {String region}) {
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now()).add(Duration(minutes: expiryMinutes)).toUtc().toString().split(' ').join('T');
    final cred = '$accessKeyId/${SigV4.buildCredentialScope(datetime, region, 's3')}';
    final p =
        Policy(key, bucket, datetime, expiration, cred, maxFileSize, sessionToken, fileContentType, region: region);
    return p;
  }

  String encode() {
    final bytes = utf8.encode(toString());
    return base64.encode(bytes);
  }

  @override
  String toString() {
    // Safe to remove the "acl" line if your bucket has no ACL permissions  {"acl": "public-read"},
    return '''
      { "expiration": "${this.expiration}",
        "conditions": [
          {"bucket": "${this.bucket}"},
          ["starts-with", "\$key", "${this.key}"],
          ["starts-with", "\$Content-Type", "${this.fileContentType}"],
          ["content-length-range", 1, ${this.maxFileSize}],
          {"x-amz-credential": "${this.credential}"},
          {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
          {"x-amz-date": "${this.datetime}" },
          {"x-amz-security-token": "${this.sessionToken}" }
        ]
      }
      '''; //["starts-with", "\$Content-Type", "image/"], --> to change aws meta-data to image than  current "binary/octet-stream"
    //https://github.com/furaiev/amazon-cognito-identity-dart-2/issues/27
  }
}

Map<String, String> awsS3contentTypeMap = {
  "323": "text/h323",
  "acx": "application/internet-property-stream",
  "ai": "application/postscript",
  "aif": "audio/x-aiff",
  "aifc": "audio/x-aiff",
  "aiff": "audio/x-aiff",
  "asf": "video/x-ms-asf",
  "asr": "video/x-ms-asf",
  "asx": "video/x-ms-asf",
  "au": "audio/basic",
  "avi": "video/x-msvideo",
  "axs": "application/olescript",
  "bas": "text/plain",
  "bcpio": "application/x-bcpio",
  "bin": "application/octet-stream",
  "bmp": "image/bmp",
  "c": "text/plain",
  "cat": "application/vnd.ms-pkiseccat",
  "cdf": "application/x-cdf",
  "cer": "application/x-x509-ca-cert",
  "class": "application/octet-stream",
  "clp": "application/x-msclip",
  "cmx": "image/x-cmx",
  "cod": "image/cis-cod",
  "cpio": "application/x-cpio",
  "crd": "application/x-mscardfile",
  "crl": "application/pkix-crl",
  "crt": "application/x-x509-ca-cert",
  "csh": "application/x-csh",
  "csv": "application/vnd.ms-excel",
  "css": "text/css",
  "dcr": "application/x-director",
  "der": "application/x-x509-ca-cert",
  "dir": "application/x-director",
  "dll": "application/x-msdownload",
  "dms": "application/octet-stream",
  "doc": "application/msword",
  "docx": "application/msword",
  "dot": "application/msword",
  "dvi": "application/x-dvi",
  "dxr": "application/x-director",
  "eps": "application/postscript",
  "etx": "text/x-setext",
  "evy": "application/envoy",
  "exe": "application/octet-stream",
  "fif": "application/fractals",
  "flr": "x-world/x-vrml",
  "gif": "image/gif",
  "gtar": "application/x-gtar",
  "gz": "application/x-gzip",
  "h": "text/plain",
  "hdf": "application/x-hdf",
  "hlp": "application/winhlp",
  "hqx": "application/mac-binhex40",
  "hta": "application/hta",
  "htc": "text/x-component",
  "htm": "text/html",
  "html": "text/html",
  "htt": "text/webviewhtml",
  "ico": "image/x-icon",
  "ief": "image/ief",
  "iii": "application/x-iphone",
  "ins": "application/x-internet-signup",
  "isp": "application/x-internet-signup",
  "jfif": "image/pipeg",
  "jpe": "image/jpeg",
  "jpeg": "image/jpeg",
  "jpg": "image/jpeg",
  "js": "application/x-javascript",
  "latex": "application/x-latex",
  "lha": "application/octet-stream",
  "lsf": "video/x-la-asf",
  "lsx": "video/x-la-asf",
  "lzh": "application/octet-stream",
  "m13": "application/x-msmediaview",
  "m14": "application/x-msmediaview",
  "m3u": "audio/x-mpegurl",
  "man": "application/x-troff-man",
  "mdb": "application/x-msaccess",
  "me": "application/x-troff-me",
  "mht": "message/rfc822",
  "mhtml": "message/rfc822",
  "mid": "audio/mid",
  "mny": "application/x-msmoney",
  "mov": "video/quicktime",
  "movie": "video/x-sgi-movie",
  "mp2": "video/mpeg",
  "mp3": "audio/mpeg",
  "mp4": "video/mp4",
  "mpa": "video/mpeg",
  "mpe": "video/mpeg",
  "mpeg": "video/mpeg",
  "mpg": "video/mpeg",
  "mpp": "application/vnd.ms-project",
  "mpv2": "video/mpeg",
  "ms": "application/x-troff-ms",
  "mvb": "application/x-msmediaview",
  "nws": "message/rfc822",
  "oda": "application/oda",
  "p10": "application/pkcs10",
  "p12": "application/x-pkcs12",
  "p7b": "application/x-pkcs7-certificates",
  "p7c": "application/x-pkcs7-mime",
  "p7m": "application/x-pkcs7-mime",
  "p7r": "application/x-pkcs7-certreqresp",
  "p7s": "application/x-pkcs7-signature",
  "pbm": "image/x-portable-bitmap",
  "pdf": "application/pdf",
  "pfx": "application/x-pkcs12",
  "pgm": "image/x-portable-graymap",
  "pko": "application/ynd.ms-pkipko",
  "pma": "application/x-perfmon",
  "pmc": "application/x-perfmon",
  "pml": "application/x-perfmon",
  "pmr": "application/x-perfmon",
  "pmw": "application/x-perfmon",
  "pnm": "image/x-portable-anymap",
  "png": "image/png",
  "pot": "application/vnd.ms-powerpoint",
  "ppm": "image/x-portable-pixmap",
  "pps": "application/vnd.ms-powerpoint",
  "ppt": "application/vnd.ms-powerpoint",
  "pptx": "application/vnd.ms-powerpoint",
  "prf": "application/pics-rules",
  "ps": "application/postscript",
  "pub": "application/x-mspublisher",
  "qt": "video/quicktime",
  "ra": "audio/x-pn-realaudio",
  "ram": "audio/x-pn-realaudio",
  "ras": "image/x-cmu-raster",
  "rgb": "image/x-rgb",
  "rmi": "audio/mid",
  "roff": "application/x-troff",
  "rtf": "application/rtf",
  "rtx": "text/richtext",
  "scd": "application/x-msschedule",
  "sct": "text/scriptlet",
  "setpay": "application/set-payment-initiation",
  "setreg": "application/set-registration-initiation",
  "sh": "application/x-sh",
  "shar": "application/x-shar",
  "sit": "application/x-stuffit",
  "snd": "audio/basic",
  "spc": "application/x-pkcs7-certificates",
  "spl": "application/futuresplash",
  "src": "application/x-wais-source",
  "sst": "application/vnd.ms-pkicertstore",
  "stl": "application/vnd.ms-pkistl",
  "stm": "text/html",
  "svg": "image/svg+xml",
  "sv4cpio": "application/x-sv4cpio",
  "sv4crc": "application/x-sv4crc",
  "t": "application/x-troff",
  "tar": "application/x-tar",
  "tcl": "application/x-tcl",
  "tex": "application/x-tex",
  "texi": "application/x-texinfo",
  "texinfo": "application/x-texinfo",
  "tgz": "application/x-compressed",
  "tif": "image/tiff",
  "tiff": "image/tiff",
  "tr": "application/x-troff",
  "trm": "application/x-msterminal",
  "tsv": "text/tab-separated-values",
  "txt": "text/plain",
  "uls": "text/iuls",
  "ustar": "application/x-ustar",
  "vcf": "text/x-vcard",
  "vrml": "x-world/x-vrml",
  "wav": "audio/x-wav",
  "wcm": "application/vnd.ms-works",
  "wdb": "application/vnd.ms-works",
  "wks": "application/vnd.ms-works",
  "wmf": "application/x-msmetafile",
  "wps": "application/vnd.ms-works",
  "wri": "application/x-mswrite",
  "wrl": "x-world/x-vrml",
  "wrz": "x-world/x-vrml",
  "xaf": "x-world/x-vrml",
  "xbm": "image/x-xbitmap",
  "xla": "application/vnd.ms-excel",
  "xlc": "application/vnd.ms-excel",
  "xlm": "application/vnd.ms-excel",
  "xls": "application/vnd.ms-excel",
  "xlsx": "application/vnd.ms-excel",
  "xlt": "application/vnd.ms-excel",
  "xlw": "application/vnd.ms-excel",
  "xof": "x-world/x-vrml",
  "xpm": "image/x-xpixmap",
  "xwd": "image/x-xwindowdump",
  "z": "application/x-compress",
  "zip": "application/zip"
};
