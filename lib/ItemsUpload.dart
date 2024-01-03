import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furni/Home_screen.dart';
import 'package:furni/api_consumer.dart';
import 'package:image_picker/image_picker.dart';

class ItemsUpload extends StatefulWidget {
  const ItemsUpload({super.key});

  @override
  State<ItemsUpload> createState() => _ItemsUploadState();
}

class _ItemsUploadState extends State<ItemsUpload> {
  Uint8List? imageFileUint8List;
  bool isUploading = false;
  TextEditingController sellername = TextEditingController();
  TextEditingController sellerphone = TextEditingController();
  TextEditingController itemname = TextEditingController();
  TextEditingController itemDesc = TextEditingController();
  TextEditingController itemprice = TextEditingController();

  String downloadUrlofUploadedImage = "";

  Widget uploadFromScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: () {
                //validating upload form
                if (isUploading != true) {
                  validateUploadForm();
                }
              },
              icon: const Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white,
                size: 45,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (isUploading)
            const LinearProgressIndicator(color: Colors.purpleAccent),
          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: imageFileUint8List != null
                ? Image.memory(imageFileUint8List!)
                : const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 45,
                  ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: sellername,
                decoration: const InputDecoration(
                  hintText: 'Seller Name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          const SizedBox(
            height: 30,
          ),
          ListTile(
            leading: const Icon(
              Icons.phone_iphone_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: sellerphone,
                decoration: const InputDecoration(
                  hintText: 'Seller Phone',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          const SizedBox(
            height: 30,
          ),
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemname,
                decoration: const InputDecoration(
                  hintText: 'Item Name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          const SizedBox(
            height: 30,
          ),
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemDesc,
                decoration: const InputDecoration(
                  hintText: 'Item Description',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          const SizedBox(
            height: 30,
          ),
          ListTile(
            leading: const Icon(
              Icons.price_change,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemprice,
                decoration: const InputDecoration(
                  hintText: 'Item Price',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
        ],
      ),
    );
  }

  validateUploadForm() async {
    if (imageFileUint8List != null) {
      if (sellername.text.isNotEmpty &&
          sellerphone.text.isNotEmpty &&
          itemname.text.isNotEmpty &&
          itemDesc.text.isNotEmpty &&
          itemprice.text.isNotEmpty) {
        setState(() {
          isUploading = true;
        });

        //upload image
        String imageUniqueName =
            DateTime.now().millisecondsSinceEpoch.toString();

        fStorage.Reference firebaseStorageRef = fStorage
            .FirebaseStorage.instance
            .ref()
            .child("items images")
            .child(imageUniqueName);

        fStorage.UploadTask uploadTaskImagefile =
            firebaseStorageRef.putData(imageFileUint8List!);

        fStorage.TaskSnapshot taskSnapshot =
            await uploadTaskImagefile.whenComplete(() => {});

        await taskSnapshot.ref.getDownloadURL().then((imagedownurl) {
          downloadUrlofUploadedImage = imagedownurl;
        });

        //2) save item info to firestore
        saveItemInfoToFirestore();
      } else {
        Fluttertoast.showToast(msg: "Every Field is mandatory");
      }
    } else {
      Fluttertoast.showToast(msg: "Please select Image file");
    }
  }



   saveItemInfoToFirestore(){
       String itemUniqueid = DateTime.now().millisecondsSinceEpoch.toString();
        FirebaseFirestore.instance.collection("items").doc(itemUniqueid).set({
          "itemID": itemUniqueid,
          "itemName": itemname.text,
          "itemDescription": itemDesc.text,
          "itemImage": downloadUrlofUploadedImage,
          "sellerName": sellername.text,
          "sellerPhone": sellerphone.text,
          "itemPrice": itemprice.text,
          "publishedDate": DateTime.now(),
          "status": "available",
        });

        Fluttertoast.showToast(msg: "Item uploaded Successfully");

        setState(() {
          isUploading = false;
          imageFileUint8List = null;
        });

        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
   }



  Widget defaultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload new item",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate,
                color: Colors.white, size: 200),
            ElevatedButton(
              onPressed: () {
                showAboutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                "Add New Item",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Item Image",
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                captureimagewithphonecamera();
              },
              child: const Text(
                "Capture Image with camera",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                chooseimagefromgallery();
              },
              child: const Text(
                "Choose Image from Gallery",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  captureimagewithphonecamera() async {
    Navigator.pop(context);
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUint8List = await pickedImage.readAsBytes();

        //remove backgroundfrom image --transparent

        imageFileUint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUint8List;
        });
      }
    } catch (error) {
      print(error.toString());

      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  chooseimagefromgallery() async {
    Navigator.pop(context);
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUint8List = await pickedImage.readAsBytes();

        imageFileUint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUint8List;
        });
      }
    } catch (error) {
      print(error.toString());

      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageFileUint8List == null ? defaultScreen() : uploadFromScreen();
  }
}
