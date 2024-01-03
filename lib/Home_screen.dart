import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furni/ItemsUpload.dart';
import 'package:furni/item_ui_design.dart';
import 'package:furni/items.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 29, 146, 54),
        title: const Text("AR App" , style: TextStyle(color: Colors.white,fontSize:18,letterSpacing: 2,fontWeight: FontWeight.bold ),),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const ItemsUpload()));
          }, icon: const Icon(Icons.add,color: Colors.white70,size: 45,))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("items").orderBy("publishedDate",descending:true).snapshots(),
        builder:(context,AsyncSnapshot dataSnapshot){
          if(dataSnapshot.hasData)
          {
            return ListView.builder(
              itemCount: dataSnapshot.data!.docs.length,
              itemBuilder: (context, index)
              {
                Items eachItemInfo = Items.fromJson(
                  dataSnapshot.data!.docs[index].data() as Map<String, dynamic>
                );

                return ItemDesignWidget(
                  itemsInfo: eachItemInfo,
                  context: context,
                );
              },
            );
          }
          else
          {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Data is not available.",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          }
        } ,
      )
    );
  }
}