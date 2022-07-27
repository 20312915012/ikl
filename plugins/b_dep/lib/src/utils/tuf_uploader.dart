import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:b_dep/src/tus_client/tus_client.dart';

class TusFileUploader {
  Function tusOnSuccess; //(String downloadUrl);
  Function tusOnFailure; //(String error)
  Function tusOnUploading; //(double progress, int currentIndex);
  TusClient client;

  Function getSuccess() {
    return tusOnSuccess;
  }

  void uploadFile(String uploadToUrl, List<String> filePathList) async {
    int i = 0;
    for (String filePath in filePathList) {
      //print("tus valls> "+uploadToUrl.toString()+" >> "+filePath.toString());
      client = TusClient(
        Uri.parse(uploadToUrl),
        XFile(filePath),
        store: TusMemoryStore(),
      );

      // Starts the upload
      try {
        await client.upload(
          onComplete: () {
            //print("Complete!");
            // Prints the uploaded file URL
            //print("url> "+client.uploadUrl.toString());
            if (tusOnSuccess != null) {
              tusOnSuccess(client.uploadUrl.toString());
            }
          },
          onProgress: (progress) {
            if (tusOnUploading != null) {
              tusOnUploading(progress, i);
            }
            //print("Progress: $progress");
          },
        );
      } catch (e) {
        tusOnFailure(e.toString());
      }
      i++;
    }
  }
}
