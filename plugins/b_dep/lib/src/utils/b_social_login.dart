import 'package:b_dep/b_dep.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BSocialLogin {
  Function onSuccess, onFailure;
  Function onSuccessSilently, onFailureSilently;

  Future<void> handleSignIn({bool isAutoSaveUser = false}) async {
    try {
      await googleSignIn.signIn().then((GoogleSignInAccount value) async {
        if (onSuccess != null) {
          app ??= await Firebase.initializeApp();
          final GoogleSignInAuthentication googleAuth = await value.authentication;
          final GoogleAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await FirebaseAuth.instance.signInWithCredential(credential).then((fireBValue) {
            //print("token> "+fireBValue.credential.toString());
            fireBValue.user.getIdToken().then((token) {
              //print("JWT_token> "+token.toString());
              if (isAutoSaveUser) {
                runBlupSheetsForUsers(value.email, value.displayName, value.photoUrl);
              }
              onSuccess(token.toString(), value.displayName, value.email, value.photoUrl);
            });
          }).catchError((onError) {
            print("onError> " + onError.toString());
            if (onFailure != null) {
              onFailure(onError);
            }
          });
        }
      }).onError((error, stackTrace) {
        if (onFailure != null) {
          onFailure(error);
        }
      });
    } catch (error) {
      print(error);
      if (onFailure != null) {
        onFailure(error);
      }
    }
  }

  Future<void> handleSignOut() async {
    try {
      await googleSignIn.signOut().then((GoogleSignInAccount value) {
        if (onSuccess != null) {
          onSuccess(null, null, null, null);
        }
      });
    } catch (error) {
      print(error);
      if (onFailure != null) {
        onFailure(error);
      }
    }
  }

  Future<void> handleSignInIfAlreadyHasSignedIn() async {
    //print("handleSignInIfAlreadyHasSignedIn");
    try {
      await googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount value) async {
        //print("onCurrentUserChanged> "+value.toString());
        handleSilentResult(value);
      });
      await googleSignIn.signInSilently().then((value) {
        handleSilentResult(value);
      });
    } catch (error) {
      print(error);
      if (onFailureSilently != null) {
        onFailureSilently(error);
      }
    }
  }

  bool isSuccessCalled = false;
  void handleSilentResult(value) async {
    if (value != null) {
      isSuccessCalled = false;
      //print("onSuccessSilently0");
      if (onSuccessSilently != null) {
        //print("onSuccessSilently");
        if (app == null) {
          app = await Firebase.initializeApp();
        }
        final GoogleSignInAuthentication googleAuth = await value.authentication;
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential).then((fireBaseValue) async {
          //print("token> " + fireBaseValue.credential.toString());
          await fireBaseValue.user.getIdToken().then((token) {
            //print("JWT_token> " + token.toString());
            if (!isSuccessCalled) {
              isSuccessCalled = true;
              onSuccessSilently(token.toString(), value.displayName, value.email, value.photoUrl);
            }
          });
        }).catchError((onError) {
          print("onError> " + onError.toString());
        });
      }
    } else {
      //print("onFailureSilently0");
      if (onFailureSilently != null) {
        //print("onFailureSilently");
        onFailureSilently("Error: User not signed in already.");
      }
    }
  }

  void runBlupSheetsForUsers(String userEmail, String userName, String userPicUrl) async {
    BlupSheetsQueryController blupSheetsQueryController = BlupSheetsQueryController(null, 'sahaj@blup.in');
    blupSheetsQueryController.runQuery(
        false,
        {
          "insert": ["users.Email", "users.Name", "users.PictureUrl|type:I"],
          "from": ["users"]
        },
        {
          "users.Email": userEmail,
          "users.Name": userName,
          "users.PictureUrl|type:I": userPicUrl,
        },
        null,
        null,
        null);
  }
}
