import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'api_service.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
class PostPage extends StatefulWidget {

  final int postId;

  const PostPage({
    super.key,
    required this.postId,
  });

  @override
  State<PostPage> createState() =>
      _PostPageState();
}

class _PostPageState
    extends State<PostPage>{

  Map<String,dynamic> data={};

  List comments=[];

  bool loading=true;

  bool sending=false;

  VideoPlayerController? video;

  final commentController=
  TextEditingController();

  final red=
  const Color(
    0xffe53935,
  );

  int userId=0;
  @override
  void initState(){

    super.initState();

    getUser();

  }
  Future<void>
  getUser()
  async{

    final prefs=

    await SharedPreferences
        .getInstance();

    userId=

        prefs.getInt(
          "user_id",
        )

            ??

            0;

    await load();

  }
  Future load() async {

    loading=true;

    if(mounted){
      setState((){});
    }

    final res=
    await ApiService
        .getPostById(
      widget.postId,
    );

    data=
    Map<String,dynamic>.from(
      res["post"] ?? {},
    );

    comments=
        res["comments"] ?? [];

    video?.dispose();

    if(
    data["type"]=="video"
        &&
        (data["media"]??"")
            .toString()
            .isNotEmpty
    ){

      video=
          VideoPlayerController.networkUrl(

            Uri.parse(

                AppConstants.imageUrl+

                    data["media"]

            ),

          );

      await video!
          .initialize();

    }

    loading=false;

    if(mounted){
      setState((){});
    }

  }

  Future sendComment()
  async{

    if(
    commentController
        .text
        .trim()
        .isEmpty
    ){

      return;

    }

    sending=true;

    setState((){});

    await ApiService
        .addComment(

      userId,

      widget.postId,

      commentController
          .text
          .trim(),

    );

    commentController
        .clear();

    sending=false;

    await load();

  }

  Future toggleLike()
  async{

    final res =

    await ApiService
        .togglePostLike(

      userId,

      widget.postId,

    );

    if(
    res["status"]
        ==
        true
    ){

      setState(() {

        data["likes"] =

            res["likes"]

                ??

                0;

      });

    }

  }
  @override
  void dispose(){

    video?.dispose();

    commentController.dispose();

    super.dispose();

  }

  Widget media(){

    final type=
    (
        data["type"]??
            ""
    )
        .toString();

    final file=
    (
        data["media"]??
            ""
    )
        .toString();

    if(file.isEmpty){

      return const SizedBox();

    }

    if(
    type=="image"
    ){

      return ClipRRect(

        borderRadius:
        BorderRadius.circular(
          24,
        ),

        child:

        Image.network(

          AppConstants.imageUrl+
              file,

          width:
          double.infinity,

          fit:
          BoxFit.cover,

          errorBuilder:
              (
              _,
              __,
              ___,
              )=>

              Container(

                height:260,

                color:
                Colors.grey
                    .shade100,

                child:

                const Icon(
                  Icons.image,
                  size:60,
                ),

              ),

        ),

      );

    }

    if(
    type=="video"
        &&
        video!=null
        &&
        video!
            .value
            .isInitialized
    ){

      return GestureDetector(

        onTap:(){

          if(
          video!
              .value
              .isPlaying
          ){

            video!
                .pause();

          }else{

            video!
                .play();

          }

          setState((){});

        },

        child:

        ClipRRect(

          borderRadius:
          BorderRadius.circular(
            24,
          ),

          child:

          Stack(

            alignment:
            Alignment.center,

            children:[

              AspectRatio(

                aspectRatio:

                video!
                    .value
                    .aspectRatio,

                child:

                VideoPlayer(
                  video!,
                ),

              ),

              AnimatedOpacity(

                duration:
                const Duration(
                  milliseconds:200,
                ),

                opacity:

                video!
                    .value
                    .isPlaying

                    ?

                0.0

                    :

                1.0,

                child:

                Container(

                  height:90,

                  width:90,

                  decoration:

                  BoxDecoration(

                    color:
                    Colors.black
                        .withOpacity(
                      0.45,
                    ),

                    shape:
                    BoxShape.circle,

                  ),

                  child:

                  Icon(

                    video!
                        .value
                        .isPlaying

                        ?

                    Icons.pause

                        :

                    Icons.play_arrow,

                    size:52,

                    color:
                    Colors.white,

                  ),

                ),

              ),

            ],

          ),

        ),

      );

    }
    return const SizedBox();

  }

  @override
  Widget build(
      BuildContext context
      ){

    return Scaffold(

      backgroundColor:
      const Color(
        0xfffafafa,
      ),

      appBar:

      AppBar(

        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        title:
        const Text(
          "Post",
        ),

      ),

      body:

      loading

          ?

      Center(

        child:

        CircularProgressIndicator(
          color:red,
        ),

      )

          :

      Column(

        children:[

          Expanded(

            child:

            SingleChildScrollView(

              padding:
              const EdgeInsets.all(
                16,
              ),

              child:

              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  Container(

                    padding:
                    const EdgeInsets.all(
                      18,
                    ),

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        28,
                      ),

                    ),

                    child:

                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children:[

                        Row(

                          children:[

                            CircleAvatar(

                              radius:26,

                              backgroundColor:
                              red,

                              child:

                              const Icon(

                                Icons.store,

                                color:
                                Colors.white,

                              ),

                            ),

                            const SizedBox(
                              width:14,
                            ),

                            Expanded(

                              child:

                              Text(

                                (
                                    data[
                                    "seller_name"
                                    ]
                                        ??
                                        "Seller"
                                )
                                    .toString(),

                                style:
                                const TextStyle(

                                  fontSize:
                                  18,

                                  fontWeight:
                                  FontWeight.w700,

                                ),

                              ),

                            ),

                          ],

                        ),

                        if(
                        (
                            data[
                            "text_content"
                            ]
                                ??
                                ""
                        )
                            .toString()
                            .isNotEmpty
                        )

                          Padding(

                            padding:
                            const EdgeInsets.only(
                              top:18,
                              bottom:18,
                            ),

                            child:

                            Text(

                              data[
                              "text_content"
                              ],

                              style:
                              const TextStyle(
                                fontSize:16,
                                height:1.6,
                              ),

                            ),

                          ),

                        media(),

                        const SizedBox(
                          height:20,
                        ),

                        Row(

                          children:[

                            InkWell(

                              onTap:
                              toggleLike,

                              child:

                              Container(

                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal:16,
                                  vertical:10,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  red
                                      .withOpacity(
                                    0.08,
                                  ),

                                  borderRadius:
                                  BorderRadius.circular(
                                    100,
                                  ),

                                ),

                                child:

                                Row(

                                  children:[

                                    Icon(

                                      Icons.favorite,

                                      color:
                                      red,

                                    ),

                                    const SizedBox(
                                      width:8,
                                    ),

                                    Text(

                                      "${data["likes"] ?? 0}",

                                    ),

                                  ],

                                ),

                              ),

                            ),

                            const SizedBox(
                              width:12,
                            ),

                            Text(

                              "${comments.length} comments",

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                  const SizedBox(
                    height:20,
                  ),

                  const Text(

                    "Comments",

                    style:
                    TextStyle(

                      fontSize:18,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                  const SizedBox(
                    height:14,
                  ),

                  ...comments.map(

                        (c){

                      return Container(

                        margin:
                        const EdgeInsets.only(
                          bottom:12,
                        ),

                        padding:
                        const EdgeInsets.all(
                          14,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                        ),

                        child:

                        Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children:[

                            Text(

                              (
                                  c["name"]
                                      ??
                                      "User"
                              )
                                  .toString(),

                              style:
                              const TextStyle(

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),

                            const SizedBox(
                              height:8,
                            ),

                            Text(

                              (
                                  c["comment"]
                                      ??
                                      ""
                              )
                                  .toString(),

                            ),

                          ],

                        ),

                      );

                    },

                  ),

                ],

              ),

            ),

          ),

          Container(

            padding:
            const EdgeInsets.all(
              16,
            ),

            color:
            Colors.white,

            child:

            Row(

              children:[

                Expanded(

                  child:

                  TextField(

                    controller:
                    commentController,

                    decoration:

                    InputDecoration(

                      hintText:
                      "Write comment",

                      filled:true,

                      fillColor:
                      Colors.grey
                          .shade100,

                      border:

                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          40,
                        ),

                        borderSide:
                        BorderSide.none,

                      ),

                    ),

                  ),

                ),

                const SizedBox(
                  width:10,
                ),

                InkWell(

                  onTap:
                  sending
                      ?null
                      :sendComment,

                  child:

                  CircleAvatar(

                    radius:26,

                    backgroundColor:
                    red,

                    child:

                    sending

                        ?

                    const SizedBox(

                      height:18,
                      width:18,

                      child:

                      CircularProgressIndicator(
                        color:
                        Colors.white,
                      ),

                    )

                        :

                    const Icon(
                      Icons.send,
                      color:
                      Colors.white,
                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }
}